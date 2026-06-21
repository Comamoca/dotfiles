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

  unstable-pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    sha256 = "sha256:1xfg014g26v79y4088s02qm0gq33fjasplznxjwjwxw2zffc1236";
  }) { system = "x86_64-linux"; };

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
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "coma"
      ];
      substituters = [
        "https://cache.iog.io"
      ];
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];
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

  # Bootloader.
  boot.loader = {
    # systemd-bootを無効化してGRUBに移行
    systemd-boot.enable = false;

    # GRUB設定（UEFI対応）
    grub = {
      enable = true;
      device = "nodev";           # UEFI環境では"nodev"
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
    "i915.enable_psr=0"      # Panel Self Refreshを無効化 - 外部ディスプレイ接続/切断時の表示崩れを防止
    "i915.enable_fbc=0"      # Frame Buffer Compressionを無効化 - マルチディスプレイ時のレンダリング安定性向上
    "i915.enable_dc=0"       # Display C-statesを無効化 - ディスプレイの電力状態遷移によるブラックアウト防止
    "loglevel=7"             # カーネルログ詳細化 - パニック調査のためデフォルト(4)から引き上げ
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
  catppuccin.grub.enable = true;      # boolean型
  catppuccin.grub.flavor = "mocha";   # "mocha"を指定

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
    loadModels = [ "qwen2.5-coder:1.5b" "qwen2.5-coder:0.5b" ];
  };

  services.xremap = {
    enable = false;
    serviceMode = "user";
    userName = "coma";

    config = xremap.xremap-config;
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
      "inputs"
      "video"  # Fix: Add video group for DRM device access (niri display hotplug)
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
      # xdg-desktop-portal-wlr
      xdg-desktop-portal-hyprland
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
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gnome

    # xwayland-satellite — provides X11 support on pure Wayland compositors (niri).
    # Discord (and other Electron apps) still call X11 functions even when running
    # as Wayland native clients. Without XWayland, they hang on startup.
    xwayland-satellite

    # Discord wrapper: --disable-gpu avoids SIGSEGV (kernel 6.12+ DRM regression),
    # --ozone-platform=x11 avoids the Wayland compatibility hang.
    (pkgs.writeShellApplication {
      name = "discord";
      text = ''
        exec ${pkgs.discord}/bin/discord --disable-gpu --ozone-platform=x11 "$@"
      '';
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
  };

  programs.nix-ld.dev.enable = true;

  containers = {
    webserver = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.2";

      forwardPorts = [
        { hostPort = 10001; containerPort = 80; }
      ];

      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";
      config = { config, pkgs, lib, ... }: {
        services.httpd = {
          enable = true;
          adminAddr = "admin@example.org";
        };
    
        networking = {
          firewall.allowedTCPPorts = [ 22 80 ];
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
        { hostPort = 10002; containerPort = 80; }
      ];

      hostAddress6 = "fc00::3";
      localAddress6 = "fc00::4";
      config = { config, pkgs, lib, ... }: {
        networking = {
          firewall.allowedTCPPorts = [ 22 80 ];
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
