#!/bin/bash -u

# tmpfile=$(mktemp)
tmpfile=/tmp/clip

cat /dev/null > /tmp/clip

wezterm \
    --config initial_rows=20 \
    --config initial_cols=60 \
    --config enable_tab_bar=false \
    --config window_background_opacity=0.4 \
    --config text_background_opacity=0.7 \
    start --class floating vim ${tmpfile} -c 'startinsert'

# wezterm start --class floating vim ${tmpfile} -c 'startinsert' -c 'startinsert' -c 'set runtimepath^=~/.cache/dpp_vim/repos/github.com/vim-skk/skkeleton' || exit 1
# kitty --class 'floating' -- vim -c 'startinsert' -c 'set runtimepath^=~/.cache/dpp_vim/repos/github.com/vim-skk/skkeleton' /tmp/clip

if [[ -e $tmpfile ]]; then
  # cat /tmp/clip | tr -d '\n' | wl-copy
  head -c -1 /tmp/clip | wl-copy

  # head -c -1 /tmp/clip | xclip -selection clipboard
  # notify-send -t 1000 copied
  # rm -f /tmp/clip
fi
