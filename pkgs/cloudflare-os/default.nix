# cloudflare-os — AI productivity environment by Cloudflare
# https://github.com/cloudflare/cloudflare-os
#
# pnpm monorepo + wrangler/workerd のため Nix から完全ビルドするのは複雑。
# git clone → pnpm install → build → run-local をラップするスクリプトを提供する。
# systemd サービス (cloudflare-os-service.nix) から ExecStart で呼ばれる。
{ pkgs }:
let
  version = "0.1.0";
in
pkgs.writeShellApplication {
  name = "cloudflare-os";

  runtimeInputs = with pkgs; [
    git
    nodejs
    pnpm
    coreutils
    gnused
    gnugrep
  ];

  text = ''
    REPO_URL="https://github.com/cloudflare/cloudflare-os.git"
    DATA_DIR="''${CLOUDFLARE_OS_DATA_DIR:-$HOME/.local/share/cloudflare-os}"
    PORT="''${CLOUDFLARE_OS_PORT:-18787}"

    mkdir -p "$DATA_DIR"

    if [ ! -d "$DATA_DIR/.git" ]; then
      echo "[cloudflare-os] Cloning repository..."
      git clone "$REPO_URL" "$DATA_DIR"
    else
      echo "[cloudflare-os] Updating repository..."
      git -C "$DATA_DIR" pull --ff-only || true
    fi

    cd "$DATA_DIR"

    echo "[cloudflare-os] Installing dependencies..."
    pnpm install --frozen-lockfile 2>/dev/null || pnpm install

    echo "[cloudflare-os] Building..."
    pnpm run build || true

    echo "[cloudflare-os] Starting on port $PORT..."
    exec pnpm run-local -- --port "$PORT"
  '';

  meta = with pkgs.lib; {
    description = "AI productivity environment by Cloudflare (local wrapper)";
    homepage = "https://github.com/cloudflare/cloudflare-os";
    license = licenses.asl20;
    mainProgram = "cloudflare-os";
  };
}