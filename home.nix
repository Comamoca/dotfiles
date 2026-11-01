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
  dotfiles = "/home/${username}/.ghq/github.com/Comamoca/dotfiles";

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
          # lispyのle-swiper.elはコンパイル時にswiperを硬要求するが、
          # nixpkgs 044bfe75のemacs-git-pgtkパッケージセットでは生成されたlispyの
          # packageRequiresが欠落している(iedit/swiper等がビルド環境に入らない)。
          # さらにmelpaBuildは.override引数を転送しないため
          # `lispy.override { ignoreCompilationError = true; }`は無効で、
          # ignore-compilation-error=nilのままビルドが致命的失敗する。
          # nixpkgsのignoreCompilationErrorヘルパーと同じoverrideAttrs形式で
          # フラグを設定し、依存を明示的に復元する。依存を戻さないと
          # lispyvilleのバイトコンパイル時にlispy.elの(require 'iedit)で
          # マクロ展開が失敗する。
          lispy = esuper.lispy.overrideAttrs (old: {
            ignoreCompilationError = true;
            packageRequires = with eself; [
              ace-window
              hydra
              iedit
              swiper
              zoutline
            ];
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
  imports = [
    ./forgejo.nix
    ./maestro.nix
    ./omniroute.nix
    ./omnigent.nix
    ./cloudflare-os-service.nix
  ];
  nixpkgs.config = {
    allowUnfree = true;
    # python3.14-posthog 7.71.0 は mcp >= 2 で meta.broken = true になっており、
    # 依存しているだけで評価が Refusing to evaluate で落ちる (aider-chat 経由)。
    # 実行時に壊れているわけではないので warn に落として通す。
    problems.handlers.posthog.broken = "warn";
    permittedInsecurePackages = [
      "electron-29.4.6"
    ];
    android_sdk.accept_license = true;
  };

  # python3.14-typecode 30.2.0 の test 2 件が nixpkgs で落ち、それを引く
  # scancode-toolkit → ort がビルドできない。テストだけスキップする。
  nixpkgs.overlays = [
    (final: prev: {
      python3Packages = prev.python3Packages.overrideScope (
        pfinal: pprev: {
          typecode = pprev.typecode.overridePythonAttrs (old: {
            doCheck = false;
          });
          scancode-toolkit = pprev.scancode-toolkit.overridePythonAttrs (old: {
            dependencies = map (d: if (d.pname or "") == "typecode" then pfinal.typecode else d) (
              old.dependencies or [ ]
            );
          });
        }
      );
    })
  ];

  sops = {
    age.keyFile = "${home.homeDirectory}/.config/sops/age/keys.txt";
    # age.keyFile = "/home/coma/.config/sops/age/keys.txt";
    # # It's also possible to use a ssh key, but only when it has no password:
    # # age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
    defaultSopsFile = ./secrets/secrets.yaml;
    secrets = {
      "claude-code" = {
        sopsFile = ./secrets/claude-code.env;
        path = "/run/user/1000/claude-code.env";
        format = "dotenv";
      };
      "aider-opencode-go" = {
        sopsFile = ./secrets/aider-opencode-go.env;
        path = "/run/user/1000/aider-opencode-go.env";
        format = "dotenv";
      };
      # maestro と agent (opencode) がローカル Forgejo へ push/PR/issue 操作する
      # ためのトークン。maestro.service の EnvironmentFile として読まれる。
      "forgejo" = {
        sopsFile = ./secrets/forgejo.env;
        path = "/run/user/1000/forgejo.env";
        format = "dotenv";
      };
      # OmniRoute の管理 API キー (/v1 の Bearer) と dashboard 初期パスワード。
      # omniroute.service の env_file として読まれる。
      "omniroute" = {
        sopsFile = ./secrets/omniroute.env;
        path = "/run/user/1000/omniroute.env";
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
      # Cloudflare Tunnel (dsh.comamoca.dev) のトンネルトークン。
      # opencode 用と同じ流儀で --token-file から読み、ps に露出させない。
      # 0600 で ~/.config/cloudflared/dsh-token に復号される。
      #
      # 値は Cloudflare でトンネルを作成した後に取得する (手順は下の
      # cloudflared-dsh サービス付近のコメントを参照)。現在はプレースホルダが
      # 入っているだけなので、トンネル作成までは cloudflared-dsh が再起動を
      # 繰り返す。sops で値を差し替えるには:
      #   sops secrets/dsh-cloudflared-token.yaml
      "dsh-cloudflared-token" = {
        sopsFile = ./secrets/dsh-cloudflared-token.yaml;
        key = "dsh-cloudflared-token";
        path = "${home.homeDirectory}/.config/cloudflared/dsh-token";
        format = "yaml";
        mode = "0600";
      };
      # Cloudflare Tunnel (omniroute.comamoca.dev) のトンネルトークン。
      # トンネル名 "omniroute" (id: cffdea8c-4266-407c-b9d4-694f5d6aaf73) は
      # `cf zero-trust tunnels cloudflared create --config-src cloudflare` で作成。
      # 0600 で ~/.config/cloudflared/omniroute-token に復号される。
      "omniroute-cloudflared-token" = {
        sopsFile = ./secrets/omniroute-cloudflared-token.yaml;
        key = "omniroute-cloudflared-token";
        path = "${home.homeDirectory}/.config/cloudflared/omniroute-token";
        format = "yaml";
        mode = "0600";
      };
      # Cloudflare Tunnel (omnigent.comamoca.dev) のトンネルトークン。
      # トンネル名 "omnigent" (id: af3ac346-6175-4e95-a6f9-e6ef582a9320) は
      # `cf zero-trust tunnels cloudflared create --name omnigent` で作成し、
      # ingress は omnigent.comamoca.dev → http://127.0.0.1:14197。
      # 0600 で ~/.config/cloudflared/omnigent-token に復号される。
      "omnigent-cloudflared-token" = {
        sopsFile = ./secrets/omnigent-cloudflared-token.yaml;
        key = "omnigent-cloudflared-token";
        path = "${home.homeDirectory}/.config/cloudflared/omnigent-token";
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
      input-remapper # Wacom ペンタブの ExpressKeys を Krita 用キーに変換

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
      dotfiles = /${home.homeDirectory}/.ghq/github.com/Comamoca/dotfiles;
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

      # rootless docker (rootlesskit の --copy-up=/etc) は namespace 内の /etc/ssl の
      # CA シンボリックを壊し、レジストリへの TLS 検証が失敗する (docker pull が
      # "certificate signed by unknown authority" で落ちる)。
      # CA を Nix ストアから直接指定して回避する。
      ".config/systemd/user/docker.service.d/ca.conf".text = ''
        [Service]
        Environment=SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
        Environment=SSL_CERT_DIR=${pkgs.cacert}/etc/ssl/certs
      '';

      # docker compose のイメージビルドが BuildKit (TARGETARCH) を必要とするため
      # buildx プラグインを配置 (無いと classic builder にフォールバックして
      # イメージビルドが "TARGETARCH: parameter not set" で失敗する)。
      ".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";

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
      ".bin/scripts/cursor-switch.sh" = {
        source = (symlink /${dotfiles}/bin/scripts/cursor-switch.sh);
      };
      ".bin/scripts/flake-lock-save" = {
        source = (symlink /${dotfiles}/bin/scripts/flake-lock-save);
      };

      # ========== SKK ==========
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

      # OmniRoute で追加した combo を opencode のモデル一覧に自動で載せる。
      # 一覧の生成は omniroute.nix の omniroute-combos.timer が行う。
      ".config/opencode/plugins/omniroute-combos.ts".source = (
        symlink /${dotfiles}/config/opencode/plugins/omniroute-combos.ts
      );

      # combo の推定単価。プラグインがプラグインと同じディレクトリから読む。
      ".config/opencode/plugins/omniroute-combo-cost.json".source = (
        symlink /${dotfiles}/config/opencode/omniroute-combo-cost.json
      );

      # combo の推定単価 (メンバー料金の重み付き平均)。
      # プラグインが combo をモデル登録するときに cost として付ける。
      ".config/opencode/omniroute-combo-cost.json".source = (
        symlink /${dotfiles}/config/opencode/omniroute-combo-cost.json
      );

      # input-remapper: Wacom ペンタブ ExpressKeys → Krita 用キー(F13-F16)変換
      # デバイス別プリセットディレクトリは activation スクリプト(setupWacomInputRemapper)で
      # デバイス名を検出して配置する。ここではテンプレートとして symlink を張る。
      ".config/input-remapper-2/presets/_wacom-krita-template/wacom-krita.json".source = (
        symlink /${dotfiles}/config/input-remapper/wacom-krita.json
      );

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

    # カーソルテーマ - niri config と同期すること
    XCURSOR_THEME = "Morino Rinze";
    XCURSOR_SIZE = "75";

    # TTY が無い (coding agent など) 状況の sudo で GUI パスワードプロンプトを出す
    SUDO_ASKPASS = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

    # sccache: Rust compilation cache
    RUSTC_WRAPPER = "sccache";
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

    # カーソルテーマ - niri config と同期すること
    XCURSOR_THEME = "Morino Rinze";
    XCURSOR_SIZE = "75";
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

    # 同期は rsync --delete なので、ここに無いエントリは各配布先から消える。
    # /synced は外部の skill 同期ツールが ~/.agents/skills/synced に置いている
    # managed tree なので、消さないよう除外する (既定は "/.system" のみ)。
    excludePatterns = [
      "/.system"
      "/synced"
    ];

    # 配布先ごとの skill ディレクトリ。既定で有効なのは claude のみなので、
    # 使っているエージェントを明示的に有効化する。
    # opencode / claude / pi は agent-skills-nix 組み込みの target 名。
    # 既定値は上流 lib/targets.nix の defaultTargets と対応しており、
    # ここでは意図を読めるよう dest も明示している (path は実機で確認済み)。
    targets = {
      # Claude Code: ~/.claude/skills
      # (CLAUDE_CONFIG_DIR を設定している場合も既定の ~/.claude に揃える)
      claude = {
        enable = true;
        dest = "$HOME/.claude/skills";
      };

      # opencode: ~/.config/opencode/skills
      # opencode は global として <config>/opencode/skill(s)/ を走査する
      # (実機で `opencode debug skill` により discovery を確認済み)。
      opencode = {
        enable = true;
        dest = "$HOME/.config/opencode/skills";
      };

      # pi: ~/.pi/agent/skills
      # pi は <agentDir>/skills を読み、既定 agentDir は ~/.pi/agent。
      pi = {
        enable = true;
        dest = "$HOME/.pi/agent/skills";
      };

      # jcode: ~/.jcode/skills
      # jcode は ~/.jcode/skills/<name>/SKILL.md を global skill として読む。
      # 組み込み target が無いので独自 target として定義する。
      jcode = {
        enable = true;
        dest = "$HOME/.jcode/skills";
      };

      # omp (oh-my-pi): ~/.omp/agent/skills
      # omp は pi 系で <agentDir>/skills を読み、omp の agentDir は ~/.omp/agent。
      # 組み込み target が無いので独自 target として定義する。
      omp = {
        enable = true;
        dest = "$HOME/.omp/agent/skills";
      };

      # DeepSeek Harness: ~/.agents/skills
      # dsh は共有 root の ~/.agents/skills を rank 500 (user-agents) で走査する。
      # omp / pi / opencode も同じ ~/.agents/skills を読むため、ここに入れておくと
      # これらにも同時に届く (dsh 専用ディレクトリは用意されていない)。
      # 組み込み target が無いので独自 target として定義する。
      agents = {
        enable = true;
        dest = "$HOME/.agents/skills";
      };
    };
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
        "${homeDirectory}/.ghq/github.com/Comamoca/glanty".trust_level = "trusted";
        "${homeDirectory}/sandbox/litellm".trust_level = "trusted";
      };
    };
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
        normal = {
          family = "UDEV Gothic NFLG";
        };
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
    dank-material-shell = {
      enable = true;
      # khal 0.14.1 は nixpkgs の sphinxHook が man 出力を作れずビルドできない。
      # カレンダー連携だけを外して home-manager のビルドを通す。
      enableCalendarEvents = false;
    };
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

  # Spotify はユーザー名/パスワード認証を廃止済みのため、認証情報は
  # `spotifyd authenticate` (OAuth) で生成され ~/.cache/spotifyd/oauth に
  # キャッシュされる。ここでの username/password_cmd 設定は無効なため削除済み。
  services.spotifyd = {
    enable = true;
    settings = {
      # dank-material-shell 等が MPRIS 経由で再生中トラックを表示できるように有効化
      global = {
        use_mpris = true;
        # spotifyd が出せる最大音質 (Ogg Vorbis 320kbps、Premium 必須)
        # 本家 Spotify の Lossless (FLAC) は librespot 系クライアント未対応
        bitrate = 320;
      };
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

  # DSH Web をログイン時に常駐させる。待ち受け自体はループバックのみで、
  # 外部アクセスは Cloudflare Tunnel (cloudflared-dsh.service) 経由。
  # 起動URL（認証トークン付き）は journalctl --user -u dsh-web で確認する。
  # 同一ホストへのアタッチは dsh-tui の dsh-remote バックエンドが担う
  # (docs/dsh-tui-attach-research.md、fish の dta 略語)。
  #
  # dsh web はトンネル越しに使うために 2 つの指定が要る:
  #   --public-url  : 印字・起動される URL を公開ホスト名にする。信頼は付与しない。
  #   --trusted-host: /api の Host/Origin フェンスが受け入れる authority。
  #                   これが無いとトンネル経由のリクエストは 403 で拒否される
  #                   (ループバックと待ち受けIPは既定で許可、それ以外は拒否)。
  # 認証は launch token のまま: トークン付き ?token= で / にアクセスすると
  # 30 日有効の署名 Cookie が発行され、以後 https://dsh.comamoca.dev/ で入れる。
  # 新しいトークンは再起動時に発行されるので journalctl のログから取り直す。
  #
  # ポート 14198: omniroute (20128 = 20 + 128) と同じく
  # 「頭の 0 を除いた 1xxxx + 末尾 4 桁」に D-S-H のアルファベット順位
  # (4, 19, 8 → 04198) を埋めた専用番号。一般的な Web 開発ポート
  # (3000/4200/5173/8000/8080 など) や 10000 未満の開発用帯域を避ける。
  systemd.user.services.dsh-web = {
    Unit = {
      Description = "DSH Web (127.0.0.1:14198)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      # switch による実行中セッションの中断を避ける。
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.llm-agents.dsh}/bin/dsh web --no-open \
          --host 127.0.0.1 --port 14198 \
          --public-url https://dsh.comamoca.dev \
          --trusted-host dsh.comamoca.dev
      '';
      WorkingDirectory = "%h";
      # yolo 常駐: sandbox=danger-full-access, approval=never。
      # dsh-base の cordis.patch.yml が DSH_PERMISSION_MODE を見て
      # sandbox モードと承認ポリシーを同時に切り替える (--yolo フラグは無い)。
      # 注意: dsh.comamoca.dev のトンネル経由で外部から到達できるため、
      # ここでエージェントは全操作を無承認で実行する。
      #
      # 外部到達の守りは Cloudflare Access アプリ "dsh" (IdP: Cloudflare,
      # 許可: comamoca.dev@gmail.com, セッション 24h) が担う。
      # DSH 自身の launch token 認証は意図的に残している (二重防御)。認証は
      # dsh-client-connection に埋め込まれており無効化オプションが無いため、
      # 消すにはモンキーパッチが要る。このエージェントは無承認で任意コードを
      # 実行できるので、認証を外すと同ホストの任意プロセスに owner 権限の
      # RCE を渡すことになる。bind は必ず 127.0.0.1 のままにする。
      # 初回のみ ?token= 付き URL で入り、以後 30 日は Cookie で通る。
      # トークンは journalctl --user -u dsh-web から取得する。
      Environment = [
        "DSH_HOME=%h/.dsh"
        "DSH_PERMISSION_MODE=danger-full-access"
      ];
      Restart = "on-failure";
      RestartSec = 3;
      UMask = "0077";
    };
    Install.WantedBy = [ "default.target" ];
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
      # クライアント側は oc / opencode 関数 (config/fish/functions/) が
      # --dir "$PWD" を渡すため、これは主に --dir 指定なしで attach した際の
      # デフォルトプロジェクトに効く。
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

  # dsh.comamoca.dev → DSH Web (127.0.0.1:14198) への Cloudflare Tunnel。
  # cloudflared-opencode と同構成: トークンは sops で復号された
  # ~/.config/cloudflared/dsh-token (0600) を --token-file で読む。
  #
  # 事前に Cloudflare 側で次を済ませておく (ダッシュボードでも CLI でも可):
  #   1. Zero Trust → Tunnels で dsh 用トンネルを新規作成
  #   2. Public Hostname: dsh.comamoca.dev → http://127.0.0.1:14198
  #   3. 発行されたトンネルトークンを secrets/dsh-cloudflared-token.yaml に sops で格納
  # トンネルが未作成のまま起動すると cloudflared は再起動を繰り返す。
  systemd.user.services.cloudflared-dsh = {
    Unit = {
      Description = "Cloudflare Tunnel for dsh.comamoca.dev";
      After = [
        "network-online.target"
        "sops-nix.service"
        "dsh-web.service"
      ];
      Wants = [ "network-online.target" ];
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token-file ${config.sops.secrets.dsh-cloudflared-token.path}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # omnigent.comamoca.dev → Omnigent server (127.0.0.1:14197) への
  # Cloudflare Tunnel。omniroute と同構成 (トンネルは remotely-managed なので
  # ingress は Cloudflare 側の設定が正本)。
  #
  # 守りは Cloudflare Access アプリ "omnigent"
  # (id: a201ed2a-a2b5-4168-ba5f-c710175c282c, IdP: Cloudflare,
  #  許可: comamoca.dev@gmail.com, セッション 24h) が担う。Access は
  # Cf-Access-Authenticated-User-Email を注入するので、Omnigent 側は
  # header 認証モードでそのヘッダを信頼する (omnigent.nix の
  # OMNIGENT_AUTH_HEADER を参照)。待ち受けは 127.0.0.1 のまま。
  systemd.user.services.cloudflared-omnigent = {
    Unit = {
      Description = "Cloudflare Tunnel for omnigent.comamoca.dev";
      After = [
        "network-online.target"
        "sops-nix.service"
        "omnigent.service"
      ];
      Wants = [ "network-online.target" ];
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token-file ${config.sops.secrets.omnigent-cloudflared-token.path}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # omniroute.comamoca.dev → OmniRoute dashboard (127.0.0.1:20128) への
  # Cloudflare Tunnel。dsh と同構成 (トンネルは remotely-managed なので
  # ingress は Cloudflare 側の設定が正本)。
  #
  # 守りは Cloudflare Access アプリ "omniroute"
  # (id: 636aa554-8ec1-466a-88e1-06f4c1ed3f7c, IdP: Cloudflare,
  #  許可: comamoca.dev@gmail.com, セッション 24h) が担う。
  # OmniRoute の dashboard は管理 API キーや provider の鍵に届くため、
  # /v1 も含めて Access の外に出さない。待ち受けは 127.0.0.1 のまま。
  systemd.user.services.cloudflared-omniroute = {
    Unit = {
      Description = "Cloudflare Tunnel for omniroute.comamoca.dev";
      After = [
        "network-online.target"
        "sops-nix.service"
        "omniroute.service"
      ];
      Wants = [ "network-online.target" ];
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token-file ${config.sops.secrets.omniroute-cloudflared-token.path}";
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
    bat.enable = true;
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
