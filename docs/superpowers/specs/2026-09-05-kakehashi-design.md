# kakehashi 導入設計書

## 背景

[kakehashi](https://github.com/atusy/kakehashi) は atusy 製の Rust 製 Language
Server (v1.0.0) である。次の 2 つの機能を持つ。

1. **Tree-sitter によるセマンティックハイライト**: Tree-sitter
   文法を持つ任意の言語で semantic tokens を提供する
2. **LSP ブリッジ**: Markdown
   のコードブロックや文字列リテラル内の埋め込みコード領域に対し、実言語サーバー
   (rust-analyzer, pyright 等) の補完・ホバー・定義ジャンプをルーティングする

単体バイナリとして配布され、リポジトリ直下に `flake.nix`
(`packages.default`) を持つ。nixpkgs 未収録。実行時に Tree-sitter
パーサーをソースからコンパイルするため、**C コンパイラが PATH 上に必要**。

## 目標

- `home.packages` に kakehashi を導入する
- Neovim で Markdown ファイルに対して kakehashi (ハイライト + LSP
  ブリッジ) が有効になる
- Emacs で Markdown ファイルに対して kakehashi (LSP
  ブリッジ) が有効になる

## 非目標

- `kakehashi.toml` の作成(デフォルト設定で動作。必要になったら
  `kakehashi config init` で生成)
- `atusy/kakehashi.nvim` プラグインの導入
- WSL 設定 (`home-manager/wsl/default.nix`) への追加
- Markdown 以外のファイルタイプへの適用(必要に応じて後から拡張)

## 採用アプローチ: flake input + overlay

kakehashi は自前の flake を持つため、ghostty / herdr / hunk / worktrunk
と同じ「flake input + overlay」規約に乗せる。

### 理由

- 上流が `flake.nix` と `flake.lock` を公開しており、ビルド定義の自前管理が不要
- 本リポジトリに確立済みの規約と同一のパターンで追記できる
- `flake.lock` でリビジョンがピン留めされ、再現性がある
- バージョンは hister 同様にタグ (`v1.0.0`) でピン留めする

## 変更ファイル

1. `flake.nix`
   - inputs に `kakehashi.url = "github:atusy/kakehashi/v1.0.0";` を追加
   - overlay ブロックに `kakehashi = inputs.kakehashi.packages.${system}.default;` を追加
2. `packages/development.nix`(実装時に dev 系リストを確認して決定)
   - `kakehashi` を追加
   - C コンパイラが未導入なら `gcc` を追加
3. `config/nvim/lua/configs/lsp.lua`
   - denols ブロックの後に kakehashi ブロックを追加
4. `emacs.d/init.el`
   - `(leaf lsp-mode ...)` ブロックに hook とカスタムクライアント登録を追加
   - `markdown-mode` が未導入なら `emacs.nix` の packages
     リストに追加(実装時に確認)

## 設定概要

### Neovim

既存の `vim.lsp.config` + `vim.lsp.enable`
パターン(astro/ts_ls/denols と同一)で追加する。ハイライトは上流 README
推奨の方法で kakehashi に委譲し、二重ハイライトを防ぐ。

```lua
-- kakehashi: Markdown埋め込みコードのハイライトとLSPブリッジ
vim.lsp.config("kakehashi", {
  cmd = { "kakehashi" },
  filetypes = { "markdown" },
  on_attach = function(_, bufnr)
    -- kakehashiがハイライトを持つため、初回トークン受信時に内蔵ハイライトを停止
    vim.api.nvim_create_autocmd("LspTokenUpdate", {
      buffer = bufnr,
      once = true,
      callback = function()
        vim.opt_local.syntax = "OFF"
        vim.treesitter.stop(bufnr)
      end,
    })
  end,
})
vim.lsp.enable("kakehashi")
```

注意: `dpp_lazy.toml` のグローバルな `FileType` autocmd
が全ファイルタイプで `vim.treesitter.start` を呼ぶため、`FileType`
イベントの再発火時には treesitter が再開される。これは上流 README
のパターン(`once = true`)に準拠した挙動であり、問題が顕在化した時点で
autocmd 側の除外を検討する。

### Emacs

lsp-mode を使用(eglot は未設定のため触らない)。amber-lsp
と同一のカスタムクライアント登録パターンを使う。

```elisp
;; :hook リストに追加
(markdown-mode . lsp-deferred)

;; (with-eval-after-load 'lsp-mode ...) 内に追加
(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection "kakehashi")
                  :major-modes '(markdown-mode)
                  :server-id 'kakehashi))
```

Emacs ではセマンティックハイライトを有効化しない(lsp-mode
のデフォルト=無効のまま)。Emacs 側は既存の treesit font-lock (level 4)
を維持し、kakehashi はコードブロック内の補完・ホバー・定義ジャンプのブリッジとして使う。これにより
Emacs での二重ハイライトを回避する。

### 適用方法

- Neovim / パッケージ: `home-manager switch --flake .#Home --impure`
- Emacs: `emacsclient -s coding` 経由で評価して反映(emacsclient-driven-elisp
  skill 準拠)。`main` デーモンには触れない

## 検証手順

1. `home-manager switch --flake .#Home --impure` を実行
2. `kakehashi --help` と `kakehashi language status` が動作することを確認
3. Neovim で Markdown ファイルを開き、`:checkhealth vim.lsp` または LSP
   アタッチ状態で kakehashi クライアントが接続されていることを確認
4. Emacs (coding デーモン) で Markdown ファイルを開き、`lsp-mode`
   が kakehashi クライアントで起動することを確認

## 代替案

### nvfetcher + `pkgs/kakehashi/default.nix` 自前ビルド

`rustPlatform.buildRustPackage` で自前定義する。ビルド方法を自分で管理できるが、上流
flake の重複実装となり、cargoHash
の更新コストがこちらに乗る。nvfetcher 規約の活用価値は、flake
を持たないツールで発揮される。

### リリースバイナリを fetchurl

`stdenvNoCC.mkDerivation` + GitHub Releases のアセットで最速だが、バージョン更新とハッシュ管理が完全に手動になる。

## 決定事項

- flake input + overlay で導入し、`v1.0.0` タグにピン留めする
- Neovim はハイライトを kakehashi に委譲、Emacs はブリッジ機能のみ使用
- 設定ファイル (`kakehashi.toml`) は作らずデフォルトで運用する
