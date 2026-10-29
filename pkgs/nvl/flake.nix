{
  description = "nvl: self-contained Neovim with nix-managed plugins";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages.${system}.default = import ./default.nix {
        inherit pkgs;
        neovim = pkgs.neovim;
      };

      packages.${system}.nvl = import ./default.nix {
        inherit pkgs;
        neovim = pkgs.neovim;
      };
    };
}