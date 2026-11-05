#!/usr/bin/env bash
# orca-serve.service と同じ環境変数で `orca serve --supervise --no-pairing` を
# 25 秒だけ試験実行し、挙動と終了後の残プロセスを記録する。
# デスクトップアプリがプロファイルを serve 中なら --supervise は待機する
# はず (exit 3 ではない)。timeout は TERM を supervisor に送る。
set -u
EVIDENCE_DIR="$(cd "$(dirname "$0")" && pwd)"

env -i \
  HOME=/home/coma \
  XDG_RUNTIME_DIR=/run/user/1000 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  ORCA_USER_DATA_PATH=/home/coma/.config/orca \
  PATH="/home/coma/.nix-profile/bin:/run/current-system/sw/bin:/usr/bin:/bin:/run/wrappers/bin" \
  timeout --signal=TERM 25 \
  /nix/store/rp6d9hb3bg2l2d5hjfrbaldhcfkaivh1-orca-1.4.248/bin/orca \
  serve --supervise --no-pairing \
  > "$EVIDENCE_DIR/03-serve-manual-run.txt" 2>&1
echo "exit=$?" >> "$EVIDENCE_DIR/03-serve-manual-run.txt"

sleep 3
pgrep -af "orca-1.4.248" > "$EVIDENCE_DIR/04-leftover-processes.txt" \
  || echo "NO_LEFTOVER_PROCESSES" > "$EVIDENCE_DIR/04-leftover-processes.txt"

echo "--- serve output ---"
cat "$EVIDENCE_DIR/03-serve-manual-run.txt"
echo "--- leftover ---"
cat "$EVIDENCE_DIR/04-leftover-processes.txt"
