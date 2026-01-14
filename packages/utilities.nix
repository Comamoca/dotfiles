{ pkgs }:
with pkgs;
[
  # CLI utilities
  tldr
  lsd
  jnv
  jq
  dasel
  jless
  teip
  tokei
  tree
  unar
  sd
  bat
  ripgrep
  fd
  fzf

  # System tools
  htop
  bottom

  # Network tools
  httpie
  wget
  curl
  k6

  # Monitoring
  playerctl
  pavucontrol
  pulsemixer

  happy-coder
]
