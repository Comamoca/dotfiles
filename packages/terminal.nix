{ pkgs }:
with pkgs;
[
  # Terminal emulators
  wezterm
  alacritty
  kitty

  # Shell tools
  starship
  just
  zellij
  tmux

  # File managers
  felix-fm
  ranger
  xfce.thunar

  claude-code
]
