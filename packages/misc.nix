{ pkgs, nurpkgs }:
with pkgs;
[
  # Misc tools
  zenn-cli
  nb
  w3m
  nixVersions.nix_2_34
  godot
  arduino
  meson
  act
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
  wakatime-cli
  cachix
  nix-output-monitor
  lazydocker
  cmigemo
  bubblewrap

  # Social
  nurpkgs.bsky

  pinta
  krita
  nyxt

  # chatgpt-unwrapped 26.1021.22027 は remote-control-device-key.node が
  # libtss2-* を要求するが、上流の buildInputs に tpm2-tss が無いため
  # autoPatchelf が失敗する。上流修正までのビルド回避。
  (llm-agents.chatgpt.override {
    chatgpt-unwrapped = llm-agents.chatgpt.unwrapped.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ tpm2-tss ];
    });
  })
  pandoc
]
