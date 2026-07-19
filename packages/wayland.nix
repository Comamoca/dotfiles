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

  # モニターホットプラグ検出とプロファイル切り替え（niri）
  kanshi

  # quickshellはdmsバンドル版を使用するため追加不要
  # quickshell
  # qt6.qtmultimedia
  # qt6.qtsvg
  # qt6.qtimageformats
  # qt6.qt5compat
]
