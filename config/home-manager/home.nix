{ config, pkgs, overlays, inputs, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
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

    # ========== TERMINAL ========== 

    # kitty now can't work. see https://github.com/NixOS/nixpkgs/issues/290847.

    # ========== EDITOR & TOOLS ========== 
    vim-full
    emacs
    felix
    micro
    # visual-studio-code-bin
    # inputs.lem-editor.packages.x86_64-linux.lem-ncurses

    metals
    meson


    tig

    # ========== OTHER TOOLS ========== 
    cava
    lsd
    bat

    slack

    # textimg
    teip
    # textql-git

    tokei
    tree
    unar


    # ========== SHELL ========== 
    fish

    # ========== BROWSER ========== 
    # firefox
    # google-chrome

    # ========== SECURITY TOOLS ========== 
    keybase
    lssecret

    # ========== RUNTIME & COMPILER ========== 
    deno
    sbcl

    # swift ==> Flake

    # ========== FONTS ========== 
    noto-fonts
    noto-fonts-cjk
    # ttf-udev-gothic


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

    boost
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

    fcitx5
    fcitx5-configtool
    fcitx5-gtk
    fcitx5-skk
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
    jnv
    jq
    jwt-cli
    k6

    # kvantum

    lazydocker
    lazygit
    leiningen
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
    rcm
    re2c
    redis
    reiserfsprogs
    ripgrep

    # riscv-gnu-toolchain-bin
    
    rlwrap
    rofi-power-menu
    roswell

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
    wezterm
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
    hyprlock
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
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
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
    EDITOR = "nvim";
  };

  programs.neovim.package = pkgs.neovim;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.neovim.enable = true;
  # programs.lem-editor.enable = true 

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    monitor = [ ",preferred,auto,auto" ];

    env = [
      "XCURSOR_SIZE,32"
      "GDK_SCALE,2"
      # "HYPRCURSOR_THEME,MyCursor"
      "HYPRCURSOR_SIZE,25"
      "XCURSOR_SIZE,24"
      "QT_QPA_PLATFORMTHEME,qt5ct"
    ];

    # "$terminal" = "\"${pkgs.kitty}\"";
    "$terminal" = "kitty";

    "$browser" = "firefox";
    "$fileManager" = "thunar";
    # "$menu" = "${pkgs.rofi} -show drun";
    "$menu" = "rofi -show drun";
    input = {
      kb_layout = "jp";
      #  kb_variant = "";
      #  kb_model = "";
      #  kb_options = "";
      #  kb_rules = "";

      follow_mouse = "0";
      mouse_refocus = false;

      touchpad = {
          natural_scroll = true;
      };

      sensitivity = 0; # -1.0 to 1.0, 0 means no modification.
    };

    xwayland = {
      force_zero_scaling = true;
    };

    general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
    };

    decoration = {
        rounding = 10;

        blur = {
            enabled = true;
            size = 3;
            passes = 1;
        };
        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
    };

    animations = {
      enabled = "yes";
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };

    # Hyprland Plugins
    plugin = {
      hyprfocus = {
        enabled = "yes";
        animate_floating = "yes";
        animate_workspacechange = "yes";
        focus_animation = "shrink";
        # # Beziers for focus animations
        # bezier = bezIn, 0.5,0.0,1.0,0.5
        # bezier = bezOut, 0.0,0.5,0.5,1.0
        # bezier = overshot, 0.05, 0.9, 0.1, 1.05
        # bezier = smoothOut, 0.36, 0, 0.66, -0.56
        # bezier = smoothIn, 0.25, 1, 0.5, 1
        # bezier = realsmooth, 0.28,0.29,.69,1.08

        # Flash settings
        # flash {
        #     flash_opacity = 0.95
        #     in_bezier = realsmooth
        #     in_speed = 0.5
        #     out_bezier = realsmooth
        #     out_speed = 3
        # }

        # Shrink settings
        shrink = {
            shrink_percentage = 0.95;
            in_bezier = "realsmooth";
            in_speed = 1;
            out_bezier = "realsmooth";
            out_speed = 2;
        };
      };
    };

    dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

    # master {
    #     # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    #     new_is_master = true
    # }

    gestures = {
        workspace_swipe = "off";
    };

    misc = {
        force_default_wallpaper = -1;
    };

    # Example per-device config
    # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
    device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
    };

    # Example windowrule v1
    # windowrule = float, ^(kitty)$
    # Example windowrule v2
    # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
    # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

    windowrule = [
     "float,^(Floaterm)$"
     "size 25% 30%,^(Floaterm)$"
     "move 60% 60%,^(Floaterm)$"
    ];

    windowrulev2 = [
      "float,class:^(firefox),title:^(ピクチャーインピクチャー)"
      "pin,class:^(firefox),title:^(ピクチャーインピクチャー)"
      "suppressevent maximize, class:.*"
    ];


    # See https://wiki.hyprland.org/Configuring/Keywords/ for more
    # $mainMod = SUPER
    "$mainMod" = "Alt";

    bind = [ 
      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      "$mainMod, Return, exec, $terminal"
      "$mainMod, q, killactive,"
      # bind = $mainMod, m, exit, 
      "$mainMod, e, exec, $fileManager"
      "$mainMod, f, togglefloating,"
      "$mainMod, f, pin,"
      "$mainMod, space, exec, $menu"
      # bind = $mainMod, P, pseudo, # dwindle
      "$mainMod, J, togglesplit," # dwindle
      "$mainMod, b, exec, $browser"

      # Move focus with mainMod + arrow keys
      "$mainMod, h, movefocus, l"
      "$mainMod, l, movefocus, r"
      "$mainMod, k, movefocus, u"
      "$mainMod, j, movefocus, d"

      # bind = $mainMod, g, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$mainMod SHIFT, 1, focusworkspaceoncurrentmonitor, 1"
      "$mainMod SHIFT, 2, focusworkspaceoncurrentmonitor, 2"
      "$mainMod SHIFT, 3, focusworkspaceoncurrentmonitor, 3"
      "$mainMod SHIFT, 4, focusworkspaceoncurrentmonitor, 4"
      "$mainMod SHIFT, 5, focusworkspaceoncurrentmonitor, 5"
      "$mainMod SHIFT, 6, focusworkspaceoncurrentmonitor, 6"
      "$mainMod SHIFT, 7, focusworkspaceoncurrentmonitor, 7"
      "$mainMod SHIFT, 8, focusworkspaceoncurrentmonitor, 8"
      "$mainMod SHIFT, 9, focusworkspaceoncurrentmonitor, 9"
      "$mainMod SHIFT, 0, focusworkspaceoncurrentmonitor, 10"

      # Example special workspace (scratchpad)
      "$mainMod, w, togglespecialworkspace, magic"
      "$mainMod SHIFT, w, movetoworkspace, special:magic"

      "$mainMod, p, workspace, +1, focuswindow"
      "$mainMod, n, workspace, -1, focuswindow"

      "$mainMod SHIFT, p, movetoworkspace, +1"
      "$mainMod SHIFT, n, movetoworkspace, -1"

      "$mainMod SHIFT, l, movewindow, r"
      "$mainMod SHIFT, h, movewindow, l"

      # Change window size
      "$mainMod ctrl, l, resizeactive, 100 100"
      "$mainMod ctrl, h, resizeactive, -100 100"

      # Screenshot
      "$mainMod SHIFT, s, exec, slurp | grim -g - - | wl-copy"
      # Take screenshot active window
      ",Print, exec, hyprctl -j activewindow | jq -r '\"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])\"' | grim -g - - | wl-copy"
      # Take screenshot active monitor
      "$mainMod, s, exec, hyprctl -j activeworkspace | jq -r '(.monitor)' | xargs -i grim -o {} -- - | wl-copy"

      # Screen lock
      "Super SHIFT, l, exec, hyprlock"

      # bind = Print, exec, slurp | grim -g - - | wl-cop

      # Vim as as IME
      "$mainMod, code:34, exec, ime.sh float"
    ];

    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    exec-once = [
      "waybar"
      "fcitx5"
      "conky"
      "swaync"
      "playerctld daemon"
      "swaybg -i ~/Pictures/wallpaper/wallpaper-1.jpg"
    ];
  };
}
