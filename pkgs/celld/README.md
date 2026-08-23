# celld

`https://celld.deno.dev/install.sh` 相当の処理を Nix flake にしたもの。
公式のプリビルド済みリリースバイナリ (`celld-<target>.gz`) を取得して展開する。

## 使い方

```sh
nix run ./pkgs/celld -- --help
nix build ./pkgs/celld#celld
nix profile install ./pkgs/celld#celld
```

このリポジトリの `{ pkgs }` 規約からは `pkgs/celld/default.nix` を使う。

```nix
pkgs.callPackage ./pkgs/celld { }   # もしくは import ./pkgs/celld { inherit pkgs; }
```

overlay も公開している。

```nix
nixpkgs.overlays = [ inputs.celld.overlays.default ];
```

## 対応プラットフォーム

インストールスクリプトと同じく `x86_64-linux` / `aarch64-linux` /
`aarch64-darwin` のみ。

## バージョン更新

1. 最新タグを確認する。

   ```sh
   curl -fsSI -o /dev/null -w '%{redirect_url}\n' \
     https://github.com/denoland/celld/releases/latest/download/celld-x86_64-unknown-linux-gnu.gz
   ```

2. `package.nix` の `version` を書き換える。
3. 各ターゲットのハッシュを取り直す。

   ```sh
   for t in x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu aarch64-apple-darwin; do
     nix store prefetch-file --json \
       "https://github.com/denoland/celld/releases/download/vX.Y.Z/celld-$t.gz" |
       jq -r --arg t "$t" '"\($t) \(.hash)"'
   done
   ```

## インストールスクリプトとの差異

- `$HOME/.local` へのインストール・`bin/celld`
  シンボリックリンクの張り替えは行わない (Nix
  のプロファイル/世代がその役割を担うため)。
- `celld deploy` が必要とする esbuild は `makeWrapper` で PATH に注入済み。
- ダウンロードの完全性は gzip の CRC ではなく固定ハッシュで検証する。
