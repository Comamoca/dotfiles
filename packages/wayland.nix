{ pkgs }:
with pkgs;
[
  # Wayland tools
  qpwgraph
  gammastep
  showmethekey

  (import ../pkgs/wl-mirror { inherit pkgs; })
  (import ../pkgs/niri-scratchpad { inherit pkgs; })

  # Audio
  # sonic-pi
]
