# flake input 由来の overlay と個別パッケージの pin。
# system は外側の引数に依存せず final から導出する (raspi は aarch64-linux)。
inputs: final: prev:
builtins.foldl' (acc: overlay: acc // overlay final acc) prev [
  inputs.neovim-nightly-overlay.overlays.default
  (import inputs.emacs-overlay)
  # (import emacs.overlay)
  inputs.nak.overlays.default
  inputs.deno-overlay.overlays.deno-overlay
  inputs.mozilla-overlay.overlays.firefox
  inputs.niri.overlays.niri
  inputs.gleam-overlay.overlays.default
  inputs.llm-agents.overlays.shared-nixpkgs
  inputs.go-overlay.overlays.default
  # inputs.quickshell.overlays.default  # dmsバンドル版と競合するため無効化
  inputs.deploy-rs.overlays.default
  (final: prev: {
    ghostty = inputs.ghostty.packages.${final.stdenv.hostPlatform.system}.default;
    xremap = inputs.xremap.packages.${final.stdenv.hostPlatform.system}.default;
    worktrunk = inputs.worktrunk.packages.${final.stdenv.hostPlatform.system}.default;
    herdr = inputs.herdr.packages.${final.stdenv.hostPlatform.system}.default;
    hunk = inputs.hunk.packages.${final.stdenv.hostPlatform.system}.default;
    lem-ncurses = inputs.lem.packages.${final.stdenv.hostPlatform.system}.lem-ncurses;
    lem-sdl2 = inputs.lem.packages.${final.stdenv.hostPlatform.system}.lem-sdl2;
  })
]
