# Out-of-store symlinks

This is the surface that makes most dotfile edits verifiable at all. `home.nix`
declares `symlink = config.lib.file.mkOutOfStoreSymlink` (`home.nix:455`) and
then maps `./config/...` into `$HOME` with `source = (symlink /${dotfiles}/...)`.
The result is a **symlink chain that ends back inside this checkout**:

```
~/.config/niri                              (home-manager's link, 2026-10-27 21:01)
  -> /nix/store/<hash>-home-manager-files/.config/niri
  -> /home/coma/.ghq/github.com/Comamoca/dotfiles/config/niri
  -> ~/.config/niri/config.kdl  ==  config/niri/config.kdl  (byte-identical)
```

So editing `config/niri/config.kdl` changes what the running desktop reads,
**without any switch**, and — the part that matters for verification — the
checkout's `home.nix` and the live `$HOME` are provably the same configuration.

## Sub-features

- A directory mapped as out-of-store resolves to the repo path
  (`~/.config/niri` → `…/dotfiles/config/niri`).
- A file inside one of those directories is byte-identical to the repo file
  (`cmp ~/.config/niri/config.kdl config/niri/config.kdl`).
- A file *newly created* in the repo directory becomes visible through the live
  `~/` path immediately (no switch, no restart).
- A plain `home.file` entry without `symlink` stays a store symlink
  (`~/.omo/omo.jsonc` → `/nix/store/…-hm_omo.jsonc`) and does **not** track the
  repo — the distinction between the two kinds is the thing to assert.
- Restoring the file restores the live view, with no residue in `git status`.

## How to get to it (user POV)

The user's daily loop is: edit `config/niri/config.kdl`, `niri msg action
reload-config` (or just reload the window manager), see the change. Same for
`config/fish/functions/*.fish` (a new shell picks it up), `config/kitty`,
`config/wezterm`, `config/omo/omo.jsonc`. They never run a switch for these —
`AGENTS.md` says so explicitly for `omo.jsonc`.

Verifying this feature means reproducing that loop and confirming it is the
*generation's* symlink doing the work, not some stale copy.

## Driving it with readlink + fish

Step 1 — the wiring (read-only):

```bash
readlink -f ~/.config/niri
readlink -f ~/.config/niri/config.kdl
cmp -s ~/.config/niri/config.kdl config/niri/config.kdl && echo identical
```

PASS: the first line is `…/dotfiles/config/niri`, the second
`…/dotfiles/config/niri/config.kdl`, and `identical` is printed.

Step 2 — the change travels (write, observe, restore in one breath):

```bash
E=.agents/skills/verify-dotfiles/evidence/$(date +%Y%m%dT%H%M%S)-oos
mkdir -p "$E"
echo "decoy" > config/niri/verify-dotfiles-probe.md
ls ~/.config/niri/verify-dotfiles-probe.md            # must exist
rm -f config/niri/verify-dotfiles-probe.md
```

PASS: `ls` prints the path through `~/.config/niri` even though the file only
ever existed under `config/`. Evidence: `06-decoy-created.txt`.

Step 3 — a real consumer, not just a path:

```bash
cp config/fish/functions/dty.fish /tmp/dty.bak
sed -i 's|dt $argv|dt $argv # PROBE-<n>|' config/fish/functions/dty.fish
fish -c 'functions dty' | grep PROBE-<n>              # must match
fish -c 'functions dty --details' | tail -1           # -> ~/.config/fish/functions/dty.fish
cp /tmp/dty.bak config/fish/functions/dty.fish
cmp /tmp/dty.bak config/fish/functions/dty.fish && echo restored
```

PASS: `grep` prints the marked line, `--details` shows fish loaded it from
`/home/coma/.config/fish/functions/dty.fish` (the live path, not the repo path),
and the `cmp` after restore is silent. Evidence: `13-drive-edit.txt` →
`17-drive-fish-live3.txt`.

Step 4 — the store-symlink contrast:

```bash
.agents/skills/verify-dotfiles/scripts/hmcheck files --json \
  | jq -r '.[] | select(.path=="/.omo/omo.jsonc") | .target'   # /nix/store/...-hm_omo.jsonc
```

## Gotchas

- **Do not drive through `fish -c 'function …'` and expect *body* edits to show
  up in `functions <name>` output for every edit kind.** `functions` pretty-prints
  the parsed body, so a trailing comment appended after the final `end` is
  dropped from the printed definition — it looked like the edit had not
  propagated when it demonstrably had (the `via ~/` read showed it). Put the
  marker *inside* the body (on the last command line) and it prints; or assert
  with `functions --details` plus a plain `grep` of the resolved file. This cost
  three attempts to notice.
- **`readlink -f ~/.config/niri` is only a chain test if it ends in the repo.**
  If it stops at `/nix/store/…-home-manager-files/.config/niri`, the mapping is
  a copy, not an out-of-store symlink, and edits will need a switch — that is a
  FAIL for this feature, not a pass with a footnote.
- **`config/niri` already contains stray `*.bak` files** (`config.bak`,
  `config.kdl.bak-jcode-hotkeys-…`) that are untracked, so `git status -- config/`
  is never empty. Compare a *specific path* (`git status --porcelain --
  config/fish/functions/dty.fish`), not the directory, or you cannot tell your
  residue from the user's.
- **`dty.fish` itself is untracked** (`?? config/fish/functions/dty.fish` is its
  baseline, it was never committed). Seeing `??` for it after a drive is not
  residue; `cmp` against the pre-drive copy is the real assertion.
- **A restored file keeps its new mtime.** `touch -r` it back from the backup if
  the user's tooling cares; the content check (`cmp`) is what proves the
  restore.
- **Never touch `~/.agents/skills` here.** It is rsync-managed, not a `home.file`
  (see [agent-skills.md](agent-skills.md)); a decoy file dropped there survives
  until the next switch and pollutes four destination directories.
- **`ls` in a pipeline prints `ls: write error: Broken pipe`** when `head` exits
  early. Harmless, but it makes a clean run look broken.
