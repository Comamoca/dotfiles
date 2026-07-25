#!/usr/bin/env bash
# niri-display-layout.sh - 起動時に wlr-randr でディスプレイ配置を適用
#
# wdisplays で調整したレイアウトを永続化するための起動スクリプト。
# レイアウト変更時は wdisplays → "Copy as script" の内容で
# このファイルの wlr-randr コマンド部分を差し替える。
#
# 依存: wlr-randr

set -euo pipefail

# niri 起動直後は出力の初期化が完了していない可能性があるため
# 少し待ってから適用する
sleep 1

wlr-randr \
  --output DP-1 \
    --mode 2560x1440 \
    --pos 4350,0 \
    --scale 1.0 \
    --transform normal \
  --output eDP-1 \
    --mode 1920x1080 \
    --pos 2814,576 \
    --scale 1.25 \
    --transform normal
