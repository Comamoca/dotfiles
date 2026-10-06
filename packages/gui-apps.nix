{ pkgs, nurpkgs }:
with pkgs;
[
  # Browsers
  google-chrome

  # Communication
  slack
  teams-for-linux
  # discord — configuration.nix のシステムラッパー (WebRTCPipeWireCapturer 付き) を使う。
  # ここに生の discord を入れると ~/.nix-profile/bin/discord が PATH で先になり、
  # ラッパーが効かず Niri (Wayland) での画面共有が壊れる。
  signal-desktop

  # Media
  spotify
  vlc
  imv

  # Utilities
  bottles
  gnome-pomodoro
  termshot
  immersed
]
