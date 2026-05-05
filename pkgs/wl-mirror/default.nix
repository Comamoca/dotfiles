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

  src = sources.wl-mirror.src;
  version = sources.wl-mirror.version;
in
pkgs.stdenv.mkDerivation {
  pname = "wl-mirror";
  inherit version src;

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    wayland-scanner
    scdoc
  ];

  buildInputs = with pkgs; [
    wayland
    wayland-protocols
    wlr-protocols
    libGL
    libglvnd
  ];

  cmakeFlags = [
    "-DWITH_GBM=OFF"
    "-DINSTALL_EXAMPLE_SCRIPTS=OFF"
    "-DINSTALL_DOCUMENTATION=ON"
    "-DFORCE_SYSTEM_WL_PROTOCOLS=ON"
    "-DFORCE_SYSTEM_WLR_PROTOCOLS=ON"
    "-DWL_PROTOCOL_DIR=${pkgs.wayland-protocols}/share/wayland-protocols"
    "-DWLR_PROTOCOL_DIR=${pkgs.wlr-protocols}/share/wlr-protocols"
  ];

  meta = with pkgs.lib; {
    description = "A simple Wayland output mirror client";
    homepage = "https://github.com/Ferdi265/wl-mirror";
    license = licenses.gpl3Plus;
    mainProgram = "wl-mirror";
    platforms = platforms.linux;
  };
}
