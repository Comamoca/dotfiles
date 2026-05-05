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

  src = sources.git-wt.src;
  version = sources.git-wt.version;
in
pkgs.buildGoModule {
  pname = "git-wt";
  inherit version src;

  vendorHash = "sha256-jXGG5CbJSy4FeLNT/IEOzoHlxrXOnf+WLjFUHno/C+w=";

  doCheck = false;

  postPatch = ''
    substituteInPlace go.mod --replace-fail 'go 1.25.7' 'go 1.25'
  '';

  overrideModAttrs = _: {
    preBuild = ''
      go mod tidy
    '';
  };

  meta = with pkgs.lib; {
    description = "A git worktree management tool";
    homepage = "https://github.com/k1LoW/git-wt";
    license = licenses.mit;
    mainProgram = "git-wt";
  };
}
