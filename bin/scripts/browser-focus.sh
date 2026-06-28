#!/usr/bin/env bash
# Focus browser if already open, otherwise launch it.
# Usage: browser-focus.sh [class]
# Default class: firefox
# Skips PiP (Picture-in-Picture) windows.

CLASS="${1:-firefox}"
PIP_TITLE="${2:-ピクチャーインピクチャー}"

# Get the first non-PiP window address matching the class
ADDRESS=$(
  hyprctl clients -j |
    jq -r --arg class "$CLASS" --arg pip "$PIP_TITLE" '
      [.[] | select(.class == $class and .title != $pip)] |
      first |
      .address // empty
    '
)

if [ -n "$ADDRESS" ]; then
  hyprctl dispatch focuswindow "address:$ADDRESS"
else
  exec "$CLASS"
fi
