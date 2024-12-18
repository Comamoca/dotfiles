{
  config,
  pkgs,
  overlays,
  inputs,
  ...
}:

let
  system = "x86_64-linux";
  nurpkgs = inputs.nur-packages.legacyPackages.${system};

  wallpapers = builtins.fetchTarball {
    url = "https://github.com/zhichaoh/catppuccin-wallpapers/archive/refs/heads/main.zip";
    sha256 = "sha256:0rd6hfd88bsprjg68saxxlgf2c2lv1ldyr6a8i7m4lgg6nahbrw7";
  };

  wallpaper = "${wallpapers}/misc/cat-sound.png";

  emacs' = pkgs.emacs-pgtk.overrideAttrs (old: {
    # configureFlags = old.configureFlags or [] ++ [ "--with-xwidgets" ];
    withXwidgets = true;
    withGTK3 = true;
    buildInputs = (old.buildInputs or []) ++ [
      pkgs.webkitgtk_6_0
    ];
  });
in
rec {
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-29.4.6"
    ];
    android_sdk.accept_license = true;
  };

  sops = {
    # age.keyFile = "${home.homeDirectory}/.config/sops/age/keys.txt";
    age.keyFile = "/home/coma/.config/sops/age/keys.txt";
    # # It's also possible to use a ssh key, but only when it has no password:
    # # age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
    defaultSopsFile = ./secrets.yaml;
  }; 

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "coma";
  home.homeDirectory = "/home/coma";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # home-manager

    # Knowledge tool for terminal
    nb
    w3m

    # theme 
    catppuccin

    # Nix
    nixVersions.nix_2_25

    # ========== NIXGL ========== 
    # nixgl.nixGLIntel

    # ========== Audio ==========
    sonic-pi
    qpwgraph

    # ========== TERMINAL ========== 
    wezterm
    alacritty
    kitty

    # ========== EDITOR & TOOLS ==========  
    cmigemo
    wakatime-cli

    tree-sitter
    arduino

    # TODO: change to vim-overlay
    vim-full
    emacs30-pgtk
    felix
    micro
    neovim
    jetbrains.idea-community

    # visual-studio-code-bin
    # inputs.lem-editor.packages.x86_64-linux.lem-ncurses

    metals
    meson
    leiningen

    tig

    just

    # ========== OTHER TOOLS ==========  
    nodePackages."@antfu/ni"
    nix-output-monitor

    kickstart
    xsel

    nix-search-cli
    zellij

    # textimg
    # textql-git
    nak

    vim-startuptime

    cachix

    ghq
    # cava
    lsd
    bat
    jnv
    jq
    dasel

    lazydocker
    lazygit
    git
    delta

    jwt-cli

    slack
    teams-for-linux
    discord
    beeper

    # Teams for linux is depends to Electron-29 but EOL.
    # teams-for-linux

    teip

    tokei
    tree
    unar
    k6

    # esp32
    easyeffects
    espup
    espflash
    esptool
    cargo-espmonitor
    mkspiffs-presets.esp-idf

    # ========== SHELL ========== 
    # Because duplicate binary name to ni.
    # nushell

    # ========== BROWSER ========== 
    # firefox
    # google-chrome

    # ========== SECURITY TOOLS ========== 
    keybase
    lssecret

    gnupg
    # pinentry-curses
    # (pkgs.lib.hiPrio pinentry-emacs)
    # (pkgs.lib.hiPrio pkgs.pinentry-gnome3)

    # ========== LANGUAGE SERVER ========== 
    lua-language-server
    vim-language-server
    typescript-language-server
    efm-langserver
    marksman
    tailwindcss-language-server

    # ========== RUNTIME & COMPILER ==========  
    babashka

    # ref: https://cons.io/
    gerbil
    # gambit

    erlang_27
    rebar3

    deno
    nodejs_22
    bun

    pnpm

    gleam

    # Common Lisp
    sbcl
    roswell
    sbclPackages.qlot-cli

    ruby

    # roswell

    # swift ==> Flake

    # ========== FONTS ========== 
    noto-fonts
    noto-fonts-cjk-sans
    # ttf-udev-gothic

    # ========== Writing ========== 
    textlint
    textlint-rule-preset-ja-technical-writing

    # ========== UTILS ========== 
    nix-prefetch-scripts

    # ========== FROM PKGLIST ========== 
    acpi
    acpid
    act

    # apparmor
    libapparmor

    # arduino-cli
    # arduino-ide-bin
    asar
    at
    autoconf-archive
    autotiling
    avahi

    # b43-fwcutter
    b43FirmwareCutter

    babashka

    # base
    # base-devel

    bison
    bitwarden-cli

    bluez
    # bluez-utils
    bluez-tools

    # boost
    bottom
    btrfs-progs
    bzip2
    # cava
    ccache
    cliphist
    cloc
    conky
    coreutils
    cpio

    # cpupower
    linuxKernel.packages.linux_zen.cpupower

    # cronie

    cryptsetup
    deno

    # device-mapper

    # dhclient
    # dhcpcd
    # diffutils
    # discord_arch_electron
    dmraid
    dnsmasq
    docker
    docker-compose
    dosfstools
    # downgrade
    doxygen
    e2fsprogs
    efibootmgr

    # era

    # esp-idf
    # esptool

    exfatprogs
    f2fs-tools

    fastfetch

    # fcitx5
    # fcitx5-configtool
    # fcitx5-gtk
    # fcitx5-skk

    fd

    ffmpeg
    ffmpegthumbnailer
    file-roller
    flashfocus
    font-manager

    fzf
    gammastep
    # gcc-fortran
    gfortran9

    gd
    github-cli
    glava

    glibcLocales

    glow
    gnome-epub-thumbnailer
    gnome-keyring
    go
    gomi

    # greetd
    # greetd-tuigreet
    greetd.greetd
    greetd.tuigreet

    # grub
    # grub-btrfs

    grim
    # gtk3-nocsd
    gvfs
    # gvfs-mtp
    helix
    himalaya
    htop
    httpie

    # immersed

    imv
    inetutils
    # intel-ucode
    jfsutils
    # kitty

    # kvantum

    less

    # lib32-glu
    # lib32-libva-vdpau-driver
    # lib32-mesa-vdpau
    # lib32-vulkan-intel
    # lib32-vulkan-radeon
    # libcava
    # libfishsound
    # liboggz
    # libsixel
    # libva-mesa-driver
    # libva-vdpau-driver

    lightdm

    # linux61

    logrotate

    luarocks
    lvm2
    ly
    gnumake
    man-db
    man-pages

    mdadm
    mediainfo

    # memtest86plus
    # memtest86-efi

    # mesa-vdpau
    # mhwd
    # mhwd-db

    # mkinitcpio-openswap

    # nfs-utils
    mplayer

    # multilib-devel
    # ncurses5-compat-libs

    # network-manager-applet
    # networkmanager

    # nss-mdns

    # ntfs-3g

    oh-my-zsh

    # openssh-askpass

    opusfile
    os-prober
    p7zip

    pass
    patch
    pavucontrol

    perl
    playerctl

    polkit_gnome

    # postgresql-libs

    poweralertd
    pulsemixer

    # python-breathe
    # python-eventlet
    # python-joblib
    # python-pyserial
    # python-recommonmark
    # python-sphinx-alabaster-theme
    # pywal-16-colors

    # qemu-base
    # qemu-desktop
    # qemu-system-riscv
    # qt5-wayland
    # qt5ct
    # qt6-multimedia
    # qt6-tools
    # qt6-wayland
    # qt6ct

    ranger
    # rcm
    re2c
    redis
    reiserfsprogs
    ripgrep

    # riscv-gnu-toolchain-bin

    rlwrap
    rofi-power-menu

    rsync

    samurai
    sd
    shotcut
    siege

    slurp
    sof-firmware
    spectre-meltdown-checker

    spotify
    # spotify-tui

    squashfsTools

    starship
    # sudo

    # super_unko-git

    # swaycwd
    # swaylock-effects
    # swaync

    # sworkstyle

    swww
    sysfsutils
    systemd

    # taglib1
    # teams-for-linux

    texinfo

    xfce.thunar

    # timeshift-autosnap-manjaro

    usbutils
    uucp

    # v4l2loopback-dkms

    vhs
    vlc

    # vulkan-intel
    # vulkan-radeon

    way-displays
    waypaper
    wdisplays

    wev
    wf-recorder
    wget
    which
    wireless-regdb
    wl-clipboard
    wlay
    wlsunset
    wofi
    wpa_supplicant

    # ========== OTHER TOOLS ========== 
    # For Emacs markdown-mode
    multimarkdown
    wakatime

    # hyprland
    # hyprlock
    hyperfine

    hyprpaper
    hyprshade

    # wqy-microhei
    # wxwidgets-gtk3
    # xclip

    xdg-desktop-portal-wlr
    xdg-user-dirs

    # xf86-video-amdgpu
    # xf86-video-ati
    # xf86-video-intel
    # xf86-video-nouveau
    # xfsprogs

    # xorg-xwayland
    xsv
    yq

    # zeit
    zeitgeist
    # ================================== 

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

  # # Building this configuration will create a copy of 'dotfiles/screenrc' in
  # # the Nix store. Activating the configuration will then make '~/.screenrc' a
  # # symlink to the Nix store copy.
  # ".screenrc".source = dotfiles/screenrc;

  # # You can also set the file content immediately.
  # ".gradle/gradle.properties".text = ''
  #   org.gradle.console=verbose
  #   org.gradle.daemon.idletimeout=3600000
  # '';
  home.file =
    let
      symlink = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = /${home.homeDirectory}/.ghq/github.com/Comamoca/dotfiles;
      xdgConfigHome = /${home.homeDirectory}/.config;
      homeBin = /${home.homeDirectory}/.bin;
    in
    {
      # scripts
      ".bin/scripts/ime" = {
        source = (symlink /${dotfiles}/bin/scripts/ime);
        recursive = true;
      };
      ".bin/scripts/mit" = {
        source = (symlink /${dotfiles}/bin/scripts/mit);
        recursive = true;
      };
      ".bin/scripts/zlib" = {
        source = (symlink /${dotfiles}/bin/scripts/zlib);
        recursive = true;
      };
      ".bin/scripts/shift" = {
        source = (symlink /${dotfiles}/bin/scripts/shift);
        recursive = true;
      };

      # Vim configs.
      # ".vimrc".source = (symlink /${dotfiles}/vimrc);
      # ".vim" = {
      #   source = (symlink /${dotfiles}/vim);
      #   recursive = true;
      # };
      # # ========== SKK ========== 
      # skk-dicts
      ".skk-dict/SKK-JISYO.L".source = "${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L";
      ".skk-dict/SKK-JISYO.im@sparql.all.utf8".source = "${nurpkgs.skk-jisyo-imasparql}/share/SKK-JISYO.im@sparql.all.utf8";

      ".migemo/utf-8/migemo-dict".source = "${pkgs.cmigemo}/share/migemo/utf-8";

      ".spell-dict/programming-english-dict".source = "${nurpkgs.programming-english}/share/dict/programming-english-dict";
      ".spell-dict/dict.txt".source = ./word_dicts/dict.txt;

      # TODO: 後で消す
      # ".config/" = {
      #   source = (symlink /${dotfiles}/config);
      #   recursive = true;
      # };

      # ".config/home-manager" = {
      #   source = (symlink /${dotfiles}/config/home-manager);
      #   recursive = true;
      # };

      # ".config/hypr" = {
      #   source = (symlink /${dotfiles}/config/hypr);
      #   recursive = true;
      # };

      ".config/swaylock" = {
        source = (symlink /${dotfiles}/config/swaylock);
        recursive = true;
      };

      ".config/cava" = {
        source = (symlink /${dotfiles}/config/cava);
        recursive = true;
      };

      ".config/conky" = {
        source = (symlink /${dotfiles}/config/conky);
        recursive = true;
      };

      # Fish functions
      ".config/fish/functions" = {
        source = (symlink /${dotfiles}/config/fish/functions);
        recursive = true;
      };

      # Fish completions
      ".config/fish/completions" = {
        source = (symlink /${dotfiles}/config/fish/completions);
        recursive = true;
      };

      ".config/i3" = {
        source = (symlink /${dotfiles}/config/i3);
        recursive = true;
      };

      ".config/ime" = {
        source = (symlink /${dotfiles}/config/ime);
        recursive = true;
      };

      ".config/kitty" = {
        source = (symlink /${dotfiles}/config/kitty);
        recursive = true;
      };

      # ".config/kitty/kitty.conf" = {
      #   source = pkgs.substituteAll {
      #     name = "kitty_themes";
      #     kitty_themes = "${inputs.catppuccin-kitty}/themes";
      #     src = /${dotfiles}/config/kitty/kitty.conf;
      #   }; 
      # };

      ".config/lazygit" = {
        source = (symlink /${dotfiles}/config/lazygit);
        recursive = true;
      };

      ".config/libskk" = {
        source = (symlink /${dotfiles}/config/libskk);
        recursive = true;
      };

      ".config/nvim" = {
        source = (symlink /${dotfiles}/config/nvim);
        recursive = true;
      };

      ".config/sway" = {
        source = (symlink /${dotfiles}/config/sway);
        recursive = true;
      };

      ".config/waybar" = {
        source = (symlink /${dotfiles}/config/waybar);
        recursive = true;
      };

      ".config/wezterm" = {
        source = (symlink /${dotfiles}/config/wezterm);
        recursive = true;
      };

      ".config/rofi" = {
        source = (symlink /${dotfiles}/config/rofi);
        # source = ;
        recursive = true;
      };

      ".config/bat" = {
        source = (symlink /${dotfiles}/config/bat);
        recursive = true;
      };

      ".config/swaync" = {
        source = (symlink /${dotfiles}/config/swaync);
        recursive = true;
      };

      # Vim configs.
      ".config/vim" = {
        source = (symlink /${dotfiles}/config/vim);
        recursive = true;
      };

      ".czrc".source = (symlink /${dotfiles}/czrc);
      ".nirc".source = (symlink /${dotfiles}/nirc);
      ".zshrc".source = (symlink /${dotfiles}/zshrc);
      # TODO: `~/.config/vsnip`に移動する。
      ".vsnip".source = (symlink /${dotfiles}/vsnip);
      ".gitconfig".source = (symlink /${dotfiles}/gitconfig);
      ".Xmodmap".source = (symlink /${dotfiles}/Xmodmap);
      ".tmux.conf".source = (symlink /${dotfiles}/tmux.conf);

      ".emacs.d" = {
        source = (symlink /${dotfiles}/emacs.d);
        recursive = true;
      };
      ".skk".source = (symlink /${dotfiles}/ddskk-config.el);
    };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/coma/etc/profile.d/hm-session-vars.sh

  home.sessionVariables = {
    # EDITOR = "nvim";
    XDG_CONFIG_HOME = "${home.homeDirectory}/.config";
  };

  # programs.neovim.package = pkgs.neovim;
  # programs.neovim.enable = true;

  # neovim-nightly
  # programs.neovim = {
  #   enable = true;
  #   package = inputs.programs.neovim.packages.${pkgs.system}.default;
  # };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Hyprland
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = import ./hyprland.nix {
    inherit
      pkgs
      wallpaper
      home
      config
      ;
  };
  wayland.windowManager.hyprland.catppuccin.enable = true;

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fish = import ./fish.nix { inherit pkgs; };
    hyprlock.settings = import ./hyprlock.nix { inherit wallpaper; };
    hyprlock.enable = true;
  };

  programs.foot = {
    enable = true;
    catppuccin.enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "UDEV Gothic NFLG:size=12.5";
        dpi-aware = "yes";
      };
    };
  };

  services.emacs = {
    enable = true;
    # package = pkgs.emacsGit;
    package = (
      with pkgs;
      # ((emacsPackagesFor emacs').emacsWithPackages (
      ((emacsPackagesFor emacsGit).emacsWithPackages (
        epkgs: with epkgs; [
          vterm
        ]
      ))
    );
    # extraOptions = [ "--with-xwidgets" ];
  }; 

  # services.gpg-agent = {
  #   enable = true;
  # };

  # programs.lem-editor.enable = true 
}
