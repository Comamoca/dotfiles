#!/bin/bash -u

if [ $# -ne 1  ]; then
	env NVIM_APPNAME=ime nvim /tmp/clip -c startinsert
	exit
fi

if [ "$1" = 'float' ]; then
	kitty --class Floaterm env NVIM_APPNAME=ime nvim /tmp/clip -c startinsert 

	if [[ -e /tmp/clip ]]; then
		head -c -1 /tmp/clip | wl-copy
		rm -f /tmp/clip
    	fi
fi
