# if status is-interactive
#     # Commands to run in interactive sessions can go here
# end


# ~/.config/fish/config.fish

eval (gh completion -s fish| source)


# starship init fish | source
zoxide init fish | source

# if test -z $TMUX
#   tmux new-session
# end

# theme_gruvbox dark soft

alias v='nvim'
alias ide="~/.scripts/tmux_layout.sh"
alias wallpapelar='feh --bg-fill'
alias ls='lsd'
alias server='python -m http.server'

export DENO_INSTALL="/home/coma/.deno"
export EDITOR=nvim
export PYTHONPATH=/home/coma/bundler/bundler/lib
export GOPATH=$HOME/go
set PATH /home/coma/.cargo/bin $PATH
export FYNE_FONT=/usr/share/fonts/PlemolJP/PlemolJP-Regular.ttf
export DENO_INSTALL="/home/coma/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"


set PATH /home/coma/go/bin $PATH
starship init fish | source

mkdir -p $fish_complete_path[1]
# cp extra/completions/alacritty.fish $fish_complete_path[1]/alacritty.fish
