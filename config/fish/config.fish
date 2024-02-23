fish_add_path /usr/local/bin
fish_add_path $HOME/.local/bin

fish_add_path $HOME/.dotnet/tools

fish_add_path $HOME/ghq/github.com/emscripten-core/emsdk
fish_add_path $HOME/ghq/github.com/emscripten-core/emsdk/upstream/emscripten
fish_add_path $HOME/.codon/bin
fish_add_path $HOME/.rye/shims
fish_add_path $HOME/.local/share/gem/ruby/3.0.0/bin
fish_add_path $HOME/.local/share/gem/ruby/3.0.0/bin/

fish_add_path $HOME/.kiex/bin/
fish_add_path $HOME/.kiex/elixirs/elixir-1.14/bin/

fish_add_path $HOME/.kerl/26.2.1/bin/

fish_add_path $HOME/.janet/bin
fish_add_path $HOME/.bin/opam
fish_add_path $HOME/.bin/mason

fish_add_path $HOME/.wasmer/wasmer.sh

fish_add_path $HOME/.local/share/aquaproj-aqua/bin/
fish_add_path $AQUA_ROOT_DIR/bin

fish_add_path $HOME/.konryu/versions/v0.1.1/cotowali/bin
fish_add_path $HOME/go/bin/

set fish_greeting

set -gx XDG_DATA_HOME $HOME/.local/share
set -gx AQUA_ROOT_DIR $XDG_DATA_HOME/aquaproj-aqua

source $HOME/.kiex/elixirs/.elixir-1.16.0-rc.1.env.fish
# source ~/.wasmer/wasmer.sh
# source "$HOME/.rye/env"

set LUA_PATH ~/.luarocks/lib/ $LUA_PATH
set LUA_PATH ~/.luarocks/lib/luarocks/rocks-5.4/ $LUA_PATH
set -x BLOG_PATH ~/ghq/github.com/coma/blog/src/content/blog/

fish_add_path ~/.nimble/bin
fish_add_path ~/.nimble/.bin/git-tasukete
fish_add_path ~/.bin/
fish_add_path ~/.bin/bin
fish_add_path $DENO_INSTALL/bin
fish_add_path /home/coma/go/bin
fish_add_path /home/coma/local/

zoxide init fish | source

alias zx='/home/coma/go/bin/z'
alias glow='glow -p'
# alias vlang='/usr/sbin/v'
alias gupm='~/.gupm/gupm/g'
# alias git='gix'
alias nush='/bin/nu'
# alias ide="~/.scripts/tmux_layout.sh"
alias wallpapelar='feh --bg-fill'
alias ls='lsd'
# alias rm='rip'
alias server='python -m http.server'
# alias fzvim='nvim (fzf)'
alias fzhq='string  join / (ghq root) (ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")'

# alias frea='freasearcher'
alias ghostscript='gs'

# alias g='git'

alias gst='git status'
alias gcl='git clone'
alias gcm='git commit'
alias gph='git push'
alias gpl='git pull'
alias gad='git add'
alias gcl='git clone'
alias gcz='git cz'
alias grm='git rm'

alias vimdiff='nvim -d'

alias README='cp (ghq root)/github.com/Comamoca/baserepo/README.md (ghq root)/github.com/Comamoca/baserepo/README.ja.md .'
alias lg='lazygit'
alias ablaze_repos='gh repo list Ablaze-MIRAI'
alias wk='wikitool'
alias zenn="npx zenn"
alias bt="boost"
alias ":wq"="exit"
alias ":wqa"="exit"

alias __recker='cd (recker)'
alias __sandbox='cd (string join "/" (~/ghq/github.com/Comamoca/sandbox) (fd -d 1 | fzf))'
alias cdf='cd (ls -d */ | sed "s/\///" | fzf)'
alias tmp='cd (mktemp -d)'

alias boost='deno run -A (string join "/" ~/.config/boost (/bin/ls ~/.config/boost/ | fzf --preview-window=down:70% --preview "bat --color=always (string join "/" ~/.config/boost {})"))'
alias wiki="wikitool"
alias BLOG='cd (ruby ~/ghq/github.com/coma/blogtool/blogtool.rb path)'
alias blog='ruby ~/ghq/github.com/coma/blogtool/blogtool.rb'

# .bin scripts
alias MIT="ruby ~/.bin/scripts/mit/mit.rb"

export EDITOR=vim
# export PYTHONPATH=/home/coma/bundler/bundler/lib
export GOPATH=$HOME/go

abbr --add e $EDITOR

set PATH /home/coma/.cargo/bin $PATH
set GH_BINPATH /home/coma/.bin/
export FYNE_FONT=/usr/share/fonts/PlemolJP/PlemolJP-Regular.ttf
export DENO_INSTALL="/home/coma/.deno"


set BAT_THEME "gruvbox-dark"
set PATH /home/coma/$CARGO_HOME/bin/ $PATH
set PATH /home/coma/.luarocks/bin/ $PATH

#set PATH /home/coma/go/bin $PATH
starship init fish | source
set -ga fish_user_paths /home/coma/.nimble/bin
set -ga fish_user_paths /home/coma/.nimble/pkgs

set -gx PNPM_HOME "/home/coma/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH

# set -x PATH "$HOME/.konryu/bin" $PATH
# set -x PATH "$HOME/.konryu/cotowali/bin/" $PATH
# eval (konryu init)

eval (gh completion -s fish| source)
eval (hugo completion fish)

set EMSDK_QUIET = 1

set SoundDriver PULSEAUDIO:JACK:ALSA:OSS

set -Ux fish_user_paths $HOME/.rbenv/bin $fish_user_paths
set -Ux fish_user_paths $HOME/.rbenv/shims $fish_user_paths
# set rg $FZF_FIND_FILE_COMMAND

# bind \cg run_recker
bind \cg __recker
bind \cb boost
bind \cf cdf
bind \cs __sandbox
bind \cc __fish_cancel_commandline

# bind \cf zi

# bind \cf fzf_prev_open

# Bun
set -Ux BUN_INSTALL "/home/coma/.bun"
set -px --path PATH "/home/coma/.bun/bin"
export PATH="$PATH":"$HOME/.pub-cache/bin"


set -gx PNPM_HOME "/home/coma/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end

if test (pwd) = "/mnt/c/Users/Coma"
	cd ~
end

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin $PATH /home/coma/.ghcup/bin # ghcup-env

export LUA_PATH='/usr/share/lua/5.4/?.lua;/usr/share/lua/5.4/?/init.lua;/usr/lib/lua/5.4/?.lua;/usr/lib/lua/5.4/?/init.lua;./?.lua;./?/init.lua;/home/coma/.luarocks/share/lua/5.4/?.lua;/home/coma/.luarocks/share/lua/5.4/?/init.lua'
export LUA_CPATH='/usr/lib/lua/5.4/?.so;/usr/lib/lua/5.4/loadall.so;./?.so;/home/coma/.luarocks/lib/lua/5.4/?.so'

# Wasmer
export WASMER_DIR="/home/coma/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

rbenv init - fish | source

# opam configuration
source /home/coma/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

source "$HOME/.kiex/scripts/kiex.fish"
