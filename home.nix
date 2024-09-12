{
  config,
  pkgs,
  overlays,
  inputs,
  ...
}:

rec {
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-29.4.6"
    ];
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

    # theme 
    catppuccin

    # Nix
    nixVersions.nix_2_23

    # ========== NIXGL ========== 
    # nixgl.nixGLIntel

    # ========== TERMINAL ========== 
    wezterm
    alacritty
    kitty

    # ========== EDITOR & TOOLS ========== 
    vim-full
    emacs
    felix
    micro
    neovim
    # visual-studio-code-bin
    # inputs.lem-editor.packages.x86_64-linux.lem-ncurses

    metals
    meson
    leiningen

    tig

    # ========== OTHER TOOLS ========== 
    # textimg
    # textql-git
    cachix

    ghq
    cava
    lsd
    bat
    jnv
    jq

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
    fish

    # ========== BROWSER ========== 
    # firefox
    # google-chrome

    # ========== SECURITY TOOLS ========== 
    keybase
    lssecret
    gnupg

    # ========== RUNTIME & COMPILER ========== 
    deno
    nodejs
    bun

    pnpm

    gleam

    sbcl
    ruby
    # ref: https://cons.io/
    gerbil

    # roswell

    # swift ==> Flake

    # ========== FONTS ========== 
    noto-fonts
    noto-fonts-cjk
    # ttf-udev-gothic

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
    cava
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
    # hyprland
    # hyprlock
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
      dotfilesRoot = /${home.homeDirectory}/.ghq/github.com/Comamoca/dotfiles;
      dotfiles = /${dotfilesRoot}/dotfiles;
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
      ".bin/scripts/shift" = {
        source = (symlink /${dotfiles}/bin/scripts/shift);
        recursive = true;
      };

      # Vim configs.
      ".vimrc".source = (symlink /${dotfiles}/vimrc);
      ".vim" = {
        source = (symlink /${dotfiles}/vim);
        recursive = true;
      };
      # # ========== SKK ========== 
      # skk-dicts
      ".skk/SKK-JISYO.L".source = "${pkgs.skk-dicts}/share/SKK-JISYO.L";

      # TODO: 後で消す
      # ".config/" = {
      #   source = (symlink /${dotfiles}/config);
      #   recursive = true;
      # };

      ".config/home-manager" = {
        source = (symlink /${dotfiles}/config/home-manager);
        recursive = true;
      };

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

      ".config/fish" = {
        source = (symlink /${dotfiles}/config/fish);
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

      ".config/emacs" = {
        source = (symlink /${dotfiles}/config/emacs);
        recursive = true;
      };

      ".czrc".source = (symlink /${dotfiles}/czrc);
      ".nirc".source = (symlink /${dotfiles}/nirc);
      ".zshrc".source = (symlink /${dotfiles}/zshrc);
      # TODO: `~/.config/vsnip`に移動する。
      ".vsnip".source = (symlink /${dotfiles}/vsnip);
      ".gitconfig".source = (symlink /${dotfiles}/gitconfig);
      ".Xmodmap".source = (symlink /${dotfiles}/Xmodmap);
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

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = import ./hyprland.nix { inherit pkgs; };
  # programs.lem-editor.enable = true 
}
