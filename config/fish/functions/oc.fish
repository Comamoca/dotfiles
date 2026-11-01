function oc --description 'opencode ラッパー (OpenCode Server 自動アタッチ) のショートカット'
    # systemd 常駐の OpenCode Server (127.0.0.1:4096) へのアタッチ処理は
    # `opencode` ラッパー (config/fish/functions/opencode.fish) に統合した。
    # サーバーの自動起動・スタンドアロンへのフォールバックも含めて
    # そちらに一任する (oc は単なるショートカット)。
    opencode $argv
end
