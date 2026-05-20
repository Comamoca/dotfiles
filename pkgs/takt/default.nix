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

  src = sources.takt.src;
  version = sources.takt.version;
in
pkgs.buildNpmPackage {
  pname = "takt";
  inherit version src;

  npmDepsHash = "sha256-fLbB77Q8AJ24qnS5+t2t0WTAG8hhjIubU4oTtK1+Uk8=";

  meta = with pkgs.lib; {
    description = "AI Agent Piece Orchestration tool";
    homepage = "https://github.com/nrslib/takt";
    license = licenses.mit;
    mainProgram = "takt";
  };
}
