#!/usr/bin/env bash
# Window switcher for Niri: search and focus any window via rofi.
# Usage: niri-window-switch.sh
# Binds to Mod+W in niri config.
# Skips PiP (Picture-in-Picture) windows.
#
# Depends on: niri, jq, rofi

set -euo pipefail

# Fetch all windows from niri
JSON=$(niri msg -j windows 2>/dev/null) || exit 0

# Filter & sort once, then derive IDs and display text from the same data
SORTED_JSON=$(echo "$JSON" | jq -c '
  [.[]
  | select(
      (.title | type == "string")
      and (.title | startswith("ピクチャー") | not)
    )
  ]
  | map({item: ., key1: (.app_id | ascii_downcase), key2: (.title | ascii_downcase)})
  | sort_by(.key1, .key2)
  | .[].item
')

mapfile -t IDS < <(echo "$SORTED_JSON" | jq -r '.id // empty')
[ ${#IDS[@]} -eq 0 ] && exit 0

FORMATTED=$(echo "$SORTED_JSON" | jq -r '
  [.app_id, .title, (.workspace_id | tostring)]
  | join(" │ ")
')

# Show rofi dmenu, get selection index (0-based; cancel → exit 1 → noop)
IDX=$(echo "$FORMATTED" | rofi -dmenu -i -p "Window" -no-custom -format i) || exit 0

# Validate index and focus the window
if [[ "$IDX" =~ ^[0-9]+$ ]] && [ "$IDX" -ge 0 ] && [ "$IDX" -lt "${#IDS[@]}" ]; then
  niri msg action focus-window --id "${IDS[$IDX]}"
fi
