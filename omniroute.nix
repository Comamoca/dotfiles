{
  config,
  pkgs,
  ...
}:
# OmniRoute を systemd (user) + rootless docker compose で常駐させる。
#
# - 上流イメージ: docker.io/diegosouzapw/omniroute (MIT、multi-arch)
# - dashboard + /v1: 127.0.0.1:20128 / server API: 127.0.0.1:20129
# - 他のコンテナから接続する場合は共有 docker network "omniroute" を使う
#   (http://omniroute:20128/v1 で見える)
# - provider の API キーは OmniRoute の SQLite に AES-256-GCM で保存される
# - 展開する秘密は secrets/omniroute.env (sops)
#
# OpenCode Go は有料プランでも quota が egress IP 単位で扱われる既定になって
# いるため、OMNIROUTE_EGRESS_IP_LOCK_PROVIDERS=none でアカウント単位に戻す。
# これを忘れると 1 アカウントの 429 が同一 IP の全アカウントを冷却する。
#
# 料金情報:
#   OmniRoute の既定料金は LiteLLM の model_prices_and_context_window.json 由来で、
#   dashboard に「料金なし」と出るモデル (opencode-go などセルフホスト側の
#   プロバイダ名) はここに載っていない。omniroute-pricing.service が
#   1) LiteLLM 同期を実行し、2) config/omniroute/pricing-backfill.json の
#   推定料金を冪等に再適用する。実行後は容器を再起動し、読み取りキャッシュ
#   (KeyValue 変化を監視しない) を捨てて即時反映させる。
let
  homeDirectory = config.home.homeDirectory;
  dataDir = "${homeDirectory}/.local/share/omniroute";
  envFile = "/run/user/1000/omniroute.env";
  docker = "${pkgs.docker}/bin/docker";
  compose = "${pkgs.docker-compose}/bin/docker-compose";

  # ホスト → コンテナへ docker cp するファイル (下の omniroute-pricing を参照)。
  pricingBackfill = ./config/omniroute/pricing-backfill.json;
  pricingApplyScript = ./config/omniroute/apply-pricing-backfill.mjs;

  # OpenCode Go のキーは dashboard の Providers で管理する。
  # sops から同期せず、既存の omniroute-data volume を正本として保持する。

  composeFile = pkgs.writeText "omniroute-docker-compose.yml" ''
    # OmniRoute ローカルスタック (home-manager / omniroute.nix が生成)。
    name: omniroute

    services:
      redis:
        image: docker.io/library/redis:8.6.5-alpine
        container_name: omniroute-redis
        command: ["redis-server", "--save", "60", "1", "--loglevel", "warning"]
        healthcheck:
          test: ["CMD", "redis-cli", "ping"]
          interval: 10s
          timeout: 5s
          retries: 3
        volumes:
          - redis-data:/data
        restart: unless-stopped
        logging:
          driver: json-file
          options:
            max-size: "10m"
            max-file: "3"

      omniroute:
        image: docker.io/diegosouzapw/omniroute:3.8.52
        container_name: omniroute
        env_file: ${envFile}
        environment:
          DATA_DIR: /app/data
          REDIS_URL: redis://redis:6379
          OMNIROUTE_EGRESS_IP_LOCK_PROVIDERS: none
        ports:
          - "127.0.0.1:20128:20128"
          - "127.0.0.1:20129:20129"
        volumes:
          # rootless docker では bind mount の UID 変換が壊れやすいので
          # named volume を使う (コンテナ内の node:1000 がそのまま書ける)。
          - omniroute-data:/app/data
        depends_on:
          redis:
            condition: service_healthy
        networks:
          - default
          - omniroute
        healthcheck:
          test: ["CMD", "node", "healthcheck.mjs"]
          interval: 30s
          timeout: 5s
          retries: 3
          start_period: 20s
        stop_grace_period: 40s
        restart: unless-stopped
        logging:
          driver: json-file
          options:
            max-size: "10m"
            max-file: "3"

    volumes:
      redis-data:
      omniroute-data:

    networks:
      # 他コンテナと共有する外部ネットワーク。作成は
      # systemd.user.services.omniroute-network が一度だけ行う。
      omniroute:
        external: true
        name: omniroute
  '';
in
{
  systemd.user.startServices = "sd-switch";

  home.file.".local/share/omniroute/docker-compose.yml".source = composeFile;

  # コンテナ内 (/app) から見える形でホストのファイルを渡すためのコピー
  # (詳細な手順と理由は下の omniroute-pricing の ExecStart を参照)。
  #
  # LiteLLM 同期で埋まらないモデルの推定料金と、それを DB へ冪等に適用する
  # スクリプト。docker cp でなく bind mount 相当 (docker exec 経由の読み取り)
  # にするため、ホスト側のファイルをそのまま渡す。
  home.file.".local/share/omniroute/pricing-backfill.json".source = pricingBackfill;
  home.file.".local/share/omniroute/apply-pricing-backfill.mjs".source =
    pricingApplyScript;

  # OmniRoute で追加した combo を各エージェントのモデル一覧へ配る。
  #
  # OmniRoute は combo を /v1/models に `owned_by: "combo"` として出すが、
  # クライアント側 (opencode / dsh) のモデル一覧は静的なので、dashboard で
  # 追加しただけでは選べない。omniroute-combos が一覧を生成し、各クライアントが
  # それを読むことで、patch / opencode.json を手で書き換えずに追随させる:
  #
  #   opencode : config/opencode/plugins/omniroute-combos.ts が config 読込時に
  #              ~/.config/opencode/omniroute-combos.json を読んで models へ足す
  #   dsh      : ~/.dsh/profiles/*/cordis.patch.yml の `models: !!js ...` が
  #              起動時に ~/.dsh/omniroute-combos.json を読む
  #
  # 再起動なしで反映されるのは opencode のみ (dsh は再起動が必要)。
  home.file.".bin/scripts/omniroute-combos/omniroute-combos".source =
    config.lib.file.mkOutOfStoreSymlink "/${homeDirectory}/.ghq/github.com/Comamoca/dotfiles/bin/scripts/omniroute-combos/omniroute-combos";

  systemd.user.services.omniroute-combos = {
    Unit = {
      Description = "Sync OmniRoute combo list into client model lists";
      # OmniRoute の起動に失敗しても、ここを巻き添えで失敗させない
      # (生成物は前回のまま残る)。順序の保証だけ行う。
      After = [ "omniroute.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${homeDirectory}/.bin/scripts/omniroute-combos/omniroute-combos";
      # 失敗しても次周期で再試行するので、タイマー側は止めない。
      SuccessExitStatus = [ "0" ];
    };
  };

  systemd.user.timers.omniroute-combos = {
    Unit.Description = "Timer for OmniRoute combo list sync";
    Timer = {
      # OmniRoute の初回起動 (image pull / DB migration) を待ってから動かす。
      OnBootSec = "5min";
      OnUnitActiveSec = "30min";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # 料金の同期 + 補完。switch 時と日次で走らせる。
  # omniroute 本体の起動直後は dashboard が未準備なので、health を待ってから実行する。
  systemd.user.services.omniroute-pricing = {
    Unit = {
      Description = "Sync OmniRoute pricing (LiteLLM) and apply local backfill";
      After = [ "omniroute.service" ];
      Requires = [ "omniroute.service" ];
    };
    Service = {
      Type = "oneshot";
      Environment = [ "DOCKER_HOST=unix://%t/docker.sock" ];
      # DB とコンテナ (=better-sqlite3) を使うので、補完スクリプトは
      # コンテナ内で実行する。同期は OmniRoute の API を叩く。
      ExecStart = pkgs.writeShellScript "omniroute-pricing-sync" ''
        set -euo pipefail
        docker=${docker}
        base=http://127.0.0.1:20128
        key=$(sed -n 's/^OMNIROUTE_API_KEY=//p' ${envFile})

        # 起動待ち。REQUIRE_API_KEY=true なので認証なしの /v1/models は
        # 常に 401 を返し「起動済み」と区別できない。-o /dev/null で
        # HTTP コードだけ見て、応答が返れば起動済みとみなす。
        for _ in $(seq 1 60); do
          code=$(${pkgs.curl}/bin/curl -sS -m 2 -o /dev/null -w '%{http_code}' \
            "$base/v1/models" || true)
          if [ "$code" != "000" ]; then
            break
          fi
          sleep 5
        done

        ${pkgs.curl}/bin/curl -fsS -m 120 -X POST \
          -H "Authorization: Bearer $key" \
          -H 'content-type: application/json' \
          -d '{"sources":["litellm"]}' \
          "$base/api/pricing/sync" > /dev/null

        # home.file の実体は /nix/store への symlink なので、解決済みのパスを
        # コンテナの「同じディレクトリ内の一時名」へコピーしてから mv する:
        #   - symlink をそのまま cp すると、コンテナ内に /nix/store への
        #     symlink が残り、そのパスはコンテナから見えないため Node が
        #     MODULE_NOT_FOUND で落ちる (switch ごとに再発する)。
        #   - docker cp は既存の symlink を置き換えられず --force も無い。
        #   - /tmp 経由の mv は overlay を跨いで EXDEV になるため不可。
        $docker cp -L ${pricingBackfill} omniroute:/app/data/pricing-backfill.json.new
        $docker cp -L ${pricingApplyScript} omniroute:/app/apply-pricing-backfill.mjs.new
        $docker exec omniroute sh -c '
          mv -f /app/data/pricing-backfill.json.new /app/data/pricing-backfill.json
          mv -f /app/apply-pricing-backfill.mjs.new /app/apply-pricing-backfill.mjs
        '
        $docker exec -w /app omniroute node apply-pricing-backfill.mjs

        # 料金の読み取りキャッシュは DB の変更を追従しないので再起動する。
        $docker restart omniroute > /dev/null
      '';
      # 初回は LiteLLM の取得と再起動待ちで数十秒かかる。
      TimeoutStartSec = "10min";
      # ネットワーク失敗などで失敗しても、次回の日次実行で回収できるようにする。
      SuccessExitStatus = [ "0" ];
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.timers.omniroute-pricing = {
    Unit.Description = "Daily OmniRoute pricing sync";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # compose が external: true で参照するネットワークを先に作る。
  # 既存なら何もしない (再起動・switch を冪等にする)。
  systemd.user.services.omniroute-network = {
    Unit = {
      Description = "Shared docker network for OmniRoute";
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = [ "DOCKER_HOST=unix://%t/docker.sock" ];
      ExecStart = "${pkgs.bash}/bin/bash -c '${docker} network inspect omniroute >/dev/null 2>&1 || ${docker} network create omniroute'";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.omniroute = {
    Unit = {
      Description = "OmniRoute AI gateway (rootless docker compose)";
      After = [
        "network-online.target"
        "sops-nix.service"
        "omniroute-network.service"
      ];
      Wants = [ "network-online.target" ];
      Requires = [ "omniroute-network.service" ];
    };
    Service = {
      WorkingDirectory = dataDir;
      # user systemd は rootless docker の socket を継承しないため明示する
      # (%t = /run/user/<uid>)。
      Environment = [ "DOCKER_HOST=unix://%t/docker.sock" ];
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${dataDir}";
      ExecStart = "${compose} -f ${dataDir}/docker-compose.yml up";
      ExecStop = "${compose} -f ${dataDir}/docker-compose.yml down";
      Restart = "on-failure";
      RestartSec = 15;
      # 初回はイメージ (~250MB) の pull と DB migration が走る。
      TimeoutStartSec = "infinity";
    };
    Install.WantedBy = [ "default.target" ];
  };

}
