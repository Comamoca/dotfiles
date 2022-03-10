#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
. "$HOME/.cargo/env"

export DENO_INSTALL="/home/coma/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"
