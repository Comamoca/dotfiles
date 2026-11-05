function opencode --description 'OpenCode TUI — systemd 常駐の OpenCode Server へ自動アタッチするラッパー'
    # ====================================================================
    # `opencode` 起動時に systemd user サービス (opencode-server.service) で
    # 常駐している OpenCode Server (127.0.0.1:4096) へ TUI をアタッチする。
    # (従来 oc.fish だけが持っていた挙動を `opencode` 本体にも拡張した)
    #
    #  - サブコマンド (serve / run / models / ...) はそのまま素通しする
    #  - attach が対応していない TUI 専用オプション (-m / --prompt など) や
    #    未知のオプションも素通しし、本体側で解釈 (またはエラー) させる
    #  - サーバーが停止している場合は systemctl --user start で起動して待つ
    #  - それでも接続できなければスタンドアロン TUI へフォールバックする
    #
    # 注意: 位置引数のディレクトリは attach の --dir に変換する。その際
    # realpath で絶対パスに解決する (サーバー側 cwd は ~/.ghq なので、
    # 相対パスを渡すと意図しないプロジェクトに繋がってしまう)。
    # ====================================================================

    set -l url http://127.0.0.1:4096

    # サブコマンド (本物の opencode へ素通し)
    set -l subcommands completion acp mcp attach run debug providers auth \
        agent upgrade uninstall serve web models stats export import github \
        pr session plugin plug db help

    # attach が解釈できるオプション (attach へそのまま渡す)
    set -l attach_flags -c --continue -s --session --fork --mini --no-replay \
        --replay-limit --print-logs --log-level --pure --dir -p --password \
        -u --username

    # attach 非対応の TUI 専用オプション (スタンドアロンで起動し直す)
    set -l tui_flags -m --model --prompt --agent --auto --port --hostname \
        --mdns --mdns-domain --cors

    # 値を取るオプション (次の引数をフラグの値として扱う)
    set -l value_flags -s --session --replay-limit --log-level --dir --port \
        --hostname --mdns-domain --cors --model --prompt --agent -m -p -u \
        --password --username

    set -l pass_args
    set -l skip_next 0
    set -l pending_dir 0
    set -l user_dir 0
    set -l positional
    set -l passthrough 0

    for a in $argv
        # 直前の値を取るオプションの値
        if test $skip_next = 1
            set skip_next 0
            if test $pending_dir = 1
                # --dir の値は相対パスだとサーバー側 cwd (~/.ghq) 基準で
                # 解釈されるため、クライアント側で絶対パスに解決する
                set pending_dir 0
                set -a pass_args (realpath -m -- $a)
            else
                set -a pass_args $a
            end
            continue
        end

        # 長いオプション (--flag / --flag=value)
        if string match -q -- '--*' $a
            set -l name (string split -m1 -f1 '=' -- $a)
            if contains -- $name $tui_flags
                set passthrough 1
                set -a pass_args $a
            else if contains -- $name $attach_flags
                if test $name = --dir
                    set user_dir 1
                    if string match -q -- '*=*' $a
                        # --dir=path 形式はここで絶対パスに解決して渡す
                        set -l val (string split -m1 -f2 '=' -- $a)
                        set -a pass_args "--dir="(realpath -m -- $val)
                    else
                        set pending_dir 1
                        set skip_next 1
                        set -a pass_args $a
                    end
                else
                    if contains -- $name $value_flags; and not string match -q -- '*=*' $a
                        set skip_next 1
                    end
                    set -a pass_args $a
                end
            else
                # 未知のオプションは本体のエラーに任せる
                set passthrough 1
                set -a pass_args $a
            end
            continue
        end

        # 短いオプション (-c / -s ID / -m model / -mmodel など)
        if string match -q -- '-*' $a
            if test $a = -m; or string match -q -- '-m?*' $a
                # モデル指定は attach 非対応のためスタンドアロンに任せる
                set passthrough 1
            else if contains -- $a $attach_flags
                if contains -- $a $value_flags
                    set skip_next 1
                end
            else
                set passthrough 1
            end
            set -a pass_args $a
            continue
        end

        # 非フラグ引数 = サブコマンド or プロジェクトディレクトリ
        if set -q positional[1]
            set -a pass_args $a
        else
            set positional $a
        end
    end

    # TUI 専用オプション・未知オプションがある場合は本体へ素通し
    if test $passthrough = 1
        command opencode $argv
        return
    end

    # 最初の非フラグ引数がサブコマンドなら素通し
    # (例: opencode --print-logs debug paths)
    if set -q positional[1]; and contains -- $positional $subcommands
        command opencode $argv
        return
    end

    # 位置引数のプロジェクトディレクトリを attach の --dir に変換
    set -l dir
    if set -q positional[1]
        if test -d $positional
            set dir (realpath -- $positional)
        else
            # 存在しないパス — 本体側のエラーメッセージに任せる
            command opencode $argv
            return
        end
    else if test $user_dir = 0
        # --dir 指定がなければカレントディレクトリをサーバー側プロジェクトにする
        set dir $PWD
    end

    # OpenCode Server のヘルスチェック (落ちていれば起こして待つ)
    set -l healthy 0
    if curl -sf -m 2 "$url/global/health" >/dev/null 2>&1
        set healthy 1
    else if systemctl --user start opencode-server.service >/dev/null 2>&1
        # 起動直後はリスン開始まで数秒かかるためヘルスチェックを待ち合わせる
        # (fish 4.x では _ が読み取り専用なのでループ変数は i を使う)
        for i in (seq 1 30)
            sleep 0.5
            if curl -sf -m 1 "$url/global/health" >/dev/null 2>&1
                set healthy 1
                break
            end
        end
    end

    if test $healthy = 0
        echo "opencode: OpenCode Server ($url) に接続できないためスタンドアローンモードで起動します" >&2
        command opencode $argv
        return
    end

    if set -q dir[1]
        command opencode attach "$url" --dir "$dir" $pass_args
    else
        command opencode attach "$url" $pass_args
    end
end
