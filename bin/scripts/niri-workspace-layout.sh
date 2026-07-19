#!/usr/bin/env bash
# niri-workspace-layout.sh - モニター構成に応じて名前付きワークスペースを配置
#
# 起動時に一度だけ実行。niri は名前付きWSの出力割当を記憶するため、
# ホットプラグ後の再配置は niri 自身が自動で行う。
#
# 動作:
#   外部モニター接続時: term/web/chat/edit/misc/stash → 内蔵, browser/code/mon → 外部
#   外部モニター未接続: 全WS → 内蔵
#
# 依存: niri (msg), jq

set -euo pipefail

INTERNAL="eDP-1"
INTERNAL_WS=(term web chat edit misc stash)
EXTERNAL_WS=(browser code mon)

move_ws() {
    local ws="$1" target="$2"
    niri msg action move-workspace-to-monitor --reference "$ws" "$target" 2>/dev/null || true
}

external_output() {
    niri msg -j outputs 2>/dev/null | jq -r --arg internal "$INTERNAL" '
        [.[] | select(.name != $internal) | .name] | first // empty
    '
}

ext="$(external_output)"
if [ -n "$ext" ]; then
    for ws in "${INTERNAL_WS[@]}"; do move_ws "$ws" "$INTERNAL"; done
    for ws in "${EXTERNAL_WS[@]}"; do move_ws "$ws" "$ext"; done
else
    for ws in "${INTERNAL_WS[@]}" "${EXTERNAL_WS[@]}"; do move_ws "$ws" "$INTERNAL"; done
fi
