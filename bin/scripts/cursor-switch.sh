#!/usr/bin/env bash
# cursor-switch.sh - niri カーソルテーマ切り替えスクリプト
#
# Usage:
#   cursor-switch.sh morino   # Morino Rinze に切り替え
#   cursor-switch.sh temari   # Temari Tsukimura に切り替え
#   cursor-switch.sh status   # 現在の設定を表示

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

switch_theme() {
    local theme="$1"
    local size="$2"
    local label="$3"

    # niri config を更新
    sed -i "s|xcursor-theme \".*\"|xcursor-theme \"$theme\"|" "$NIRI_CONFIG"
    sed -i "s|xcursor-size [0-9]*|xcursor-size $size|" "$NIRI_CONFIG"

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

case "${1:-status}" in
    morino|rinze)
        switch_theme "$morino_theme" "$morino_size" "Morino Rinze"
        ;;
    temari|tsukimura)
        switch_theme "$temari_theme" "$temari_size" "Temari Tsukimura"
        ;;
    status)
        current_theme=$(grep 'xcursor-theme' "$NIRI_CONFIG" | sed 's/.*"\(.*\)".*/\1/')
        current_size=$(grep 'xcursor-size' "$NIRI_CONFIG" | sed 's/.*\s\([0-9]*\)/\1/')
        echo "現在のカーソル設定:"
        echo "  テーマ: $current_theme"
        echo "  サイズ: $current_size"
        echo ""
        echo "利用可能なテーマ:"
        echo "  morino  - Morino Rinze"
        echo "  temari  - Temari Tsukimura"
        ;;
    *)
        echo "Usage: cursor-switch.sh [morino|temari|status]"
        exit 1
        ;;
esac