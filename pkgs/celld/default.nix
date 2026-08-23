# Entry point for this repository's `{ pkgs }` convention.
# The standalone flake in this directory uses ./package.nix directly.
{ pkgs }:
pkgs.callPackage ./package.nix { }
