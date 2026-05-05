{ pkgs }:
let
  generated = import ../_sources/generated.nix;
  sources = generated {
    inherit (pkgs)
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };

  autoclaude = pkgs.buildGoModule {
    pname = "autoclaude ";
    version = "0.1.2";
    src = sources.autoclaude.src;
    vendorHash = "sha256-bq27PpkygOvE0HQpqWCbDRcNgYRP8pV+Q3RSNovCN58=";

    doCheck = false;
    };
in
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

  inotify-tools
  happy-coder

  autoclaude
  telegram-desktop
  wlr-randr
  deploy-rs.deploy-rs
]
