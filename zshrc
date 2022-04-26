# Use powerline
# USE_POWERLINE="true"
# Source manjaro-zsh-configuration
# if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
#   source /usr/share/zsh/manjaro-zsh-config
# fi
# # Use manjaro zsh prompt
# if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
#   source /usr/share/zsh/manjaro-zsh-prompt
# fi

source $HOME/.cargo/env

alias v='nvim'
alias んゔぃｍ='echo 日本語入力ONになってますよ;nvim'
alias urxvt_setconf='xrdb -merge $HOME/.Xresources'

alias zenn='npx zenn'
alias composer='/home/coma/composer.phar'
alias ..='cd ..'

# mkdir -p ${ZDOTDIR:-~}/.zsh_functions
# echo 'fpath+=${ZDOTDIR:-~}/.zsh_functions' >> ${ZDOTDIR:-~}/.zshrc
# fpath+=${ZDOTDIR:-~}/.zsh_functions

export DENO_INSTALL="/home/coma/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export PATH="$HOME/.scripts:$PATH"
export PATH="$HOME/.poetry/env:$PATH"

export PATH="/home/coma/go/bin:$PATH"

# .zshrc
# fpath+=$HOME/.zsh/pure
# fpath+=$HOME/.zsh/zsh-syntax-highlighting

# if [[ ! -n $TMUX && $- == *l* ]]; then
#   # get the IDs
#   ID="`tmux list-sessions`"
#   if [[ -z "$ID" ]]; then
#     tmux new-session
#   fi
#   create_new_session="Create New Session"
#   ID="$ID\n${create_new_session}:"
#   ID="`echo $ID | $PERCOL | cut -d: -f1`"
#   if [[ "$ID" = "${create_new_session}" ]]; then
#     tmux new-session
#   elif [[ -n "$ID" ]]; then
#     tmux attach-session -t "$ID"
#   else
#     :  # Start terminal normally
#   fi
# fi




# =========================== functions ===============================

fzgrep() {
  INITIAL_QUERY=""
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
    fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --phony --query "$INITIAL_QUERY" \
        --preview 'bat `echo {} | cut -f 1 --delim ":"`'
}


# [[ -z "$TMUX" && ! -z "$PS1" ]] && tmux

# export PATH="$HOME/.poetry/bin:$PATH"
# source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh


# PURE_PROMPT_SYMBOL="🐾"


# # .zshrc
# autoload -U promptinit; promptinit
# prompt pure


eval "$(starship init zsh)"
alias x='xonsh'
# x



export PATH="$HOME/.poetry/bin:$PATH"

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

zinit light zdharma/fast-syntax-highlighting


# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi
export PATH=/home/coma/.nimble/bin:$PATH
export PATH="/home/coma/.bin:$PATH"

fish


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
