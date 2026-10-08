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
  # ルーターのソース。上流 (flake 入力 weave-router) にローカルパッチを当てた
  # ものを compose のビルドコンテキストにする。
  #
  # なぜパッチが必要か:
  #   secrets/weave-os.env の OPENROUTER_BASE_URL は OpenCode Go
  #   (https://opencode.ai/zen/go/v1) を指すが、このエンドポイントは
  #   x-opencode-session の無いリクエストを MissingSessionID (HTTP 400) で
  #   全部拒否する。ルーターは受信ヘッダを上流へ転送しない (forwarded_client_
  #   headers はプロバイダ設定が無いと効かない) ので、パッチ無しでは1件も
  #   通らない。internal/providers/openaicompat/client.go の上流リクエスト
  #   構築直後に、元リクエストから会話セッション ID を取り直して注入している。
  #
  # 4つの置換はすべて --replace-fail なので、タグを上げて置換対象が変わると
  # ビルドが落ちる (= パッチの再確認を促す)。タグ更新時は必ず全置換を見直す。
  routerSrc = pkgs.runCommand "weave-router-src" { } ''
    cp -r ${inputs.weave-router} $out
    chmod -R u+w $out
    f=$out/internal/providers/openaicompat/client.go

    # 上流リクエスト構築直後の呼び出し。proxyTo / Passthrough の両経路に入る。
    substituteInPlace "$f" --replace-fail \
      $'c.applyDefaultHeaders(upstream)' \
      $'c.applyDefaultHeaders(upstream)\n\tinjectOpenCodeSessionHeader(upstream, r)'

    # ヘルパー本体を applyProtectedHeaders の直後に追加。
    substituteInPlace "$f" --replace-fail \
      $'func (c *Client) applyProtectedHeaders(req *http.Request) {\n\tfor k, vs := range c.protectedHeaders {\n\t\treq.Header[http.CanonicalHeaderKey(k)] = append([]string(nil), vs...)\n\t}\n}' \
      $'func (c *Client) applyProtectedHeaders(req *http.Request) {\n\tfor k, vs := range c.protectedHeaders {\n\t\treq.Header[http.CanonicalHeaderKey(k)] = append([]string(nil), vs...)\n\t}\n}\n\n// injectOpenCodeSessionHeader は OpenCode Go が必須とする x-opencode-session を\n// 上流リクエストへ注入する (無いと MissingSessionID で 400)。ルーターは受信ヘッダを\n// 上流へ転送しないため、元リクエストのセッションヘッダから取り直し、無ければ\n// 定数で存在だけ保証する。opencode.ai 以外の上流には付けない。\nfunc injectOpenCodeSessionHeader(upstream, inbound *http.Request) {\n\tif !strings.HasSuffix(upstream.URL.Host, "opencode.ai") {\n\t\treturn\n\t}\n\tif upstream.Header.Get("X-Opencode-Session") != "" {\n\t\treturn\n\t}\n\tsid := requestcontext.OpenCodeSessionIDFromHeaders(inbound.Header)\n\tif sid == "" {\n\t\tsid = requestcontext.SessionIDFromHeaders(inbound.Header)\n\t}\n\tif sid == "" {\n\t\tsid = "weave-router"\n\t}\n\tupstream.Header.Set("X-Opencode-Session", sid)\n}'

    # --- パッチ2: Anthropic ベースラインフェイルオフは認証情報があるときだけ ---
    # リクエスト元 (pi / jcode 等) に Anthropic の資格情報が無いのにフェイルオフが
    # 走ると、ルーターキーが x-api-key として api.anthropic.com へ渡り 401 が
    # そのままクライアントに返る (本来のエラーも隠れる)。ベースライン再試行の
    # 前提条件に「Anthropic へ出せる資格情報が在る」ことを足す。Claude Code は
    # OAuth 資格を持つので従来どおりフォールバックできる。
    sv=$out/internal/proxy/service.go
    substituteInPlace "$sv" --replace-fail \
      $'\t\tsiblingFitsContext(baselineModel, providers.ProviderAnthropic, overflowEstimate, env.SignatureTokenSavings(), outputReserve)\n\tbaselineEligible := !routeRes.AuthoritativePerTurn && baselineViable' \
      $'\t\tsiblingFitsContext(baselineModel, providers.ProviderAnthropic, overflowEstimate, env.SignatureTokenSavings(), outputReserve) &&\n\t\ts.anthropicBaselineHasCredentials(ctx, r.Header)\n\tbaselineEligible := !routeRes.AuthoritativePerTurn && baselineViable'

    substituteInPlace "$sv" --replace-fail \
      $'// resolveAndInjectCredentials resolves credentials for the selected provider' \
      $'// anthropicBaselineHasCredentials はベースライン再試行先の Anthropic が実際に\n// 認証できる資格情報 (デプロイキー / BYOK / クライアント資格 / サブスクトークン) を\n// 持つかを返す。無ければ再試行せず、元のルーティング失敗をそのまま返す。\nfunc (s *Service) anthropicBaselineHasCredentials(ctx context.Context, header http.Header) bool {\n\tif s.deploymentKeyedProviders != nil {\n\t\tif _, ok := s.deploymentKeyedProviders[providers.ProviderAnthropic]; ok {\n\t\t\treturn true\n\t\t}\n\t}\n\tif byok := BuildCredentialsMap(externalKeysFromContext(ctx)); byok != nil {\n\t\tif _, ok := byok[providers.ProviderAnthropic]; ok {\n\t\t\treturn true\n\t\t}\n\t}\n\tif ExtractClientCredentials(providers.ProviderAnthropic, header) != nil {\n\t\treturn true\n\t}\n\treturn subscriptionCredsFromToken(anthropicSubscriptionFromContext(ctx)) != nil\n}\n\n// resolveAndInjectCredentials resolves credentials for the selected provider'
  '';
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
          # OpenCode Go はカタログ ID (vendor/name) を解釈しないので、OpenRouter
          # カタログ ID → OpenCode Go のモデル ID へ書き換える (catalog=upstream)。
          # 対象は OpenRouter 紐付けのうち OpenCode Go が chat/completions で
          # 呼べる10モデル (疎通済み)。
          ROUTER_MODEL_ID_MAP: "deepseek/deepseek-v4-flash=deepseek-v4-flash,deepseek/deepseek-v4.1-flash=deepseek-v4.1-flash,deepseek/deepseek-v4-pro=deepseek-v4-pro,xiaomi/mimo-v2.6-flash=mimo-v2.6-flash,xiaomi/mimo-v2.6-pro=mimo-v2.6-pro,xiaomi/mimo-v2.5-pro=mimo-v2.5-pro,moonshotai/kimi-k2.6=kimi-k2.6,moonshotai/kimi-k3=kimi-k3,minimax/minimax-m3=minimax-m3,z-ai/glm-5.1=glm-5.1"
          # OpenRouter 紐付けのうち OpenCode Go が持たないモデル、および
          # minimax-m2.7 (chat/completions 非対応、/messages 専用) を除外。
          # 除外しないとスコアラーがこれらを選び400で落ちる。
          ROUTER_EXCLUDED_MODELS: "qwen/qwen3-235b-a22b-2507,qwen/qwen3-coder-next,qwen/qwen3-next-80b-a3b-instruct,inclusionai/ling-3.0-flash,deepseek/deepseek-v4-pro-0813,moonshotai/kimi-k2.5,qwen/qwen3.6-35b-a3b,minimax/minimax-m2.7,z-ai/glm-5,mistralai/mistral-small-2603,qwen/qwen3-30b-a3b-instruct-2507,qwen/qwen3-coder,qwen/qwen3.5-flash-02-23"
        volumes:
          - ${captureDir}:/router-captures
        ports:
          # host 側は 18080 (web 開発で 8080 が衝突しやすいため)。コンテナ内 PORT=8080 のまま。
          - "127.0.0.1:18080:8080"
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
