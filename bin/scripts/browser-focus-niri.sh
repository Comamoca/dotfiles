#!/usr/bin/env bash
# Focus browser if already open, otherwise launch it (for Niri).
# Usage: browser-focus-niri.sh [app-id]
# Default app-id: firefox
# Skips PiP (Picture-in-Picture) windows.

APP_ID="${1:-firefox}"

# Get the first non-PiP window ID matching the app-id
WINDOW_ID=$(
  niri msg -j windows 2>/dev/null |
    jq -r --arg app_id "$APP_ID" '
      [.[]
      | select(
          .app_id == $app_id
          and (.title | type == "string")
          and (.title | startswith("ピクチャー") | not)
        )
      ] | first | .id // empty
    '
)

if [ -n "$WINDOW_ID" ]; then
  niri msg action focus-window --id "$WINDOW_ID"
else
  exec "$APP_ID"
fi
