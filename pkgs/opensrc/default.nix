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
pkgs.buildNpmPackage {
  pname = "opensrc";
  inherit version src;

  npmDepsHash = pkgs.lib.fakeHash;

  meta = with pkgs.lib; {
    description = "Fetch source code of dependencies for AI coding agents";
    homepage = "https://github.com/vercel-labs/opensrc";
    license = licenses.mit;
    mainProgram = "opensrc";
  };
}
