set PATH /usr/local/bin $PATH
set PATH ~/.local/bin $PATH

set PATH ~/ghq/github.com/emscripten-core/emsdk $PATH
set PATH ~/ghq/github.com/emscripten-core/emsdk/upstream/emscripten $PATH
set PATH ~/.codon/bin $PATH
set PATH ~/.rye/shims/ $PATH
set PATH ~/.local/share/gem/ruby/3.0.0/bin/ $PATH
source ~/.wasmer/wasmer.sh

set LUA_PATH ~/.luarocks/lib/ $LUA_PATH
set LUA_PATH ~/.luarocks/lib/luarocks/rocks-5.4/ $LUA_PATH

zoxide init fish | source

alias zx='/home/coma/go/bin/z'
alias glow='glow -p'
# alias vlang='/usr/sbin/v'
alias e='nvim'
alias gupm='~/.gupm/gupm/g'
# alias git='gix'
alias g='git'
alias nush='/bin/nu'
# alias ide="~/.scripts/tmux_layout.sh"
alias wallpapelar='feh --bg-fill'
alias ls='lsd'
alias rm='rip'
alias server='python -m http.server'
# alias fzvim='nvim (fzf)'
alias fzhq='string  join / (ghq root) (ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")'

# alias frea='freasearcher'
alias ghostscript='gs'

alias gst='g status'
alias gcl='g clone'
alias gcm='g commit'
alias gph='g push'
alias gpl='g pull'
alias gad='g add'
alias gcl='g clone'
alias gcz='g cz'
alias grm='g rm'

alias blog='cd /home/coma/ghq/github.com/coma/blog/src/content/blog && e'

alias vimdiff='nvim -d'

alias README='cp ~/ghq/github.com/Comamoca/baserepo/README.md ~/ghq/github.com/Comamoca/baserepo/README.ja.md .'
alias lg='lazygit'
alias ablaze_repos='gh repo list Ablaze-MIRAI'
alias wk='wikitool'
alias zenn="npx zenn"
alias bt="boost"
alias ":wq"="exit"
alias ":wqa"="exit"

alias __recker='cd (recker)'
alias cdf='cd (ls -d */ | sed "s/\///" | fzf)'

alias boost='deno run -A (string join "/" ~/.config/boost (/bin/ls ~/.config/boost/ | fzf --preview-window=down:70% --preview "bat --color=always (string join "/" ~/.config/boost {})"))'

export EDITOR=nvim
# export PYTHONPATH=/home/coma/bundler/bundler/lib
export GOPATH=$HOME/go
export PATH="$HOME/.nimble/bin:$PATH"
export PATH="$HOME/.nimble/.bin/git-tasukete:$PATH"
# export PATH=" $HOME/.local/kitty.app/bin/:$PATH"
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
set PATH /home/coma/.luarocks/bin/ $PATH

#set PATH /home/coma/go/bin $PATH
starship init fish | source
set -ga fish_user_paths /home/coma/.nimble/bin
set -ga fish_user_paths /home/coma/.nimble/pkgs

set -gx PNPM_HOME "/home/coma/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH

set -x PATH "$HOME/.konryu/bin" $PATH
set -x PATH "$HOME/.konryu/cotowali/bin/" $PATH

eval (gh completion -s fish| source)
eval (hugo completion fish)
eval (konryu init)

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

# bind \cg run_recker
bind \cg __recker
bind \cb boost
bind \cf cdf
bind \cc __fish_cancel_commandline

# bind \cf zi

# bind \cf fzf_prev_open

# Bun
set -Ux BUN_INSTALL "/home/coma/.bun"
set -px --path PATH "/home/coma/.bun/bin"
export PATH="$PATH":"$HOME/.pub-cache/bin"
# alias emoji=''
# to copy to xclip system keyboard (on mac use pbcopy) after selecting
# emoj | xclip -selection c

set -x BLUESKY_IDENTIFIER "comamoca.bsky.social"
set -x BLUESKY_PASSWORD (__secret bluesky_pass)

# pnpm
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
export PATH='/home/coma/.luarocks/bin:/home/coma/.rbenv/shims:/home/coma/.asdf/shims:/opt/asdf-vm/bin:/home/coma/.rbenv/bin:/home/coma/.local/share/rtx/bin:/home/coma/.nimble/bin:/home/coma/.nimble/pkgs:/home/coma/.cabal/bin:/home/coma/.bun/bin:/home/coma/.konryu/cotowali/bin/:/home/coma/.konryu/bin:/home/coma/.local/share/pnpm:/home/coma/.luarocks/bin/:/home/coma/local/:/home/coma/go/bin:/home/coma/.deno/bin:/home/coma/.cargo/bin:/home/coma/.bin/:/home/coma/.nimble/.bin/git-tasukete:/home/coma/.local/share/gem/ruby/3.0.0/bin/:/home/coma/.rye/shims/:/home/coma/.codon/bin:/home/coma/ghq/github.com/emscripten-core/emsdk/upstream/emscripten:/home/coma/ghq/github.com/emscripten-core/emsdk:/home/coma/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/mnt/c/Program Files/Oculus/Support/oculus-runtime:/mnt/c/Program Files/Microsoft/jdk-11.0.12.7-hotspot/bin:/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS:/mnt/c/WINDOWS/System32/Wbem:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/:/mnt/c/WINDOWS/System32/OpenSSH/:/mnt/c/Program Files/dotnet/:/mnt/c/Program Files/Docker/Docker/resources/bin:/mnt/c/Program Files/Microsoft SQL Server/150/Tools/Binn/:/mnt/c/Program Files/usbipd-win/:/mnt/c/ProgramData/chocolatey/bin:/mnt/c/Program Files/Neovide/:/mnt/c/Program Files/Cloudflare/Cloudflare WARP/:/mnt/c/Program Files/WezTerm:/mnt/c/Program Files/gsudo/Current:/mnt/c/Program Files/komorebi/bin/:/mnt/c/Users/Coma/AppData/Local/Programs/Python/Python311/Scripts/:/mnt/c/Users/Coma/AppData/Local/Programs/Python/Python311/:/mnt/c/Users/Coma/AppData/Local/Programs/Python/Launcher/:/mnt/c/Users/Coma/.cargo/bin:/mnt/c/Users/Coma/go/bin:/mnt/c/Users/Coma/scoop/apps/python/current/Scripts:/mnt/c/Users/Coma/scoop/apps/python/current:/mnt/c/Users/Coma/scoop/shims:/mnt/c/Users/Coma/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/Coma/.dotnet/tools:/mnt/c/Users/Coma/.deno/bin:/mnt/c/Users/Coma/AppData/Roaming/pypoetry:/mnt/c/Users/Coma/AppData/Local/Programs/FirefoxPWA/:/mnt/c/users/coma/.local/bin:/mnt/c/Users/Coma/.bin:/mnt/c/Users/Coma/AppData/Local/Programs/Microsoft VS Code/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/var/lib/snapd/snap/bin:/home/coma/.pub-cache/bin:/home/coma/.ghcup/bin'

# Wasmer
export WASMER_DIR="/home/coma/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"
