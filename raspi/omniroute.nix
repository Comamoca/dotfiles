{
  config,
  pkgs,
  ...
}:
# raspi (aarch64) で OmniRoute を rootless Docker + systemd user service で常駐させる。
#
# comabook 側の omniroute.nix (home-manager) を NixOS モジュールとして移植したもの。
# raspi には home-manager を入れていないので、同じ構成をシステム側で組む。
#
# - 上流イメージ: docker.io/diegosouzapw/omniroute (MIT、linux/arm64 マニフェストあり)
# - dashboard + /v1: 0.0.0.0:20128 (firewall は tailscale0 のみ許可)
# - server API: 127.0.0.1:20129 (ホスト内からのみ)
# - 秘密は secrets/raspi/omniroute.yaml (sops)。sops-nix が dotenv を
#   /run/secrets/rendered/omniroute-env へ描画し、compose の env_file が読む。
# - Pi 3 は RAM 928MiB なので Node のヒープを 384MiB に絞り、zram を足す。
# - raspi には comabook と違い相乗りするコンテナが無いため、共有 docker
#   network (comabook 版の omniroute-network.service) は作らない。compose の
#   既定ネットワークだけで redis ⇄ omniroute は通じる。
#
# OpenCode Go は有料プランでも quota が egress IP 単位で扱われる既定になって
# いるため、OMNIROUTE_EGRESS_IP_LOCK_PROVIDERS=none でアカウント単位に戻す
# (comabook と同じ。忘れると 1 アカウントの 429 が同一 IP の全アカウントを冷却する)。
#
# 料金情報: comabook と同じく omniroute-pricing.service が LiteLLM 同期と
# config/omniroute/pricing-backfill.json の推定料金の冪等な再適用を行う。
# 適用後は読み取りキャッシュ (DB の変化を追従しない) を捨てるため容器を再起動する。
let
  user = "coma";
  homeDirectory = config.users.users.${user}.home;
  dataDir = "${homeDirectory}/.local/share/omniroute";

  omniroutePort = 20128;
  serverPort = 20129;

  # sops-nix が描画する dotenv。compose の env_file にそのまま渡す。
  envFile = config.sops.templates."omniroute-env".path;
  composeFile = "/etc/omniroute/docker-compose.yml";

  docker = "${pkgs.docker}/bin/docker";
  compose = "${pkgs.docker-compose}/bin/docker-compose";

  # ホストから docker cp する料金補完ファイル (comabook と同じ実体を使う)。
  pricingBackfill = ../config/omniroute/pricing-backfill.json;
  pricingApplyScript = ../config/omniroute/apply-pricing-backfill.mjs;
in
{
  # ---------------------------------------------------------------- 秘密情報
  sops.secrets = {
    "OMNIROUTE_API_KEY" = {
      sopsFile = ../secrets/raspi/omniroute.yaml;
      owner = user;
    };
    "INITIAL_PASSWORD" = {
      sopsFile = ../secrets/raspi/omniroute.yaml;
      owner = user;
    };
    "REQUIRE_API_KEY" = {
      sopsFile = ../secrets/raspi/omniroute.yaml;
      owner = user;
    };
  };

  # sops-nix はテンプレートを描画するとき、参照した秘密だけを復号して
  # プレースホルダを置換する。実体は /run/secrets/rendered/omniroute-env。
  sops.templates."omniroute-env" = {
    owner = user;
    content = ''
      OMNIROUTE_API_KEY=${config.sops.placeholder."OMNIROUTE_API_KEY"}
      INITIAL_PASSWORD=${config.sops.placeholder."INITIAL_PASSWORD"}
      REQUIRE_API_KEY=${config.sops.placeholder."REQUIRE_API_KEY"}
    '';
  };

  # ------------------------------------------------------------ rootless docker
  # raspi の docker は rootless で動かす (root デーモンを常駐させない)。
  # newuidmap/newgidmap と subuid 範囲は NixOS 既定で用意される。
  virtualisation.docker.rootless = {
    enable = true;
    # docker CLI が socket を見つけられるよう DOCKER_HOST を既定で入れる。
    setSocketVariable = true;
  };

  # rootlesskit の --copy-up=/etc は namespace 内の /etc/ssl のシンボリック
  # リンクを壊し、レジストリへの TLS 検証が失敗する (docker pull が
  # "certificate signed by unknown authority" で落ちる)。CA をストアから
  # 直接指定して回避する。comabook の docker.service.d/ca.conf と同じ内容。
  systemd.user.services.docker.serviceConfig.Environment = [
    "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    "SSL_CERT_DIR=${pkgs.cacert}/etc/ssl/certs"
  ];

  # ログインしていなくても user service を起動する。
  users.users.${user}.linger = true;

  # ------------------------------------------------------------------ compose
  environment.etc."omniroute/docker-compose.yml".text = ''
    # OmniRoute raspi スタック (raspi/omniroute.nix が生成)。
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
        mem_limit: 128m
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
          # Pi 3 (928MiB) 向けのヒープ上限。イメージ既定は 1024MiB。
          OMNIROUTE_MEMORY_MB: "384"
          NODE_OPTIONS: "--max-old-space-size=384"
        ports:
          # tailnet へ公開するのは dashboard + /v1 のみ。
          - "${toString omniroutePort}:${toString omniroutePort}"
          # server API はホスト内専用。
          - "127.0.0.1:${toString serverPort}:${toString serverPort}"
        volumes:
          # rootless docker では bind mount の UID 変換が壊れやすいので
          # named volume を使う (comabook と同じ理由)。
          - omniroute-data:/app/data
        depends_on:
          redis:
            condition: service_healthy
        healthcheck:
          test: ["CMD", "node", "healthcheck.mjs"]
          interval: 30s
          timeout: 5s
          retries: 3
          # Pi 3 は Node の起動に時間がかかる。15s (イメージ既定) では足りない。
          start_period: 180s
        # ホスト全体の OOM を避けるため、コンテナ側で先に落とす。
        mem_limit: 768m
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
  '';

  # ------------------------------------------------------------ systemd (user)
  systemd.user.services.omniroute = {
    description = "OmniRoute AI gateway (rootless docker compose)";
    after = [
      "network-online.target"
      "docker.service"
    ];
    wants = [ "network-online.target" ];
    requires = [ "docker.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      # 初回起動時は dataDir がまだ無い。先頭の `-` で「無ければ無視」に
      # しないと systemd が ExecStartPre の前に CHDIR で失敗する。
      WorkingDirectory = "-${dataDir}";
      # user systemd は rootless docker の socket を継承しないため明示する
      # (%t = /run/user/<uid>)。
      Environment = [ "DOCKER_HOST=unix://%t/docker.sock" ];
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${dataDir}"
        # sops-nix の描画待ち。user unit は system unit (sops-install-secrets)
        # と manager が別なので after で順序を保証できず、ブート直後はまだ
        # 描画されていないことがある。2s × 90 回 (=3 分) 待ってから諦める。
        "${pkgs.bash}/bin/bash -c 'for _ in $(seq 1 90); do test -r ${envFile} && exit 0; sleep 2; done; echo sops-nix template not rendered: ${envFile} >&2; exit 1'"
      ];
      ExecStart = "${compose} -f ${composeFile} up";
      # 起動完了 (healthcheck が通るまで) は別 unit が待たない。状態は
      # journal と `docker compose ps`、ready 待ちする側は HTTP ポーリングで確認する。
      ExecStop = "${compose} -f ${composeFile} down";
      Restart = "on-failure";
      RestartSec = 30;
      # 初回は arm64 イメージ (~1.9GB) の pull と DB migration が走る。
      TimeoutStartSec = "infinity";
    };
  };

  # 料金の同期 + 補完。comabook と同じく日次で走らせる。
  systemd.user.services.omniroute-pricing = {
    description = "Sync OmniRoute pricing (LiteLLM) and apply local backfill";
    after = [
      "docker.service"
      "omniroute.service"
    ];
    requires = [
      "docker.service"
      "omniroute.service"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      Environment = [ "DOCKER_HOST=unix://%t/docker.sock" ];
      # DB とコンテナ (=better-sqlite3) を使うので、補完スクリプトは
      # コンテナ内で実行する。同期は OmniRoute の API を叩く。
      ExecStart = pkgs.writeShellScript "omniroute-pricing-sync" ''
        set -euo pipefail
        docker=${docker}
        # user systemd は rootless docker の socket を継承しない。Environment の
        # %t 展開に頼らず、ここでも明示しておく。
        export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
        base=http://127.0.0.1:${toString omniroutePort}
        key=$(sed -n 's/^OMNIROUTE_API_KEY=//p' ${envFile})

        # 起動待ち。REQUIRE_API_KEY=true なので認証なしの /v1/models は
        # 常に 401 を返し「起動済み」と区別できない。-o /dev/null で
        # HTTP コードだけ見て、応答が返れば起動済みとみなす。
        for _ in $(seq 1 120); do
          code=$(${pkgs.curl}/bin/curl -sS -m 2 -o /dev/null -w '%{http_code}' \
            "$base/v1/models" || true)
          if [ "$code" != "000" ]; then
            break
          fi
          sleep 5
        done

        ${pkgs.curl}/bin/curl -fsS -m 300 -X POST \
          -H "Authorization: Bearer $key" \
          -H 'content-type: application/json' \
          -d '{"sources":["litellm"]}' \
          "$base/api/pricing/sync" > /dev/null

        # store path をそのまま cp すると、コンテナ内に /nix/store への
        # symlink が残り Node が MODULE_NOT_FOUND で落ちる。解決済みの実体を
        # コンテナの同じディレクトリ内の一時名へコピーしてから mv する
        # (/tmp 経由の mv は overlay を跨いで EXDEV になるため不可)。
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
      # Pi 3 は LiteLLM の取得と再起動待ちに時間がかかる。
      TimeoutStartSec = "30min";
    };
  };

  systemd.user.timers.omniroute-pricing = {
    description = "Daily OmniRoute pricing sync";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  # ------------------------------------------------------------------ network
  # 公開するのは tailnet のみ。rootless docker は rootlesskit がホスト側
  # netns でポートを待ち受けるため、NixOS firewall (INPUT) が効く。rootful
  # docker と違い nat PREROUTING をバイパスしないので、tailscale0 のみ許可
  # すれば LAN からは届かない。LAN からも使いたい場合は
  # networking.firewall.allowedTCPPorts = [ 20128 ]; に変える。
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ omniroutePort ];

  # Pi 3 は 928MiB しかない。Node のヒープを絞ったうえで、なお足りない分を
  # 圧縮スワップで受ける (SD カードへの書き込みを避けるため zram を使う)。
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
}
