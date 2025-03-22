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

  generated = import ./_sources/generated.nix;
  sources = generated {
    inherit (pkgs)
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };

  xremap-config = import ./xremap.nix { inherit pkgs; };

  batch =
    pkgs.writers.writePython3Bin "convert_and_resize"
      {
        libraries = with pkgs; [
          python312Full
          python312Packages.cairosvg
          python312Packages.pillow
        ];
      }
      ''
        import pathlib
        from PIL import Image
        import cairosvg


        def convert_and_resize(
            svg_path: pathlib.Path, png_path: pathlib.Path, scale: float = 0.5
        ):
            png_data = cairosvg.svg2png(url=str(svg_path))

            png_path.write_bytes(png_data)

            with Image.open(png_path) as img:
                new_size = (int(img.width * scale), int(img.height * scale))
                resized_img = img.resize(new_size, Image.LANCZOS)
                resized_img.save(png_path)


        current_dir = pathlib.Path()
        for svg_file in current_dir.glob("*.svg"):
            png_file = svg_file.with_stem(
                svg_file.stem + "_resize").with_suffix(".png")
            convert_and_resize(svg_file, png_file)
      '';

  emacs_fancy_logo = pkgs.stdenv.mkDerivation rec {
    name = "emacs_fancy_logos";
    src = sources.emacs_fancy_logos.src;
    # nativeBuildInputs = [ batch ];
    buildPhase = ''
      ${batch}/bin/convert_and_resize
    '';

    installPhase = ''
      mkdir -p $out/share/
      cp -r * $out/share/
    '';
  };

  wallpapers = builtins.fetchTarball {
    url = "https://github.com/zhichaoh/catppuccin-wallpapers/archive/refs/heads/main.zip";
    sha256 = "sha256:0rd6hfd88bsprjg68saxxlgf2c2lv1ldyr6a8i7m4lgg6nahbrw7";
  };

  wallpaper = "${wallpapers}/misc/cat-sound.png";

  gitmoji = pkgs.fetchurl {
    url = "https://gitmoji.dev/api/gitmojis";
    hash = "sha256-deIjmV/50HY0PwVtlQzaXBOQhug4wEQAr5RD1JK2G/4=";
  };

  # pgtkでビルドするとエラーこそ出ないものの有効にならない
  # Gitでビルドするとwebkitがない旨のエラーが出る
  # emacs' = pkgs.emacs-pgtk.overrideAttrs (old: {
  # emacs' = pkgs.emacs-git.overrideAttrs (old: {
  #   # configureFlags = old.configureFlags or [] ++ [ "--with-cairo" "--with-xwidgets" "--with-x-toolkit=gtk3" ];
  #   withXwidgets = true;
  #   withGTK3 = true;
  #   # buildInputs = (old.buildInputs or []) ++ [
  #   #   pkgs.webkitgtk_4_0
  #   # ];
  # });

  emacs' = (pkgs.emacsPackagesFor pkgs.emacs-unstable).emacsWithPackages (
    epkgs: (import ./emacs.nix { inherit pkgs epkgs nurpkgs; }).epkgs
  );

  sbcl' = pkgs.sbcl.withPackages (
    ps: with ps; [
      slite
      slynk
    ]
  );
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

  # systemd.user.services.mbsync.Unit.After = [ "sops-nix.service" ];

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

    immersed

    # home-manager

    comma

    # Knowledge tool for terminal
    nb
    w3m

    # theme
    # catppuccin

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
    # ghostty

    # ========== EDITOR & TOOLS ==========
    # Game
    godot

    # For Emacs
    emacs-lsp-booster

    cmigemo
    wakatime-cli

    tree-sitter
    arduino

    # TODO: change to vim-overlay
    vim-full
    emacs'
    felix
    micro
    neovim

    # NOTE: 2024/12/31 アプデしたらビルドできなくなった
    # jetbrains.idea-community

    # visual-studio-code-bin
    # inputs.lem.packages.x86_64-linux.lem-ncurses
    # inputs.lem.packages.x86_64-linux.lem-sdl2

    meson

    tig

    just

    # ========== SOCIAL NET ==========
    nurpkgs.bsky

    # ========== OTHER TOOLS ==========
    jless
    gitify
    algia
    polybarFull
    devenv

    libnotify

    zf
    jo

    signal-desktop

    # Show key stroke
    showmethekey

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

    # Teams for linux is depends to Electron-29 but EOL.
    # teams-for-linux

    teip

    tokei
    tree
    unar
    k6

    # esp32
    # easyeffects
    # espup
    # espflash
    # esptool
    # cargo-espmonitor
    # mkspiffs-presets.esp-idf

    # ========== SHELL ==========
    # Because duplicate binary name to ni.
    # nushell

    # ========== BROWSER ==========
    # firefox
    google-chrome

    # ========== SECURITY TOOLS ==========
    keybase
    lssecret

    # gnupg
    # pinentry-curses
    # pinentry-gnome3
    pinentry-qt
    # pinentry-rofi
    # pinentry-gtk2
    # (pkgs.lib.hiPrio pinentry-emacs)
    # (pkgs.lib.hiPrio pkgs.pinentry-gnome3)

    # ========== LANGUAGE SERVER ==========
    # lua-language-server
    # vim-language-server
    # typescript-language-server
    # efm-langserver
    # marksman
    # tailwindcss-language-server

    # ========== RUNTIME & COMPILER ==========
    vlang

    clojure
    babashka
    # clasp-common-lisp

    # ref: https://cons.io/
    # NOTE: 2024/12/30 アプデしたらビルドできなくなった
    # gerbil
    # gambit

    # erlang_27
    # rebar3

    deno
    nodejs_22
    bun

    # pnpm

    # gleam

    # Common Lisp
    # sbcl'
    # roswell
    # sbclPackages.qlot-cli

    ruby

    # roswell

    # swift ==> Flake

    # ========== FONTS ==========
    noto-fonts
    noto-fonts-cjk-sans
    # ttf-udev-gothic

    # ========== Writing ==========
    # textlint
    # textlint-rule-preset-ja-technical-writing

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

    # base
    # base-devel

    bison
    # NOTE 2/13 ビルドできなくなった
    # bitwarden-cli

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
    # gfortran9

    gd
    github-cli
    glava

    # glibcLocales

    glow
    gnome-epub-thumbnailer
    gnome-keyring
    # go
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

    # linux61

    # logrotate

    # luarocks
    lvm2
    # ly
    # gnumake
    man-db
    man-pages

    # mdadm
    mediainfo

    # memtest86plus
    # memtest86-efi

    # mesa-vdpau
    # mhwd
    # mhwd-db

    # mkinitcpio-openswap

    # nfs-utils

    # NOTE: 2024/12/30 アプデしたらビルドできなくなった
    # mplayer

    # multilib-devel
    # ncurses5-compat-libs

    # network-manager-applet
    # networkmanager

    # nss-mdns

    # ntfs-3g

    # oh-my-zsh

    # openssh-askpass

    # opusfile
    # os-prober
    p7zip

    pass
    patch
    pavucontrol

    # perl
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
    # redis
    reiserfsprogs
    ripgrep

    # riscv-gnu-toolchain-bin

    rlwrap
    rofi-power-menu

    rsync

    # samurai
    sd

    # NOTE: 2024/12/31 アプデしたらビルドできなくなった
    shotcut

    siege

    slurp
    # sof-firmware
    # spectre-meltdown-checker

    spotify
    # spotify-tui

    squashfsTools

    starship
    # sudo

    # super_unko-git

    # swaycwd
    # swaylock-effects

    swaybg
    swaynotificationcenter
    swaylock

    # sworkstyle

    # swww
    # sysfsutils
    # systemd

    # taglib1
    # teams-for-linux

    texinfo

    xfce.thunar

    # timeshift-autosnap-manjaro

    usbutils
    # NOTE: 2024/12/30 アプデしたらビルドできなくなった
    # uucp

    # v4l2loopback-dkms

    vhs
    vlc

    # vulkan-intel
    # vulkan-radeon

    # way-displays
    # waypaper
    # wdisplays

    wev
    wf-recorder
    wget
    which
    wireless-regdb
    wl-clipboard
    wlay
    wlsunset
    wofi
    fuzzel
    wpa_supplicant

    # ========== OTHER TOOLS ==========
    # For org-roam
    sqlite
    graphviz

    # For Emacs markdown-mode
    multimarkdown
    wakatime

    # hyprland
    # hyprlock
    hyperfine

    # hyprpaper
    # hyprshade

    # wqy-microhei
    # wxwidgets-gtk3
    # xclip

    # xdg-desktop-portal-wlr
    xdg-user-dirs

    xremap

    # xf86-video-amdgpu
    # xf86-video-ati
    # xf86-video-intel
    # xf86-video-nouveau
    # xfsprogs

    # xorg-xwayland
    # xsv
    yq

    # zeit
    # zeitgeist
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
      base = ".cache/dpp/_generated";
    in
    {
      "${base}/nvim-treesitter" =
        let
          ts = pkgs.vimPlugins.nvim-treesitter;
        in
        {
          source = pkgs.symlinkJoin {
            name = "ts-all";
            paths = [
              ts
            ] ++ ts.withAllGrammars.dependencies;
          };
        };
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
      ".skk-dict/SKK-JISYO.im@sparql.all.utf8".source =
        "${nurpkgs.skk-jisyo-imasparql}/share/SKK-JISYO.im@sparql.all.utf8";

      ".migemo/utf-8/migemo-dict".source = "${pkgs.cmigemo}/share/migemo/utf-8";

      ".spell-dict/programming-english-dict".source =
        "${nurpkgs.programming-english}/share/dict/programming-english-dict";
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

      ".config/niri" = {
        source = (symlink /${dotfiles}/config/niri);
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

      # ".config/bat" = {
      #   source = (symlink /${dotfiles}/config/bat);
      #   recursive = true;
      # };

      ".config/swaync" = {
        source = (symlink /${dotfiles}/config/swaync);
        recursive = true;
      };

      # Vim configs.
      ".config/vim" = {
        source = (symlink /${dotfiles}/config/vim);
        recursive = true;
      };

      ".config/xremap/config.yaml".source = (symlink xremap-config.xremap-config-yaml);

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
      # ".local/share/tree-sitter".source = (symlink "${pkgs.tree-sitter-grammars}/lib");
      ".data/gitmoji.json".source = (symlink gitmoji);
      ".skk".source = (symlink /${dotfiles}/ddskk-config.el);
      "Pictures/wallpapers".source = (symlink wallpapers);
      "Pictures/.emacs-logos".source = (symlink "${emacs_fancy_logo}/share");
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
    # SECRET = sops.secrets.spotify.spotify_secret;
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
  # wayland.windowManager.hyprland.enable = true;
  # wayland.windowManager.hyprland.settings = import ./hyprland.nix {
  #   inherit
  #     pkgs
  #     wallpaper
  #     home
  #     config
  #     ;
  # };

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
    settings = {
      main = {
        term = "xterm-256color";
        font = "UDEV Gothic NFLG:size=12.5";
        dpi-aware = "yes";
      };
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
    };
  };

  services.emacs = {
    enable = true;
    # package = pkgs.emacs-git;
    package = emacs';
    # package = (
    #   with pkgs;
    #   # ((emacsPackagesFor emacs').emacsWithPackages (
    #   ((emacsPackagesFor emacs-git).emacsWithPackages (
    #     epkgs: (import ./emacs.nix { inherit pkgs epkgs; }).epkgs
    #   ))
    # );
    # extraOptions = [ "--with-xwidgets" ];
  };

  catppuccin = {
    hyprland.enable = true;
    foot.enable = true;
    bat.enable = true;
    sway.enable = true;
  };

  # services.gpg-agent = {
  #   enable = true;
  # };

  # programs.lem-editor.enable = true
}
