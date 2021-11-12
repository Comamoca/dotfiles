autoload -Uz compinit && compinit

fpath=( /path/to/Your-self-made-completion "${fpath[@]}" )
autoload -Uz your-self-made-completion

# if [[ ! -n $TMUX ]]; then
#   ID="`tmux list-sesstions`"
#   if [[ -z "$ID" ]]; then
#     tmux new-sesstion
#   fi
#   ID="`echo $ID | fzf | cut -d: -f1`"
#   tmux attach-sesstion -t "$ID"
# fi

alias tmux="tmux -u2"

# tmuxの自動起動
count=`ps aux | grep tmux | grep -v grep | wc -l`
if test $count -eq 0; then
    echo `tmux`
elif test $count -eq 1; then
    echo `tmux a`
fi

# === depertment variavle ===
#

# === alias ===
alias vim='nvim -S ~/.Session.vim'
alias holodule='python ~/holo-schedule-CLI/main.py'
# alias kiseki='pwsh -C '-join'

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# === Zplug ===

# zplug
source ~/.zplug/init.zsh
# zplug 'sobolevn/wakatime-zsh-plugin'
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
# 非同期処理できるようになる
zplug "mafredri/zsh-async"
# テーマ(ここは好みで。調べた感じpureが人気)
zplug "sindresorhus/pure"
# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zplug "zsh-users/zsh-syntax-highlighting"
# コマンド入力途中で上下キー押したときの過去履歴がいい感じに出るようになる
zplug "zsh-users/zsh-history-substring-search"
# 過去に入力したコマンドの履歴が灰色のサジェストで出る
zplug "zsh-users/zsh-autosuggestions"
# 補完強化
zplug "zsh-users/zsh-completions"
# 256色表示にする
zplug "chrissicool/zsh-256color"
# コマンドライン上の文字リテラルの絵文字を emoji 化する
zplug "mrowa44/emojify", as:command
# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
# コマンドの履歴機能
# 履歴ファイルの保存先
HISTFILE=$HOME/.zsh_history
# メモリに保存される履歴の件数
HISTSIZE=10000
# HISTFILE で指定したファイルに保存される履歴の件数
SAVEHIST=10000
# Then, source plugins and add commands to $PATH
zplug load

source "$HOME/.homesick/repos/homeshick/homeshick.sh"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

