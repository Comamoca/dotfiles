# Agent skills

`programs.agent-skills` (`home.nix:958`, the `agent-skills-nix` home-manager
module) distributes agent skills from `./skills/local` plus `skills/remote.nix`
into **four** destination trees: `~/.agents/skills` (this repo's own agents read
that one), `~/.claude/skills`, `~/.jcode/skills`, `~/.omp/agent/skills`.

This surface behaves differently from everything else in this repo, and that
difference is the whole point of verifying it:

- it is **not** a `home.file` entry — `hmcheck files | grep agents/skills`
  returns **0** hits;
- it is installed by an **activation step** — the generation's `activate`
  script has an `_iNote "Activating %s" "agent-skills"` block that runs
  `/nix/store/<hash>-skills-install/bin/skills-install`;
- that script rsyncs a prebuilt bundle (`…-agent-skills-bundle`) with
  `--delete`, so entries present in the destination but absent from the bundle
  are removed, and `excludePatterns = [ "/.system" "/synced" ]` is the only
  protection;
- the result is a **symlink tree** of per-skill store paths
  (`~/.agents/skills/architect -> /nix/store/…-agent-skills-source-<hash>-safe/architect`),
  tracked by `~/.agents/skills/.agent-skills-managed.json`.

## Sub-features

- `home.nix` declares the sources and the two exclude patterns
  (`skills/local`, `skills/remote.nix`, `/.system`, `/synced`).
- The generation carries an `agent-skills` activation step pointing at a
  `skills-install` script, which references a `skills-install-config.json`, which
  names the bundle and the four destinations.
- The bundle has 63 entries and the live `~/.agents/skills` has exactly those 63
  plus the excluded `/synced` — nothing missing, nothing extra.
- The live managed marker's bundle equals the bundle the generation would
  install, so the checkout and the live tree agree.
- Every destination exists with the same 63 entries.
- A skill sourced from this repo resolves to the repo's bytes
  (`cmp skills/local/grill-me/SKILL.md ~/.agents/skills/grill-me/SKILL.md`).

## How to get to it (user POV)

The user edits `skills/local/<name>/SKILL.md` or adds a `fetchurl` to
`skills/remote.nix`, then runs `home-manager switch --flake .#Home` (there is no
`--impure`-less shortcut here) and checks that the new skill shows up in the
agent's skill catalog. The catalog is what an agent sees as
`~/.agents/skills/<name>/SKILL.md` — for this very skill, the copy an agent reads
is `verify-dotfiles` in that tree.

There is no user-facing command other than the switch; that is why this feature
is largely verified from generation content rather than by driving a process.

## Driving it with hmcheck + bundle inspection

Step 1 — it is not `home.file` (assert the surprising fact, don't assume it):

```bash
.agents/skills/verify-dotfiles/scripts/hmcheck files --json \
  | jq '[.[] | select(.path|test("agents/skills"))] | length'      # -> 0
```

Step 2 — the generation carries the activation step and its config:

```bash
L=.agents/skills/verify-dotfiles/proof/result-homeConfigurations.Home.activationPackage
grep -n -A2 'Activating %s" "agent-skills' "$L/activate"
S=$(grep -o '/nix/store/[a-z0-9]*-skills-install/bin/skills-install' "$L/activate")
head -12 "$S"
```

The last line of `head` names the config JSON; read it:

```bash
C=/nix/store/<hash>-skills-install-config.json
jq '.bundle, [.targets[] | {name, dest}]' "$C"
jq -r '.excludePatterns[]' "$C"        # -> /.system, /synced
```

Step 3 — the live tree is that bundle:

```bash
jq -r .bundle ~/.agents/skills/.agent-skills-managed.json    # equals $C's .bundle
ls "$(jq -r .bundle ~/.agents/skills/.agent-skills-managed.json)" | wc -l   # 63
ls ~/.agents/skills | wc -l                                                # 64
comm -23 <(ls ~/.agents/skills | sort) <(ls "$(jq -r .bundle ~/.agents/skills/.agent-skills-managed.json)" | sort)
```

`comm` prints exactly one line, `synced` — the only live entry the bundle does
not provide, and it is covered by `excludePatterns`, so `rsync --delete` leaves
it alone.

Step 4 — all four destinations:

```bash
for d in ~/.agents/skills ~/.claude/skills ~/.jcode/skills ~/.omp/agent/skills; do
  printf '%-24s %s\n' "$d" "$(ls "$d" 2>/dev/null | wc -l)"; done
```

PASS: `63` for each of the four.

Step 5 — repo-sourced skill identity:

```bash
cmp skills/local/grill-me/SKILL.md ~/.agents/skills/grill-me/SKILL.md && echo identical
```

Evidence files: `25-agent-skills.txt`, `26-agent-skills-bundle.txt`,
`27-agent-skills-activate.txt`, `28-agent-skills-dest-targets.txt`,
`30-local-skill-source.txt` in `../evidence/20261027T212035-sync-proof/`.

## Gotchas

- **The bundle path is not in `home-files`, so `hmcheck fresh` does not cover
  it.** Everything above reads the bundle from a live
  `.agent-skills-managed.json` and the config from the *built* generation; they
  matched in this session, but a checkout whose `skills/` changed after the last
  switch will show the old bundle live. Compare the two bundle paths explicitly
  and report "generation would install X, live has Y" instead of a bare pass.
- **`rsync --delete` makes this the most destructive surface in the repo.** A
  decoy file or a deleted entry in `~/.agents/skills` is reverted (or, if it lives
  outside the bundle and outside the two exclude patterns, *deleted*) by the next
  activation. Never put a drive's scratch files there. `.agents/skills/` **in the
  repo** is a different thing and is safe — but note it is not a *source* either.
- **`skills/local` is not symlinked into place.** `~/.agents/skills/<skill>` is a
  symlink into `…-agent-skills-source-<hash>-safe/…`, a **store copy**, so editing
  `skills/local/grill-me/SKILL.md` does *not* change `~/.agents/skills/grill-me`
  until a switch + re-activation. Unlike `config/niri`, there is no out-of-store
  shortcut here; do not expect one.
- **`~/.agents/skills` shows `drwxr-xr-x … Jan 1 1970`** and per-skill links with
  the same epoch mtime — that is how the rsync'd symlink tree reproduces mtimes.
  Not a corruption.
- **`.agent-skills-managed.json` says `"schemaVersion": 1` while the generation's
  `skills-install-config.json` says `2`.** They are different documents
  (marker vs installer config); do not compare them wholesale, only `.bundle`.
- **`.agents/skills/verify-dotfiles/` (this skill) is not part of the bundle.**
  It exists only in the working tree, so `~/.agents/skills/verify-dotfiles` will
  not exist until it is either added to `skills/local` or committed and picked up
  by whatever remote source the user chooses. Report that plainly rather than
  claiming the skill is "installed".
- **Directory mode is `0700` on this skill's dirs** (`drwx------` on `evidence/`,
  `proof/`, `scripts/`). Any tool that walks `~/.agents/skills` as another user —
  or `rsync` running as a different uid — will read less than you expect.
