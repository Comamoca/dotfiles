#/bin/sh

set -eu

echo "Load pocho..."

# cecho $red "hello"

red=31
green=32
yellow=33
blue=34

function cecho {
    color=$1
    shift
    echo -e "\033[${color}m$@\033[m"
}

cecho red "This is test..."
cecho green "This is test..."
cecho yellow "This is test..."
cecho blue "This is test..."
