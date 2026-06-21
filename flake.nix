{
  #ref: https://github.com/yasunori0418/dotfiles/blob/485eee2794c2e5217823b7bba5201e9f9fe16d1e/flake.nix#L2
  description = "My dotfiles, all my effort, my sword.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    ghostty.url = "github:ghostty-org/ghostty";
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
        inputs.neovim-nightly-overlay.overlays.default
        (import inputs.emacs-overlay)
        inputs.nak.overlays.default
        inputs.deno-overlay.overlays.deno-overlay
        # (import emacs.overlay)
        inputs.mozilla-overlay.overlays.firefox
        inputs.niri.overlays.niri
        inputs.gleam-overlay.overlays.default
        inputs.llm-agents.overlays.default
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

      homeConfigurations = {
        WSL = inputs.home-manager.lib.homeManagerConfiguration rec {
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

        Home = inputs.home-manager.lib.homeManagerConfiguration rec {
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
            {
              nixpkgs.overlays = overlays ++ [
                inputs.deploy-rs.overlays.default
                (final: prev: {
                  # nak = inputs.nak.packages.x86_64-linux.default;
                  ghostty = inputs.ghostty.packages.x86_64-linux.default;
                  xremap = inputs.xremap.packages.${pkgs.stdenv.hostPlatform.system}.default;
                  worktrunk = inputs.worktrunk.packages.x86_64-linux.default;
                })
              ];
            }
          ];
        };
      };

      deploy.nodes.raspi = {
        hostname = "raspi.tailbd3ca7.ts.net";
        profiles.system = {
          user = "root";
          sshUser = "coma";
          sshOpts = [ "-o" "IdentitiesOnly=yes" "-i" "/home/coma/.ssh/id_ed25519" ];
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
