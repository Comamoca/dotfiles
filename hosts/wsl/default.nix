{
  inputs,
  config,
  pkgs,
  ...
}:
let
  xremap = import ./xremap.nix { inherit pkgs; };

  old-pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e89cf1c932006531f454de7d652163a9a5c86668.tar.gz";
    sha256 = "sha256:09cbqscrvsd6p0q8rswwxy7pz1p1qbcc8cdkr6p6q8sx0la9r12c";
  }) { };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      # ./hardware-configuration.nix
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
      noto-fonts-emoji
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
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "coma"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  catppuccin.enable = true;

  networking.hostName = "comabook"; # Define your hostname.
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  services.ollama = {
    enable = true;
  };

  services.xremap = {
    enable = true;
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

  # Keybase
  services.keybase.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # hardware.pulseaudio.enable = false;
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.displayManager.ly.enable = true;

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
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
    shell = pkgs.fish;
  };

  # GnuPG
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    # pinentryPackage = pkgs.pinentry-curses;
    # pinentryPackage = pkgs.pinentry-gnome3;
    # settings = {
    #   pinentry-program = "${(pkgs.lib.mkForce pkgs.pinentry-gnome3)}";
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
  xdg.portal.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # gparted

    # showmethekey

    # gnupg
    light

    # waybar

    # android-studio

    arduino
    arduino-cli

    kitty

    deno
    wlogout
    # wofiif

    # cursor theme
    phinger-cursors
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

  programs.nix-ld.enable = true;

  # Android Debug Bridge
  # programs.adb.enable = true;

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
