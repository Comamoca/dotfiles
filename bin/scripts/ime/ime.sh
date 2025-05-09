#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash

nvim_bin="$HOME/.nix-profile/bin/nvim"
# nvim_bin="nvim"

# kitty_bin="$HOME/.nix-profile/bin/kitty"
kitty_bin="kitty"

if [ $# -ne 1  ]; then
	env NVIM_APPNAME=ime $nvim_bin /tmp/clip -c startinsert
	head -c -1 /tmp/clip | wl-copy
	rm -f /tmp/clip
	exit
fi

if [ "$1" = 'float' ]; then
	# $kitty_bin --class Floaterm env NVIM_APPNAME=ime $nvim_bin /tmp/clip -c startinsert
	foot -T Floaterm -W 60x13 env NVIM_APPNAME=ime $nvim_bin /tmp/clip -c startinsert
	# kitty --class Floaterm env vim /tmp/clip -c startinsert

	if [[ -e /tmp/clip ]]; then
		head -c -1 /tmp/clip | wl-copy
		rm -f /tmp/clip
    	fi
fi
