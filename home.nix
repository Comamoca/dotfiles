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
  dotfiles = "/home/${username}/.ghq/localhost/comamoca/dotfiles";

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

  # treefmt 本体と treefmt.nix で有効化している formatter 群。
  # コミット済み treefmt.toml (flake.nix の packages.treefmt-toml で生成)
  # がコマンド名で参照するので、PATH に揃えておく。
  # deno は treefmt.nix と同じく 2.5.4 に固定 (オーバーレイ非適用時は素のパッケージ)。
  treefmt-packages = [
    pkgs.treefmt
    pkgs.nixfmt
    pkgs.taplo
    pkgs.stylua
    (pkgs.deno."2.5.4" or pkgs.deno)
  ];

  programming-english = pkgs.fetchFromGitHub {
    owner = "MatsumotoDesuyo";
    repo = "programming-english";
    rev = "main";
    hash = "sha256-PZRJqDMfy4F92i10jeUY0R5P45YYBvEB3hm55dSbubo=";
  };

  batch =
    pkgs.writers.writePython3Bin "convert_and_resize"
      {
        libraries = with pkgs.python3Packages; [
          cairosvg
          pillow
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
    epkgs:
    let
      # projectile 20260627+ ships projectile-consult.el which hard-requires
      # consult at compile time, but the MELPA recipe only declares (emacs compat).
      # Override at the scope level so all dependents benefit.
      epkgs' = epkgs.overrideScope (
        eself: esuper: {
          projectile = esuper.projectile.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ eself.consult ];
            propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ eself.consult ];
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
        }
      );
    in
    (import ./emacs.nix {
      inherit pkgs;
      epkgs = epkgs';
      inherit nurpkgs;
    }).packages
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
      # nixpkgs の tree-sitter-grammars は scope 化されており、
      # callPackage / packages / allGrammars / derivations 等の非 grammar 属性が混在する。
      # `tree-sitter-` プレフィックスを持つ属性だけが grammar derivation。
      #
      # tree-sitter-cuda は除外する。nixpkgs の指定ハッシュと GitHub が返す
      # 自動生成 tarball (archive/v0.21.2.tar.gz) の内容が一致せず、
      # hash mismatch でビルドが必ず失敗するため。
      #   specified: sha256-QGNCld6J0eTPDv+VjjtGuv5/6SCJx8iSMECQTN01V6Q=
      #   got:       sha256-s2qrZx5fEu/I6xE2paX/Nlmgvo6T27qqvy1cI8iznAA=
      # nixpkgs 側で修正されたら、この除外は外してよい。
      brokenGrammars = [ "tree-sitter-cuda" ];
      grammars = lib.filterAttrs (
        n: v: lib.hasPrefix "tree-sitter-" n && !(builtins.elem n brokenGrammars)
      ) pkgs.tree-sitter-grammars;
      mkLink =
        name: grammar:
        let
          shortName = lib.removePrefix "tree-sitter-" name;
        in
        if builtins.isList grammar then
          lib.imap0 (i: g: "ln -s ${g}/parser \"$out/libtree-sitter-${shortName}-${toString i}.so\"") grammar
        else
          [ "ln -s ${grammar}/parser \"$out/libtree-sitter-${shortName}.so\"" ];
      links = lib.concatLists (lib.mapAttrsToList mkLink grammars);
    in
    ''
      mkdir -p $out
      ${lib.concatStringsSep "\n" links}
    ''
  );

  # nix-index のプリビルド DB は Hydra がビルドした (= cache.nixos.org に存在する)
  # パッケージしか収録しない。docker-sbx は Hydra 未ビルドのため DB に無く、comma で
  # 実行できない。DB はパッケージごとの frcode ブロックを zstd フレームとして連結した
  # 形式なので、ローカルでビルドした docker-sbx のブロックを追記した DB を生成して使う。
  nix-index-database-pkgs = inputs.nix-index-database.packages.${system};

  merge-nix-index-db =
    {
      name,
      base,
      filterPrefix,
    }:
    pkgs.runCommand "nix-index-database-${name}"
      {
        nativeBuildInputs = [
          pkgs.python3
          pkgs.zstd
        ];
      }
      ''
        python3 ${./pkgs/nix-index-db-merge.py} \
          --base ${base} \
          --package ${pkgs.docker-sbx} \
          --attr docker-sbx \
          --system ${system} \
          --filter-prefix '${filterPrefix}' \
          --out $out
      '';

  nix-index-docker-sbx-db = {
    full = merge-nix-index-db {
      name = "full-with-docker-sbx";
      base = nix-index-database-pkgs.nix-index-database;
      filterPrefix = "";
    };
    small = merge-nix-index-db {
      name = "small-with-docker-sbx";
      base = nix-index-database-pkgs.nix-index-small-database;
      filterPrefix = "/bin/";
    };
  };

  # nix-index-database のラッパーを、マージ済み DB を指すように組み直す。
  nix-index-with-db = pkgs.callPackage "${inputs.nix-index-database}/nix-index-wrapper.nix" {
    nix-index-database = nix-index-docker-sbx-db.full;
  };

  comma-with-db = pkgs.callPackage "${inputs.nix-index-database}/comma-wrapper.nix" {
    nix-index-database = nix-index-docker-sbx-db.small;
  };

  # codex-plugin-cc の rescue 経路 (skill / subagent / slash command) が使う
  # モデルを gpt-6-sol に固定したコピーを作る。
  #
  # 上流は「モデルは既定では指定しない」(Leave model unset by default) 方針で、
  # そのままだと ~/.codex/config.toml の既定モデルがそのまま使われる。
  # config.toml 側の model は pin しない方針を維持したいので、
  # rescue 経由の Codex 実行だけをここで sol に寄せる。
  #
  # 上流は flake input の読み取り専用 store path なので、ビルド時に書き換える。
  # 対象行が消えたら --replace-fail でビルドが失敗するため、input の rev を
  # 上げたときに書き換え漏れを黙って通すことはない。
  codexRescueModel = "gpt-6-sol";
  codex-plugin-cc = pkgs.runCommand "codex-plugin-cc-${codexRescueModel}" { } ''
    cp -r ${inputs.codex-plugin-cc} "$out"
    chmod -R u+w "$out"

    substituteInPlace "$out/plugins/codex/skills/codex-cli-runtime/SKILL.md" \
      --replace-fail \
        '- Leave model unset by default. Add `--model` only when the user explicitly asks for one.' \
        '- Default to `--model ${codexRescueModel}`. Add a different `--model` only when the user explicitly asks for another model.'

    substituteInPlace "$out/plugins/codex/agents/codex-rescue.md" \
      --replace-fail \
        '- Leave model unset by default. Only add `--model` when the user explicitly asks for a specific model.' \
        '- Default to `--model ${codexRescueModel}`. Only pass a different `--model` when the user explicitly asks for a specific model.'

    substituteInPlace "$out/plugins/codex/commands/rescue.md" \
      --replace-fail \
        '- Leave the model unset unless the user explicitly asks for one. If they ask for `spark`, map it to `gpt-5.3-codex-spark`.' \
        '- Default the model to `${codexRescueModel}` unless the user explicitly asks for another one. If they ask for `spark`, map it to `gpt-5.3-codex-spark`.'
  '';

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
        path = "/run/user/1000/spotify-password";
      };
      "claude-code" = {
        sopsFile = ./secrets/claude-code.env;
        path = "/run/user/1000/claude-code.env";
        format = "dotenv";
      };
      "opencode-failover" = {
        sopsFile = ./secrets/opencode-failover.env;
        path = "/run/user/1000/opencode-failover.env";
        format = "dotenv";
      };
      "aider-opencode-go" = {
        sopsFile = ./secrets/aider-opencode-go.env;
        path = "/run/user/1000/aider-opencode-go.env";
        format = "dotenv";
      };
      # Cloudflare Tunnel (opencode.comamoca.dev) のトンネルトークン。
      # cloudflared は --token-file でこのファイルを読む (ps に露出しない)。
      # 0600 で ~/.config/cloudflared/opencode-token に復号される。
      "opencode-cloudflared-token" = {
        sopsFile = ./secrets/opencode-cloudflared-token.yaml;
        key = "opencode-cloudflared-token";
        path = "${home.homeDirectory}/.config/cloudflared/opencode-token";
        format = "yaml";
        mode = "0600";
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
      input-remapper  # Wacom ペンタブの ExpressKeys を Krita 用キーに変換

      # NOTE: 2025/06/22 hashまわりで壊れたので一旦無効化
      # (import ./pkgs/lspx { inherit pkgs; })
      rclone-sync
      rclone-resync
      (callPackage ./pkgs/nvim-lzn-plugins { })
    ])
    ++ [
      emacs'
      comma-with-db
    ]
    ++ treefmt-packages;

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
      dotfiles = /${home.homeDirectory}/.ghq/localhost/comamoca/dotfiles;
      xdgConfigHome = /${home.homeDirectory}/.config;
      homeBin = /${home.homeDirectory}/.bin;
      base = ".cache/dpp/_generated";
    in
    {
      # OpenAI 公式の Codex プラグイン (codex-plugin-cc) を Claude Code に配置する。
      # marketplace.json を持つリポジトリルートをそのまま marketplaces/ に置き、
      # ~/.claude/settings.json の extraKnownMarketplaces / enabledPlugins から
      # "codex@openai-codex" として参照する。
      #
      # skills だけでなく agents/codex-rescue.md, commands/, scripts/ も入るので、
      # /codex:rescue と codex:codex-rescue サブエージェントが実際に動くようになる。
      # codex 系 skill はこちら経由で入るため skills/remote.nix からは外してある。
      #
      # 実行時の状態は CLAUDE_PLUGIN_DATA (未設定なら $TMPDIR/codex-companion) に
      # 書かれるので、プラグイン本体が読み取り専用の store path でも問題ない。
      #
      # source は上流そのままではなく、rescue 経路のモデルを gpt-6-sol に
      # 書き換えたコピー (let の codex-plugin-cc)。
      ".claude/plugins/marketplaces/openai-codex".source = codex-plugin-cc;

      # NIX_INDEX_DATABASE 未設定時に参照される ~/.cache/nix-index/files を、
      # docker-sbx を追記した DB に差し替える。
      "${config.xdg.cacheHome}/nix-index/files".source = lib.mkForce nix-index-docker-sbx-db.full;

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

      ".bin/scripts/verify-opencode-failover.fish" = {
        source = (symlink /${dotfiles}/bin/scripts/verify-opencode-failover.fish);
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

      # nvim-lzn: nix + lz.n の試用環境 (NVIM_APPNAME=nvim-lzn)
      # プラグインは pkgs/nvim-lzn-plugins が home.packages 経由で ~/.nix-profile/share
      # に配置され、packpath に入る。config は既存 dpp 環境とは完全に別。
      ".config/nvim-lzn" = {
        source = (symlink /${dotfiles}/config/nvim-lzn);
        recursive = true;
      };

      # efm-langserver (Gleam マニフェストのライセンス診断)
      ".config/efm-langserver" = {
        source = (symlink /${dotfiles}/config/efm-langserver);
        recursive = true;
      };

      ".config/nyxt" = {
        source = (symlink /${dotfiles}/config/nyxt);
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

      ".config/opencode/tui-plugins" = {
        source = (symlink /${dotfiles}/config/opencode/tui-plugins);
        recursive = true;
      };

      ".config/opencode/commands/btw.md".source = (symlink /${dotfiles}/config/opencode/commands/btw.md);

      ".config/opencode/plugins/btw.ts".source = (symlink /${dotfiles}/config/opencode/plugins/btw.ts);

      # input-remapper: Wacom ペンタブ ExpressKeys → Krita 用キー(F13-F16)変換
      # デバイス別プリセットディレクトリは activation スクリプト(setupWacomInputRemapper)で
      # デバイス名を検出して配置する。ここではテンプレートとして symlink を張る。
      ".config/input-remapper-2/presets/_wacom-krita-template/wacom-krita.json".source =
        (symlink /${dotfiles}/config/input-remapper/wacom-krita.json);

      ".omo/omo.jsonc".source = (symlink /${dotfiles}/config/omo/omo.jsonc);

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
        # OpenCode Go (OpenAI API compatible) - API key comes from sops
        # via AIDER_OPENAI_API_KEY (loaded in fish.nix)
        model = "openai/deepseek-v4-pro";
        openai-api-base = "https://opencode.ai/zen/go/v1";
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

    # TTY が無い (coding agent など) 状況の sudo で GUI パスワードプロンプトを出す
    SUDO_ASKPASS = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

    # opencode-failover reads API keys from this file at startup
    OPENCODE_FAILOVER_ENV_FILE = config.sops.secrets.opencode-failover.path;
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

    # sudo の askpass (サービスから GUI パスワードプロンプトを出す)
    SUDO_ASKPASS = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

    # opencode-failover reads API keys from this file at startup
    OPENCODE_FAILOVER_ENV_FILE = config.sops.secrets.opencode-failover.path;
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

  # Agent Skills (SKILL.md) を宣言的に管理し、~/.claude/skills へ同期する。
  # - remote: 固定した上流ソースまたは公開 SKILL.md を fetch して配置する。
  #           追加は ./skills/remote.nix に定義する。
  # - local:  上流が無い自作 skill だけを ./skills/local/<name>/SKILL.md に置く。
  # structure = "symlink-tree" は rsync --delete なので、ここに無い skill は
  # ~/.claude/skills から削除される点に注意。
  programs.agent-skills = {
    enable = true;
    sources.remote.path = import ./skills/remote.nix { inherit pkgs lib; };
    sources.local.path = ./skills/local;
    skills.enableAll = true;
    targets.claude.enable = true;
  };

  # codex (OpenAI Codex CLI) の設定を宣言的に管理する。
  # 生成先は ~/.codex/config.toml (home.preferXdgDirectories 未設定のため)。
  #
  # mutableSettings = true により config.toml は /nix/store への読み取り専用
  # シンボリックリンクではなく実ファイルになり、home-manager switch のたびに
  # 「Nix 宣言値」を「現在の config.toml」へマージする (宣言値が優先、codex が
  # 追記したキーは保持)。これで静的な設定は Nix が正、codex 自身が書き込む
  # stateful な設定 (ディレクトリ信頼、TUI の初回検出フラグ、モデル移行の通知
  # など) は $HOME に残り続ける。
  # 既知の信頼ディレクトリを projects に宣言しておくと、別マシンでも初回から
  # trust 済みになる (新しいディレクトリは codex の書き込みが保持される)。
  programs.codex = {
    enable = true;
    package = pkgs.llm-agents.codex;

    # config.toml を実ファイルとして codex に所有させ、宣言値だけをマージする。
    # 読み取り専用シンボリックリンクに戻すと codex の書き込みが消えるため false のままにしない。
    mutableSettings = true;

    settings = {
      personality = "pragmatic";
      # モデルとプロバイダは意図的に pin しない。
      # codex は ChatGPT サブスク認証 (~/.codex/auth.json, auth_mode = "chatgpt")
      # で純正エンドポイントに接続し、現行の codex チューニング版モデルを
      # 自動選択する。codex-cli-runtime skill も
      # "Leave model unset by default" を前提にしているため、ここで固定すると
      # skill 側の想定 (spark 指定時のみ --model を渡す) と食い違う。
      #
      # 以前は OpenCode Go (zen/go/v1) を proxy プロバイダとして噛ませていたが、
      # Go プランは codex 系モデルを配っておらず、skill が想定する
      # codex チューニング版を使えなかったため撤去した。
      model_reasoning_effort = "high";

      approval_policy = "on-request";
      approvals_reviewer = "auto_review";

      tui.screen_reader_detection_done = true;

      projects = {
        "${homeDirectory}".trust_level = "trusted";
        "${dotfiles}".trust_level = "trusted";
        "${homeDirectory}/.ghq/github.com/Comamoca/dotfiles".trust_level = "trusted";
        "${homeDirectory}/.ghq/github.com/Comamoca/glanty".trust_level = "trusted";
        "${homeDirectory}/sandbox/litellm".trust_level = "trusted";
      };
    };
  };

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
  # EnvironmentFile ="/run/user/1000/claude-code.env";
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
    # ローカルでビルドした docker-sbx を追記した DB を使う。
    package = lib.mkForce nix-index-with-db;
  };

  # 上流の comma-with-db は DB を自身の store path に固定する (makeBinaryWrapper の
  # --set は後勝ちで外から差し替えられない) ため enable せず、マージ済み DB を指す
  # ラッパー (home.packages の comma-with-db) を使う。
  programs.nix-index-database.comma.enable = false;

  services.spotifyd = {
    enable = true;
    settings = {
      username = "31tkpkdg2lkjahtnnj4es4l2fs6q";
      password_cmd = "cat ${config.sops.secrets.spotify-password.path}";
    };
  };

  # セルフホストの検索エンジン。ブラウザ拡張の履歴取り込み先。
  # Web UI: http://127.0.0.1:4433
  # データはデフォルトの ~/.config/hister に置かれる。
  services.hister = {
    enable = true;
    settings = {
      server.address = "127.0.0.1:4433";
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
      Documentation = [
        "info:emacs"
        "man:emacs(1)"
        "https://gnu.org/software/emacs/"
      ];
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
  # ソケット名は "main"。ユニット名は emacs-main.service (手動配置、home-manager 管理外)。
  # sd-switch は「emacs@」テンプレートユニットの内容が変わると、現在起動中の
  # emacs@* という名前にマッチする全インスタンスをまとめて再起動する。
  # 以前 emacs@main という名前で動かしていたところ、nh home switch のたびに
  # emacs@coding / emacs@canary と一緒に main まで巻き込まれて再起動していた。
  # emacs@ プレフィックスを共有しない emacs-main.service という名前に変更し、
  # home-manager 管理下にも置かないことで、switch 時の巻き込み再起動を回避している。
  #   再起動: systemctl --user restart emacs-main
  #   canary接続: emacsclient -s canary -c
  #   gcroot確認: readlink ~/.local/state/home-manager/gcroots/current-home

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

  # Desktop entry for main daemon. rofi -show drun (Mod+Space) から選択可能。
  # Nixpkgs 同梱の emacsclient.desktop はソケット名を指定しない
  # (--alternate-editor= は空なのでフォールバックもない)。
  # 名前付きソケット(main)の環境では接続できず起動に失敗するため、
  # ここで emacsclient.desktop を上書きして明示的に -s main を指定する。
  xdg.desktopEntries."emacsclient" = {
    name = "Emacs (Client)";
    genericName = "Text Editor";
    comment = "Edit text";
    exec = "${emacs'}/bin/emacsclient -s main -c";
    icon = "emacs";
    type = "Application";
    categories = [
      "Development"
      "TextEditor"
    ];
    terminal = false;
    startupNotify = true;
  };

  # Desktop entry for canary daemon. rofi -show drun (Mod+Space) から選択可能。
  xdg.desktopEntries."emacs-canary" = {
    name = "Emacs(Canary)";
    exec = "${emacs'}/bin/emacsclient -s canary -c";
    icon = "emacs";
    type = "Application";
    categories = [
      "Development"
      "TextEditor"
    ];
    terminal = false;
    startupNotify = true;
  };

  # Byte-compile early-init.el on every home-manager switch.
  # init.el は外部パッケージ（leaf, hydra, reformatter 等）のマクロに
  # 依存しているため、emacs -Q では正しくコンパイルできない。
  # init.el の高速化は runtime native-compile（early-init.el 参照）に任せる。
  home.activation.byteCompileEmacsInit = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
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
  home.activation.createTreeSitterGrammars = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p ~/.emacs.d/tree-sitter
    # Remove old non-Nix grammar files (committed .so files)
    find ~/.emacs.d/tree-sitter -maxdepth 1 -name '*.so' -not -type l -delete 2>/dev/null || true
    # Clean up broken symlinks
    find ~/.emacs.d/tree-sitter -maxdepth 1 -type l ! -xtype l -delete 2>/dev/null || true
    # Symlink all grammars from Nix
    ln -sf ${emacs-ts-grammars}/* ~/.emacs.d/tree-sitter/
  '';

  # Wacom ペンタブの ExpressKeys を Krita 用キー(F13-F16)に変換する input-remapper プリセットを
  # デバイス名に応じたディレクトリへ配置し、autoload を有効化する。
  # デバイス名は実行時に input-remapper-control で検出するため、ハードウェア依存の値は Nix に持たない。
  home.activation.setupWacomInputRemapper = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    PRESET_SRC="${home.homeDirectory}/.config/input-remapper-2/presets/_wacom-krita-template/wacom-krita.json"
    CONFIG_DIR="${home.homeDirectory}/.config/input-remapper-2"

    # Wacom Pad デバイス名を検出する (例: "Wacom Intuos S Pad")
    DEVICE_NAME=$(${pkgs.input-remapper}/bin/input-remapper-control --list-devices 2>/dev/null | \
      ${pkgs.gnugrep}/bin/grep -i "pad" | ${pkgs.gnugrep}/bin/grep -i wacom | \
      ${pkgs.coreutils}/bin/head -n 1 | ${pkgs.coreutils}/bin/cut -d: -f2 | ${pkgs.findutils}/bin/xargs || true)

    if [ -z "$DEVICE_NAME" ]; then
      echo "No Wacom Pad device found for input-remapper preset."
    else
      echo "Setting up input-remapper preset for: $DEVICE_NAME"

      # デバイス別 preset ディレクトリを作成し、テンプレートをコピーする
      ${pkgs.coreutils}/bin/mkdir -p "$CONFIG_DIR/presets/$DEVICE_NAME"
      ${pkgs.coreutils}/bin/cp -f "$PRESET_SRC" "$CONFIG_DIR/presets/$DEVICE_NAME/wacom-krita.json"

      # autoload 設定を更新する（既存設定は保持）
      ${pkgs.coreutils}/bin/mkdir -p "$CONFIG_DIR"
      ${pkgs.python3}/bin/python3 - "$CONFIG_DIR/config.json" "$DEVICE_NAME" <<'PY'
import json
import sys

config_path = sys.argv[1]
device_name = sys.argv[2]

try:
    with open(config_path) as f:
        config = json.load(f)
except FileNotFoundError:
    config = {}

config.setdefault("version", "2.2.0")
config.setdefault("autoload", {})
config["autoload"][device_name] = "wacom-krita"

with open(config_path, "w") as f:
    json.dump(config, f, indent=4)
    f.write("\n")
PY
    fi
  '';

  # Krita のショートカット設定に Wacom ペンタブ用の F13-F16 割当を追記する。
  # kritashortcutsrc は Krita が起動/終了時に書き換えるため、全体を Nix store への
  # symlink にはせず、[Shortcuts] セクション内に割当が無い場合のみ挿入する。
  # Krita 側でショートカットを変更した場合はこの追記はスキップされ、Krita の設定が優先される。
  home.activation.setupKritaShortcuts = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    SHORTCUTS_FILE="${home.homeDirectory}/.config/kritashortcutsrc"
    ADDITIONS="${dotfiles}/config/krita/kritashortcutsrc"

    if [ -f "$SHORTCUTS_FILE" ]; then
      # 既に F13 割当があればスキップ (exit ではなく else で分岐。exit は activation 全体を止める)
      if ! ${pkgs.gnugrep}/bin/grep -q "rotate_canvas_left=F13" "$SHORTCUTS_FILE" 2>/dev/null; then
        echo "Adding Wacom tablet shortcuts to kritashortcutsrc..."
        # [Shortcuts] セクションの直後に割当を挿入する
        ${pkgs.python3}/bin/python3 - "$SHORTCUTS_FILE" "$ADDITIONS" <<'PY'
import sys

shortcuts_file = sys.argv[1]
additions_file = sys.argv[2]

with open(additions_file) as f:
    additions = f.read()

with open(shortcuts_file) as f:
    content = f.read()

marker = "[Shortcuts]"
if marker in content:
    content = content.replace(marker, marker + "\n" + additions.rstrip("\n"), 1)
else:
    content = content.rstrip("\n") + "\n\n" + marker + "\n" + additions.rstrip("\n") + "\n"

with open(shortcuts_file, "w") as f:
    f.write(content)
PY
      else
        echo "Krita shortcuts already configured, skipping."
      fi
    fi
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

  systemd.user.services.wl-clip-persist = {
    Unit = {
      Description = "Wayland clipboard persistence daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
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

  # OpenCode Server 常駐プロセス (127.0.0.1:4096 のみで待ち受け)。
  # 外部アクセスは必ず Cloudflare Tunnel (cloudflared-opencode.service) 経由。
  # X-SwitchMethod = "keep-old": セッション/作業状態を保持するため
  # home-manager switch 時は再起動しない (変更適用は手動再起動時)。
  systemd.user.services.opencode-server = {
    Unit = {
      Description = "OpenCode Server (127.0.0.1:4096)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.llm-agents.opencode}/bin/opencode serve --hostname 127.0.0.1 --port 4096";
      # ghq 管理下のリポジトリ (~/.ghq) をサーバーのデフォルト作業ディレクトリにする。
      # クライアント側は oc 関数が --dir "$PWD" を渡すため、これは主に
      # --dir 指定なしで attach した際のデフォルトプロジェクトに効く。
      WorkingDirectory = "%h/.ghq";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # opencode.comamoca.dev → OpenCode Server への Cloudflare Tunnel。
  # トークンは sops で復号された ~/.config/cloudflared/opencode-token (0600) を
  # --token-file で読み込むため、ps / プロセスリストにトークンが露出しない。
  systemd.user.services.cloudflared-opencode = {
    Unit = {
      Description = "Cloudflare Tunnel for opencode.comamoca.dev";
      After = [
        "network-online.target"
        "sops-nix.service"
        "opencode-server.service"
      ];
      Wants = [ "network-online.target" ];
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token-file ${config.sops.secrets.opencode-cloudflared-token.path}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
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
