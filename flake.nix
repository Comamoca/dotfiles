{
  #ref: https://github.com/yasunori0418/dotfiles/blob/485eee2794c2e5217823b7bba5201e9f9fe16d1e/flake.nix#L2
  description = "My dotfiles, all my effort, my sword.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # services.ollama.package 専用。可動タグを builtins.fetchTarball + 固定
    # sha256 で取っていたため、上流が進むたび hash mismatch で評価が壊れていた。
    # flake input にして flake.lock で固定する。
    # 既存の nixpkgs とはブランチが異なる (nixpkgs-unstable vs nixos-unstable)
    # ので、統合せず別 input のままにしてある。
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mozilla-overlay.url = "github:mozilla/nixpkgs-mozilla";
    catppuccin.url = "github:catppuccin/nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs.url = "github:cmacrae/emacs";
    nak.url = "github:comamoca/flake-nak";
    nur-packages.url = "github:Comamoca/nur-packages";
    eqsh = {
      url = "github:eq-desktop/eqsh";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap.url = "github:xremap/nix-flake";
    sops-nix.url = "github:Mic92/sops-nix";
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lem.url = "github:lem-project/lem";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    niri.url = "github:sodiboo/niri-flake";
    deno-overlay.url = "github:haruki7049/deno-overlay";

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gleam-overlay.url = "github:Comamoca/gleam-overlay";
    llm-agents.url = "github:numtide/llm-agents.nix";
    go-overlay.url = "github:purpleclay/go-overlay";
    deploy-rs.url = "github:serokell/deploy-rs";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    openclaw-workspace = {
      url = "git+ssh://git@github.com/Comamoca/openclaw-workspace";
      flake = false;
    };
    worktrunk.url = "github:max-sixty/worktrunk";

    # ~/.claude/skills などエージェントの skill ディレクトリを宣言的に管理する。
    # skill の実体は ./skills/ 配下に置き、home-manager モジュールから同期する。
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-plugin-cc = {
      url = "github:openai/codex-plugin-cc/db52e28f4d9ded852ab3942cea316258ae4ef346";
      flake = false;
    };

    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # main の vendorHash が go.mod と同期切れしている (2026-08-24 時点) ため
    # セルフコンシステントな v0.18.0 タグにピン留めする。
    hister = {
      url = "github:asciimoo/hister/v0.18.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      treefmt-nix,
      chaotic,
      nix-ld,
      gleam-overlay,
      nix-index-database,
      deploy-rs,
      eqsh,
      quickshell,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      overlays = [
        # Shadow deprecated stdenv.is{Linux,Aarch64,Darwin} with the recommended
        # hostPlatform equivalents. Several external overlays still use the old
        # names and would otherwise emit evaluation warnings.
        (final: prev: {
          stdenv = prev.stdenv // {
            isLinux = prev.stdenv.hostPlatform.isLinux;
            isAarch64 = prev.stdenv.hostPlatform.isAarch64;
            isDarwin = prev.stdenv.hostPlatform.isDarwin;
          };
        })
        inputs.neovim-nightly-overlay.overlays.default
        (import inputs.emacs-overlay)
        inputs.nak.overlays.default
        inputs.deno-overlay.overlays.deno-overlay
        # (import emacs.overlay)
        inputs.mozilla-overlay.overlays.firefox
        inputs.niri.overlays.niri
        # WORKAROUND(sodiboo/niri-flake#1851): nixpkgs removed libdisplay-info_0_2
        # (2026-08-04, now a throwing alias) while niri-flake's make-niri asserts
        # version == "0.2.0". Shadow the alias with a real 0.2.0 build via the
        # generic expression still shipped in nixpkgs.
        # Remove once https://github.com/sodiboo/niri-flake/pull/1853 lands.
        (final: prev: {
          libdisplay-info_0_2 = final.callPackage (import
            "${inputs.nixpkgs}/pkgs/by-name/li/libdisplay-info/generic.nix"
            {
              version = "0.2.0";
              hash = "sha256-6xmWBrPHghjok43eIDGeshpUEQTuwWLXNHg7CnBUt3Q=";
            }
          ) { };
        })
        inputs.gleam-overlay.overlays.default
        inputs.llm-agents.overlays.shared-nixpkgs
        inputs.go-overlay.overlays.default
        # inputs.quickshell.overlays.default  # dmsバンドル版と競合するため無効化
        # openldap のフラッキーなテストをスキップ (bottles の依存)
        (final: prev: {
          openldap = prev.openldap.overrideAttrs (_: {
            doCheck = false;
          });
        })
      ];
    in
    # code = _: s: s;
    {
      formatter.x86_64-linux = treefmtEval.config.build.wrapper;

      # エディタ・CI 用の treefmt.toml を生成する。
      # treefmt.nix の設定から formatter コマンドをコマンド名で解決する形で書き出し、
      # リポジトリにコミットして素の treefmt から使えるようにする。
      #   nix build .#treefmt-toml -o treefmt-toml && cp treefmt-toml/treefmt.toml ./
      packages.x86_64-linux.treefmt-toml = treefmt-nix.lib.mkConfigFile pkgs {
        imports = [
          ./treefmt.nix
          {
            settings.formatter.nixfmt.command = "nixfmt";
            settings.formatter.taplo.command = "taplo";
            settings.formatter.deno.command = "deno";
            settings.formatter.stylua.command = "stylua";
          }
        ];
      };

      checks.x86_64-linux = {
        format = treefmtEval.config.build.wrapper;
      };

      nixosConfigurations = {
        raspi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.sops-nix.nixosModules.sops
            inputs.hermes-agent.nixosModules.default
            ./raspi/configuration.nix
          ];
        };

        WSL = inputs.nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            inputs.nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              system.stateVersion = "24.05";
              wsl.enable = true;
              environment.systemPackages = with pkgs; [
                vim
              ];
            }
          ];
        };

        NixOS = inputs.nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            # configuration.nix の sops.* (nixbuild.net トークン) に必要。
            # raspi は既に読み込んでいるが、こちらには入っていなかった。
            inputs.sops-nix.nixosModules.sops
            inputs.catppuccin.nixosModules.catppuccin
            inputs.nix-index-database.nixosModules.default
            # home-manager.nixosModules.home-manager
            inputs.xremap.nixosModules.default
            inputs.niri.nixosModules.niri
            # disko.nixosModules.disko
            # ({ config, ... }: {
            #   # system.stateVersion = config.system.stateVersion;
            #   disko.devices.disk.main.imageSize = "10G";
            # })
            ./configuration.nix
            chaotic.nixosModules.nyx-cache
            # NOTE: nyx-overlay disabled due to replaceStdenv incompatibility with current nixpkgs
            # Re-enable when chaotic-nyx is updated
            # chaotic.nixosModules.nyx-overlay
            chaotic.nixosModules.nyx-registry
            nix-ld.nixosModules.nix-ld
            {
              nixpkgs.overlays = overlays ++ [
                (final: prev: {
                  xremap = inputs.xremap.packages.${system}.default;
                  lem-ncurses = inputs.lem.packages.${system}.lem-ncurses;
                  lem-sdl2 = inputs.lem.packages.${system}.lem-sdl2;
                })
              ];
            }
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };

      homeConfigurations =
        let
          homeConfigHome = inputs.home-manager.lib.homeManagerConfiguration rec {
            pkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
            extraSpecialArgs = {
              inherit inputs;
            };
            modules = [
              ./home.nix
              inputs.catppuccin.homeModules.catppuccin
              inputs.sops-nix.homeManagerModules.sops
              inputs.dms.homeModules.dank-material-shell
              inputs.nix-index-database.homeModules.default
              inputs.hister.homeModules.default
              inputs.agent-skills.homeManagerModules.default
              {
                nixpkgs.overlays = overlays ++ [
                  inputs.deploy-rs.overlays.default
                  (final: prev: {
                    # nak = inputs.nak.packages.x86_64-linux.default;
                    ghostty = inputs.ghostty.packages.${system}.default;
                    xremap = inputs.xremap.packages.${pkgs.stdenv.hostPlatform.system}.default;
                    worktrunk = inputs.worktrunk.packages.${system}.default;
                    herdr = inputs.herdr.packages.${system}.default;
                    hunk = inputs.hunk.packages.${system}.default;
                    shinycolors-jacket = import ./pkgs/shinycolors-jacket { pkgs = final; };
                  })
                ];
              }
            ];
          };

          homeConfigWSL = inputs.home-manager.lib.homeManagerConfiguration rec {
            pkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
            extraSpecialArgs = {
              inherit inputs;
            };
            modules = [
              # ./home.nix
              ./home-manager/wsl
              inputs.catppuccin.homeModules.catppuccin
              inputs.sops-nix.homeManagerModules.sops
              inputs.nix-index-database.homeModules.default
              {
                nixpkgs.overlays = overlays ++ [
                  (final: prev: {
                    xremap = inputs.xremap.packages.${pkgs.stdenv.hostPlatform.system}.default;
                  })
                ];
              }
            ];
          };
        in
        {
          inherit homeConfigHome homeConfigWSL;
          Home = homeConfigHome;
          WSL = homeConfigWSL;
          # nh home switch の自動検出用 (username = coma, hostname = comabook)
          coma = homeConfigHome;
          "coma@comabook" = homeConfigHome;
        };

      deploy.nodes.raspi = {
        hostname = "raspi.tailbd3ca7.ts.net";
        profiles.system = {
          user = "root";
          sshUser = "coma";
          sshOpts = [
            "-o"
            "IdentitiesOnly=yes"
            "-i"
            "/home/coma/.ssh/id_ed25519"
          ];
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.raspi;
        };
      };

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          sops
          age

          lua-language-server
          stylua
          nil
        ];

        inputsFrom = [
        ];

        # shellHook = ''
        #   export DEBUG=1
        # '';
      };
    };
}
