# ローカル Forgejo を home-manager 管理の systemd user service として起動する。
# 管理者登録は初回に CLI で作成する:
#   forgejo admin user create --config ~/.local/state/forgejo/custom/conf/app.ini \
#     --admin --username coma --email coma@localhost --password <pass>
# API トークンも CLI で発行できる:
#   forgejo admin user generate-token --config ~/.local/state/forgejo/custom/conf/app.ini \
#     --username coma --token-name maestro
{
  config,
  pkgs,
  ...
}: let
  stateDir = "${config.home.homeDirectory}/.local/state/forgejo";
  # forgejo は起動時に internal token を app.ini へ追記するため、
  # nix store から state 配下にコピーして書き込み可能にしておく。
  appIni = pkgs.writeText "forgejo-app.ini" ''
    APP_NAME = forgejo (local)
    RUN_MODE = prod
    RUN_USER = coma

    [server]
    PROTOCOL = http
    HTTP_ADDR = 127.0.0.1
    HTTP_PORT = 3300
    ROOT_URL = http://localhost:3300/
    DISABLE_SSH = true
    [database]
    DB_TYPE = sqlite3
    PATH = ${stateDir}/data/forgejo.db

    [security]
    INSTALL_LOCK = true
    SECRET_KEY = f5583b2dcbed45e558c3391bc68e47a3

    [service]
    DISABLE_REGISTRATION = true
    REQUIRE_SIGNIN_VIEW = false

    [log]
    MODE = file
    LEVEL = Info

    [migrations]
    ALLOWED_DOMAINS = localhost,127.0.0.1
  '';
in {
  # systemd の switch 時に新規/更新ユニットを起動する
  systemd.user.startServices = "sd-switch";

  systemd.user.services.forgejo = {
    Unit = {
      Description = "forgejo (local git forge)";
      After = ["network.target"];
    };
    Service = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${stateDir}/custom/conf ${stateDir}/data"
        "${pkgs.coreutils}/bin/install -m 600 ${appIni} ${stateDir}/custom/conf/app.ini"
      ];
      ExecStart = "${pkgs.forgejo}/bin/forgejo web --config ${stateDir}/custom/conf/app.ini";
      Environment = [
        "GITEA_WORK_DIR=${stateDir}"
        "GITEA_CUSTOM=${stateDir}/custom"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };
}
