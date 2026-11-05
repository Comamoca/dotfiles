# カーソルテーマ (Temari Tsukimura) 適用調査ログ

niriにカスタムカーソルテーマ「Temari Tsukimura」を導入する際、Emacs
(pgtkビルド、systemdユーザーサービスとして常駐) だけカーソルアイコンが
新しいテーマに変わらない問題が未解決のまま残っている。

## 状況 (2026-09-09時点)

- niri本体・他のGUIアプリ (ターミナル、ブラウザ等) では新テーマが正しく描画される
- Emacs (emacs-main / emacs@canary / emacs@coding の3デーモン) だけ、
  以前のテーマ (breeze_cursors) のまま変化しない
- 上記すべての対策を投入し、デーモンを完全に再起動 (systemctl restart) した後でも改善せず

## テーマの導入元

- `fast_install.run` という自己解凍型インストーラー (Simple Cursor Loader /
  SimpleCursorMake製) から、同梱バイナリを実行せずにペイロード
  (`payload.tar.gz`) のみを手動展開して導入
- テーマ名: `Temari Tsukimura` (作者: 乱涂乱画ben)
- 配置場所: `~/.local/share/icons/Temari Tsukimura/`
  (`index.theme` に `Inherits=Adwaita`、カーソル43種、`manifest.json` 上のネイティブサイズは32px)

## これまでに適用した対策

### 1. niri設定へのcursorブロック追加

- **ファイル**: `config/niri/config.kdl`
- **設定**:
  ```kdl
  cursor {
      xcursor-theme "Temari Tsukimura"
      xcursor-size 43
  }
  ```
- **効果**: niriが直接起動するプロセス、および compositor 自身が描画する
  カーソル (cursor-shape-v1経由) には正しく反映されることを確認済み
- **参考**: https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous

### 2. `~/.local/share/icons` から `~/.icons` へのシンボリックリンク追加

- **設定**: `~/.icons/Temari Tsukimura -> ~/.local/share/icons/Temari Tsukimura`
- **理由**: niri 25.08系に、`~/.local/share/icons` 配下のカスタムカーソル
  テーマを認識できない既知バグがある。`XCURSOR_PATH` に含まれていても
  niri側で無視される (2026-09時点でも再発報告あり、未修正)
- **参考**: https://github.com/niri-wm/niri/issues/2339
- **削除条件**: niriの当該issueが修正された場合

### 3. GTK settings.ini の書き換え

- **ファイル**: `~/.config/gtk-3.0/settings.ini`, `~/.config/gtk-4.0/settings.ini`
  (dotfiles管理外、直接編集)
- **設定**: `gtk-cursor-theme-name=Temari Tsukimura` / `gtk-cursor-theme-size=43`
  (元々 `breeze_cursors` / `24` が明示的に設定されていた)
- **効果**: 他のGTKアプリでは有効。Emacsには効果なし

### 4. systemdユーザー環境への XCURSOR_THEME / XCURSOR_SIZE 追加

- **ファイル**: `~/.config/environment.d/98-cursor-theme.conf` (dotfiles管理外)
  ```
  XCURSOR_THEME=Temari Tsukimura
  XCURSOR_SIZE=43
  ```
- **理由**: `emacs-main.service` 等はniriのプロセスツリー外の
  systemdユーザーサービスとして起動されるため、niriの `cursor {}`
  ブロックが生成する環境変数を一切継承していなかった (対策前は
  `XCURSOR_THEME`/`XCURSOR_SIZE` が環境変数に存在しないことを確認済み)
- **効果**: `systemctl --user set-environment` で即時反映、
  `emacs-main` / `emacs@canary` / `emacs@coding` を再起動して
  各プロセスの `/proc/<pid>/environ` で正しい値が渡っていることまで
  確認したが、**Emacs上のカーソル描画自体には変化なし**

## 未解決の切り分け状況

- niri: OK (compositor描画・直接起動プロセスとも正常)
- niri journal (`journalctl --user -u niri.service`): "Temari Tsukimura"
  テーマの読み込みエラーなし (`grabbing` 形状のみ未対応で警告、
  `default`/`text`等の基本形状はエラーなし)
- 他のGTKアプリ: OK (settings.ini反映後、正常に新テーマへ変化)
- Emacs (pgtk, 3デーモンとも): NG
  - `journalctl --user -u emacs-main.service`: Gtk/Gdk/cursor関連の
    警告・エラーは一切出力されていない (エラーなしで単に変わらない)
  - 環境変数・GTK設定ファイルの両方を正しく渡していることを確認済みだが
    改善しない → Emacs pgtk側の実装がそもそも `gtk-cursor-theme-name`や
    `XCURSOR_THEME`環境変数を見ていない、または独自にカーソルを
    キャッシュ/ハードコードしている可能性が高い

## 次の調査候補 (未実施)

- [ ] Emacsを一切のsystemdサービス化なしで直接ターミナルから
      `emacs -Q` (素の状態) で起動し、カーソルが変わるか確認する
      → 個人の init.el 側の設定 (例: `x-pointer-shape` や
      `void-text-area-pointer` の明示的な上書き) が原因かどうかの切り分け
- [ ] `M-x report-emacs-bug` 相当のdebbugs.gnu.orgで
      "pgtk cursor theme" 関連の既知バグを検索する
      (使用しているEmacsはnixpkgs unstableのgitスナップショット
      ビルド (`emacs-git-pgtk`) であり、master追跡ビルド特有の
      リグレッションの可能性も否定できない)
- [ ] `(frame-parameter nil 'cursor-type)` ではなく、マウスポインタ形状に
      関わる `void-text-area-pointer` / `x-pointer-shape` 等の変数が
      init.el 内でカスタマイズされていないか確認する
- [ ] xwayland-satellite やXWayland経由での描画になっていないか
      (pgtkのはずだが、一部プラグイン/フレームがXWaylandを
      経由していないか) 確認する

## 削除条件

上記のいずれかの原因が特定でき、Emacsでも正しくテーマが反映されることを
確認できた時点で、このファイルの内容を反映結果に置き換えるか削除する。
