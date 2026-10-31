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
- `config/niri/config.kdl` 末尾の include ブロックは**必須**。niri が `dms/*.kdl` を
  読まないと `ConfigLoaded` が発火せず、DMS の `FrameTransitionState` が
  「レイアウト適用待ち」のままラッチして、通常バーの代わりに画面全周の角丸フレームを
  描画し続ける。削除・整理しないこと。
- `dms/input.kdl` `binds.kdl` `outputs.kdl` `cursor.kdl` は `config.kdl` 側の設定と
  衝突するため意図的に include しない。
- niri の `include` は glob 非対応（`include "dms/*.kdl"` は exit 1）。パスは
  `config.kdl` からの相対、または絶対で 1 ファイルずつ書く。宣言は niri 26.04 で
  実測した 5 本（`colors` `alttab` `windowrules` `wpblur` `layout`）で固定。
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
- gaps は DMS の `niriLayoutGapsOverride` が制御する。`-2` = Off で layout.kdl に
  `gaps` を書かず `config.kdl` の値が有効。`0` 以上だと `gaps N` で上書きされる。
  `border` / `focus-ring` の幅は `niriLayoutBorderSize` 由来（layout.kdl に反映）。
- 検証は `niri msg layers` に `dms:bar` が出ること、`dms ipc call settings set
  frameEnabled true/false` で `dms:frame` ⇄ `dms:bar` が入れ替わること。負値の設定は
  `dms ipc call settings set niriLayoutGapsOverride -- -2` のように `--` を挟む。

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
