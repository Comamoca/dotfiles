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
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh


# PURE_PROMPT_SYMBOL="🐾"


# # .zshrc
# autoload -U promptinit; promptinit
# prompt pure


eval "$(starship init zsh)"
alias x='xonsh'
# x

export PATH="$HOME/.poetry/bin:$PATH"
