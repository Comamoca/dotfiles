# hister.el 設計仕様 — hister × consult リアルタイム検索

- 日付: 2026-08-25
- ステータス: ユーザーレビュー待ち
- 成果物: `~/.emacs.d/lisp/hister.el` (+ `~/.emacs.d/lisp/hister-test.el`)

## 1. 目的

Emacs から個人検索エンジン hister (asciimoo/hister v0.18.0) を検索し、consult
のライブ絞り込みで結果をリアルタイム表示する。候補を RET するとそのページの本文を
hister のインデックスから取得して Org 形式でバッファに書き出す。ブラウザで開く・
URL コピーは embark アクションとして提供する。

## 2. 確定済み決定事項(ユーザー回答)

| # | 決定 | 出所 |
|---|---|---|
| D1 | RET = サイトの内容をバッファに書き出して表示 | ユーザー回答 1 |
| D2 | ブラウザで開く・URLコピーは embark アクションで対応 | ユーザー回答 1 |
| D3 | 出力形式は Org 優先(RET = Org) | ユーザー回答 3 |
| D4 | 実装アプローチは CLI subprocess 経由(案1) | ユーザー回答 4 |

## 3. 実測済み技術事実(本環境)

- hister v0.18.0 (`~/.nix-profile/bin/hister`)、サーバー稼働中 `127.0.0.1:4433`
- `hister search <query> -f json -L N --sort relevance --client-timeout 5` → JSON 配列
  - **末尾カンマ付き**(最終要素の後にも `,`)→ 厳密 JSON 非準拠。パース前に `,\n]` → `\n]` 正規化が必要(実測で確認)
  - フィールド: `id, url, title, domain, score, added, updated, text, html, ...`
  - `-F html` で本文 HTML 取得可(実測 ~200–330KB/件)
  - `url:<exact-url>` フィルタで特定ページ検索可(実測 OK)
  - `added`/`updated` は unix timestamp
- HTTP API (`GET /search?format=json&include_html=1`) も存在するが D4 により不使用
- Emacs 32.0.50、consult v20260805(async pipeline primitives 全存在を実確認)、embark 利用可(`embark-keymap-alist`)
- `libxml-parse-html-region` 組込。pandoc 等の外部変換器なし → 純 elisp DOM→Org 変換

## 4. アーキテクチャ

単一ファイル `~/.emacs.d/lisp/hister.el`。依存: consult / embark(共に既導入) /
libxml2(built-in)。init.el には統合行数行のみ追加(§7)。

### 4.1 カスタマイズ変数

| 変数 | 初期値 | 説明 |
|---|---|---|
| `hister-executable` | `"hister"` | CLI パス |
| `hister-limit` | `30` | 1クエリ最大件数 |
| `hister-client-timeout` | `5` | CLI `--client-timeout` 秒 |
| `hister-sort` | `"relevance"` | relevance / date / domain / visits |
| `hister-min-input` | `2` | 検索発火に必要な最小入力文字数 |

### 4.2 コンポーネント

```
(hister--run-search QUERY FIELDS LIMIT) → alist のリスト | nil
    CLI を同期実行: hister search QUERY -f json [-F FIELDS] [-L LIMIT]
                    --sort hister-sort --client-timeout hister-client-timeout
    出力正規化(",\n]"→"\n]")→ json-parse-string (:object-type 'alist :array-type 'list)
    プロセス異常・パース失敗 → lwarn 'hister して nil

(hister--format-candidate DOC) → 候補文字列
    書式: "TITLE · domain · YYYY-MM-DD" (日付は updated 由来)
    text-property 'hister-url に url、'hister-title に title を付与

(hister-search) interactive — メインコマンド
    consult--read + async pipeline:
      入力 → process起動(hister search <input> ...) → 変換(JSONパース+候補化)
           → throttle/debounce → refresh
    入力が hister-min-input 未満なら検索しない
    category 'hister(metadata)で embark と接続
    RET → hister-open

(hister--fetch-html URL) → html string | nil
    (hister--run-search (concat "url:" URL) "id,url,title,html" 1)
    html > 5MB は先頭で切り詰め

(hister--html-to-org HTML) → org string
    libxml-parse-html-region → DOM 再帰変換(対応表 §4.3)

(hister-open CANDIDATE-OR-URL)
    fetch → convert → バッファ "*Hister: TITLE*"(60字上限)、org-mode、read-only
    header-line-format: "hister · URL · updated YYYY-MM-DD"
```

### 4.3 HTML → Org 対応表

| 要素 | Org 出力 |
|---|---|
| h1–h6 | `*` – `******` |
| p | 段落(空行区切り) |
| ul/li, ol/li | `- ` / `N. `(ネストはレベル毎にスペース2) |
| pre(内包 code 含む) | `#+begin_example` / `#+end_example` |
| blockquote | `#+begin_quote` / `#+end_quote` |
| a | `[[href][text]]` |
| img | `[[src]]` |
| strong/b, em/i, code(inline) | `*text*`, `/text/`, `` ~text~ `` |
| br / hr | 改行 / `-----` |
| table | org テーブル化(`|セル|`)。先頭行が th なら次行に `|---+---|` 区切り。colspan/rowspan はセルのフラット化で縮退 |
| script/style/noscript/svg/head | 除去 |
| テキストノード | 空白正規化 |

未知タグは子要素を再帰処理。

### 4.4 embark 統合

```elisp
;; 候補文字列から 'hister-url property を取り出してからアクションへ渡すラッパ
(defun hister--with-url (fn candidate)
  (funcall fn (get-text-property 0 'hister-url candidate)))

(with-eval-after-load 'embark     ; embark 未ロード時の embark-url-map 参照を回避
  (defvar-keymap hister-embark-actions
    :parent embark-url-map        ; 標準 URL アクションを継承
    "b" (apply-partially #'hister--with-url #'browse-url)
    "w" (apply-partially #'hister--with-url #'kill-new))
  (add-to-list 'embark-keymap-alist '(hister . hister-embark-actions)))
```

## 5. データフロー

```
M-x hister-search
  → minibuffer 入力(≥2文字で発火)
  → [非同期] hister search <q> -f json -L 30 ...
  → 正規化 → json-parse-string → 候補変換 → ライブ絞り込み
RET → 'hister-url 取得 → url:<url> で本文 HTML 取得
    → libxml-parse-html-region → Org 変換 → org-mode バッファ表示
embark → b(ブラウザ) / w(URLコピー)
```

## 6. エラー処理

| 状況 | 挙動 |
|---|---|
| サーバー停止・タイムアウト | 候補領域に "(No results)" + `lwarn` 接続失敗(クラッシュしない) |
| 本文が未インデックス | `user-error`「インデックスに本文がありません(URL)。embark b でブラウザ表示できます」 |
| JSON パース失敗 | `lwarn` + nil |
| 巨大 HTML (>5MB) | 先頭 5MB に切詰め、バッファ先頭に警告行 |
| 短すぎる入力 (<min-input) | 検索スキップ |

## 7. init.el 統合(案)

```elisp
(with-eval-after-load 'consult
  (add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
  (require 'hister))
```

正確な挿入位置・use-package 構造への適合は plan フェーズで init.el 実装に合わせ確定。

## 8. テスト計画

ERT (`~/.emacs.d/lisp/hister-test.el`):

| テスト | 内容 |
|---|---|
| json 正規化 | trailing comma フィクスチャ → パース成功・件数一致 |
| 候補整形 | title/domain/date 書式 + `'hister-url` property |
| HTML→Org | 見出し/リスト/リンク/pre/quote/bold/img/table 各フィクスチャ → 期待 Org 文字列 |
| 除去系 | script/style が出力に混入しないこと |

実行: `emacs --batch -l lisp/hister.el -l lisp/hister-test.el -f ert-run-tests-batch-and-exit` → exit 0

手動 QA(実サーバー):
1. batch で `hister--run-search` を実データに対し実行 → 実件数 > 0
2. 実ページ HTML を `hister--html-to-org` に通し Org 出力を確認
3. `hister-search` 相当の非同期フローで候補生成 → RET 相当でバッファ生成を確認

## 9. 非目標(YAGNI)

- Markdown 出力(D3 により RET=Org のみ。将来要望があれば拡張点)
- semantic search UI、書き込み操作(index/delete/import)
- hister の config.yml を elisp から管理すること(CLI が処理)
- ローカルファイル文書(type=local 等)の専用表示フロー(v1 では web 文書と同一経路。html 取得不可なら §6 のエラー処理に従う)

## 10. Plan フェーズでの検証項目

- インストール済み consult v20260805 ソースでの async pipeline 正確な API 名・シグネチャ確認
- init.el の use-package 構造への組み込み位置確定
