#!/bin/bash -u

# kitty --class Floaterm nvim /tmp/clip
kitty --class Floaterm env NVIM_APPNAME=ime nvim /tmp/clip -c startinsert 
# wezterm start --class Floaterm nvim /tmp/clip || exit 1

if [[ -e /tmp/clip ]]; then
  head -c -1 /tmp/clip | wl-copy
  rm -f /tmp/clip
fi
