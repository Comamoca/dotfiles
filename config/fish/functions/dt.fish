function dt --description 'dsh TUI — 起動中の dsh web へアタッチするラッパー'
    # ====================================================================
    # `dt` は systemd user サービス (dsh-web.service) で常駐している
    # dsh web (127.0.0.1:14198) のセッションへ TUI をアタッチする。
    #
    # 背景: `dsh tui` は既定で web のサーバーに繋がず tui profile を
    # in-process で起動するため、web 側の履歴を共有しない。アタッチは
    # dsh-tui の dsh-remote バックエンドが担う
    # (docs/dsh-tui-attach-research.md)。
    #
    #  - サーバーが生きていれば --backend dsh-remote でアタッチする
    #  - 落ちていれば従来どおり tui profile をローカル起動する
    #    (`dtl` と同じ挙動。dtl は明示的にローカル起動したいとき用)
    #
    # DSH_WEB_URL は必ずループバックを指す。公開ホスト名
    # (dsh.comamoca.dev) を使うと Cloudflare Access が ?token= を IdP へ
    # 302 するため launch token 交換が成立しない。
    # ====================================================================

    set -l url http://127.0.0.1:14198
    set -l tui ~/.ghq/github.com/Comamoca/dsh-TUI/bin/dsh-tui.js

    # サーバー生存確認。認証前の GET / は 401 を返すのが正常なので、
    # curl -f ではなく HTTP ステータスが返ること自体を生存とみなす。
    set -l http (curl -s -o /dev/null -m 2 -w '%{http_code}' $url/ 2>/dev/null)

    if test "$http" != 000; and test -n "$http"
        env DSH_WEB_URL=$url node $tui --backend dsh-remote $argv
        return
    end

    echo "dt: dsh web ($url) に接続できないためローカル起動します" >&2
    echo "dt: アタッチするには systemctl --user start dsh-web.service" >&2
    command dsh tui $argv
end
