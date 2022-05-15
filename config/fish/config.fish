#set PATH /usr/local/bin $PATH
#export PATH=/home/coma/.config/fish/functions/ $PATH



# function ghq_fzf_repo -d 'Repository search'
#   select = (ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
#   [ -n "$select" ]; and cd "$select"
#   echo string join (ghq root) " $select "
#   commandline -f repaint
# end

# fish key bindings
# function fish_user_key_bindings
#   bind \cg ghq_fzf_repo
# end


## ~/.config/fish/config.fish

eval (gh completion -s fish| source)


## starship init fish | source
zoxide init fish | source

## if test -z $TMUX
##   tmux new-session
## end

## theme_gruvbox dark soft

alias v='nvim'
alias ide="~/.scripts/tmux_layout.sh"
alias wallpapelar='feh --bg-fill'
alias ls='lsd'
alias server='python -m http.server'
alias fzf='fzf --preview "bat  --color=always --style=header,grid --line-range :100 {}"'
alias fzvim='nvim (fzf)'
alias fzhq='cd (string  join / (ghq root) (ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*"))'

export EDITOR=nvim
export PYTHONPATH=/home/coma/bundler/bundler/lib
export GOPATH=$HOME/go
export PATH="$HOME/.nimble/bin:$PATH"

set PATH /home/coma/.cargo/bin $PATH
export FYNE_FONT=/usr/share/fonts/PlemolJP/PlemolJP-Regular.ttf
export DENO_INSTALL="/home/coma/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
export PATH="/home/coma/.bin:$PATH"
export PATH="/home/coma/local/:$PATH"
export BAT_THEME="gruvbox-dark"


#set PATH /home/coma/go/bin $PATH
starship init fish | source
set -ga fish_user_paths /home/coma/.nimble/bin
set -ga fish_user_paths /home/coma/.nimble/pkgs

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

set -Ux fish_user_paths $HOME/.rbenv/bin $fish_user_paths
set -Ux fish_user_paths $HOME/.rbenv/shims $fish_user_paths
set rg $FZF_FIND_FILE_COMMAND
bind \cg __fzhq
xmodmap ~/.Xmodmap
