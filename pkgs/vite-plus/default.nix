# Entry point for this repository's `{ pkgs }` convention.
{ pkgs }:
let
  generated = import ../../_sources/generated.nix;
  sources = generated {
    inherit (pkgs)
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };

  # nvfetcher 管理のプラットフォーム別 CLI バイナリ (nvfetcher.toml の vite-plus-cli-*)
  cliBinaries = {
    x86_64-linux = sources.vite-plus-cli-linux-x64-gnu.src;
    aarch64-linux = sources.vite-plus-cli-linux-arm64-gnu.src;
    x86_64-darwin = sources.vite-plus-cli-darwin-x64.src;
    aarch64-darwin = sources.vite-plus-cli-darwin-arm64.src;
  };

  version = sources.vite-plus-cli-linux-x64-gnu.version;
in
pkgs.callPackage ./package.nix { inherit version cliBinaries; }
