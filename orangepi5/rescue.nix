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

      watchInterval = lib.mkOption {
        type = lib.types.int;
        default = 15;
        description = ''
          キーボードが無い実機向けに、診断を N 秒ごとに繰り返す。
          0 を指定すると 1 回だけ表示して終わる。
        '';
      };
    };

    # DHCP が動かないときの保険。eth0 がリンクアップしたら固定 IP を
    # 直接振る。NetworkManager と衝突させないため、nmcli で手動プロファイルを
    # 作るのではなく iproute2 で一時的に設定する。
    fallbackAddress = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "192.168.10.50/24";
      description = ''
        eth0 のリンクアップを検出したら、この CIDR を一時的に割り当てる。
        null なら何もしない。
      '';
    };
  };

  config = lib.mkIf config.orangepi5.rescue.enable {
    # tty1 と serial (getty@ttyS2 テンプレート) の両方で自動ログイン。
    # パスワードが無い coma でもこのモジュール経由なら入れる。
    services.getty.autologinUser = "coma";

    # 診断で ethtool / mdio を読むため、救援モードのときだけ入れる。
    environment.systemPackages = with pkgs; [ ethtool iproute2 usbutils pciutils ];

    # DHCP が取れないときの保険。NetworkManager を止めてから ip で直接
    # アドレスを振る。到達確認用の一時処置なので、成功したら
    # ユーザが nmcli で本来の設定に戻す前提。
    systemd.services.orangepi5-fallback-ip = lib.mkIf (config.orangepi5.rescue.fallbackAddress != null) {
      description = "Orange Pi 5 救援用の固定 IP フォールバック";
      wantedBy = [ "multi-user.target" ];
      after = [ "NetworkManager.service" ];
      wants = [ "NetworkManager.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "orangepi5-fallback-ip" ''
          set -eu
          addr=''${config.orangepi5.rescue.fallbackAddress}
          iface=eth0

          # リンクアップを最大 60 秒待つ。
          for _ in $(seq 1 60); do
            [ "$(cat /sys/class/net/$iface/carrier 2>/dev/null || echo 0)" = "1" ] && break
            sleep 1
          done

          # NetworkManager にこのデバイスを握らせない (DHCP と衝突させない)。
          ${pkgs.networkmanager}/bin/nmcli device set "$iface" managed no || true
          ${pkgs.iproute2}/bin/ip addr flush dev "$iface" || true
          ${pkgs.iproute2}/bin/ip link set "$iface" up
          ${pkgs.iproute2}/bin/ip addr add "$addr" dev "$iface"
          echo "fallback ip: $addr on $iface" | ${pkgs.systemd}/bin/systemd-cat -t orangepi5-fallback-ip
        '';
      };
    };

    # キーボードが無いので tty1 に何も入力できない。診断を繰り返し出す
    # ため、シェル初期化の中でループさせる (watchInterval > 0 のとき)。
    environment.interactiveShellInit = lib.mkIf config.orangepi5.rescue.diagnostics.enable
      (let
        interval = config.orangepi5.rescue.diagnostics.watchInterval;
        credits = toString config.orangepi5.rescue.diagnostics.journalLines;
      in
      ''
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
        echo "--- eth0 link state (sysfs) ---"
        for f in carrier operstate speed duplex address; do
          printf '%s: %s\n' "$f" "$(cat /sys/class/net/eth0/$f 2>/dev/null || echo n/a)"
        done
        echo "--- mdio bus / phy devices ---"
        ls -d /sys/class/mdio_bus/* 2>/dev/null || echo "(no mdio_bus)"
        for d in /sys/class/mdio_bus/*/*; do
          [ -d "$d" ] || continue
          case "$(basename "$d")" in
            *:*|*.*) continue ;;
          esac
          printf '%s phy_id=%s\n' "$d" "$(cat "$d/phy_id" 2>/dev/null || echo n/a)"
        done
        ethtool eth0 2>&1 | head -25 || true
        if $privileged; then
          echo "--- dmesg (net/firmware) ---"
          dmesg | grep -iE 'eth|r8169|stmmac|dwmac|fec|phy|mdio|link|firmware' | tail -40
          echo "--- dmesg: fe1c0000 / gmac ---"
          dmesg | grep -iE 'fe1c0000|gmac|rk_gmac' | tail -30
          echo "--- journal errors (last ${credits} lines) ---"
          journalctl -b --no-pager -p 3 | tail -${credits}
          echo "--- NetworkManager journal (last 40 lines) ---"
          journalctl -b --no-pager -u NetworkManager | tail -40
        else
          echo "(sudo 使えないので dmesg / journal は省略)"
        fi
        echo "=== rescue diagnostics end ==="
      '' + lib.optionalString (interval > 0) ''

        # キーボードが無いので、状況が変わるまで同じ診断を流し続ける。
        trap ':' INT
        while :; do
          sleep ${toString interval}
          echo ""
          echo "=== rescue watch $(date +%H:%M:%S) ==="
          for i in ${config.networking.hostName}; do :; done
          iface=$(ip -o -4 addr show scope global | awk '{print $2"="$4}' | tr '\n' ' ')
          link=$(ip -br link | awk '$1 != "lo" {print $1":"$2":"$3}' | tr '\n' ' ')
          echo "addr: ''${iface:-none}  link: ''${link:-none}"
          nmcli -t device status 2>&1 | tr '\n' ' '
          echo ""
          echo "carrier: $(cat /sys/class/net/eth0/carrier 2>/dev/null || echo n/a)  operstate: $(cat /sys/class/net/eth0/operstate 2>/dev/null || echo n/a)"
          echo "speed: $(cat /sys/class/net/eth0/speed 2>/dev/null || echo n/a)  phy: $(ls /sys/class/mdio_bus/*/ 2>/dev/null | tr '\n' ' ')"
          echo "gmac: $(dmesg 2>/dev/null | grep -ciE 'fe1c0000') lines, phy: $(dmesg 2>/dev/null | grep -ciE 'mdio|phy') lines"
        done
      '');
  };
}
