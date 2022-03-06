#! /usr/bin/bash

. ./pocho.sh
. ./utils.sh
. ./linstalls.sh



# some code...

# if type python >/dev/null 2>&1; then
#   # some code...
# fi



echo " ------------ Set Password ------------"
# パスワードを記憶
read -sp "パスワードを入力してください: " __pass;
echo "\n ------------ End ------------ "

echo " ------------ Homebrew ------------"
read -p "Homebrewをインストールしますか？ (y/n)" Answer < /dev/tty
case ${Answer} in
  y|Y) 

    echo "Start Install Homebrew..."

    check_install deno

    echo "Install Homebrew is Complete!" ;;

  n|N)
    echo "インストールをスキップしました" ;;

esac
echo " ------------ END ------------"

echo " ------------ zsh ------------"
read -p "ログインシェルをzshに変更しますか？ (y/n)" Answer < /dev/tty
case ${Answer} in
  y|Y)
    echo "=================="
    echo "現在のzshのPATH: $(which zsh)"
    echo "=================="

    echo "=================="
    echo "現在のzshのバージョン: $(/bin/zsh --version)"
    echo "=================="

    echo "=================="
    echo "Homebrewでインストールできるzshのバージョン: $(brew info zsh)"
    echo "=================="

    read -p "このままzshをインストールしていいですか？ (y/n)" Answer < /dev/tty
    case ${Answer} in
      y|Y)
        brew install zsh zsh-syntax-highlighting
        echo ${__pass} | sudo -S -- sh -c 'echo '/usr/local/bin/zsh' >> /etc/shells'
        chsh -s /usr/local/bin/zsh
        ;;

      n|N)
        echo "インストールをスキップしました" ;;
    esac

    echo "=================="
    echo "現在のzshのPATH: $(which zsh)"
    echo "=================="

    echo "=================="
    echo "現在のzshのバージョン: $(/usr/local/bin/zsh --version)"
    echo "=================="

    echo "=================="
    echo "現在のログインシェル: $(echo $SHELL)"
    echo "=================="

    FILE="${HOME}/.bash_profile"

    if [[ -e ${FILE} ]]; then
      source ${FILE} >> ~/.zshrc
    elif [[ ! -e ${FILE} ]]; then
      touch ${FILE}
    fi

    source ~/.zshrc

    echo "zshをインストールしました。一度プロセスを終了します。"

    exec $SHELL -l #ログインシェルの再読み込み

    ;;

  n|N)
    echo "インストールをスキップしました" ;;
esac
echo " ------------ END ------------"

echo " ------------ ITerm2 ------------"
read -p "ITerm2をインストールしますか？ (y/n)" Answer < /dev/tty
case ${Answer} in
  y|Y) check_install pip3 install_pip ;;


  n|N)
    echo "インストールをスキップしました" ;;
esac
echo " ------------ END ------------"

echo " ------------ Install Ruby ------------"
read -p "zshにrbenv/ruby-buildをインストールしますか？ (y/n)" Answer < /dev/tty
case ${Answer} in
 y|Y) brew update
      brew install rbenv ruby-build
      echo 'eval "$(rbenv init -)"' >> ~/.zshrc
      source ~/.zshrc

      echo "rbenvとruby-buildをインストールしました"

      echo "=================="
      echo "現在のrbenvのバージョン: $(rbenv --version)"
      echo "=================="

      echo "=================="
      echo "現在のインストール済Rubyのバージョン \n $(rbenv versions)"      
      echo "=================="

      read -p "最新版のrubyをglobalのバージョンとして設定しますか？ (y/n)" Answer < /dev/tty
      case ${Answer} in
        y|Y)
          ruby_latest=$(rbenv install -l | grep -v '[a-z]' | tail -1 | sed 's/ //g')
          rbenv install ${ruby_latest}
          rbenv global ${ruby_latest}
          rbenv rehash
          echo "===インストールされたRubyのバージョン=== \n $(ruby -v) \n======"
          ;;

        n|N)
          echo "インストールをスキップしました" ;;
      esac;;

 n|N)
    echo "インストールをスキップしました" ;;
esac
echo " ------------ END ------------"

echo " ------------ MySQL ------------"
read -p "MySQL5.7をインストールしますか？ (y/n)" Answer < /dev/tty
case ${Answer} in
  y|Y) brew install mysql@5.7
       brew link mysql@5.7 --force

       echo "MySQL5.7のインストールが完了しました" ;;
  n|N)
    echo "インストールをスキップしました" ;;
esac
echo " ------------ END ------------"

echo " ------------ Nokogiri ------------"
read -p "Nokogiri関連のライブラリをインストールしますか? (y/n)" Answer < /dev/tty
case ${Answer} in
  y|Y) brew install libxml2
      echo 'export PATH="/usr/local/opt/libxml2/bin:$PATH"' >> ~/.zshrc
      export PKG_CONFIG_PATH="/usr/local/opt/libxml2/lib/pkgconfig"
      export LDFLAGS="-L/usr/local/opt/libxml2/lib"
      export CPPFLAGS="-I/usr/local/opt/libxml2/include" 
      echo "インストールが完了しました" ;;

  n|N)
    echo "インストールをスキップしました" ;;
esac
echo " ------------ END ------------"

echo " ------------ Redis ------------"
read -p "Redisをインストールしますか？ (y/n)" Answer < /dev/tty
case ${Answer} in
  y|Y) brew install redis
      echo "インストールが完了しました" ;;
  n|N)
    echo "インストールをスキップしました" ;;
esac
echo " ------------ END ------------"

echo " ------------ Yarn ------------"
read -p "yarnをインストールしますか？ (y/n)" Answer < /dev/tty
case ${Answer} in
  y|Y) brew install yarn
       echo "インストールが完了しました" ;;
  n|N)
    echo "インストールをスキップしました" ;;
esac


echo "Setup Configs..."
env RCRC=$HOME/dotfiles/rcrc rcup


echo " ------------ END ------------"



