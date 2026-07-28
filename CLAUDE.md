# AI-DLC and Spec-Driven Development

Kiro-style Spec Driven Development implementation on AI-DLC (AI Development Life Cycle)

## Project Context

### Paths
- Steering: `.kiro/steering/`
- Specs: `.kiro/specs/`

### Current Environment
- **Desktop**: [niri](https://github.com/YaLTeR/niri) (Wayland compositor)
- The repository contains legacy Hyprland config files (`config/hypr/`, `hyprland.nix`, `hyprlock.nix`) for reference, but the active environment is niri.
- Do not assume Hyprland is the current desktop environment based on the presence of these files.

### Steering vs Specification

**Steering** (`.kiro/steering/`) - Guide AI with project-wide rules and context
**Specs** (`.kiro/specs/`) - Formalize development process for individual features

### Active Specifications
- Check `.kiro/specs/` for active specifications
- Use `/kiro:spec-status [feature-name]` to check progress

## Development Guidelines
- Think in English, generate responses in Japanese. All Markdown content written to project files (e.g., requirements.md, design.md, tasks.md, research.md, validation reports) MUST be written in the target language configured for this specification (see spec.json.language).

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
- Follow the user's instructions precisely, and within that scope act autonomously: gather the necessary context and complete the requested work end-to-end in this run, asking questions only when essential information is missing or the instructions are critically ambiguous.

## Steering Configuration
- Load entire `.kiro/steering/` as project memory
- Default files: `product.md`, `tech.md`, `structure.md`
- Custom files are supported (managed via `/kiro:steering-custom`)

## Project-Specific Tooling Rules

### Emacs Lisp Evaluation

This dotfiles setup runs multiple Emacs daemons as systemd units (`emacs@<name>.service`). When modifying Emacs configuration (`init.el`, `emacs.d/lisp/`, etc.), configuration changes must be applied through the running daemon.

- **Always use `emacsclient`** to evaluate or load elisp.
- **Always target the `coding` daemon** (`emacsclient -s coding -e '...'`).
- **Never evaluate expressions against the `main` daemon** — that is the user's primary session.
- Do **not** start a standalone `emacs` process for evaluation.
- Do **not** leave application of changes to the user; apply them via `emacsclient` and verify the result.
- After changing `emacs.nix` or Nix-related Emacs package definitions, remind the user to run `home-manager switch --flake .#Home --impure` (or the equivalent NixOS rebuild) so the daemon's package set is rebuilt.

See the `emacsclient-driven-elisp` skill for detailed commands and verification steps.
