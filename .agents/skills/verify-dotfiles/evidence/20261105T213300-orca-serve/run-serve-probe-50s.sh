#!/usr/bin/env bash
# orca-serve.service の実際の環境 (ユーザーマネージャと同じ変数群 + unit の
# Environment) に寄せて `orca serve --supervise --no-pairing` を 50 秒実行し、
# 25 秒超でも安定して serve し続けるか (TERM 前の GPU FATAL がシャットダウン
# ノイズかの確認) と、終了後の残プロセスを記録する。
set -u
EVIDENCE_DIR="$(cd "$(dirname "$0")" && pwd)"

env -i \
  HOME=/home/coma \
  XDG_RUNTIME_DIR=/run/user/1000 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  WAYLAND_DISPLAY=wayland-1 \
  DISPLAY=:0 \
  ORCA_USER_DATA_PATH=/home/coma/.config/orca \
  PATH="/home/coma/.nix-profile/bin:/run/current-system/sw/bin:/usr/bin:/bin:/run/wrappers/bin" \
  timeout --signal=TERM 50 \
  /nix/store/rp6d9hb3bg2l2d5hjfrbaldhcfkaivh1-orca-1.4.248/bin/orca \
  serve --supervise --no-pairing \
  > "$EVIDENCE_DIR/05-serve-50s-with-display.txt" 2>&1
echo "exit=$?" >> "$EVIDENCE_DIR/05-serve-50s-with-display.txt"

sleep 3
pgrep -af "orca-1.4.248" > "$EVIDENCE_DIR/06-leftover-50s.txt" \
  || echo "NO_LEFTOVER_PROCESSES" > "$EVIDENCE_DIR/06-leftover-50s.txt"

echo "--- stable markers ---"
grep -nE "Orca server ready|Bound endpoint|FATAL|Goodbye|waiting|exited" \
  "$EVIDENCE_DIR/05-serve-50s-with-display.txt" || true
echo "--- tail ---"
tail -8 "$EVIDENCE_DIR/05-serve-50s-with-display.txt"
echo "--- leftover ---"
cat "$EVIDENCE_DIR/06-leftover-50s.txt"
