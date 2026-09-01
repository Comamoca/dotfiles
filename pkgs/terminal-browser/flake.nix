{
  description = "terminal-browser - a browser in a terminal pane (prebuilt release)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      overlay = final: prev: {
        terminal-browser = final.callPackage ./package.nix { };
      };
    in
    {
      overlays.default = overlay;
    }
    // flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        terminal-browser = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          inherit terminal-browser;
          default = terminal-browser;
        };

        apps.default = {
          type = "app";
          program = "${terminal-browser}/bin/terminal-browser";
          meta.description = "Run terminal-browser";
        };

        formatter = pkgs.nixfmt-tree;
      }
    );
}
