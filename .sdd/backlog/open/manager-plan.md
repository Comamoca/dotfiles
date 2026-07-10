# Dotfiles Management Plan

## Goal
Manage and improve the dotfiles configuration — reduce technical debt, consolidate redundant configs, and maintain quality.

## Current State Assessment

### Strengths
- Well-modularized Nix configuration (packages split by category)
- Active maintenance (recent commits show consistent updates)
- Good use of Catppuccin theming across tools
- Existing Kiro spec-driven development workflow
- Emacs daemon via systemd with proper Wayland integration

### Pain Points
- **Dead code**: ~80+ commented-out lines in fish.nix, stale TODO comments in home.nix
- **Redundant PATH management**: PATH entries in home.nix sessionPath, fish.nix, and other places
- **Duplicate packages**: emacs.nix has several packages listed twice
- **Nix flake hygiene**: `old-pkgs`/`unstable-pkgs` fetchTarball anti-pattern, potentially unused flake inputs
- **Multi-WM sprawl**: 4 WMs configured (Niri primary, Hyprland, Sway, i3) with potential conflicts
- **Missing steering**: .kiro/steering/ directory not yet established for AI agent guidance
- **stateVersion**: Still at 24.05 — should evaluate bump

## Task Decomposition

### Priority 1 (High) — Cleanup & Hygiene

**Task 1: Clean up dead code and commented-out configurations** (89cbc8136725)
- Clean fish.nix: remove ~80 lines of stale commented-out path/alias entries
- Remove/resolve TODO comments in home.nix
- Remove eqsh references (temporarily disabled indefinitely)
- Remove duplicate Emacs packages in emacs.nix
- *Effort: 45 min | Complexity: Low*

**Task 2: Consolidate shell and path configuration** (1cb545d1cd04)
- Single source of truth for PATH in home.nix sessionPath
- Remove duplicate entries from fish.nix
- Clean up fish.nix shellInit from dead aliases
- *Effort: 30 min | Complexity: Low | Depends on Task 1*

### Priority 2 (Medium) — Maintenance

**Task 3: Update Nix flake inputs and fix deprecations** (e7361b6ff968)
- Run `nix flake update`
- Audit unused flake inputs
- Replace `fetchTarball` anti-patterns with flake inputs where appropriate
- Evaluate stateVersion bump from 24.05
- *Effort: 60 min | Complexity: Medium*

**Task 4: Emacs package set maintenance** (a986e6e3c461)
- Remove duplicate packages
- Verify external package sources are current
- Audit emacs-overlay vs emacs input necessity
- *Effort: 30 min | Complexity: Low*

### Priority 3 (Lower) — Documentation & Audit

**Task 5: Create steering files and document conventions** (f9a5bfda4d63)
- Create .kiro/steering/product.md, tech.md, structure.md
- Document codebase conventions (commented-out section patterns, etc.)
- *Effort: 45 min | Complexity: Low*

**Task 6: Multi-WM configuration audit and consolidation** (f68e4f2136e0)
- Audit Niri vs Hyprland vs Sway vs i3 usage
- Check portal configuration conflicts
- Document which WMs are active vs legacy
- *Effort: 45 min | Complexity: Medium*

## Execution Order
1. Task 1 → Task 2 (dependent)
2. Task 3, Task 4 (parallel — independent of cleanup)
3. Task 5, Task 6 (parallel — can run anytime)

## Success Criteria
- [ ] All 6 subtasks completed on task server
- [ ] No functional changes — only cleanup, consolidation, and documentation
- [ ] Steering files created for future AI agents
- [ ] PATH management consolidated to single source of truth
