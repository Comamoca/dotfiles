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
  # SUDO_ASKPASS / SSH_ASKPASS 用の GUI パスワードプロンプト
  kdePackages.ksshaskpass
  # Cloudflare Tunnel (opencode.comamoca.dev 用)。トークンは sops 管理。
  cloudflared
]
