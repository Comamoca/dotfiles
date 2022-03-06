#! /bin/bash


function install_pip () {
	#get pi
	wget https://bootstrap.pypa.io/get-pip.py
	python3 get-pip.p
	# remove get-pip.p
	rm get-pip.p
}

function install_deno () {
	curl -fsSL https://deno.land/install.sh | sh
}

function install_node () {
	os=$1
	if [ $os = "arch" ]; then
		# Arch
		rm /tmp/hoge.txt
	elif [ $os = "ubuntu" ]; then
		# Ubuntu
		sudo apt update && sudo apt install nodejs
	else
		# Debian
		sudo apt update && sudo apt install nodejs
	fi

}

function install_rust () {
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}
