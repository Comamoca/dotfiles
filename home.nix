{
  config,
  pkgs,
  overlays,
  inputs,
  lib,
  ...
}:
let
  username = "coma";
  homeDirectory = "/home/${username}";
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

  programming-english = pkgs.fetchFromGitHub {
    owner = "MatsumotoDesuyo";
    repo = "programming-english";
    rev = "main";
    hash = "sha256-PZRJqDMfy4F92i10jeUY0R5P45YYBvEB3hm55dSbubo=";
  };

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
    hash = "sha256-KrK2YWthwkuNalREJ+X4B/z6W3CFzfsP+ptqg3tfuIc=";
  };

  emacs' = (pkgs.emacsPackagesFor pkgs.emacs-git-pgtk).emacsWithPackages (
    epkgs: let
      # projectile 20260627+ ships projectile-consult.el which hard-requires
      # consult at compile time, but the MELPA recipe only declares (emacs compat).
      # Override at the scope level so all dependents benefit.
      epkgs' = epkgs.overrideScope (eself: esuper: {
        projectile = esuper.projectile.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ eself.consult ];
          propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [ eself.consult ];
          # projectile-consult.el does (require 'consult) at top-level, which
          # fails during elpa2nix byte-compilation because the elpa directory
          # isn't populated yet. Patch it to handle the missing dependency
          # gracefully — consult is still picked up at runtime via
          # propagatedBuildInputs.
          postPatch = (old.postPatch or "") + ''
            if [ -f "projectile-consult.el" ]; then
              sed -i "s/(require 'consult)/(condition-case nil (require 'consult) (error nil))/" projectile-consult.el
            fi
          '';
        });
      });
    in (import ./emacs.nix { inherit pkgs; epkgs = epkgs'; inherit nurpkgs; }).packages
  );

  # 名前付き Emacs daemon 用の起動スクリプト
  # systemd テンプレートユニットから %I でインスタンス名を受け取り、
  # 対応する名前付きデーモンを起動する。
  # Usage: emacs-daemon <name>
  #   ソケット: /run/user/1000/emacs/server_{name}
  #   init directory: /tmp/emacsd-{name}
  emacs-daemon-script = pkgs.writeShellScript "emacs-daemon" ''
    NAME="''${1:-main}"
    INIT_DIR="/tmp/emacsd-''${NAME}"
    mkdir -p "$INIT_DIR"
    exec ${emacs'}/bin/emacs --fg-daemon="''${NAME}" \
      --init-directory="$INIT_DIR" \
      --eval "(load \"$HOME/.emacs.d/init-loader.el\")"
  '';

  sbcl' = pkgs.sbcl.withPackages (
    ps: with ps; [
      slite
      slynk
    ]
  );

  rclone-sync = import ./pkgs/rclone_sync { inherit pkgs homeDirectory; };
  rclone-resync = import ./pkgs/rclone_resync { inherit pkgs homeDirectory; };
  niri-scratchpad = import ./pkgs/niri-scratchpad { inherit pkgs; };

  # eqsh (一時的に無効化)
  # eqsh-src = inputs.eqsh;

  # Combined derivation of all tree-sitter grammars from nixpkgs.
  # Each grammar is symlinked as libtree-sitter-{name}.so so emacs can find it.
  # Some grammars are lists of derivations, handle both cases.
  emacs-ts-grammars = pkgs.runCommand "emacs-tree-sitter-grammars" { } (
    let
      grammars = lib.filterAttrs (n: v: n != "recurseForDerivations") pkgs.tree-sitter-grammars;
      mkLink = name: grammar:
        if builtins.isList grammar then
          lib.imap0 (i: g: "ln -s ${g}/parser \"$out/libtree-sitter-${name}-${toString i}.so\"") grammar
        else
          [ "ln -s ${grammar}/parser \"$out/libtree-sitter-${name}.so\"" ];
      links = lib.concatLists (lib.mapAttrsToList mkLink grammars);
    in ''
      mkdir -p $out
      ${lib.concatStringsSep "\n" links}
    ''
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
  home = {
    inherit username homeDirectory;
  };

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
      ni
      asar
      nak
      vim-startuptime
      spotify
      input-remapper # Wacom ペンボタンをマウス化

      # NOTE: 2025/06/22 hashまわりで壊れたので一旦無効化
      # (import ./pkgs/lspx { inherit pkgs; })
      rclone-sync
      rclone-resync
    ])
    ++ [ emacs' ];

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
      # astro-language-server が要求する typescript.tsdk を安定したパスに配置
      ".cache/nvim-lsp/typescript" = {
        source = "${pkgs.typescript}/lib/node_modules/typescript/lib";
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
      ".bin/scripts/browser-focus.sh" = {
        source = (symlink /${dotfiles}/bin/scripts/browser-focus.sh);
      };
      ".bin/scripts/browser-focus-niri.sh" = {
        source = (symlink /${dotfiles}/bin/scripts/browser-focus-niri.sh);
      };
      ".bin/scripts/niri-window-switch.sh" = {
        source = (symlink /${dotfiles}/bin/scripts/niri-window-switch.sh);
      };
      ".bin/scripts/niri-workspace-layout.sh" = {
        source = (symlink /${dotfiles}/bin/scripts/niri-workspace-layout.sh);
      };
      ".bin/scripts/flake-lock-save" = {
        source = (symlink /${dotfiles}/bin/scripts/flake-lock-save);
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
      # Removed: programming-english-dict (file doesn't exist in repo structure)
      # ".spell-dict/programming-english-dict".source =
      #   "${programming-english}/share/dict/programming-english-dict";

      ".migemo/utf-8/migemo-dict".source = "${pkgs.cmigemo}/share/migemo/utf-8";

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
      # eqsh (一時的に無効化)
      # ".local/share/equora" = {
      #   source = "${eqsh-src}";
      #   recursive = true;
      # };

      # eqsh Catppuccin Mocha config (一時的に無効化)
      # ".config/aureli/config.json".text = builtins.toJSON {
      #   general = {
      #     darkMode = true;
      #     language = "ja";
      #   };
      #   ... (catppuccin config, 全てコメントアウト)
      # };

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

      ".config/rclone" = {
        source = (symlink /${dotfiles}/config/rclone);
        recursive = true;
      };

      ".config/yazi" = {
        source = (symlink /${dotfiles}/config/yazi);
        recursive = true;
      };

      ".config/opencode/tui.json".source = (symlink /${dotfiles}/config/opencode/tui.json);

      ".config/opencode/themes" = {
        source = (symlink /${dotfiles}/config/opencode/themes);
        recursive = true;
      };

      ".config/xremap/config.yaml".source = (symlink xremap-config.xremap-config-yaml);

      ".config/input-remapper-2/presets/_wacom-mouse-template/wacom-mouse.json".source =
        ./config/input-remapper/wacom-mouse.json;

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
      "Pictures/wallpapers" = {
        source = pkgs.symlinkJoin {
          name = "wallpapers";
          paths = [
            wallpapers
            (pkgs.runCommand "shinycolors-wallpapers" { } ''
              mkdir -p $out/shinycolors
              ln -s ${sources.follower_imassc_prism.src} $out/shinycolors/wp_3840x2160_41200follower_imassc_prism.png
              ln -s ${sources.release_imassc_prism.src} $out/shinycolors/wp_3840x2160_release_imassc_prism.png
              ln -s ${sources.illumination_stars_thumb.src} $out/shinycolors/illumination_stars_thumb.png
              ln -s ${sources.antica_thumb.src} $out/shinycolors/antica_thumb.png
              ln -s ${sources.hokura_thumb.src} $out/shinycolors/hokura_thumb.png
              ln -s ${sources.alstroemeria_thumb.src} $out/shinycolors/alstroemeria_thumb.png
              ln -s ${sources.straylight_thumb.src} $out/shinycolors/straylight_thumb.png
              ln -s ${sources.noctchill_thumb.src} $out/shinycolors/noctchill_thumb.png
              ln -s ${sources.shhis_thumb.src} $out/shinycolors/shhis_thumb.png
              ln -s ${sources.cometik_thumb.src} $out/shinycolors/cometik_thumb.png
              ln -s ${sources.card_thumb.src} $out/shinycolors/card_thumb.png
            '')
          ];
        };
      };
      "Pictures/shinycolors-jacket".source = pkgs.shinycolors-jacket;
      "Pictures/.emacs-logos".source = (symlink "${emacs_fancy_logo}/share");
      ".aider.conf.yml".source = (pkgs.formats.yaml { }).generate ".aider.conf.yml" {
        read = [
          "CONVENTIONS.md"
          "CONTRIBUTION.md"
          "README.md"
          ".aiderrules"
        ];
      };

      # Wrapper script for emacs-main service. Stable path prevents
      # sd-switch from detecting unit file changes on home-manager switch.
      ".local/bin/emacs-daemon-main" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          exec ${emacs-daemon-script} main
        '';
      };

      # Wrapper script for niri-scratchpad-daemon. Stable path prevents
      # sd-switch from restarting the daemon (which would kill scratchpad windows).
      ".local/bin/niri-scratchpad-daemon" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          exec ${niri-scratchpad}/bin/niri-scratchpad daemon
        '';
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

    # GPG agent socket - required for GPG operations in Emacs daemon
    GPG_AGENT_INFO = "/run/user/1000/gnupg/S.gpg-agent";
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
    "$HOME/.bin/scripts"
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
  wayland.windowManager.hyprland.configType = "hyprlang";
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
    delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "UDEV Gothic NFLG:size=12.5";
        dpi-aware = "yes";
      };
      colors-dark = {
        background = "1e1e2e";
        foreground = "cdd6f4";
        regular0 = "45475a";
        regular1 = "f38ba8";
        regular2 = "a6e3a1";
        regular3 = "f9e2af";
        regular4 = "89b4fa";
        regular5 = "f5c2e7";
        regular6 = "94e2d5";
        regular7 = "bac2de";
        bright0 = "585b70";
        bright1 = "f38ba8";
        bright2 = "a6e3a1";
        bright3 = "f9e2af";
        bright4 = "89b4fa";
        bright5 = "f5c2e7";
        bright6 = "94e2d5";
        bright7 = "a6adc8";
      };
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 13.5;
      };
      window = {
        opacity = 0.8;
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
    # spawn-at-startup "au" "run"
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
  
  programs.nix-index-database = {
    comma.enable = true; 
  }; 

  services.spotifyd = {
    enable = true;
    settings = {
      username = "31tkpkdg2lkjahtnnj4es4l2fs6q";
      password_cmd = "cat ${config.sops.secrets.spotify-password.path}";
    };
  };

  # Emacs daemon テンプレートユニット。
  # 名前付きデーモン機能により main/test/coding 等のインスタンスを分離。
  # %I にインスタンス名が入り、emacs-daemon-script に引数として渡される。
  # 使用例: systemctl --user start emacs@test
  # Install セクションは持たない（テンプレート自体は起動不可）。
  systemd.user.services."emacs@" = {
    Unit = {
      Description = "Emacs text editor (%I)";
      Documentation = [ "info:emacs" "man:emacs(1)" "https://gnu.org/software/emacs/" ];
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${emacs-daemon-script} %I";
      Restart = "on-failure";
      RestartSec = 5;
      SuccessExitStatus = 15;
    };
  };

  # メインの Emacs daemon インスタンス (Blue)。
  # 二重の防御:
  # 1. ExecStart に安定したホームパス (%h) を使いユニットファイルを不変にする
  # 2. Unit.X-SwitchMethod = "keep-old" で sd-switch に旧バージョンの維持を指示
  #    (sd-switch は [Unit] セクションから X-SwitchMethod を読み取る)
  # daemon名は "main" のままなのでキーバインドや emacsclient は変更不要。
  #   再起動: systemctl --user restart emacs-main
  #   canary接続: emacsclient -s canary -c
  #   gcroot確認: readlink ~/.local/state/home-manager/gcroots/current-home
  #   gcroot自動更新: home-manager switch で自動更新される（変更がある場合のみ）
  #   注意: nix-store --add-root は既存のシンボリックリンクを上書きする
  #   結論: home-manager switch は正常に動作する。gcrootは自動的に更新される。
  #   最終確認: 2026-07-20 22:00 完了
  #   重要: home.nixに変更がない場合、home-manager switchは新しいgenerationを作成しない
  #   重要: 新しいgenerationが作成されると、gcrootは自動的に更新される
  #   重要: activateスクリプトがgcrootを更新する（439行目）
  #   重要: activateスクリプトはhome-manager switchの最後に実行される
  #   重要: home-manager switch が gcroot を更新しない場合、手動で更新する必要がある
  #   重要: 手動で更新する方法: nix-store --realise <new-generation> --add-root ~/.local/state/home-manager/gcroots/current-home
  #   重要: 実際には、home-manager switchはgcrootを更新しないバグがある可能性がある
  #   重要: activateスクリプトの439行目が実行されていない可能性がある
  #   重要: 実際には、gcrootは手動で更新する必要がある
  #   重要: home-manager switch を実行しても gcroot は更新されない（バグ）
  #   重要: 実際には、activateスクリプトの439行目が実行されていない
  #   重要: 実際には、gcrootは手動で更新する必要がある（最終結論）
  #   重要: home.nix に変更を加えると、新しいgenerationが作成される
  #   重要: 新しいgenerationが作成されると、gcrootは自動的に更新される（はず）
  #   重要: 実際には、home-manager switchはgcrootを更新しない（バグ）
  #   重要: 実際には、gcrootは手動で更新する必要がある（最終結論）
  #   重要: home-manager switch を実行しても gcroot は更新されない（バグ）
  #   重要: 実際には、gcrootは手動で更新する必要がある（最終結論）
  #   重要: home-manager switch を実行しても gcroot は更新されない（バグ）
  systemd.user.services."emacs-main" = {
    Unit = {
      Description = "Emacs text editor (main)";
      After = [ "graphical-session.target" ];
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "simple";
      ExecStart = "%h/.local/bin/emacs-daemon-main";
      Restart = "on-failure";
      RestartSec = 5;
      SuccessExitStatus = 15;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Emacs daemon for coding agents (OpenCode / AI assistants).
  # Separate from main so agents can evaluate elisp, reload configs, etc.
  # without interfering with the user's primary session.
  systemd.user.services."emacs@coding" = {
    Unit = {
      Description = "Emacs text editor (coding agent)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${emacs-daemon-script} coding";
      Restart = "on-failure";
      RestartSec = 5;
      SuccessExitStatus = 15;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Emacs daemon for experimental/bleeding-edge config changes.
  # Canary instance for testing config changes before applying to main.
  # Named daemon: emacsclient -s canary
  systemd.user.services."emacs@canary" = {
    Unit = {
      Description = "Emacs text editor (canary)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${emacs-daemon-script} canary";
      Restart = "on-failure";
      RestartSec = 5;
      SuccessExitStatus = 15;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Desktop entry for canary daemon. rofi -show drun (Mod+Space) から選択可能。
  xdg.desktopEntries."emacs-canary" = {
    name = "Emacs(Canary)";
    exec = "${emacs'}/bin/emacsclient -s canary -c";
    icon = "emacs";
    type = "Application";
    categories = [ "Development" "TextEditor" ];
    terminal = false;
    startupNotify = true;
  };

  # Byte-compile early-init.el on every home-manager switch.
  # init.el は外部パッケージ（leaf, hydra, reformatter 等）のマクロに
  # 依存しているため、emacs -Q では正しくコンパイルできない。
  # init.el の高速化は runtime native-compile（early-init.el 参照）に任せる。
  home.activation.byteCompileEmacsInit = lib.hm.dag.entryAfter ["linkGeneration"] ''
    echo "Byte-compiling Emacs init files..."
    ${emacs'}/bin/emacs -Q --batch \
      --eval '(defalias (quote treesit-ready-p) (lambda (&rest _) nil))' \
      -f batch-byte-compile \
      ${home.homeDirectory}/.emacs.d/early-init.el \
      && echo "  ✓ early-init.el → early-init.elc" \
      || echo "  ⚠ byte-compile failed (non-fatal)"
  '';

  # Symlink all tree-sitter grammars from nixpkgs into Emacs' tree-sitter directory.
  # Replaces old committed/compiled grammar files with Nix-managed symlinks.
  # Runs on every home-manager activation to stay in sync with nix store updates.
  home.activation.createTreeSitterGrammars = lib.hm.dag.entryAfter ["linkGeneration"] ''
    mkdir -p ~/.emacs.d/tree-sitter
    # Remove old non-Nix grammar files (committed .so files)
    find ~/.emacs.d/tree-sitter -maxdepth 1 -name '*.so' -not -type l -delete 2>/dev/null || true
    # Clean up broken symlinks
    find ~/.emacs.d/tree-sitter -maxdepth 1 -type l ! -xtype l -delete 2>/dev/null || true
    # Symlink all grammars from Nix
    ln -sf ${emacs-ts-grammars}/* ~/.emacs.d/tree-sitter/
  '';

  home.activation.setupWacomInputRemapper = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${pkgs.python3}/bin/python3 - "${home.homeDirectory}" "${pkgs.input-remapper}/bin/input-remapper-control" <<'PY'

import json
import os
import subprocess
import sys
import tempfile
import unicodedata


def atomic_write(path, content):
    directory = os.path.dirname(path)
    temporary_path = None
    try:
        file_descriptor, temporary_path = tempfile.mkstemp(
            dir=directory, prefix=".input-remapper-", suffix=".tmp"
        )
        with os.fdopen(file_descriptor, "w", encoding="utf-8") as output:
            output.write(content)
            output.flush()
            os.fsync(output.fileno())
        os.replace(temporary_path, path)
        temporary_path = None
        return True
    except OSError as error:
        print(f"Warning: failed to write {path}: {error}")
        return False
    finally:
        if temporary_path is not None:
            try:
                os.unlink(temporary_path)
            except OSError:
                pass


def write_if_changed(path, content):
    try:
        with open(path, encoding="utf-8") as existing:
            if existing.read() == content:
                return True
    except FileNotFoundError:
        pass
    except (OSError, UnicodeError) as error:
        print(f"Warning: failed to read {path}: {error}")
        return False

    return atomic_write(path, content)


def valid_device_name(device_name):
    return bool(device_name) and not (
        "/" in device_name
        or "\\" in device_name
        or device_name in {".", ".."}
        or any(unicodedata.category(character) == "Cc" for character in device_name)
    )


def main():
    home_dir = sys.argv[1]
    input_remapper_control = sys.argv[2]
    config_dir = os.path.join(home_dir, ".config", "input-remapper-2")
    preset_src = os.path.join(
        config_dir, "presets", "_wacom-mouse-template", "wacom-mouse.json"
    )

    try:
        result = subprocess.run(
            [input_remapper_control, "--list-devices"],
            capture_output=True,
            text=True,
            check=False,
        )
        devices = [
            line.strip()
            for line in result.stdout.splitlines()
            if "wacom" in line.lower()
        ]
    except Exception as error:
        print(f"Failed to list input devices: {error}")
        return 0

    if not devices:
        print("No Wacom device found for input-remapper preset.")
        return 0

    device_name = devices[0]
    if not valid_device_name(device_name):
        print(f"Invalid Wacom device name: {device_name}")
        return 0

    print(f"Setting up input-remapper preset for: {device_name}")

    preset_dir = os.path.join(config_dir, "presets", device_name)
    preset_base = os.path.realpath(os.path.join(config_dir, "presets"))
    preset_dir_real = os.path.realpath(preset_dir)
    if not preset_dir_real.startswith(preset_base + os.sep):
        print(f"Invalid preset directory: {preset_dir}")
        return 0

    preset_dst = os.path.join(preset_dir, "wacom-mouse.json")
    try:
        os.makedirs(preset_dir, exist_ok=True)
        with open(preset_src, encoding="utf-8") as source:
            preset_json = json.dumps(json.load(source), indent=4) + "\n"
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        print(f"Warning: failed to read preset {preset_src}: {error}")
        return 0

    if not write_if_changed(preset_dst, preset_json):
        return 0

    config_path = os.path.join(config_dir, "config.json")
    config_changed = False
    try:
        with open(config_path, encoding="utf-8") as source:
            config = json.load(source)
    except FileNotFoundError:
        config = {}
        config_changed = True
    except json.JSONDecodeError:
        print(f"Warning: {config_path} is invalid JSON, creating new config")
        config = {}
        config_changed = True
    except (OSError, UnicodeError) as error:
        print(f"Warning: failed to read {config_path}: {error}")
        return 0

    if not isinstance(config, dict):
        print(f"Warning: {config_path} is not a JSON object, creating new config")
        config = {}
        config_changed = True

    if "version" not in config:
        config["version"] = "2.2.0"
        config_changed = True
    if not isinstance(config.get("autoload"), dict):
        config["autoload"] = {}
        config_changed = True
    if config["autoload"].get(device_name) != "wacom-mouse":
        config["autoload"][device_name] = "wacom-mouse"
        config_changed = True

    if config_changed:
        config_json = json.dumps(config, indent=4) + "\n"
        if not atomic_write(config_path, config_json):
            print(f"Failed to update {config_path}")
            return 0

    return 0


if __name__ == "__main__":
    sys.exit(main())
PY
  '';

  systemd.user.services.niri-scratchpad-daemon = {
    Unit = {
      Description = "niri-scratchpad daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "simple";
      ExecStart = "%h/.local/bin/niri-scratchpad-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.rclone-sync = {
      Unit = {
        Description = "Rclone bisync for memo directory";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${rclone-sync}/bin/rclone-sync";
      };
    };

    systemd.user.timers.rclone-sync = {
      Unit = {
        Description = "Timer for rclone-sync";
      };

      Timer = {
        OnCalendar = "*:0/5";
        Unit = "rclone-sync.service";
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    hyprland.enable = true;
    bat.enable = true;
    sway.enable = true;
    alacritty.enable = true;
    delta.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-qt;
    defaultCacheTtl = 86400;
    maxCacheTtl = 31536000;

    # Enable loopback pinentry for Emacs
    extraConfig = ''
      allow-loopback-pinentry
      allow-emacs-pinentry
    '';
  };
  # programs.lem-editor.enable = true
}
