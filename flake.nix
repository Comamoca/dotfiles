{
  #ref: https://github.com/yasunori0418/dotfiles/blob/485eee2794c2e5217823b7bba5201e9f9fe16d1e/flake.nix#L2
  description = "My dotfiles, all my effort, my sword.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      treefmt-nix,
      catppuccin,
      neovim-nightly-overlay,
      emacs-overlay,
      emacs,
      nak,
      mozilla-overlay,
      nur-packages,
      disko,
      xremap,
    }@inputs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      overlays = [
        neovim-nightly-overlay.overlays.default
        (import emacs-overlay)
        nak.overlays.default
        # (import emacs.overlay)
        mozilla-overlay.overlays.firefox
      ];
    in
    # code = _: s: s;
    {
      formatter.x86_64-linux = treefmtEval.config.build.wrapper;

      checks.x86_64-linux = {
        format = treefmtEval.config.build.wrapper;
      };

      nixosConfigurations = {
        NixOS = inputs.nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            inputs.catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            # xremap.nixosModules.default
            # disko.nixosModules.disko
            # ({ config, ... }: {
            #   # system.stateVersion = config.system.stateVersion;
            #   disko.devices.disk.main.imageSize = "10G";
            # })
            ./configuration.nix
            # {
            #   nixpkgs.overlays = overlays ++ [
            #     (final: prev: {
            #       xremap = xremap.packages.${system}.default;
            #     })
            #   ];
            # }
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };
      homeConfigurations = {
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
            inputs.catppuccin.homeManagerModules.catppuccin
            {
              nixpkgs.overlays = overlays ++ [
                (final: prev: {
                  # nak = inputs.nak.packages.x86_64-linux.default;
                  xremap = xremap.packages.${"x86_64-linux"}.default;
                })
              ];
            }
          ];
        };
      };

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          lua-language-server
          stylua
          nil
        ];

        inputsFrom =
          [
          ];

        # shellHook = ''
        #   export DEBUG=1
        # '';
      };
    };
}
