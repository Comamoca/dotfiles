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

  src = sources.opensrc.src;
  version = sources.opensrc.version;
in
pkgs.rustPlatform.buildRustPackage {
  pname = "opensrc";
  inherit version;

  src = "${src}/packages/opensrc/cli";

  cargoLock = {
    lockFile = "${src}/packages/opensrc/cli/Cargo.lock";
  };

  # Bump to force rebuild (nixbuild.net cached failure workaround)
  preBuild = "echo opensrc rebuild";

  meta = with pkgs.lib; {
    description = "Fetch source code of dependencies for AI coding agents";
    homepage = "https://github.com/vercel-labs/opensrc";
    license = licenses.asl20;
    mainProgram = "opensrc";
  };
}
