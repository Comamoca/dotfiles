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
    environment.systemPackages = with pkgs; [ ethtool iproute2 usbutils pciutils ]
      ++ lib.optionals config.orangepi5.rescue.diagnostics.enable [
        (pkgs.writeShellApplication {
          name = "orangepi5-diag";
          runtimeInputs = with pkgs; [
            iproute2
            networkmanager
            ethtool
            systemd
            gnugrep
            gawk
            coreutils
          ];
          text = ''
            iface=${lib.escapeShellArg iface}
            ${detectIface}
            echo "=== orangepi5-diag $(date --iso-8601=seconds) ==="
            echo "--- iface: ''${iface:-none} ---"
            ip -br addr || true
            ip route || true
            nmcli device status || true
            if [ -n "$iface" ]; then
              for f in carrier operstate speed duplex address; do
                printf '%s: %s\n' "$f" "$(cat "/sys/class/net/$iface/$f" 2>/dev/null || echo n/a)"
              done
              ethtool "$iface" 2>&1 | head -25 || true
            fi
            echo "--- mdio bus / phy ---"
            ls -d /sys/class/mdio_bus/* 2>/dev/null || echo "(no mdio_bus)"
            for d in /sys/class/mdio_bus/*/*; do
              [ -d "$d" ] || continue
              case "$(basename "$d")" in *:*|*.*) continue ;; esac
              printf '%s phy_id=%s\n' "$d" "$(cat "$d/phy_id" 2>/dev/null || echo n/a)"
            done
            echo "--- dmesg (net) ---"
            dmesg 2>/dev/null | grep -iE 'eth|stmmac|dwmac|gmac|phy|mdio|link' | tail -40 || true
          '';
        })
      ];

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

    # 診断は「1 回だけ出して制御を返す」形にする。
    #
    # 以前はここで `while :; do ... done` を回し、`trap ':' INT` で Ctrl-C を
    # 握り潰していた。interactiveShellInit はログインシェルが起動するたびに
    # 走るため、Ctrl-C も Ctrl-D も効かず端末が操作不能になり、再起動しても
    # 自動ログインで同じループに入って復旧できない事故になった。
    #
    # 対策:
    #   1. シェル初期化では「その場で 1 回出す」だけにして必ず return する。
    #   2. 継続監視は systemd の oneshot サービスで journal に流す。
    #      シェルとは独立なので、端末が固まることはない。
    #   3. Ctrl-C を握り潰す trap は置かない。
    environment.interactiveShellInit = lib.mkIf config.orangepi5.rescue.diagnostics.enable
      (let
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
        echo "--- ''${iface:-none} link state (sysfs) ---"
        if [ -n "$iface" ]; then
          for f in carrier operstate speed duplex address; do
            printf '%s: %s\n' "$f" "$(cat "/sys/class/net/$iface/$f" 2>/dev/null || echo n/a)"
          done
          ethtool "$iface" 2>&1 | head -25 || true
        else
          echo "(有線 IF が見つからない)"
        fi
        echo "--- mdio bus / phy devices ---"
        ls -d /sys/class/mdio_bus/* 2>/dev/null || echo "(no mdio_bus)"
        for d in /sys/class/mdio_bus/*/*; do
          [ -d "$d" ] || continue
          case "$(basename "$d")" in
            *:*|*.*) continue ;;
          esac
          printf '%s phy_id=%s\n' "$d" "$(cat "$d/phy_id" 2>/dev/null || echo n/a)"
        done
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
        echo "継続監視は orangepi5-watch.service (journalctl -t orangepi5-watch -f)。"
        echo "この診断を出し直すには: orangepi5-diag"
        unset iface privileged
      ''
      );

    # 端末を占有せずに状態を追い続けるための監視サービス。
    # journal に書くので、HDMI に出ていなくても後から `ssh`/`journalctl -t`
    # で読める。Enable は既定で false。watchInterval = 0 なら生成しない。
    systemd.services.orangepi5-watch = lib.mkIf
      (config.orangepi5.rescue.diagnostics.enable
        && config.orangepi5.rescue.diagnostics.watchInterval > 0)
      {
        description = "Orange Pi 5 rescue watch (network state to journal)";
        wantedBy = [ "multi-user.target" ];
        after = [ "NetworkManager.service" ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 5;
        };
        script = ''
          set -u
          iface=${lib.escapeShellArg iface}
          ${detectIface}
          while :; do
            ts=$(${pkgs.coreutils}/bin/date +%H:%M:%S)
            addrs=$(${pkgs.iproute2}/bin/ip -o -4 addr show scope global 2>/dev/null | awk '{print $2"="$4}' | tr '\n' ' ')
            link=$(${pkgs.iproute2}/bin/ip -br link 2>/dev/null | awk '$1 != "lo" {print $1":"$2":"$3}' | tr '\n' ' ')
            carrier=$(${pkgs.coreutils}/bin/cat "/sys/class/net/$iface/carrier" 2>/dev/null || echo n/a)
            operstate=$(${pkgs.coreutils}/bin/cat "/sys/class/net/$iface/operstate" 2>/dev/null || echo n/a)
            speed=$(${pkgs.coreutils}/bin/cat "/sys/class/net/$iface/speed" 2>/dev/null || echo n/a)
            phys=$(${pkgs.coreutils}/bin/ls -d /sys/class/mdio_bus/*/ 2>/dev/null | tr '\n' ' ')
            echo "$ts if=$iface carrier=$carrier operstate=$operstate speed=$speed"
            echo "$ts addr=$addrs link=$link"
            echo "$ts phy=$phys"
            sleep ${toString config.orangepi5.rescue.diagnostics.watchInterval}
          done
        '';
        # 標準出力は journal に拾わせる。
        serviceConfig.StandardOutput = "journal";
        serviceConfig.StandardError = "journal";
        serviceConfig.SyslogIdentifier = "orangepi5-watch";
      };
    }
  );
}
