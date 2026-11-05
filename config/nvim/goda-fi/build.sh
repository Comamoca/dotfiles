#!/usr/bin/env bash
# goda-fi.vim の設定 (このディレクトリの Go モジュール) をビルドして
# キャッシュディレクトリへ置く。dpp の installerBuild からも、手動からも呼べる。
#
# 使い方:
#   ./build.sh          # ビルドして ~/.cache/nvim/goda-fi/goda-fi を置き換える
#   ./build.sh --check  # ビルドせず、go が見つかるかと出力先だけ確認する
#
# go は PATH に無いことがある (このマシンには入っていない) ので、
# 無ければ nix shell で一時的に用意する。
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
out_dir="${XDG_CACHE_HOME:-$HOME/.cache}/nvim/goda-fi"
out="$out_dir/goda-fi"

if [[ "${1:-}" == "--check" ]]; then
  echo "config dir: $here"
  echo "output:     $out"
  command -v go >/dev/null 2>&1 && echo "go: $(command -v go)" || echo "go: not in PATH (nix shell で補う)"
  exit 0
fi

mkdir -p "$out_dir"

# go が PATH に無ければ nix から借りる。--inputs-from は使わず、
# nixpkgs をそのまま引く (go はバイナリキャッシュ済みなので数秒で用意できる)。
if command -v go >/dev/null 2>&1; then
  build() { go -C "$here" build -o "$1" .; }
else
  build() { nix shell nixpkgs#go --command go -C "$here" build -o "$1" .; }
fi

# 実行中のバイナリを壊さないよう、別名で作ってから rename する。
tmp="$out.new"
build "$tmp"
mv -f "$tmp" "$out"
echo "goda-fi: built $out"
