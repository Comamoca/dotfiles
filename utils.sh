#! /usr/bin/bash

set -eu
# . ./pocho.sh

echo "Load utils..."

check_install () {
    echo "checking ..."
    if type $1 >/dev/null 2>&1; then
	    echo "Installed. Skip..."
    else
	    cecho red "Nothing. Installing..."
	    $2
    fi
}

get_os_distribution() {
    if   [ -e /etc/debian_version ] ||
         [ -e /etc/debian_release ]; then
        # Check Ubuntu or Debian
        if [ -e /etc/lsb-release ]; then
            # Ubuntu
            distri_name="ubuntu"
        else
            # Debian
            distri_name="debian"
        fi
    elif [ -e /etc/fedora-release ]; then
        # Fedra
        distri_name="fedora"
    elif [ -e /etc/redhat-release ]; then
        if [ -e /etc/oracle-release ]; then
            # Oracle Linux
            distri_name="oracle"
        else
            # Red Hat Enterprise Linux
            distri_name="redhat"
        fi
    elif [ -e /etc/arch-release ]; then
        # Arch Linux
        distri_name="arch"
    elif [ -e /etc/turbolinux-release ]; then
        # Turbolinux
        distri_name="turbol"
    elif [ -e /etc/SuSE-release ]; then
        # SuSE Linux
        distri_name="suse"
    elif [ -e /etc/mandriva-release ]; then
        # Mandriva Linux
        distri_name="mandriva"
    elif [ -e /etc/vine-release ]; then
        # Vine Linux
        distri_name="vine"
    elif [ -e /etc/gentoo-release ]; then
        # Gentoo Linux
        distri
    else
        # Other
        distri_name="unkown"
    fi

    echo ${distri_name}
}

# Get distribution and bit
function get_os_info() {
   echo $(get_os_distribution)
}

function distoro_install () {
	if [ "$(get_os_distribution)" = "$arch" ]; then
		# On Arch
	      	echo "Run pacman..."
	elif [ "$(get_os_distribution)" = "$debian" ]; then
		# On Debian
	      	echo "Run apt..."
	elif [ "$(get_os_distribution)" = "$ubuntu" ]; then
		# On Ubuntu
	      	echo "Run apt..."
	else
		echo "This distortion is not supported."
	fi
}

get_os_info
