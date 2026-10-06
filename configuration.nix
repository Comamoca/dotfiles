# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  config,
  pkgs,
  ...
}:
let
  xremap = import ./xremap.nix { inherit pkgs; };
  username = "coma";
  homeDirectory = config.users.users.${username}.home;

  containers = import ./containers.nix { inherit pkgs; };

  old-pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e89cf1c932006531f454de7d652163a9a5c86668.tar.gz";
    sha256 = "sha256:09cbqscrvsd6p0q8rswwxy7pz1p1qbcc8cdkr6p6q8sx0la9r12c";
  }) { };

  # flake input 経由 (flake.lock で固定)。以前は可動タグ nixos-unstable.tar.gz を
  # 固定 sha256 で fetchTarball しており、上流が進むたびに hash mismatch で
  # 評価全体が壊れていた。更新は `nix flake update nixpkgs-unstable` で行う。
  unstable-pkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  hyprland-0-35-0 = old-pkgs.hyprland;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./disko.nix
  ]

  ++ (with inputs.nixos-hardware.nixosModules; [
    common-pc-ssd
  ]);

  fonts = {
    packages = with pkgs; [
      udev-gothic-nf
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      twemoji-color-font
      # nerd-fonts
    ];
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = [
          "Noto Serif CJK JP"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Noto Sans CJK JP"
          "Noto Color Emoji"
        ];
        monospace = [
          "UDEV Gothic NFLG"
          # "JetBrainsMono Nerd Font"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        # nixbuild.net の新SSH実装 (port 2223)。旧実装 (port 22) は OpenSSH 10.4+ と非互換。
        # ref: https://github.com/nixbuild/feedback/issues/49
        hostName = "eu.nixbuild.net:2223";
        # アクセストークン認証では SSH ユーザは固定で "authtoken"。
        # 実際の認証情報は SSH 公開鍵ではなく、/root/.ssh/nixbuild.conf の
        # SetEnv NIXBUILDNET_TOKEN で渡す (sops テンプレートが生成)。
        # そのため sshKey は指定しない。
        sshUser = "authtoken";
        # root (nix-daemon) has no known_hosts entry for this host, so every
        # dispatch attempt hangs/fails SSH host-key verification. Pinning the
        # key inline (same key already trusted in ~/.ssh/known_hosts) lets
        # nix skip known_hosts entirely.
        # base64 は "[eu.nixbuild.net]:2223 ssh-ed25519 <key>" 形式でエンコードする必要がある。
        # 非標準ポート接続時、SSHはホスト部を "[host]:port" 表記で照合するため、
        # 角括弧+ポートを省いた形式だとホストキー照合が常に失敗する。
        publicHostKey = "W2V1Lm5peGJ1aWxkLm5ldF06MjIyMyBzc2gtZWQyNTUxOSBBQUFBQzNOemFDMWxaREkxTlRFNUFBQUFJUElRQ1pjNTRwb0o4dnFhd2Q4VHJhTnJ5UWVKbnZIMWVMcElEZ2JpcXltTQ==";
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        maxJobs = 16;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
          "nixos-test"
        ];
      }
    ];
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "coma"
      ];
      # 素の substituters/trusted-public-keys は NixOS のデフォルト
      # (cache.nixos.org) を上書きしてしまうため、extra- を使って追加する。
      extra-substituters = [
        "https://cache.iog.io"
      ];
      extra-trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];
      # ローカルの並列ビルド枠を絞り、溢れた分を nixbuild.net にオフロードさせる。
      max-jobs = 2;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = [ "03:00" ];
    };
  };

  # nix.buildMachines.*.publicHostKey (/etc/nix/machines field 8) doesn't
  # suppress SSH host-key checking for the legacy "ssh://" protocol used
  # above, so nix-daemon (root) still fails with "Host key verification
  # failed" since root has no known_hosts entry of its own. Registering the
  # key system-wide (/etc/ssh/ssh_known_hosts, referenced via
  # GlobalKnownHostsFile) covers root regardless of protocol.
  programs.ssh.knownHosts."eu.nixbuild.net" = {
    hostNames = [
      "eu.nixbuild.net"
      "[eu.nixbuild.net]:2223"
    ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
  };

  # --- nixbuild.net アクセストークン ---------------------------------------
  #
  # SSH 公開鍵認証ではなくアクセストークンで認可する。鍵は認証(authentication)
  # には通るが認可(authorization)で弾かれていたため、必要な権限を持つトークンを
  # 使う。トークンは SetEnv NIXBUILDNET_TOKEN で渡すのが公式の方式。
  #
  # ビルドを投げるのは nix-daemon = root なので、トークンは root が読める形で
  # 配置する必要がある (ユーザの ~/.ssh/config は root には効かない)。
  #
  # 注意: この設定を /etc/ssh/ssh_config 側の Include で行ってはいけない。
  # OpenSSH は「読めない Include」を致命的エラーとして扱い、root 専用ファイルを
  # グローバル設定から include すると一般ユーザの ssh が全て起動しなくなる。
  # (「存在しない Include」は無視されるので、初回適用前でも安全。)
  # そのため root 自身の /root/.ssh/config からのみ include する。
  sops = {
    # NixOS レベル (root) での復号鍵。.sops.yaml の &main に対応する age 鍵。
    # より堅牢にするなら、このホストの ssh host key を .sops.yaml の recipient に
    # 追加して age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ] に切り替える
    # (raspi/configuration.nix と同じ方式)。その場合 sops updatekeys が必要。
    age.keyFile = "/home/coma/.config/sops/age/keys.txt";

    secrets."nixbuild-token" = {
      sopsFile = ./secrets/nixbuild.yaml;
    };

    # トークンを埋め込んだ root 専用の SSH 設定断片を生成する。
    templates."nixbuild-ssh-config" = {
      path = "/root/.ssh/nixbuild.conf";
      owner = "root";
      mode = "0400";
      # --- リモートビルドが "unexpected end-of-file" で落ちる問題への緩和 ---
      #
      # nixbuild.net から *ビルド成果物を取得する* 途中で SSH 接続が切れる
      # ことがある。ログ上は
      #   could not copy /nix/store/...-elisa-26.08.1: error: unexpected end-of-file
      #   error: Cannot build '...'. Reason: builder failed with exit code 1.
      # となり、パッケージ側の不具合に見えるが、nixbuild.net のログには
      # status 'built' が残っている (= ビルドは成功、持ち帰りに失敗)。
      # 落ちる derivation は毎回変わる。出力の多い巨大パッケージ (KDE の
      # -debug 出力など) が狙われやすい。
      #
      # ここの設定は接続を切れにくくするだけで、根治はしない。実際に詰まった
      # ときの対処は以下 (2026-09-21 に有効を確認):
      #   1. `--keep-going` を付けて丸ごと再実行する。転送できた分は store に
      #      残るので、数回で収束する。
      #   2. 特定の derivation が毎回落ちるなら、それだけローカルで作る:
      #      nix build --builders '' '/nix/store/<hash>-<name>.drv^*'
      # パッケージ定義やバージョンをいじる必要は無い。
      #
      #   ServerAliveInterval / ServerAliveCountMax / TCPKeepAlive
      #     無通信でも 60 秒ごとに probe を送り、10 回連続無応答 (= 10 分)
      #     まで接続を維持する。アイドル切断の方を防ぐ。
      #   NIXBUILDNET_KEEP_BUILDS_RUNNING=true
      #     接続が切れてもリモート側のビルドを止めない。再試行時に走行中/
      #     完了済みのビルドへ合流でき、最初からやり直しにならない。
      #   NIXBUILDNET_REUSE_BUILD_FAILURES=false
      #     nixbuild.net は既定でビルド *失敗* もキャッシュし、同じ derivation
      #     の再要求に過去の失敗を即座に返す。上記の偽の失敗が焼き付くのを防ぐ。
      #     cf. pkgs/opensrc/default.nix の "Bump to force rebuild" 回避策。
      #
      # NIXBUILDNET_* はユーザの ~/.ssh/config には既に入っているが、ビルドを
      # 投げるのは root なので root 側にも必要 (ユーザの設定は root に効かない)。
      content = ''
        Host eu.nixbuild.net
          Port 2223
          User authtoken
          PreferredAuthentications none
          SetEnv NIXBUILDNET_TOKEN=${
            config.sops.placeholder."nixbuild-token"
          } NIXBUILDNET_KEEP_BUILDS_RUNNING=true NIXBUILDNET_REUSE_BUILD_FAILURES=false
          ServerAliveInterval 60
          ServerAliveCountMax 10
          TCPKeepAlive yes
      '';
    };
  };

  # /root/.ssh/config に上記断片の Include を冪等に追加する。
  # 既存の root SSH 設定を壊さないよう、ファイルごと上書きはしない。
  system.activationScripts.nixbuildRootSshInclude = ''
    install -d -m 0700 /root/.ssh
    touch /root/.ssh/config
    chmod 0600 /root/.ssh/config
    if ! grep -qxF 'Include /root/.ssh/nixbuild.conf' /root/.ssh/config; then
      # Include はファイル先頭に置く必要がある。SSH は最初に現れた値を採用するため、
      # 後方に置くと既存の Host * ブロックに先に食われる。
      printf 'Include /root/.ssh/nixbuild.conf\n%s' "$(cat /root/.ssh/config)" \
        > /root/.ssh/config.new
      mv /root/.ssh/config.new /root/.ssh/config
      chmod 0600 /root/.ssh/config
    fi
  '';
  # -------------------------------------------------------------------------

  # Bootloader.
  boot.loader = {
    # systemd-bootを無効化してGRUBに移行
    systemd-boot.enable = false;

    # GRUB設定（UEFI対応）
    grub = {
      enable = true;
      device = "nodev"; # UEFI環境では"nodev"
      efiSupport = true;
      efiInstallAsRemovable = false;
    };

    # EFI変数設定
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # niri外部ディスプレイのホットプラグ安定性のためのi915パラメータ
  # これらはIntel GPUの省電力機能を無効化し、ディスプレイ出力の安定性を優先する。
  # niriのバージョンアップやカーネル更新後に不要になる可能性あり。
  # 検証手順は config/niri/WORKAROUNDS.md を参照。
  boot.kernelParams = [
    "i915.enable_psr=0" # Panel Self Refreshを無効化 - 外部ディスプレイ接続/切断時の表示崩れを防止
    "i915.enable_fbc=0" # Frame Buffer Compressionを無効化 - マルチディスプレイ時のレンダリング安定性向上
    "i915.enable_dc=0" # Display C-statesを無効化 - ディスプレイの電力状態遷移によるブラックアウト防止
    "loglevel=7" # カーネルログ詳細化 - パニック調査のためデフォルト(4)から引き上げ
    "crash_kexec_post_notifiers" # パニック時にnotifier完了後にkexecを実行 - クラッシュダンプ保存を確実にする
  ];
  # カーネルパニック時のクラッシュダンプ保存
  boot.crashDump.enable = true;
  # ZFS 未使用のため明示的に false に設定 (26.11 からのデフォルト変更に備える)
  boot.zfs.forceImportRoot = false;
  # niriがDRMデバイスに早期アクセスできるよう、initrd段階でi915モジュールをロードする。
  # これにより、ディスプレイのホットプラグ検出が安定する。
  boot.initrd.kernelModules = [ "i915" ];
  # NOTE: 2/9 ビルドに失敗した
  # boot.kernelPackages = pkgs.linuxPackages_cachyos;

  # boot.loader.grub.catppuccin.enable = true;
  # boot.loader.grub.catppuccin.flavor = "mocha";

  catppuccin.enable = true;
  catppuccin.autoEnable = true;
  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";
  catppuccin.sddm.enable = true;

  # GRUB用Catppuccin Mochaテーマ
  catppuccin.grub.enable = true; # boolean型
  catppuccin.grub.flavor = "mocha"; # "mocha"を指定

  networking.hostName = "comabook"; # Define your hostname.
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "wlo1";
  };

  # Enable networking
  networking.networkmanager.enable = true;

  services.logind.settings.Login.HandlePowerKey = "ignore";

  # systemd sleep configuration for suspend/hibernate
  systemd.sleep.settings.Sleep = {
    SuspendState = "mem";
    HibernateMode = "platform";
  };

  # Power management: Force DRM connector detection after resume
  powerManagement = {
    enable = true;

    resumeCommands = ''
      # Wait for system to stabilize
      ${pkgs.coreutils}/bin/sleep 2

      # Force DRM connector detection for all displays
      for connector in /sys/class/drm/card*/status; do
        if [ -w "$connector" ]; then
          echo detect > "$connector" || true
        fi
      done

      # Log resume event
      ${pkgs.coreutils}/bin/echo "Display resume script executed at $(${pkgs.coreutils}/bin/date)" | ${pkgs.systemd}/bin/systemd-cat -t display-resume
    '';
  };

  services.gnome = {
    gnome-keyring.enable = true;
  };

  services.ollama = {
    enable = true;
    package = unstable-pkgs.ollama;
    loadModels = [
      "qwen2.5-coder:1.5b"
      "qwen2.5-coder:0.5b"
    ];
  };

  services.xremap = {
    enable = false;
    serviceMode = "user";
    userName = "coma";

    config = xremap.xremap-config;
  };

  # Wacom ペンタブの ExpressKeys をキーに変換するための input-remapper サービス。
  # プリセットは Home Manager の activation スクリプト(setupWacomInputRemapper)が
  # ~/.config/input-remapper-2/ に配置し、autoload する。
  services.input-remapper = {
    enable = true;
  };

  # NextDNS
  services.nextdns = {
    enable = true;
    arguments = [
      "-config"
      "10.0.3.0/24=abcdef"
      "-cache-size"
      "10MB"
    ];
  };

  # use NextDNS
  networking.nameservers = [
    "2a07:a8c0::f2:3b72"
    "2a07:a8c1::f2:3b72"
  ];

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # i18n.inputMethod = {
  # type = "fcitx5";
  # # waylandFrontend = true;
  # enable = false;
  # fcitx5.addons = with pkgs; [
  #   fcitx5-skk
  #   fcitx5-gtk
  #   ];
  # };

  # Keybase
  services.keybase.enable = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "jp";
    variant = "";
  };

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        waybar
        dmenu
        i3status
        i3lock
        xauth
      ];
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  # Enable sound with pipewire.
  # hardware.pulseaudio.enable = false;
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # services.displayManager.ly.enable = true;

  # SDDM with Catppuccin theme (configured via catppuccin module)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Set default session for SDDM
  services.displayManager.defaultSession = "niri";

  services.envfs.enable = true;
  services.tailscale.enable = true;

  # services.mako.enable = true;
  # services.mako.catppuccin.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.coma = {
    isNormalUser = true;
    description = "Comamoca";
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      "adbusers"
      "plugdev"
      "input" # input-remapper が /dev/input を読むために必要
      "video" # Fix: Add video group for DRM device access (niri display hotplug)
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
    shell = pkgs.fish;
  };

  # GnuPG - Managed by home-manager (see home.nix services.gpg-agent)
  # programs.gnupg.agent = {
  #   enable = true;
  #   pinentryPackage = pkgs.pinentry-gnome3;
  # };

  # Install irefox.
  programs.firefox = {
    enable = true;
    languagePacks = [
      "ja"
      "en-US"
    ];
    # profiles = {
    #   myprofile = {
    #     settings = {
    #       "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    #     };
    #   };
    # };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true; # $EDITOR=nvimに設定
      viAlias = true;
      vimAlias = true;
    };
    starship = {
      enable = true;
    };
    fish = {
      enable = true;
    };
    # kitty.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  # services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      # xdg-desktop-portal-wlr — Niri では使わない（wlroots ベースではない）
      # xdg-desktop-portal-hyprland — REMOVED: Hyprland 用。Niri には不要。
    ];
    config = {
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
      sway.default = pkgs.lib.mkForce [
        "wlr"
        "gtk"
      ];
      niri.default = [
        "gnome"
        "gtk"
      ];
      common.default = "*";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # XDG Desktop Portal
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    # xdg-desktop-portal-wlr — REMOVED: Niri は wlroots ベースではないため競合する。
    #   Niri のスクリーンキャストは GNOME ポータル (org.gnome.Mutter.ScreenCast) を使う。
    xdg-desktop-portal-gnome

    # xwayland-satellite — provides X11 support on pure Wayland compositors (niri).
    # Discord (and other Electron apps) still call X11 functions even when running
    # as Wayland native clients. Without XWayland, they hang on startup.
    xwayland-satellite

    # Discord wrapper:
    #   --disable-gpu: SIGSEGV 回避 (kernel 6.12+ DRM regression)
    #   --ozone-platform=wayland: Wayland ネイティブで起動
    #   --enable-features: PipeWire 経由の画面共有を有効化
    #     NOTE: NIXOS_OZONE_WL=1 だと nixpkgs 側ラッパーが先に
    #     --enable-features=WaylandWindowDecorations を付け、
    #     Chromium の --enable-features は「最後勝ち」のため
    #     両方を 1 つにマージして渡す必要がある。
    #   --enable-wayland-ime=true: 日本語 IME (Wayland) — nixpkgs ラッパーと同値だが明示。
    #   NOTE: home-manager (packages/gui-apps.nix) に生の discord を入れると
    #         ~/.nix-profile が PATH でこのラッパーを遮蔽し、画面共有が壊れる。
    #   NOTE: 2026年3月以降の Discord は Vulkan encode を使うため、
    #         Niri の dma-buf フォーマットと合わない場合がある。
    #         共有できない場合は Vesktop またはブラウザ版 Discord を試す。
    (pkgs.writeShellApplication {
      name = "discord";
      text = ''
        exec ${pkgs.discord}/bin/discord --disable-gpu \
          --enable-features=WebRTCPipeWireCapturer,WaylandWindowDecorations \
          --enable-wayland-ime=true \
          --ozone-platform=wayland "$@"
      '';
    })
    # 上のラッパーは .desktop を持たないため、生 discord の除去後も
    # ランチャーから起動できるようエントリを補う (Exec はラッパーを指す)
    (pkgs.makeDesktopItem {
      name = "discord";
      desktopName = "Discord";
      genericName = "Internet Messenger";
      exec = "discord";
      icon = "discord";
      categories = [ "Network" "InstantMessaging" ];
      startupWMClass = "discord";
    })

    # gparted
    lan-mouse

    # showmethekey

    # gnupg
    brightnessctl

    # waybar

    # android-studio

    arduino
    arduino-cli

    kitty
    swaybg
    swaynotificationcenter
    swaylock

    hyprlock
    hyprpaper
    rofi
    # deno
    wlogout
    # wofiif

    # cursor theme
    phinger-cursors

    # Display diagnostics tool for external display issues
    (pkgs.writeShellScriptBin "display-diag" ''
      echo "=== Display Diagnostics ==="
      echo
      echo "--- Connector Status ---"
      for connector in /sys/class/drm/card*/status; do
        name=$(basename $(dirname $connector))-status
        status=$(cat $connector 2>/dev/null || echo "error")
        echo "$name: $status"
      done
      echo
      echo "--- Enabled Displays ---"
      for enabled in /sys/class/drm/card*/enabled; do
        name=$(basename $(dirname $enabled))-enabled
        status=$(cat $enabled 2>/dev/null || echo "error")
        echo "$name: $status"
      done
      echo
      echo "--- Active i915 Parameters ---"
      for param in /sys/module/i915/parameters/*; do
        name=$(basename $param)
        value=$(cat $param 2>/dev/null || echo "error")
        echo "$name: $value"
      done
      echo
      echo "--- Recent suspend/resume logs ---"
      ${pkgs.systemd}/bin/journalctl -b -n 100 | ${pkgs.gnugrep}/bin/grep -i -E "(suspend|resume|drm|i915|thunderbolt)" | ${pkgs.coreutils}/bin/tail -20
    '')
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Android Debug Bridge
  # programs.adb.enable = true;

  programs.waybar.enable = false;

  programs.xwayland.enable = pkgs.lib.mkForce false;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = false;
    # package = pkgs.swayfx;
  };

  programs.hyprland = {
    enable = true;
  };

  programs.niri = {
    enable = true;
    # niri-flake の main は 2026-08-04 から止まっており、niri-stable が v25.08 に
    # 固定されたまま。v25.08 は設定ファイルの `include` に未対応で、DMS が書き込む
    # `include "dms/*.kdl"` を読めずに niri がデフォルト設定へフォールバックする。
    # nixpkgs の niri (v26.04) を使う。cache.nixos.org のバイナリも利用できる。
    # niri-flake が追随したら (sodiboo/niri-flake#1853 等) この上書きは外してよい。
    package = pkgs.niri;
  };

  programs.nix-ld.dev.enable = true;

  containers = {
    webserver = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.2";

      forwardPorts = [
        {
          hostPort = 10001;
          containerPort = 80;
        }
      ];

      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";
      config =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          services.httpd = {
            enable = true;
            adminAddr = "admin@example.org";
          };

          networking = {
            firewall.allowedTCPPorts = [
              22
              80
            ];
            useHostResolvConf = lib.mkForce false;
          };
          services.resolved.enable = true;
          system.stateVersion = "24.11";
        };
    };

    ai-agent = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.3";

      forwardPorts = [
        {
          hostPort = 10002;
          containerPort = 80;
        }
      ];

      hostAddress6 = "fc00::3";
      localAddress6 = "fc00::4";
      config =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          networking = {
            firewall.allowedTCPPorts = [
              22
              80
            ];
            useHostResolvConf = lib.mkForce false;
          };

          users.users.coma = {
            isNormalUser = true;
            home = "/home/coma";
            extraGroups = [ "wheel" ];
          };

          environment.systemPackages = with pkgs; [
            git
          ];

          services.resolved.enable = true;
          system.stateVersion = "24.11";
        };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
