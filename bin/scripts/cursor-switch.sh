#!/usr/bin/env bash
# cursor-switch.sh - niri カーソルテーマ切り替えスクリプト
#
# Usage:
#   cursor-switch.sh morino   # Morino Rinze に切り替え
#   cursor-switch.sh temari   # Temari Tsukimura に切り替え
#   cursor-switch.sh status   # 現在の設定を表示
#   cursor-switch.sh check    # 設定の食い違いを検査（drift 検出）
#
# カーソル設定は 1 か所では完結しない。用途ごとに読む場所が違うため:
#   config/niri/config.kdl        niri 自身のカーソル描画 + niri が起動する子プロセス
#   home.nix                      systemd user / ログインシェルの環境変数
#   ~/.config/environment.d/*.conf  systemd user サービスの環境変数
#   ~/.config/gtk-{3,4}.0/settings.ini  GTK アプリ
# これらがずれると「niri は 75 なのに Xwayland/GTK だけ 86」のような症状になる。
# `check` はその食い違いを検出する。

set -euo pipefail

DOTFILES="$HOME/.ghq/github.com/Comamoca/dotfiles"
NIRI_CONFIG="$DOTFILES/config/niri/config.kdl"
HOME_NIX="$DOTFILES/home.nix"
ENV_CONF="$HOME/.config/environment.d/98-cursor-theme.conf"
GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
GTK4_SETTINGS="$HOME/.config/gtk-4.0/settings.ini"

morino_theme='Morino Rinze'
morino_size=75
temari_theme='Temari Tsukimura'
temari_size=43

# niri config の environment ブロックに XCURSOR_* を反映する。
# niri の environment は「niri が起動するプロセスの環境変数を上書きする」ので、
# Xwayland (xwayland-satellite) や niri から起動した GTK アプリはここを見る。
# home-manager switch を待たずに config だけで揃うようにしておく。
update_niri_environment() {
    local theme="$1"
    local size="$2"

    local mode tmp
    mode=$(stat -c '%a' "$NIRI_CONFIG")
    # 同じディレクトリに作る（同一ファイルシステムなので mv が rename になり、
    # niri の watch が中途半端な内容を読まない）。mktemp の 600 を引き継がないよう
    # 元ファイルのモードをコピーする。
    tmp=$(mktemp "$(dirname "$NIRI_CONFIG")/.config.kdl.XXXXXX")

    if grep -qE '^environment \{' "$NIRI_CONFIG"; then
        # 既存 environment ブロックの値を差し替える。
        # sed の置換だけだと「片方のキーだけ書いた config」で値が反映されないまま
        # 素通りするので、欠けているキーはブロック末尾に足す。
        awk -v theme="$theme" -v size="$size" '
            BEGIN { in_env = 0; has_theme = 0; has_size = 0 }
            /^environment \{/ && !in_env { in_env = 1; print; next }
            in_env {
                if ($0 ~ /^[[:space:]]*XCURSOR_THEME[[:space:]]+"/) {
                    print "    XCURSOR_THEME \"" theme "\""; has_theme = 1; next
                }
                if ($0 ~ /^[[:space:]]*XCURSOR_SIZE[[:space:]]+"/) {
                    print "    XCURSOR_SIZE \"" size "\""; has_size = 1; next
                }
                if ($0 ~ /^[[:space:]]*\}/) {
                    if (!has_theme) print "    XCURSOR_THEME \"" theme "\""
                    if (!has_size) print "    XCURSOR_SIZE \"" size "\""
                    print; in_env = 0; next
                }
                print; next
            }
            { print }
        ' "$NIRI_CONFIG" > "$tmp"
    else
        # cursor ブロックの直前に environment ブロックを作る
        awk -v theme="$theme" -v size="$size" '
            BEGIN { done = 0 }
            /^cursor \{/ && !done {
                print "environment {"
                print "    XCURSOR_THEME \"" theme "\""
                print "    XCURSOR_SIZE \"" size "\""
                print "}"
                print ""
                done = 1
            }
            { print }
        ' "$NIRI_CONFIG" > "$tmp"
    fi

    # 書き込み前に値を検証する。失敗したら元ファイルには触れない。
    if ! grep -qF "XCURSOR_THEME \"$theme\"" "$tmp" || ! grep -qF "XCURSOR_SIZE \"$size\"" "$tmp"; then
        rm -f "$tmp"
        echo "環境変数ブロックを更新できませんでした（niri の cursor ブロックが見つからない）" >&2
        return 1
    fi
    chmod "$mode" "$tmp"
    mv "$tmp" "$NIRI_CONFIG"
}

switch_theme() {
    local theme="$1"
    local size="$2"
    local label="$3"

    # niri config を更新
    sed -i "s|xcursor-theme \".*\"|xcursor-theme \"$theme\"|" "$NIRI_CONFIG"
    sed -i "s|xcursor-size [0-9]*|xcursor-size $size|" "$NIRI_CONFIG"
    update_niri_environment "$theme" "$size"

    # home.nix の sessionVariables を更新
    sed -i "s|XCURSOR_THEME = \".*\";|XCURSOR_THEME = \"$theme\";|" "$HOME_NIX"
    sed -i "s|XCURSOR_SIZE = \".*\";|XCURSOR_SIZE = \"$size\";|" "$HOME_NIX"

    # environment.d を更新 (systemd ユーザーサービス用)
    cat > "$ENV_CONF" <<EOF
XCURSOR_THEME=$theme
XCURSOR_SIZE=$size
EOF

    # GTK settings を更新
    for settings_file in "$GTK3_SETTINGS" "$GTK4_SETTINGS"; do
        if [ -f "$settings_file" ]; then
            sed -i "s|gtk-cursor-theme-name=.*|gtk-cursor-theme-name=$theme|" "$settings_file"
            sed -i "s|gtk-cursor-theme-size=.*|gtk-cursor-theme-size=$size|" "$settings_file"
        fi
    done

    echo "✓ カーソルテーマを $label に変更しました"
    echo "  テーマ: $theme"
    echo "  サイズ: $size"
    echo ""
    echo "反映するには:"
    echo "  home-manager switch --flake .#Home --impure && niri msg action quit"
}

read_niri_cursor() {
    NIRI_THEME=$(sed -n 's/.*xcursor-theme "\(.*\)".*/\1/p' "$NIRI_CONFIG" | head -1)
    NIRI_SIZE=$(sed -n 's/.*xcursor-size \([0-9]*\).*/\1/p' "$NIRI_CONFIG" | head -1)
}

check_drift() {
    read_niri_cursor
    local rc=0

    report() {
        # report <ok?> <label> <value>
        # printf の %-Ns はバイト幅で詰めるため日本語ラベルでは桁が崩れる。
        # 整列はあきらめて「ラベル: 値」形式にする。
        if [ "$1" = "ok" ]; then
            printf '  %s: %s\n' "$2" "$3"
        else
            printf '  %s: %s  <- ずれ\n' "$2" "$3"
            rc=1
        fi
    }

    printf 'niri config (基準): %s / %s\n\n' "$NIRI_THEME" "$NIRI_SIZE"

    # config.kdl の environment ブロック
    local env_theme env_size
    env_theme=$(sed -n 's/^[[:space:]]*XCURSOR_THEME "\(.*\)"/\1/p' "$NIRI_CONFIG" | head -1)
    env_size=$(sed -n 's/^[[:space:]]*XCURSOR_SIZE "\([0-9]*\)"/\1/p' "$NIRI_CONFIG" | head -1)
    if [ "$env_theme" = "$NIRI_THEME" ] && [ "$env_size" = "$NIRI_SIZE" ]; then
        report ok "config.kdl environment" "$env_theme / $env_size"
    else
        report ng "config.kdl environment" "${env_theme:-未設定} / ${env_size:-未設定}"
    fi

    # home.nix (sessionVariables + systemd.user.sessionVariables の 2 か所)
    local nix_themes nix_sizes
    nix_themes=$(grep -c "XCURSOR_THEME = \"$NIRI_THEME\";" "$HOME_NIX" || true)
    nix_sizes=$(grep -c "XCURSOR_SIZE = \"$NIRI_SIZE\";" "$HOME_NIX" || true)
    local nix_total
    nix_total=$(grep -c 'XCURSOR_SIZE = ' "$HOME_NIX" || true)
    if [ "$nix_themes" = "$nix_total" ] && [ "$nix_sizes" = "$nix_total" ]; then
        report ok "home.nix ($nix_total か所)" "$NIRI_THEME / $NIRI_SIZE"
    else
        local actual
        actual=$( { grep -o 'XCURSOR_THEME = "[^"]*"' "$HOME_NIX"; grep -o 'XCURSOR_SIZE = "[^"]*"' "$HOME_NIX"; } | sort -u | tr '\n' ' ')
        report ng "home.nix ($nix_total か所)" "$NIRI_THEME / $NIRI_SIZE 期待, 実際: $actual"
    fi

    # environment.d
    if [ -f "$ENV_CONF" ]; then
        local ed_theme ed_size
        ed_theme=$(sed -n 's/^XCURSOR_THEME=//p' "$ENV_CONF")
        ed_size=$(sed -n 's/^XCURSOR_SIZE=//p' "$ENV_CONF")
        if [ "$ed_theme" = "$NIRI_THEME" ] && [ "$ed_size" = "$NIRI_SIZE" ]; then
            report ok "environment.d" "$ed_theme / $ed_size"
        else
            report ng "environment.d" "$ed_theme / $ed_size"
        fi
    else
        report ng "environment.d" "ファイル無し"
    fi

    # GTK
    local settings_file gtk_theme gtk_size
    for settings_file in "$GTK3_SETTINGS" "$GTK4_SETTINGS"; do
        if [ ! -f "$settings_file" ]; then
            report ng "$(basename "$(dirname "$settings_file")")" "ファイル無し"
            continue
        fi
        gtk_theme=$(sed -n 's/^gtk-cursor-theme-name=//p' "$settings_file")
        gtk_size=$(sed -n 's/^gtk-cursor-theme-size=//p' "$settings_file")
        if [ "$gtk_theme" = "$NIRI_THEME" ] && [ "$gtk_size" = "$NIRI_SIZE" ]; then
            report ok "$(basename "$(dirname "$settings_file")")" "$gtk_theme / $gtk_size"
        else
            report ng "$(basename "$(dirname "$settings_file")")" "${gtk_theme:-未設定} / ${gtk_size:-未設定}"
        fi
    done

    # 実行中の環境 (systemd user) - 起動中のプロセスは後から変えられない
    if command -v systemctl >/dev/null 2>&1; then
        local sd_theme sd_size
        sd_theme=$(systemctl --user show-environment 2>/dev/null | sed -n 's/^XCURSOR_THEME=//p')
        sd_size=$(systemctl --user show-environment 2>/dev/null | sed -n 's/^XCURSOR_SIZE=//p')
        sd_theme=${sd_theme#\$}
        sd_theme=${sd_theme//\'/}
        if [ "$sd_theme" = "$NIRI_THEME" ] && [ "$sd_size" = "$NIRI_SIZE" ]; then
            report ok "systemd user 環境" "$sd_theme / $sd_size"
        else
            report ng "systemd user 環境" "${sd_theme:-未設定} / ${sd_size:-未設定}"
        fi
    fi

    # 実行中の niri の起動時環境変数
    # これは niri プロセスが systemd から受け取った値で、後から変えられない。
    # ただし config.kdl の environment ブロックが子プロセスに効くので、
    # 設定が揃っていればここの差は実害がない（drift 判定には入れない）。
    local niri_pid
    niri_pid=$(pgrep -x niri | head -1 || true)
    if [ -n "$niri_pid" ]; then
        local nr_theme nr_size
        nr_theme=$(tr '\0' '\n' < "/proc/$niri_pid/environ" | sed -n 's/^XCURSOR_THEME=//p')
        nr_size=$(tr '\0' '\n' < "/proc/$niri_pid/environ" | sed -n 's/^XCURSOR_SIZE=//p')
        if [ "$nr_theme" = "$NIRI_THEME" ] && [ "$nr_size" = "$NIRI_SIZE" ]; then
            report ok "実行中の niri (pid $niri_pid)" "$nr_theme / $nr_size"
        else
            printf '  %s: %s  (起動時の値。子プロセスは environment で上書きされるため実害なし)\n' \
                "実行中の niri (pid $niri_pid)" "${nr_theme:-未設定} / ${nr_size:-未設定}"
        fi
    fi

    echo ""
    if [ "$rc" -eq 0 ]; then
        echo "✓ ずれなし"
    else
        echo "✗ ずれあり"
        echo "  設定ファイルのずれ: cursor-switch.sh morino|temari で揃う。"
        echo "  反映されていない場合は home-manager switch --flake .#Home --impure を実行する。"
    fi
    return "$rc"
}

case "${1:-status}" in
    morino|rinze)
        switch_theme "$morino_theme" "$morino_size" "Morino Rinze"
        ;;
    temari|tsukimura)
        switch_theme "$temari_theme" "$temari_size" "Temari Tsukimura"
        ;;
    status)
        read_niri_cursor
        echo "現在のカーソル設定:"
        echo "  テーマ: $NIRI_THEME"
        echo "  サイズ: $NIRI_SIZE"
        echo ""
        echo "利用可能なテーマ:"
        echo "  morino  - Morino Rinze"
        echo "  temari  - Temari Tsukimura"
        ;;
    check)
        check_drift
        ;;
    *)
        echo "Usage: cursor-switch.sh [morino|temari|status|check]"
        exit 1
        ;;
esac
