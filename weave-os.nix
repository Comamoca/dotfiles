{
  config,
  pkgs,
  inputs,
  ...
}:
# weave-os router を systemd (user) + docker compose で常駐させる。
#
# 上流: https://github.com/weave-os/router (flake.nix の weave-router 入力で
# リリースタグ router-v0.2.28 にピン留め)。
#
# 公開コンテナイメージが無いため、同梱 Dockerfile からソースビルドする。
# 初回起動時にイメージビルド (Go + ONNX、Jina 埋め込みモデル約 162MB を
# HuggingFace から取得) が走るため数分かかる。
#
# 上流の docker-compose.yml は DEV 専用のため、パスだけを Nix ストア
# (読み取り専用) と書き込み可能な capture ディレクトリへ差し替えたものを
# ここで生成する。上流プロバイダは opencode-go (OpenAI 互換) を使う。
#
# 必要な秘密情報は secrets/weave-os.env (sops) にあり、
# /run/user/1000/weave-os.env として compose の env_file から読まれる。
#   OPENROUTER_API_KEY  = opencode-go の API キー
#   OPENROUTER_BASE_URL = https://opencode.ai/zen/go/v1
let
  homeDirectory = config.home.homeDirectory;
  # ルーターのソース (Nix ストア、読み取り専用)。
  routerSrc = inputs.weave-router;
  # compose の作業ディレクトリ (書き込み可能)。
  dataDir = "${homeDirectory}/.local/share/weave-os";
  captureDir = "${dataDir}/router-captures";
  # sops が展開する env ファイル (home.nix の sops.secrets."weave-os")。
  envFile = "/run/user/1000/weave-os.env";

  composeFile = pkgs.writeText "weave-os-docker-compose.yml" ''
    # weave-os router ローカルスタック (home-manager / weave-os.nix が生成)。
    # 上流 compose をベースに、パスのみ Nix ストアと書き込み可能領域へ変更。
    name: weave-os

    services:
      postgres:
        image: postgres:15-alpine
        environment:
          POSTGRES_USER: router
          POSTGRES_PASSWORD: router
          POSTGRES_DB: router
        healthcheck:
          test: ["CMD-SHELL", "pg_isready -U router -d router"]
          interval: 1s
          timeout: 3s
          retries: 30
        volumes:
          - router_postgres_data:/var/lib/postgresql/data
          - ${routerSrc}/db/init:/docker-entrypoint-initdb.d:ro

      pubsub-emulator:
        image: gcr.io/google.com/cloudsdktool/google-cloud-cli:emulators
        entrypoint: ["/entrypoint.sh"]
        environment:
          PUBSUB_PROJECT_ID: router-local
          PUBSUB_TOPIC_ROUTER_INVALIDATION: router-installation-invalidate
        volumes:
          - ${routerSrc}/db/pubsub/entrypoint.sh:/entrypoint.sh:ro
        healthcheck:
          test: ["CMD-SHELL", "curl -sf http://localhost:8085 >/dev/null || exit 1"]
          interval: 2s
          timeout: 3s
          retries: 30

      migrate:
        image: migrate/migrate:v4.17.1
        depends_on:
          postgres:
            condition: service_healthy
        volumes:
          - ${routerSrc}/db/migrations:/migrations
        command:
          - "-path=/migrations"
          - "-database=postgres://router:router@postgres:5432/router?sslmode=disable&search_path=router"
          - "up"
        restart: "no"

      server:
        image: router-server
        build:
          context: ${routerSrc}
        depends_on:
          postgres:
            condition: service_healthy
          migrate:
            condition: service_completed_successfully
          pubsub-emulator:
            condition: service_healthy
        env_file:
          - path: ${envFile}
            required: false
        environment:
          DATABASE_URL: postgres://router:router@postgres:5432/router?sslmode=disable
          PORT: "8080"
          ROUTER_ONNX_ASSETS_DIR: /opt/router/assets
          ROUTER_ONNX_LIBRARY_DIR: /usr/lib
          PUBSUB_EMULATOR_HOST: pubsub-emulator:8085
          PUBSUB_PROJECT_ID: router-local
          PUBSUB_TOPIC_ROUTER_INVALIDATION: router-installation-invalidate
          PUBSUB_SUBSCRIPTION_ROUTER_INVALIDATION: router-installation-invalidate
          ROUTER_HTTP_CAPTURE_LISTEN_HOST: "0.0.0.0"
        volumes:
          - ${captureDir}:/router-captures
        ports:
          - "127.0.0.1:8080:8080"
        restart: unless-stopped

      seed:
        image: router-seed
        build:
          context: ${routerSrc}
          target: seed-runtime
        depends_on:
          postgres:
            condition: service_healthy
          migrate:
            condition: service_completed_successfully
        environment:
          DATABASE_URL: postgres://router:router@postgres:5432/router?sslmode=disable
        profiles:
          - tools
        restart: "no"

    volumes:
      router_postgres_data:
  '';

  # 初回セットアップ用: インストール + rk_ キーを発行して表示する。
  #   ~/.local/share/weave-os/seed.sh
  seedScript = pkgs.writeShellScript "weave-os-seed.sh" ''
    set -euo pipefail
    export DOCKER_HOST="unix://''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/docker.sock"
    exec ${pkgs.docker-compose}/bin/docker-compose \
      -f ${dataDir}/docker-compose.yml run --rm seed
  '';

  compose = "${pkgs.docker-compose}/bin/docker-compose";
in
{
  # systemd の switch 時に新規/更新ユニットを起動する。
  systemd.user.startServices = "sd-switch";

  # compose 定義と seed スクリプトを書き込み可能領域へ配置する。
  home.file.".local/share/weave-os/docker-compose.yml".source = composeFile;
  home.file.".local/share/weave-os/seed.sh".source = seedScript;

  systemd.user.services.weave-os = {
    Unit = {
      Description = "weave-os router (docker compose: postgres + pubsub + server)";
      After = ["network-online.target" "sops-nix.service"];
      Wants = ["network-online.target"];
    };
    Service = {
      WorkingDirectory = dataDir;
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${dataDir} ${captureDir}"
      ];
      ExecStart = "${compose} -f ${dataDir}/docker-compose.yml up";
      ExecStop = "${compose} -f ${dataDir}/docker-compose.yml down";
      # rootless docker のソケットは systemd ユーザーサービスへ環境変数として
      # 継承されないため明示する (%t = /run/user/<uid>)。
      Environment = [
        "DOCKER_HOST=unix://%t/docker.sock"
      ];
      Restart = "on-failure";
      RestartSec = 30;
      # 初回のイメージビルド中にタイムアウトしないようにする。
      TimeoutStartSec = "infinity";
    };
    Install.WantedBy = ["default.target"];
  };
}
