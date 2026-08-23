{
  description = "celld - self-hosted, distributed Durable Objects (prebuilt release binaries)";

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
        "aarch64-darwin"
      ];

      overlay = final: prev: {
        celld = final.callPackage ./package.nix { };
      };
    in
    {
      overlays.default = overlay;
    }
    // flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        celld = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          inherit celld;
          default = celld;
        };

        apps.default = {
          type = "app";
          program = "${celld}/bin/celld";
          meta.description = "Run celld";
        };

        devShells.default = pkgs.mkShell {
          packages = [
            celld
            pkgs.esbuild
          ];
        };

        formatter = pkgs.nixfmt-tree;
      }
    );
}
