{
  description = "Home Manager configuration of coma";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixgl.url = "github:nix-community/nixGL";

    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lem-editor = {
      url = "github:dariof4/lem-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, neovim-nightly, lem-editor, nixgl, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      overlays = [
        neovim-nightly.overlays.default
        nixgl.overlay
      ]; 
    in {
      homeConfigurations."coma" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          { nixpkgs.overlays = overlays; }
          # lem-editor.packages.${system}.lem-ncurses
        ];
        extraSpecialArgs = { inherit inputs; };

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
