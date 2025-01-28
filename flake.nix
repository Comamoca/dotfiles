{
  #ref: https://github.com/yasunori0418/dotfiles/blob/485eee2794c2e5217823b7bba5201e9f9fe16d1e/flake.nix#L2
  description = "My dotfiles, all my effort, my sword.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # nixpkgs.url = "git+https://github.com/nixos/nixpkgs?shallow=1&ref=nixos-unstable-small";
    # nixpkgs.url = "github:NixOS/nixpkgs/336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
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
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap.url = "github:xremap/nix-flake";
    sops-nix.url = "github:Mic92/sops-nix";
    ghostty.url = "github:ghostty-org/ghostty";
    lem.url = "github:lem-project/lem";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      treefmt-nix,
      ...
    }@inputs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
        (import inputs.emacs-overlay)
        inputs.nak.overlays.default
        # (import emacs.overlay)
        inputs.mozilla-overlay.overlays.firefox
      ];
    in
    # code = _: s: s;
    {
      formatter.x86_64-linux = treefmtEval.config.build.wrapper;

      checks.x86_64-linux = {
        format = treefmtEval.config.build.wrapper;
      };

      nixosConfigurations = {
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
            inputs.nix-index-database.nixosModules.nix-index
            home-manager.nixosModules.home-manager
            inputs.xremap.nixosModules.default
            # disko.nixosModules.disko
            # ({ config, ... }: {
            #   # system.stateVersion = config.system.stateVersion;
            #   disko.devices.disk.main.imageSize = "10G";
            # })
            ./configuration.nix
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
          system = "x86_64-linux";

          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            # ./home.nix
            ./home-manager/wsl
            inputs.catppuccin.homeManagerModules.catppuccin
            inputs.sops-nix.homeManagerModules.sops
            inputs.nix-index-database.hmModules.nix-index
            {
              nixpkgs.overlays = overlays ++ [
                (final: prev: {
                  xremap = inputs.xremap.packages.${system}.default;
                })
              ];
            }
          ];
        };

        Home = inputs.home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-linux";

          pkgs = import inputs.nixpkgs { 
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            ./home.nix
            inputs.catppuccin.homeManagerModules.catppuccin
            inputs.sops-nix.homeManagerModules.sops
            inputs.nix-index-database.hmModules.nix-index
            {
              nixpkgs.overlays = overlays ++ [
                (final: prev: {
                  # nak = inputs.nak.packages.x86_64-linux.default;
                  ghostty = inputs.ghostty.packages.x86_64-linux.default;
                  xremap = inputs.xremap.packages.${system}.default;
                })
              ];
            }
          ];
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
