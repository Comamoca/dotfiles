# Orange Pi 5 用救援モジュール。
#
# キーボードが無い実機で、HDMI/シリアルに「自動ログイン + 自動診断」を出す
# ためのオプションモジュール。普段は flake.nix の modules に読み込まない。
# 使うときは orangepi5 の modules に ./orangepi5/rescue.nix を足して
# イメージを焼き直す。diagnostics.enable = false にすると自動診断だけ消せる。
{ config, lib, pkgs, ... }:

{
  options.orangepi5.rescue = {
    enable = lib.mkEnableOption "getty 自動ログイン (救援モード)";

    diagnostics = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "ログイン時にネットワーク診断をコンソールに流す。";
      };

      journalLines = lib.mkOption {
        type = lib.types.int;
        default = 80;
        description = "表示する journal の行数。";
      };
    };
  };

  config = lib.mkIf config.orangepi5.rescue.enable {
    # tty1 と serial (getty@ttyS2 テンプレート) の両方で自動ログイン。
    # パスワードが無い coma でもこのモジュール経由なら入れる。
    services.getty.autologinUser = "coma";

    # sudo は wheelNeedsPassword = false なので対話なしに流せる (設定は
    # configuration.nix 側)。wheel に入っていなければ sudo 行は自動で飛ばす。
    environment.interactiveShellInit = lib.mkIf config.orangepi5.rescue.diagnostics.enable ''
      if [ "$(id -u)" -gt 0 ] && ! sudo -n true 2>/dev/null; then
        privileged=false
      else
        privileged=true
      fi

      echo ""
      echo "=== orangepi5 rescue diagnostics $(date --iso-8601=seconds) ==="
      echo "--- ip -br addr ---"
      ip -br addr
      echo "--- ip route ---"
      ip route
      echo "--- nmcli device status ---"
      nmcli device status 2>&1
      echo "--- nmcli general + connections ---"
      nmcli general status 2>&1
      nmcli connection show 2>&1
      echo "--- ethernet kernel drivers ---"
      grep -E 'r8169|stmmac|dwmac|rk[0-9]' /proc/modules 2>/dev/null || true
      if $privileged; then
        echo "--- dmesg (net/firmware) ---"
        dmesg | grep -iE 'eth|r8169|stmmac|dwmac|fec|phy|firmware' | tail -40
        echo "--- journal errors (last ${toString config.orangepi5.rescue.diagnostics.journalLines} lines) ---"
        journalctl -b --no-pager -p 3 | tail -${toString config.orangepi5.rescue.diagnostics.journalLines}
        echo "--- NetworkManager journal (last 40 lines) ---"
        journalctl -b --no-pager -u NetworkManager | tail -40
      else
        echo "(sudo 使えないので dmesg / journal は省略)"
      fi
      echo "=== rescue diagnostics end ==="
    '';
  };
}
