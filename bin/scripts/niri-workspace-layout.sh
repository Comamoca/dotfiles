#!/usr/bin/env bash
# niri-workspace-layout.sh - モニター構成に応じて名前付きワークスペースを自動配置
#
# Usage:
#   niri-workspace-layout.sh           # ワンショット: 現在の出力構成を検出して適用
#   niri-workspace-layout.sh --daemon  # 常駐: event-stream を監視して出力変化時に再配置
#
# 動作:
#   - 内蔵ディスプレイ (eDP-1): term, web, chat, edit, misc, stash
#   - 外部ディスプレイ (eDP-1以外): browser, code, mon
#   - 外部切断時: 全ワークスペースを eDP-1 に戻す
#
# 依存: niri (msg), jq, bash >= 4.0

set -euo pipefail

# -- 設定 ----------------------------------------------------------------
# 内蔵ディスプレイのコネクタ名（必要に応じて変更）
INTERNAL="eDP-1"

# 内蔵ディスプレイ用ワークスペース（常に内蔵に置く）
INTERNAL_WS=(term web chat edit misc stash)

# 外部ディスプレイ用ワークスペース（接続時に外部へ移動）
EXTERNAL_WS=(browser code mon)

# -- 関数定義 ----------------------------------------------------------------

# エラーログ（stderr へ出力）
log_error() {
    echo "[niri-workspace-layout] ERROR: $*" >&2
}

# 情報ログ
log_info() {
    echo "[niri-workspace-layout] $*"
}

# move-workspace-to-monitor をラップ（エラーを握り潰す）
move_ws() {
    local ws="$1"
    local target="$2"
    niri msg action move-workspace-to-monitor --reference "$ws" "$target" 2>/dev/null || true
}

# 現在接続中の外部出力名を取得（内蔵以外で最初に見つかったもの）
detect_external_output() {
    niri msg -j outputs 2>/dev/null | jq -r --arg internal "$INTERNAL" '
        [.[] | select(.name != $internal) | .name] | first // empty
    '
}

# 外部モニターが接続されているか判定
has_external_output() {
    local ext
    ext="$(detect_external_output)"
    [ -n "$ext" ]
}

# シングルモニターレイアウト: 全WSを内蔵ディスプレイへ
apply_single() {
    log_info "Layout: single monitor ($INTERNAL only)"

    for ws in "${INTERNAL_WS[@]}" "${EXTERNAL_WS[@]}"; do
        move_ws "$ws" "$INTERNAL"
    done
}

# デュアルモニターレイアウト: 内蔵＋外部でWSを分割
apply_dual() {
    local external
    external="$(detect_external_output)"

    if [ -z "$external" ]; then
        log_error "No external output detected, falling back to single"
        apply_single
        return
    fi

    log_info "Layout: dual monitor ($INTERNAL + $external)"

    for ws in "${INTERNAL_WS[@]}"; do
        move_ws "$ws" "$INTERNAL"
    done

    for ws in "${EXTERNAL_WS[@]}"; do
        move_ws "$ws" "$external"
    done
}

# 現在の出力構成を検出して自動適用
apply_auto() {
    if has_external_output; then
        apply_dual
    else
        apply_single
    fi
}

# -- デーモンモード（event-stream 監視） -----------------------------------

run_daemon() {
    log_info "Starting daemon (event-stream monitor)"

    # 状態管理: 前回検出時の外部モニター接続状態
    local prev_has_external=false
    if has_external_output; then
        prev_has_external=true
    fi

    # 起動時に一度適用
    apply_auto

    # event-stream を購読して WorkspacesChanged を監視
    niri msg --json event-stream 2>/dev/null | while IFS= read -r line; do
        # イベントタイプを抽出
        local event_type
        event_type="$(echo "$line" | jq -r 'keys[0]' 2>/dev/null)" || continue

        # WorkspacesChanged は出力構成変更を含む可能性がある
        if [ "$event_type" = "WorkspacesChanged" ]; then
            local current_has_external=false
            if has_external_output; then
                current_has_external=true
            fi

            if [ "$prev_has_external" != "$current_has_external" ]; then
                log_info "Output configuration changed (external: $prev_has_external -> $current_has_external)"
                if [ "$current_has_external" = true ]; then
                    apply_dual
                else
                    apply_single
                fi
                prev_has_external="$current_has_external"
            fi
        fi
    done

    # event-stream が途切れた場合
    log_error "Event stream ended unexpectedly, restarting..."
    sleep 2
    exec "$0" --daemon
}

# -- メインエントリーポイント ---------------------------------------------

case "${1:-}" in
    --daemon)
        run_daemon
        ;;
    single|--single)
        apply_single
        ;;
    dual|--dual)
        apply_dual
        ;;
    --help|-h|help)
        echo "Usage: $0 [--daemon|single|dual|--help]"
        echo ""
        echo "  (default)   Auto-detect outputs and apply layout"
        echo "  --daemon    Monitor event-stream and reapply on output changes"
        echo "  single      Force single-monitor layout (all WS to eDP-1)"
        echo "  dual        Force dual-monitor layout (split WSs)"
        echo "  --help      Show this help"
        ;;
    *)
        apply_auto
        ;;
esac
