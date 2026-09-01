# terminal-browser

`https://terminal-browser.sh/install` 相当の処理を Nix パッケージにしたもの。
公式のプリビルド済みリリース (`terminal-browser-<target>.tar.gz`)
を取得して展開する。

インストールスクリプトと違い、以下は行わない。

- `~/.local/share` / `~/.local/bin` への書き込み
- 各エージェントのスキルディレクトリ (`~/.claude/skills` など)
  へのシンボリックリンク作成
- 起動中プロセスの `pkill`
- `terminal-browser setup` の自動実行

## 使い方

```sh
nix run ./pkgs/terminal-browser -- --help
nix build ./pkgs/terminal-browser#terminal-browser
```

このリポジトリの `{ pkgs }` 規約からは `pkgs/terminal-browser/default.nix`
を使う。

```nix
pkgs.callPackage ./pkgs/terminal-browser { }   # もしくは import ./pkgs/terminal-browser { inherit pkgs; }
```

overlay も公開している。

```nix
nixpkgs.overlays = [ inputs.terminal-browser.overlays.default ];
```

## Electron

tarball が同梱する 313 MB の Electron 43.3.0 は破棄し、nixpkgs の `electron_43`
(43.2.0) を使う。ネイティブアドオン `browser/native/pixel.node` は N-API なので
Electron のマイナー差では ABI が壊れない。

CLI は `$TERMINAL_BROWSER_DIST_ROOT/electron/electron` を直接 spawn するため、
そこには nixpkgs の**ラッパー** (`bin/electron`) へのシンボリックリンクを置いて
いる。GTK / GIO / gsettings の環境変数がこれで揃う。

Chromium のサンドボックスは setuid ヘルパではなく unprivileged user namespace
で動く (NixOS のデフォルトで有効)。`scripts/apparmor.sh` は
`/proc/sys/kernel/apparmor_restrict_unprivileged_userns` が `1` のときだけ動く
ので、NixOS では発火しない。

## スキル

`$out/share/terminal-browser/skills/{default,codex}/terminal-browser` に入って
いる。インストールスクリプトと同じ配置にしたい場合は home-manager から張る。

```nix
home.file.".claude/skills/terminal-browser".source =
  "${terminal-browser}/share/terminal-browser/skills/default/terminal-browser";
home.file.".codex/skills/terminal-browser".source =
  "${terminal-browser}/share/terminal-browser/skills/codex/terminal-browser";
```

## 対応プラットフォーム

`x86_64-linux` / `aarch64-linux` のみ。 darwin 版の tarball は `electron/`
ではなく `terminal-browser.app` を同梱して おり、install phase
を分ける必要があるため未対応。

## バージョン更新

インストールスクリプトがバージョンと SHA-256 を持っているので、そこから拾う。

```sh
curl -fsSL https://terminal-browser.sh/install | grep -A4 '^PLATFORMS='
nix hash convert --hash-algo sha256 --to sri <hex>
```
