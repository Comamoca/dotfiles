{
  description = "nvl: self-contained Neovim with nix-managed plugins";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    { nixpkgs, neovim-nightly-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ neovim-nightly-overlay.overlays.default ];
      };
    in
    {
      packages.${system} = rec {
        default = nvl;
        nvl = import ./default.nix {
          inherit pkgs;
          neovim = pkgs.neovim;
        };
      };
    };
}