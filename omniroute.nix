{
  config,
  pkgs,
  ...
}:
# OmniRoute を systemd (user) + rootless docker compose で常駐させる。
#
# - 上流イメージ: docker.io/diegosouzapw/omniroute (MIT、multi-arch)
# - dashboard + /v1: 127.0.0.1:20128 / server API: 127.0.0.1:20129
# - weave-os とは共有 docker network "omniroute" で接続する
#   (weave-os 側からは http://omniroute:20128/v1 が見える)
# - provider の API キーは OmniRoute の SQLite に AES-256-GCM で保存される
# - 展開する秘密は secrets/omniroute.env (sops)
#
# OpenCode Go は有料プランでも quota が egress IP 単位で扱われる既定になって
# いるため、OMNIROUTE_EGRESS_IP_LOCK_PROVIDERS=none でアカウント単位に戻す。
# これを忘れると 1 アカウントの 429 が同一 IP の全アカウントを冷却する。
let
  homeDirectory = config.home.homeDirectory;
  dataDir = "${homeDirectory}/.local/share/omniroute";
  envFile = "/run/user/1000/omniroute.env";
  docker = "${pkgs.docker}/bin/docker";
  compose = "${pkgs.docker-compose}/bin/docker-compose";

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
      # weave-os と共有する外部ネットワーク。作成は
      # systemd.user.services.omniroute-network が一度だけ行う。
      omniroute:
        external: true
        name: omniroute
  '';
in
{
  systemd.user.startServices = "sd-switch";

  home.file.".local/share/omniroute/docker-compose.yml".source = composeFile;

  # 両 compose が external: true で参照するネットワークを先に作る。
  # 既存なら何もしない (再起動・switch を冪等にする)。
  systemd.user.services.omniroute-network = {
    Unit = {
      Description = "Shared docker network for OmniRoute and weave-os";
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
