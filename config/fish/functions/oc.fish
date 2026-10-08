function oc
    # systemd 常駐の OpenCode Server (127.0.0.1:4096) へ TUI を接続する。
    # --dir "$PWD" で現在のディレクトリをサーバー側のプロジェクトとして指定する。
    # サーバーが起動していない場合は systemctl --user start opencode-server で起動する。
    opencode attach http://127.0.0.1:4096 --dir "$PWD" $argv
end