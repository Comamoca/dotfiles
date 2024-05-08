#!/bin/bash -u

# tmpfile=$(mktemp)
tmpfile=/tmp/clip

cat /dev/null > /tmp/clip
wezterm start --class floating vim ${tmpfile} -c 'startinsert'|| exit 1

if [[ -e $tmpfile ]]; then
  cat /tmp/clip | tr -d '\n' | wl-copy
  head -c -1 /tmp/clip | wl-copy

  # head -c -1 /tmp/clip | xclip -selection clipboard
  # notify-send -t 1000 copied
  # rm -f /tmp/clip
fi
