# ローカル Forgejo を home-manager 管理の systemd user service として起動する。
# 管理者登録は初回に CLI で作成する:
#   forgejo admin user create --config ~/.config/forgejo/app.ini \
#     --admin --username coma --email coma@localhost --password <pass>
# API トークンも CLI で発行できる:
#   forgejo admin user generate-token --config ~/.config/forgejo/app.ini \
#     --username coma --token-name maestro
{
  config,
  pkgs,
  ...
}: let
  stateDir = "${config.home.homeDirectory}/.local/state/forgejo";
  configDir = "${config.home.homeDirectory}/.config/forgejo";
in {
  # systemd の switch 時に新規/更新ユニットを起動する
  systemd.user.startServices = "sd-switch";

  xdg.configFile."forgejo/app.ini".text = ''
    APP_NAME = forgejo (local)
    RUN_MODE = prod
    RUN_USER = coma

    [server]
    PROTOCOL = http
    HTTP_ADDR = 127.0.0.1
    HTTP_PORT = 3000
    ROOT_URL = http://localhost:3000/
    DISABLE_SSH = true
    APP_DATA_PATH = ${stateDir}/data

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

  systemd.user.services.forgejo = {
    Unit = {
      Description = "forgejo (local git forge)";
      After = ["network.target"];
    };
    Service = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${stateDir}/data"
      ];
      ExecStart = "${pkgs.forgejo}/bin/forgejo web --config ${configDir}/app.ini";
      Environment = "GITEA_WORK_DIR=${stateDir}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };
}
