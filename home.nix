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
          python313FreeThreading
          python313Packages.cairosvg
          python313Packages.pillow
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
    hash = "sha256-+bzNCqGOnVkpgvTdpWfcRtVfHQO2pX1/nYgluMA7VYo";
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

  # emacs' = (pkgs.emacsPackagesFor pkgs.emacs-unstable).emacsWithPackages (
  # emacs' = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (
  emacs' = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages (
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
    age.keyFile = "${home.homeDirectory}/.config/sops/age/keys.txt";
    # age.keyFile = "/home/coma/.config/sops/age/keys.txt";
    # # It's also possible to use a ssh key, but only when it has no password:
    # # age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
    defaultSopsFile = ./secrets/secrets.yaml;
    secrets = {
      "spotify-password" = {
        path = "${home.homeDirectory}/.secrets/spotify-password";
      };
      "claude-code" = {
        sopsFile = ./secrets/claude-code.env;
        path = "${home.homeDirectory}/.secrets/claude-code.env";
        format = "dotenv";
      };
    };
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
  # environment. Packages are now organized in ./packages/ directory.
  home.packages =
    (import ./packages/development.nix { inherit pkgs; })
    ++ (import ./packages/editors.nix { inherit pkgs emacs' nurpkgs; })
    ++ (import ./packages/terminal.nix { inherit pkgs; })
    ++ (import ./packages/utilities.nix { inherit pkgs; })
    ++ (import ./packages/gui-apps.nix { inherit pkgs nurpkgs; })
    ++ (import ./packages/system.nix { inherit pkgs; })
    ++ (import ./packages/git.nix { inherit pkgs; })
    ++ (import ./packages/security.nix { inherit pkgs; })
    ++ (import ./packages/wayland.nix { inherit pkgs; })
    ++ (import ./packages/fonts.nix { inherit pkgs; })
    ++ (import ./packages/misc.nix { inherit pkgs nurpkgs; })
    ++ (with pkgs; [
      # Additional packages
      nodePackages."@antfu/ni"
      asar
      nak
      vim-startuptime
      spotify

      # NOTE: 2025/06/22 hashまわりで壊れたので一旦無効化
      # (import ./pkgs/lspx { inherit pkgs; })
    ]);

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
            ]
            ++ ts.withAllGrammars.dependencies;
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
      ".bin/scripts/life" = {
        source = (symlink /${dotfiles}/bin/scripts/life);
        recursive = true;
      };
      ".bin/scripts/ghq-attach" = {
        source = (symlink /${dotfiles}/bin/scripts/ghq-attach);
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

      # ".spell-dict/programming-english-dict".source =
      #   "${nurpkgs.programming-english}/share/dict/programming-english-dict";
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

      ".secrets/.keep" = {
        text = "";
      };

      ".emacs.d" = {
        source = (symlink /${dotfiles}/emacs.d);
        recursive = true;
      };
      # ".local/share/tree-sitter".source = (symlink "${pkgs.tree-sitter-grammars}/lib");
      ".data/gitmoji.json".source = (symlink gitmoji);
      ".skk".source = (symlink /${dotfiles}/ddskk-config.el);
      "Pictures/wallpapers".source = (symlink wallpapers);
      "Pictures/.emacs-logos".source = (symlink "${emacs_fancy_logo}/share");
      ".aider.conf.yml".source = (pkgs.formats.yaml { }).generate ".aider.conf.yml" {
        read = [
          "CONVENTIONS.md"
          "CONTRIBUTION.md"
          "README.md"
          ".aiderrules"
        ];
      };
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

    # Enable native Wayland support for Electron/Chromium apps
    # Affects: Signal, Slack, Discord, Teams, Chrome, etc.
    NIXOS_OZONE_WL = "1";
  };

  # Systemd user session variables
  # Make Wayland environment available to systemd services like Emacs daemon
  systemd.user.sessionVariables = {
    # Wayland display - required for GUI applications
    WAYLAND_DISPLAY = "wayland-1";

    # Enable Wayland support for Electron/Chromium apps in services
    NIXOS_OZONE_WL = "1";

    # Runtime directory (usually already set, but explicit for clarity)
    XDG_RUNTIME_DIR = "/run/user/1000";
  };

  # PATH management centralized here to avoid duplications
  home.sessionPath = [
    "$HOME/.cabal/bin"
    "$HOME/.bun/bin"
    "$HOME/.rbenv/shims"
    "$HOME/.rbenv/bin"
    "$HOME/.deno/bin"
    "$HOME/.bin"
    "$HOME/.bin/scripts/life"
    "$HOME/.bin/scripts/ime"
    "$HOME/.bin/scripts/ghq-attach"
    "$HOME/.npm-global/bin"
    "$HOME/go/bin"
    "$HOME/.local/bin"
    "$HOME/.local/share"
    "$HOME/.nimble/bin"
    "$HOME/.nimble/pkgs"
    "$HOME/.local/share/pnpm"
    "$HOME/.luarocks/bin"
    "$HOME/.cargo/bin"
    "$HOME/.pub-cache/bin"
    "$HOME/.ghcup/bin"
  ];

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

  # systemd.user.services.claude-code-provider-proxy = {
  # Unit = {
  #   Description = "Claude Code Provider Proxy";
  #   After = [ "network.target" ];
  # };

  # Service = {
  #   Type = "simple";
  #   WorkingDirectory = "/home/coma/.ghq/github.com/ujisati/claude-code-provider-proxy";
  #   ExecStart = "${pkgs.python3Packages.uv}/bin/uv run src/main.py";
  #   Restart = "on-failure";
  #   RestartSec = 10;
  # EnvironmentFile ="${home.homeDirectory}/.secrets/claude-code.env";
  # };

  # Install = {
  #   WantedBy = [ "default.target" ];
  # };
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

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 13.5;
      };
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
    };
  };

  programs = {
    dank-material-shell.enable = true;
  };

  services.spotifyd = {
    enable = true;
    settings = {
      username = "31tkpkdg2lkjahtnnj4es4l2fs6q";
      password_cmd = "cat ${config.sops.secrets.spotify-password.path}";
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
    alacritty.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
  };

  # programs.lem-editor.enable = true
}
