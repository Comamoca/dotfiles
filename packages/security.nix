{ pkgs }:
with pkgs;
[
  # Security tools
  libsodium
  libsecret
  keybase
  lssecret
  pinentry-qt
  gnupg
  # Cloudflare Tunnel (opencode.comamoca.dev 用)。トークンは sops 管理。
  cloudflared
]
