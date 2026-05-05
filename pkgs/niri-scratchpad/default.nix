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

  src = sources.niri-scratchpad.src;
  version = sources.niri-scratchpad.version;
in
pkgs.rustPlatform.buildRustPackage {
  pname = "niri-scratchpad";
  inherit version src;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Scratchpad window manager for the niri compositor";
    homepage = "https://github.com/argosnothing/niri-scratchpad-rs";
    license = licenses.gpl3Only;
    mainProgram = "niri-scratchpad";
  };
}
