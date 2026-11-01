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

      # mainline カーネルでは有線の名前が eth0 にならず end0 になることがある
      # (MAC が DTB の nvmem-cells から読めた場合の predictable name)。
      # Orange Pi 5 では実結線が eth1 になることもある (実測)。
      # usePredictableInterfaceNames = false でも揺れるので、名前は決め打ちせず
      # 実在する有線デバイスを sysfs から探す。
      watchInterval = lib.mkOption {
        type = lib.types.int;
        default = 15;
        description = ''
          キーボードが無い実機向けに、診断を N 秒ごとに繰り返す。
          0 を指定すると 1 回だけ表示して終わる。
        '';
      };
    };

    # 有線 IF の名前。Orange Pi 5 の mainline DTS では実結線が eth0 でも
    # end0 でもなく eth1 になることがある (実測)。決め打ちすると存在しない
    # 名前を読み続けて診断が n/a になり、fallback の ip addr add も
    # 「デバイスが無い」で失敗する。よって既定は自動検出。
    interface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "eth1";
      description = ''
        診断と fallbackAddress が使うインターフェース名。null なら
        /sys/class/net から type=1 (Ethernet) かつ device を持つものを
        自動検出する (carrier=1 を優先)。
      '';
    };

    # DHCP が動かないときの保険。有線 IF がリンクアップしたら固定 IP を
    # 直接振る。NetworkManager と衝突させないため、nmcli で手動プロファイルを
    # 作るのではなく iproute2 で一時的に設定する。
    fallbackAddress = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "192.168.10.50/24";
      description = ''
        有線 IF (interface または自動検出) がリンクアップしたら、この CIDR を
        一時的に割り当てる。null なら何もしない。
      '';
    };
  };

  config = lib.mkIf config.orangepi5.rescue.enable (
    let
      # interface オプションが指定されていればそれを使う。null なら空文字に
      # して、各スクリプトが sysfs から有線デバイスを自動検出する。
      iface = if config.orangepi5.rescue.interface != null then config.orangepi5.rescue.interface else "";

      # シェル側の自動検出スニペット。
      #
      # Orange Pi 5 の mainline DTS は gmac ノードを複数持ち、実結線が
      # eth0 ではなく eth1 になることがある (実測: eth1 が up、eth0 は
      # 存在しないか別ノード)。素朴に /sys/class/net を辞書順で舐めると
      # eth0 を誤選択するため、次の優先順で選ぶ。
      #
      #   1. type=1 (ARPHRD_ETHER) かつ carrier=1 のもの
      #   2. type=1 かつ device を持つもの
      #
      # type=1 で lo (type 772) / tailscale0 / docker0 / veth は外れる。
      detectIface = ''
        if [ -z "$iface" ]; then
          _pick=""
          for _d in /sys/class/net/*; do
            _c=$(basename "$_d")
            [ -e "$_d/device" ] || continue
            [ "$(cat "$_d/type" 2>/dev/null || echo 0)" = "1" ] || continue
            if [ "$(cat "$_d/carrier" 2>/dev/null || echo 0)" = "1" ]; then
              _pick="$_c"
              break
            fi
            [ -z "$_pick" ] && _pick="$_c"
          done
          iface="$_pick"
        fi
      '';
    in
    {

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
          addr=${lib.escapeShellArg config.orangepi5.rescue.fallbackAddress}
          iface=${lib.escapeShellArg iface}

          # 名前が未指定なら sysfs から有線デバイスを探す。
          # これは set -eu より前に済ませる必要がある (iface 空のまま
          # ip link set すると即死するのが今回のバグだった)。
          ${detectIface}

          if [ -z "$iface" ]; then
            echo "fallback ip: no ethernet interface found" \
              | ${pkgs.systemd}/bin/systemd-cat -t orangepi5-fallback-ip
            exit 0
          fi

          echo "fallback ip: using interface $iface" \
            | ${pkgs.systemd}/bin/systemd-cat -t orangepi5-fallback-ip

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
        # 対象の有線 IF を決める (未指定なら sysfs から探す)。
        iface=${lib.escapeShellArg iface}
        ${detectIface}

        if [ "$(id -u)" -gt 0 ] && ! sudo -n true 2>/dev/null; then
          privileged=false
        else
          privileged=true
        fi

        echo ""
        echo "=== orangepi5 rescue diagnostics $(date --iso-8601=seconds) ==="
        echo "--- detected ethernet interface: ''${iface:-none} ---"
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
        echo "--- $iface link state (sysfs) ---"
        for f in carrier operstate speed duplex address; do
          printf '%s: %s\n' "$f" "$(cat /sys/class/net/$iface/$f 2>/dev/null || echo n/a)"
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
        ethtool "$iface" 2>&1 | head -25 || true
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
        # 上の診断で iface に有線 IF 名が入っている。見つからなければ
        # ここで改めて探す (初回はネットワーク初期化前の可能性がある)。
        trap ':' INT
        while :; do
          sleep ${toString interval}
          echo ""
          echo "=== rescue watch $(date +%H:%M:%S) ==="
          iface=${lib.escapeShellArg iface}
          ${detectIface}
          addrs=$(ip -o -4 addr show scope global | awk '{print $2"="$4}' | tr '\n' ' ')
          link=$(ip -br link | awk '$1 != "lo" {print $1":"$2":"$3}' | tr '\n' ' ')
          echo "if: ''${iface:-none}"
          echo "addr: ''${addrs:-none}  link: ''${link:-none}"
          nmcli -t device status 2>&1 | tr '\n' ' '
          echo ""
          echo "carrier: $(cat /sys/class/net/$iface/carrier 2>/dev/null || echo n/a)  operstate: $(cat /sys/class/net/$iface/operstate 2>/dev/null || echo n/a)"
          echo "speed: $(cat /sys/class/net/$iface/speed 2>/dev/null || echo n/a)  phy: $(ls /sys/class/mdio_bus/*/ 2>/dev/null | tr '\n' ' ')"
          echo "gmac: $(dmesg 2>/dev/null | grep -ciE 'fe1c0000') lines, phy: $(dmesg 2>/dev/null | grep -ciE 'mdio|phy') lines"
        done
      '');
    }
  );
}
