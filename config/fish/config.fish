set PATH /usr/local/bin $PATH
set PATH ~/.local/bin $PATH

set PATH ~/ghq/github.com/emscripten-core/emsdk $PATH
set PATH ~/ghq/github.com/emscripten-core/emsdk/upstream/emscripten $PATH
set PATH ~/.codon/bin $PATH

## starship init fish | source
zoxide init fish | source

## if test -z $TMUX
##   tmux new-session
## end

## theme_gruvbox dark soft

alias vlang='/usr/sbin/v'
alias v='nvim'
alias g='git'
alias ide="~/.scripts/tmux_layout.sh"
alias wallpapelar='feh --bg-fill'
alias ls='lsd'
alias rm='rip'
alias server='python -m http.server'
# alias fzvim='nvim (fzf)'
# alias fzhq='cd (string  join / (ghq root) (ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*"))'
# alias frea='freasearcher'
alias ghostscript='gs'

alias gts='g status'
alias gcl='g clone'
alias gcm='g commit'
alias gph='g push'
alias gpl='g pull'
alias gad='g add'
alias gcl='g clone'
alias gcz='g cz'
alias grm='g rm'
alias vimdiff='nvim -d'

alias README='cp ~/ghq/github.com/Comamoca/baserepo/README.md ~/ghq/github.com/Comamoca/baserepo/README.ja.md .'
alias lg='lazygit'
alias ablaze_repos='gh repo list Ablaze-MIRAI'
alias wk='wikitool'
alias zenn="npx zenn"
alias bt="boost"

export EDITOR=nvim
export PYTHONPATH=/home/coma/bundler/bundler/lib
export GOPATH=$HOME/go
export PATH="$HOME/.nimble/bin:$PATH"
export PATH="$HOME/.nimble/.bin/git-tasukete:$PATH"
export PATH=" $HOME/.local/kitty.app/bin/:$PATH"
export PATH="$HOME/.bin/:$PATH"

set PATH /home/coma/.cargo/bin $PATH
set GH_BINPATH /home/coma/.bin/
export FYNE_FONT=/usr/share/fonts/PlemolJP/PlemolJP-Regular.ttf
export DENO_INSTALL="/home/coma/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
export PATH="/home/coma/go/bin:$PATH"
export PATH="/home/coma/local/:$PATH"


set BAT_THEME "gruvbox-dark" $PATH
set PATH /home/coma/$CARGO_HOME/bin/ $PATH

#set PATH /home/coma/go/bin $PATH
starship init fish | source
set -ga fish_user_paths /home/coma/.nimble/bin
set -ga fish_user_paths /home/coma/.nimble/pkgs

set -gx PNPM_HOME "/home/coma/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH

eval (gh completion -s fish| source)
# eval (konryu init)

set EMSDK_QUIET = 1

# eval (fzenn completion fish | source)

#mkdir -p $fish_complete_path[1]
## cp extra/completions/alacritty.fish $fish_complete_path[1]/alacritty.fish
##
#export PATH=/home/coma/.nimble/bin:$PATH

# bind \cp __fzf_open --editor


# alias ghlist='cd "~/ghq/"(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")'

# # fish key bindings
# function fish_user_key_bindings
#   bind \cg ghlist
# end

# set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'

set SoundDriver PULSEAUDIO:JACK:ALSA:OSS

set -Ux fish_user_paths $HOME/.rbenv/bin $fish_user_paths
set -Ux fish_user_paths $HOME/.rbenv/shims $fish_user_paths
# set rg $FZF_FIND_FILE_COMMAND

bind \cg run_recker
bind \cc __fish_cancel_commandline

# bind \cf zi

# bind \cf fzf_prev_open

# Bun
set -Ux BUN_INSTALL "/home/coma/.bun"
set -px --path PATH "/home/coma/.bun/bin"
# alias emoji=''
# to copy to xclip system keyboard (on mac use pbcopy) after selecting
# emoj | xclip -selection c

# pnpm
set -gx PNPM_HOME "/home/coma/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
set CODON_PYTHON /usr/lib/libpython3.10.so

source /opt/asdf-vm/asdf.fish

__chatgpt

# source /opt/asdf-vm/asdf.fish
# config.fish

rtx activate fish | source
rtx hook-env -s fish | source  # プラグインのパスを追加する
rtx complete -s fish | source

/home/coma/.local/share/rtx/bin/rtx activate -s fish | source

#set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin /home/coma/.ghcup/bin $PATH # ghcup-env
set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin /home/coma/.ghcup/bin $PATH # ghcup-env


if test (pwd) = "/mnt/c/Users/Coma"
	cd ~
end
