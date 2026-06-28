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

  # Filter only shinycolors jacket entries (sc_ prefix)
  scEntries =
    builtins.filter
      (name: builtins.match "sc_.*" name != null)
      (builtins.attrNames sources);

  # Create symlink commands for each jacket image.
  # url.name is set in nvfetcher.toml, so basename gives the correct filename.
  linkCmds = builtins.concatStringsSep "\n" (
    builtins.map (name: ''
      ln -s ${sources.${name}.src} "$out/$(basename ${sources.${name}.src})"
    '') scEntries
  );
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "shinycolors-jacket";
  version = "latest";

  dontUnpack = true;

  buildPhase = ''
    mkdir -p $out
    ${linkCmds}
  '';

  installPhase = "true";

  meta = with pkgs.lib; {
    description = "THE IDOLM@STER SHINY COLORS - Jacket images from Lantis discography page";
    homepage = "https://shinycolors.lantis.jp/discography/";
    license = licenses.unfree;
  };
}
