# AI-DLC and Spec-Driven Development

Kiro-style Spec Driven Development implementation on AI-DLC (AI Development Life
Cycle)

## Project Context

### Paths

- Steering: `.kiro/steering/`
- Specs: `.kiro/specs/`

### Current Environment

- **Desktop**: [niri](https://github.com/YaLTeR/niri) (Wayland compositor)
- Hyprland and Sway are retired. Their configuration files have been deleted and
  neither compositor is enabled in the NixOS or home-manager configuration. Do
  not reintroduce them or assume either is available on this machine.

### Steering vs Specification

**Steering** (`.kiro/steering/`) - Guide AI with project-wide rules and context
**Specs** (`.kiro/specs/`) - Formalize development process for individual
features

### Active Specifications

- Check `.kiro/specs/` for active specifications
- Use `/kiro:spec-status [feature-name]` to check progress

## Development Guidelines

- Think in English, generate responses in Japanese. All Markdown content written
  to project files (e.g., requirements.md, design.md, tasks.md, research.md,
  validation reports) MUST be written in the target language configured for this
  specification (see spec.json.language).

## Minimal Workflow

- Phase 0 (optional): `/kiro:steering`, `/kiro:steering-custom`
- Phase 1 (Specification):
  - `/kiro:spec-init "description"`
  - `/kiro:spec-requirements {feature}`
  - `/kiro:validate-gap {feature}` (optional: for existing codebase)
  - `/kiro:spec-design {feature} [-y]`
  - `/kiro:validate-design {feature}` (optional: design review)
  - `/kiro:spec-tasks {feature} [-y]`
- Phase 2 (Implementation): `/kiro:spec-impl {feature} [tasks]`
  - `/kiro:validate-impl {feature}` (optional: after implementation)
- Progress check: `/kiro:spec-status {feature}` (use anytime)

## Development Rules

- 3-phase approval workflow: Requirements → Design → Tasks → Implementation
- Human review required each phase; use `-y` only for intentional fast-track
- Keep steering current and verify alignment with `/kiro:spec-status`
- Follow the user's instructions precisely, and within that scope act
  autonomously: gather the necessary context and complete the requested work
  end-to-end in this run, asking questions only when essential information is
  missing or the instructions are critically ambiguous.

## Steering Configuration

- Load entire `.kiro/steering/` as project memory
- Default files: `product.md`, `tech.md`, `structure.md`
- Custom files are supported (managed via `/kiro:steering-custom`)

## Project-Specific Tooling Rules

### oh-my-openagent (opencode) Configuration

- **The active oh-my-openagent config is `~/.omo/omo.jsonc`**, sourced from
  `config/omo/omo.jsonc` in this repo. `~/.omo/omo.jsonc` is an out-of-store
  symlink, so edits apply without `home-manager switch`.
- The legacy `~/.config/opencode/oh-my-opencode.json` (sourced from
  `config/opencode/oh-my-opencode.json`) predates the 2026-07 opencode config
  unification. **Do not edit it for model changes** — edit
  `config/omo/omo.jsonc` instead, otherwise changes will not take effect.
- Agent models are overridden per-harness under the `"[opencode]"` section of
  `omo.jsonc`. `agents.<name>.model` sets the primary model; `fallback_models`
  is only the runtime failover chain and does **not** determine the primary
  model.
- Model changes require restarting opencode (new session) to take effect.

### DeepSeek Harness (dsh) Permission Mode

dsh has **no `--yolo` CLI flag**. Sandbox mode and approval policy are derived
only from the `DSH_PERMISSION_MODE` environment variable in
`@deepseek-ai/dsh-base/cordis.patch.yml`:

| `DSH_PERMISSION_MODE` | sandbox              | approval | meaning   |
| --------------------- | -------------------- | -------- | --------- |
| unset                 | `workspace-write`    | `ask`    | default   |
| `read-only`           | `read-only`          | `ask`    | read-only |
| `danger-full-access`  | `danger-full-access` | `never`  | yolo      |

- **Always yolo**: `dsh-web` (`systemd.user.services.dsh-web` in `home.nix`) and
  the `dty` fish abbreviation export `DSH_PERMISSION_MODE=danger-full-access`.
  The Web instance is reachable via the `dsh.comamoca.dev` Cloudflare Tunnel, so
  it is effectively an unauthenticated-by-policy, fully privileged shell.
- Plain `dsh tui` (abbrev `dt`) keeps the defaults.
- Mid-session switching uses `/permission danger-full-access`; that changes only
  the current session, not the default for new ones.
- An explicit `sandbox-policy.mode` / `approval.policy` in a profile's
  `cordis.patch.yml` wins over the environment variable (the profile layer is
  applied after the bundle layer).

### OmniRoute Model Lists (opencode / dsh)

- **Do not hand-edit model lists** in `~/.config/opencode/opencode.json`
  (`provider.omniroute.models`) or in `~/.dsh/profiles/*/cordis.patch.yml` to
  add a combo. Combos are generated from OmniRoute's `GET /v1/models` by
  `bin/scripts/omniroute-combos/omniroute-combos` and consumed by
  `config/opencode/plugins/omniroute-combos.ts` (opencode) and the
  `models: !!js ...` expression in the dsh profiles.
- The generator runs from `omniroute-combos.timer` (`omniroute.nix`). Run
  `omniroute-combos --check` to see whether the client lists are stale.
- dsh evaluates `!!js` with `new Function(... "with(ctx) { eval(expr) }")` under
  YAML `JSON_SCHEMA`: no `require` (use `process.getBuiltinModule`), no object
  literals, and no colon-followed-by-space inside the expression.

### DMS (DankMaterialShell) + niri の自動生成 kdl

- `config/niri/` は `mkOutOfStoreSymlink` で `~/.config/niri` にリンクしている。DMS は
  `~/.config/niri/dms/*.kdl`（= リポジトリの `config/niri/dms/`、トラッキング済み）を
  自動生成する。ヘッダに `DO NOT EDIT` がある通り手で編集しても上書きされる。
  連鎖は `~/.config/niri` → `/nix/store/<hash>-home-manager-files/.config/niri` →
  `/nix/store/<hash>-hm_niri` → **リポジトリの `config/niri/` ディレクトリ**（最後の 1 段が
  ディレクトリ symlink）。つまり store は read-only ではなく、DMS の `cp` / `touch` は
  リポジトリの作業ツリーに直接落ちる（`test -w ~/.config/niri/dms` が真、`readlink -f`
  がリポジトリを返す）。そのため DMS の `.backup<epoch>` もリポジトリ側に出る。
  `config.kdl.backup` と `config.kdl.backup1789124269` は過去に生成されたまま
  **git 追跡されている**ので、`git status` には出てこない。
- `config/niri/config.kdl` 末尾の include ブロックは**必須**。niri が `dms/*.kdl` を
  読まないと `ConfigLoaded` が発火せず、DMS の `FrameTransitionState` が
  「レイアウト適用待ち」のままラッチして、通常バーの代わりに画面全周の角丸フレームを
  描画し続ける。削除・整理しないこと。
- `dms/input.kdl` `binds.kdl` `outputs.kdl` `cursor.kdl` は意図的に include しない。
  公式仕様では include した設定は「それより前に書かれた設定を上書きする」ため、
  config.kdl 末尾の include ブロックに入れると DMS 生成値が `config.kdl` の
  `input` / `cursor` / `outputs` / `binds` を上書きしてしまう。**エラーにはならず
  黙って上書きされる**（26.04 で実測: 4 本とも include しても `config is valid`）。
- niri の `include` は glob 非対応（`include "dms/*.kdl"` は exit 1、`optional=true`
  付きなら `optional include not found: ".../dms/*.kdl"` の WARN だけで exit 0 =
  `*` はリテラル文字として扱われる）。パスは `config.kdl` からの相対、または絶対で
  1 ファイルずつ書く。宣言は niri 26.04 で実測した 5 本
  （`colors` `alttab` `windowrules` `wpblur` `layout`）で固定。
- include のネストは **9 段まで**。10 段で
  `reached the recursion limit; includes cannot be 10 levels deep` になり、
  `niri validate` は exit 1（26.04 実測: 9 段は exit 0、10 段と 20 段は失敗）。
  現構成は 1 段なので余裕があるが、include を連鎖させる仕組みを足すときは注意する。
- すべての include に `optional=true` を付けている。`include "x.kdl" optional=true`
  はファイル欠落時 `optional include not found` の WARN を出して続行する（niri
  26.04 で確認）。これが無いと 1 ファイル欠落で `niri validate` が exit 1 になり
  **設定全体**が parse error になる。include を足すときは `optional=true` を忘れない。
  optional でも補間先の内容が壊れていれば `failed to parse included config` で
  エラーになるため、生成ミスの検出は効いたまま。欠落した optional ファイルも
  watch 対象なので、後から生成されれば自動 reload される。
  仕様: https://niri-wm.github.io/niri/Configuration:-Include.html （`Since: 26.04`）。
  ドキュメント表記は `include optional=true "x.kdl"` だが、KDL として正しい
  `include "x.kdl" optional=true` でも同じように動く（実測）。
- `optional` は **boolean プロパティ必須**。`include "x.kdl" optional`（値なし）は
  `identifiers cannot be used as arguments`、`optional="true"`（文字列）は
  `expected boolean scalar, found string` でどちらもエラー（26.04 実測）。
  `optional=false` は通常 include と同じ扱い。
- optional が許すのは「ファイルが無い」場合だけ。ディレクトリを指すと
  `Is a directory (os error 21)` でエラーになる。
- 相対パスは **その include を書いたファイルのディレクトリ**基準で解決される
  （realpath 基準でも cwd 基準でもない）。ネストした include も同じ規則
  （`a.kdl` が `include "b.kdl"` と書けば `a.kdl` と同じディレクトリの `b.kdl` を読む）。
  `~/.config/niri` ディレクトリごと symlink している現構成なら問題ないが、
  `config.kdl` だけを別ディレクトリへ symlink すると include が壊れるので、
  ファイル単体の symlink 化はしない。
- 起動時に設定が壊れていると niri は WARN を出して**デフォルト設定で起動を続ける**
  （プロセスは落ちない）。reload 時は旧設定を維持したまま同じ WARN を出す。
- `include` はトップレベル専用。ブロック内に書くと `unexpected node \`include\``。
- 自己 include・相互 include は `recursive include (file includes itself)` でエラーに
  なる（ハングしない）。パスは trim されないので末尾スペースは別ファイル扱い。
- 自分自身を指す symlink を include すると `Too many levels of symbolic links
  (os error 40)` でエラー（`optional` では救えない）。壊れた symlink（リンク先が
  存在しない）は ENOENT なので optional で WARN 済み、と挙動が分かれる。
- optional が救えるのは ENOENT だけ。権限エラーは `Permission denied (os error 13)`、
  非 UTF-8 は `stream did not contain valid UTF-8` でどちらもエラーになる。
  空ファイル・コメントのみ・CRLF 改行は valid。
- 欠落ディレクトリや壊れた symlink を指す場合も ENOENT なので optional で WARN 済み。
  rename による原子的置換や「削除 → 再作成」でも reload される（DMS の書き方に追随できる）。
- gaps は DMS の `niriLayoutGapsOverride` が制御する。`-2` = Off で layout.kdl に
  `gaps` を書かず `config.kdl` の値が有効。`0` 以上だと `gaps N` で上書きされる。
  `border` / `focus-ring` の幅は `niriLayoutBorderSize` 由来（layout.kdl に反映）。
- 検証は `niri msg layers` に `dms:bar` が出ること、`dms ipc call settings set
  frameEnabled true/false` で `dms:frame` ⇄ `dms:bar` が入れ替わること。負値の設定は
  `dms ipc call settings set niriLayoutGapsOverride -- -2` のように `--` を挟む。

#### niri include のマージ仕様（26.04 実測）

- 単一セクション（`layout` `input` `cursor` `binds` `animations` など）は
  **プロパティ単位でマージ**され、後から現れた指定が勝つ（位置依存）。実測:
  `config.kdl` に `layout { gaps 0 }` を書いて末尾で include した `gaps 40` が勝ち
  （`layout.tile_size` の高さ 1306px）、2 行の順序を入れ替えると `gaps 0` が勝った
  （1390px）。指定しなかったプロパティは上書きされず残る（`merge_with` は `Some`
  のフィールドだけコピーする）。
- 同一ファイル内で同じ単一セクションを 2 回書くと `duplicate node` でエラーになる。
  別ファイル（include 先）ならエラーにならずマージされる。同じファイルを 2 回
  include してもエラーにならない（重複検出は無く、単に 2 回評価されて後勝ち）。
  違うファイルから同じプロパティ（例 `layout { gaps }`）を与えても同様に exit 0 で、
  後に include した方が勝つ。**include の重複は niri では検出できない**ので、
  気付くには `grep -n '^include'` で一覧を目視するしかない。
- **`output` だけは例外**。multipart として `Vec` に積まれ、検索が
  `Outputs::find`（`iter().find()`）なので **最初にマッチしたブロックだけが有効**で
  マージされない。実測: `output "winit" { scale 4.0 }` の次に
  `output "winit" { position x=30 y=40 }` を書くと scale=4.0、position は既定の 0,0。
  同一ファイル内の重複も許容され、2 個目以降は黙って無視される。したがって
  `output` の設定は 1 か所にまとめ、include より前に置く。
  `window-rule` `workspace` `spawn-at-startup` も multipart だが、こちらは全件が
  適用され、include の位置が評価順になる。
- `binds` は「新しい定義が競合する既存定義を置き換える」実装なので、include を
  後ろに置くと include 側の bind が勝つ。だから `dms/binds.kdl` は include しない。
- `layout` の `border` / `focus-ring` は `off` と `on` が独立したフラグで、
  `off |= part.off`、`on` が来たら `off = false` という単調なマージ。include 先の
  `layout { border { width 4 } }` は `off` も `on` も書かないので、こちらの
  `border { off }` は保持される（border は描かれない。focus-ring は別セクションなので
  `width 4` のリングはそのまま出る）。なお `layout { border {} }` が
  border を有効化するのは最上位ファイル（`recursion == 0`）だけで、include 先では
  その特別扱いが効かない。
- 前段の「include した設定はそれより前の設定を上書きする」は単一セクションの話で、
  `output` には当てはまらない。混同しないこと。

#### DMS の include 自動修復（`ConfigInclude.fix()`）の危険

- DMS 設定 UI は `dms config resolve-include niri <kind>.kdl`（Go 側）の結果で
  `included` を判定し、欠けている kind があるとバナーを出す。kind は 6 個
  （`outputs` `layout` `input` `windowrules` `cursor` `binds`）。2026-10 時点の実測は
  `layout` と `windowrules` が `true`、`outputs` `input` `cursor` `binds` が `false`。
  DMS が生成する 9 kind（上記 + `colors` `alttab` `wpblur`）で現在の値を引くと
  `alttab` `colors` `layout` `windowrules` `wpblur` が `included:true`、
  `binds` `cursor` `input` `outputs` が `included:false`（= 意図通り）。
  このコマンドは 1 行 JSON（`{"exists":true,"included":true}`）を返すので
  スクリプトからも判定できる。**`exists:true` でも `included:false` なら設定は
  効いていない**（`dms/input.kdl` は DMS に書かれても include していないので無効）。
- バナーの「fix」を押すと `ConfigInclude.fix()` が
  `Common/ConfigIncludeResolve.js` の repair script を `sh -c` で実行し、
  `config.kdl` を `.backup<epoch>` に `cp` したうえで **include 行をファイル末尾に
  追記**する（`mkdir -p dms` と `touch dms/*.kdl` も同時に行う）。
- 追記される行は `include "dms/<name>.kdl"` で、**`optional=true` が付かない**。
  我々の手書き行と違い、対応する `dms/*.kdl` が後で消えると `niri validate` が
  exit 1 になり設定全体が parse error になる（niri はデフォルト設定で起動を続ける）。
- 追記前の重複判定は「コメント行を除いた本文に `include.*"dms/<name>.kdl"` があるか」
  の grep。我々の `include "dms/layout.kdl" optional=true` も一致するので
  `layout` と `windowrules` は追記されない。残り 4 本が追記される。
- `// DMS Include Configs` のバナー行が付くのは「`dms/` への include が 1 本も無い」
  ときだけ。既に 5 本あるのでバナーは付かず、**末尾に 4 行だけ静かに増える**。
  そのため diff を見るまで追記に気付きにくい。
- 末尾追記 = 後勝ちなので、追記された `dms/input.kdl` などの値が `config.kdl` の
  `input` / `cursor` を黙って上書きする。後勝ちのマージ順自体は `layout.gaps` で
  実測済み。`dms/input.kdl` は `mouse.accel-speed 0.0` と
  `touchpad.accel-speed 0.0` を書くので、末尾に追記されると `config.kdl` の
  `0.5` / `0.4` は `0.0` になる（accel-speed は IPC に出ないため値の変化は
  ファイルと実装から判断する）。エラーも通知も出ない。
- `binds` `cursor` `outputs` は現在 0 バイトなので追記されても実害は出ないが、
  DMS の設定 UI を触って値が書き込まれた時点で上書きが始まる。
- **結論: DMS の include バナーでは fix を押さない。** include は `config.kdl` の
  ブロックを唯一の正とする。追記された場合はその行を消して戻す（消すとバナーが
  再び出るだけで実害はない）。検出は `dms config resolve-include niri <kind>.kdl`
  （Go 側の実装）で、grep を使うのは repair script の重複判定だけ。

#### include とマージ仕様の再検証手順

- 検証用の config を手で書くときは KDL v2 の構文に注意。**1 行ブロックは不可**で
  `layout { gaps 3 }` は `found `}`, expected ...` で exit 1 になる。`}` の前に改行が
  必要（`layout {\n    gaps 3\n}\n`）。include 先でこれをやると
  `failed to parse included config` になり、原因が include 側に見えて紛らわしい。
- ネスト niri を `WAYLAND_DISPLAY=wayland-1 niri -c /tmp/x/config.kdl` で起動すると
  次の空き socket 名（`wayland-2`）を取り、IPC は `niri.wayland-2.<pid>.sock` になる。
  クライアントは `WAYLAND_DISPLAY=wayland-2` で接続する。起動ログの
  `IPC listening on:` 行から socket を特定できる。
- 設定の反映は `touch <config>`（`reload-config` action は 26.04 に存在しない）。
  反映は journal の `loaded config from` で確認する。
- `layout` の値は `foot` を `WAYLAND_DISPLAY=wayland-2` で起動し、
  `niri msg --json windows` の `layout.tile_size` で読める（gaps 差が高さにそのまま出る）。
- `output` の scale / position は `niri msg --json outputs` で読める。ただし winit
  バックエンドは `transform` を反映しない（実測: `transform "90"` を書いても
  `Flipped180` のまま）ので、transform を観測値に使わない。

### Emacs Lisp Evaluation

This dotfiles setup runs multiple Emacs daemons as systemd units
(`emacs@<name>.service`). When modifying Emacs configuration (`init.el`,
`emacs.d/lisp/`, etc.), configuration changes must be applied through the
running daemon.

- **Always use `emacsclient`** to evaluate or load elisp.
- **Always target the `coding` daemon** (`emacsclient -s coding -e '...'`).
- **Never evaluate expressions against the `main` daemon** — that is the user's
  primary session.
- Do **not** start a standalone `emacs` process for evaluation.
- Do **not** leave application of changes to the user; apply them via
  `emacsclient` and verify the result.
- After changing `emacs.nix` or Nix-related Emacs package definitions, remind
  the user to run `home-manager switch --flake .#Home --impure` (or the
  equivalent NixOS rebuild) so the daemon's package set is rebuilt.

See the `emacsclient-driven-elisp` skill for detailed commands and verification
steps.

### sudo / Askpass

- `SUDO_ASKPASS` is wired to `ksshaskpass` in `home.nix`
  (`home.sessionVariables` and `systemd.user.sessionVariables`), so privileged
  commands ask the user for the password through a GUI dialog instead of
  requiring a terminal.
- An agent shell usually has no TTY, so plain `sudo <cmd>` automatically falls
  back to that dialog. Use `sudo -A <cmd>` to force it when a TTY is present.
- Never capture, store, or pipe the password yourself — let the askpass helper
  read it. Do not add `NOPASSWD` rules to skip the prompt.
