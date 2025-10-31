{ pkgs, nurpkgs }:
with pkgs; [
  # Misc tools
  zenn-cli
  comma
  nb
  w3m
  nixVersions.nix_2_28
  godot
  arduino
  meson
  act
  aider-chat
  algia
  polybarFull
  devenv
  libnotify
  zf
  jo
  gitify
  kickstart
  xsel
  nix-search-cli
  jwt-cli
  nix-prefetch-scripts
  vhs
  hyperfine
  sqlite
  graphviz
  multimarkdown
  wakatime
  wakatime-cli
  cachix
  nix-output-monitor
  lazydocker
  cmigemo

  # Social
  nurpkgs.bsky
]
