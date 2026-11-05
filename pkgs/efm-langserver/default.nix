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

  src = sources.efm-langserver.src;
  version = sources.efm-langserver.version;
in
pkgs.buildGoModule {
  pname = "efm-langserver";
  inherit version src;

  vendorHash = "sha256-3Rz/9p1moT3rQPY3/lka9HZ16T00+bAWCc950IBTkFE=";

  ldflags = [
    "-s"
    "-w"
    "-X main.revision=${version}"
  ];

  meta = with pkgs.lib; {
    description = "General purpose Language Server that integrates external formatters and linters";
    homepage = "https://github.com/mattn/efm-langserver";
    license = licenses.mit;
    mainProgram = "efm-langserver";
  };
}
