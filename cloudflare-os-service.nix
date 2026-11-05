# cloudflare-os を systemd user サービスとして常起動させる。
#
# 上流: https://github.com/cloudflare/cloudflare-os
# ラッパースクリプト (pkgs/cloudflare-os) が git clone → pnpm install → build →
# run-local を担当する。初回起動時はクローン + ビルドで数分かかる。
#
# データ永続化: ~/.local/share/cloudflare-os/ (git clone + node_modules + .wrangler)
# ポート: 18787 (通常の web 開発ポートと衝突回避)
#
# OAuth クレデンシャル: ~/.config/cloudflare-os/env から EnvironmentFile で読み込む。
# テンプレートは env.template を参照。未設定でもサービスは起動するが Gatekeeper は未接続になる。
{
  config,
  pkgs,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
  dataDir = "${homeDirectory}/.local/share/cloudflare-os";
  cloudflareOsPkg = import ./pkgs/cloudflare-os { inherit pkgs; };
in
{
  systemd.user.startServices = "sd-switch";

  home.packages = [ cloudflareOsPkg ];

  systemd.user.services.cloudflare-os = {
    Unit = {
      Description = "Cloudflare OS — AI productivity environment (local)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${cloudflareOsPkg}/bin/cloudflare-os";
      # OAuth クレデンシャルを外部ファイルから読む（"-" プレフィックスでファイル不在でも起動する）
      EnvironmentFile = "-${homeDirectory}/.config/cloudflare-os/env";
      Environment = [
        "CLOUDFLARE_OS_DATA_DIR=${dataDir}"
        "CLOUDFLARE_OS_PORT=18787"
      ];
      Restart = "on-failure";
      RestartSec = 30;
      # 初回の clone + install + build がタイムアウトしないようにする。
      TimeoutStartSec = "infinity";
    };
    Install.WantedBy = [ "default.target" ];
  };
}