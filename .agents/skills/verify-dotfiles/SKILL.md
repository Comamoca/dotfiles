---
name: verify-dotfiles
description: Use when verifying that a change to this NixOS/home-manager dotfiles repository actually reaches the running machine - checks the flake evaluates, builds the home-manager activation package, and drives the result through home-files, out-of-store symlinks, systemd user units, or a script's real behaviour.
---

# Verifying the dotfiles configuration

This repo has no web app and no dev server. "The app" is the configured
environment itself: `home.nix` (plus `configuration.nix`, `emacs.nix`,
`fish.nix`, `omniroute.nix`, `packages/*.nix`, `config/*`) is turned by
home-manager into a **generation** in the Nix store, and that generation is what
`~/.config/*`, `~/.bin/scripts/*`, `~/.agents/skills/*` and the systemd user
units are at runtime. So verifying a change means proving three links, in order:

1. the flake still evaluates and the activation package still builds,
2. the file / unit / option you changed is present in the generation's
   `home-files` tree with the target you expect,
3. the thing that consumes it (`~/.config/...` after the out-of-store symlink
   resolves, `systemctl --user`, `fish -c ...`, `emacsclient`) actually shows
   the new behaviour.

Never skip link 3 by pointing at your own source file: the point of the check is
that the *generation* carries the change, not that the file you edited
contains the text you typed.

Most of this skill is **read-only**. A full `home-manager switch` mutates the
user's live desktop (restarts units, rewrites `~/.config`) and is usually
unnecessary: the repo is wired with out-of-store symlinks, and the built
generation can be inspected directly under `proof/`.

## Launch

Launch = obtain a built home-manager generation for this checkout, with an
out-link inside the skill so nothing outside it changes.

```bash
export XDG_CACHE_HOME=/tmp/nixcache   # ~/.cache/nix is read-only on this host
cd /home/coma/.ghq/github.com/Comamoca/dotfiles
.agents/skills/verify-dotfiles/scripts/hmcheck build
```

Expected output (second line is the store path; the first is the out-link):

```
building .#homeConfigurations.Home.activationPackage -> .../verify-dotfiles/proof/result-homeConfigurations.Home.activationPackage
/nix/store/<hash>-home-manager-generation
```

The build is normally a no-op because the same generation is already live; the
observed cold-ish cost was ~12 s and the warm re-run ~2 s. Ready check — the
generation exposes the three things every drive needs:

```bash
L=.agents/skills/verify-dotfiles/proof/result-homeConfigurations.Home.activationPackage
test -x "$L/activate" && readlink -f "$L/home-files" && readlink -f "$L/home-files/.config/niri"
```

A `warning: Git tree ... is dirty` line on stderr is normal here — this checkout
is routinely dirty. It is not an error; see Gotchas.

`nix flake metadata`, `nix eval`, `nix build` and anything that only *reads*
can be run at will. `home-manager switch` / `nixos-rebuild switch` are the only
mutating commands, and this skill never runs them.

## Doctor

One command answers "can this checkout be verified at all, and is what I am
about to inspect the thing the user is running?":

```bash
.agents/skills/verify-dotfiles/scripts/hmcheck doctor
```

It is read-only and prints five blocks. The lines that decide whether you may
trust a drive:

```
== configuration attrs (evaluation only, no build)
activation:    /nix/store/...-home-manager-generation.drv
username:      coma
homeDirectory: /home/coma
stateVersion:  24.05

== live state
profile link:  <hash>-home-manager-generation
gcroots:       <hash>-home-manager-generation
emacs@coding:  active

== proof results vs live
  live home-files:  <hash>-home-manager-files
  built home-files: <hash>-home-manager-files
MATCH: ...
```

Then the one-line form:

```bash
.agents/skills/verify-dotfiles/scripts/hmcheck fresh   # exit 1 when the built generation is stale
```

Read `fresh` before every drive. `FRESH` means `proof/`'s `home-files` **is**
the store path the live `$HOME` resolves through, so anything observable under
`~/` is evidence about this checkout's `home.nix`. `STALE` means the checkout
changed since the last activation: files under `~/` still show the *old*
configuration, so drives must go through `hmcheck resolve REL`
(`proof/.../home-files/REL`) and you must record the divergence — do not read
the new behaviour out of `~/` and call it a pass.

`hashT` caveat: `hmcheck fresh` compares `home-files`, not the whole
generation. Activation-side changes (systemd unit content, environment
variables, `home.path`) can leave `home-files` identical while the live system
is still old. For those, also check `hmcheck units` and
`systemctl --user show -p FragmentPath` (see the systemd-services feature).

`hmcheck doctor` exits non-zero if `XDG_CACHE_HOME` is not under `/tmp`, if
`nix`/`jq` are missing, if there is no `flake.nix`, or if
`homeConfigurations.Home` fails to evaluate — those are the only reasons to stop
and report a blocker instead of a verification result.

## Drive

Drives are ordered from cheapest to most invasive. Pick the cheapest one that
actually observes the change, and say in the report which one you used.

**1. Evaluation only** — the change exists as a Nix value:

```bash
XDG_CACHE_HOME=/tmp/nixcache nix eval --raw .#homeConfigurations.Home.config.home.username
XDG_CACHE_HOME=/tmp/nixcache nix eval --json .#homeConfigurations.Home.config.home.file --apply builtins.attrNames
```

**2. Generation content** — the built generation carries the file/unit/attr:

```bash
.agents/skills/verify-dotfiles/scripts/hmcheck files            # every link in home-files
.agents/skills/verify-dotfiles/scripts/hmcheck files --json | jq '.[] | select(.path | test("fish/functions"))'
.agents/skills/verify-dotfiles/scripts/hmcheck units --json     # systemd user units it would install
.agents/skills/verify-dotfiles/scripts/hmcheck resolve .config/niri/config.kdl
```

**3. Runtime, read-only** — the consumer already running in the live session
shows the change (safe because it starts nothing and edits nothing):

```bash
readlink -f ~/.config/niri/config.kdl                    # out-of-store symlink -> repo file
cmp -s ~/.config/niri/config.kdl config/niri/config.kdl && echo identical
fish -c 'functions dty'                                  # ~/.config/fish/functions/*.fish, real load
emacsclient -s coding -e '(symbol-value (quote emacs-version))'
systemctl --user is-active emacs@coding.service dsh-web.service
```

**4. Runtime by construction** — edit a repo file behind an out-of-store
symlink, observe it through the *live* `~/` path, then restore. This proves the
whole wiring without a switch:

```bash
cp config/fish/functions/dty.fish /tmp/dty.bak
sed -i 's|dt $argv|dt $argv # PROBE|' config/fish/functions/dty.fish
fish -c 'functions dty' | grep PROBE          # must match
cp /tmp/dty.bak config/fish/functions/dty.fish && diff /tmp/dty.bak config/fish/functions/dty.fish
```

Restore in the same command or the very next one, and prove the restore with
`cmp`/`diff` — a drive that leaves the user's fish prompt or `~/.config` edited
is a failed verification, not a slow one.

**5. Full build of a heavier attribute** — only when the change is in the build
itself (a package, an Emacs build, a derivation):

```bash
.agents/skills/verify-dotfiles/scripts/hmcheck build .#packages.x86_64-linux.treefmt-toml
```

Never `home-manager switch` as part of verification. If a journey genuinely
cannot be observed without activating (see the feature files), report it as
NOT VERIFIED with the reason — do not activate, and do not water the journey
down to something that passes.

Each drive surface has a feature file under [`features/`](features/README.md)
with the full journey, the deciding output line and its own gotchas. Read the
one that matches the change before driving by hand; the index also states the
baseline preconditions and the pass/skip reporting contract.

| Feature               | Feature file                                               | Drive through                                        |
| --------------------- | ---------------------------------------------------------- | ---------------------------------------------------- |
| Home and flake        | [home-and-flake.md](features/home-and-flake.md)             | `nix eval`, `hmcheck doctor/build/fresh`              |
| Out-of-store symlinks | [out-of-store-symlinks.md](features/out-of-store-symlinks.md) | `readlink -f ~/...`, `fish -c`, `cmp` vs `config/`   |
| systemd user units    | [systemd-user-units.md](features/systemd-user-units.md)     | `hmcheck units`, `systemctl --user is-active/enabled` |
| Agent skills          | [agent-skills.md](features/agent-skills.md)                 | activation step + bundle, `~/.agents/skills`          |
| Emacs daemons         | [emacs-daemons.md](features/emacs-daemons.md)               | `emacsclient -s coding -e ...`, `systemctl --user`    |

Note the odd one out: `~/.agents/skills` is **not** a `home.file` entry
(`hmcheck files` has 0 hits for it). It is an activation step that rsyncs a
bundle with `--delete` into four destinations, so `hmcheck resolve` cannot see
it and `hmcheck fresh` does not cover it — see the feature file for what to
check instead.

## Evidence

Every drive writes artifacts under `.agents/skills/verify-dotfiles/` — never
`/tmp` (it is not evidence) and never the repo root. Two directories, by
lifetime:

```
.agents/skills/verify-dotfiles/proof/
└── result-homeConfigurations.Home.activationPackage   # gc root, disposable
.agents/skills/verify-dotfiles/evidence/
└── 20261027T212035-sync-proof/                        # permanent record
    ├── 01-home-file-attrnames.json
    ├── 02-built-niri-target.txt
    └── ...
```

Create one evidence directory per session, numbered files in the order you ran
them, with a self-describing suffix (`-before`, `-after`, `-restored`,
`-cleanup`). Capture the commands' *output*, not a summary — the point is that
someone can re-read the run and see exactly what was printed.

```bash
E=.agents/skills/verify-dotfiles/evidence/$(date +%Y%m%dT%H%M%S)-<feature>
mkdir -p "$E"
.agents/skills/verify-dotfiles/scripts/hmcheck doctor > "$E/00-doctor.txt" 2>&1
```

Evidence must survive cleanup. After `hmcheck cleanup` the `proof/result-*`
symlink is gone and the store path may be collected, but `evidence/` and the
files inside it must still be readable — re-read one to confirm, and say so.

## Cleanup

```bash
.agents/skills/verify-dotfiles/scripts/hmcheck cleanup
```

This removes only the `proof/result-*` gc roots this skill created. It does not
touch `evidence/`, the store contents, `~/.cache/../nix` roots, the repo's own
`./result` symlink, or any live unit. After cleanup, confirm that the evidence
still exists:

```bash
ls .agents/skills/verify-dotfiles/evidence/*/ | head
```

Also undo anything a drive touched:

- restored files: `cmp` the backup against the file, and check
  `git status --short --untracked-files=all -- <path>` for leftovers,
- probe files created inside `config/`: `git status` must not list them,
- processes: nothing in this skill starts a process it does not stop, so if one
  is left over you started it by hand — kill it before reporting.

`/tmp/nixcache` may be left in place; it is a cache, not evidence.

## Helpers

One helper, `scripts/hmcheck`, ~200 lines of bash, read-only except for
`proof/`:

| Command                      | What it does                                                             |
| ---------------------------- | ------------------------------------------------------------------------ |
| `hmcheck doctor`             | Checkout/flake/eval/live-state report; exits 1 on a real blocker          |
| `hmcheck build [ATTR]`       | `nix build ATTR --out-link proof/result-<slug>`, default activationPackage |
| `hmcheck files [--json]`     | Every file/symlink in the built generation's `home-files`                 |
| `hmcheck units [--json]`     | systemd user units/timers the generation would install                   |
| `hmcheck resolve REL`        | Store path the build puts at `~/REL`, without touching `~/`              |
| `hmcheck fresh`              | Is the built generation the one `~/` uses? (exit 1 when stale)           |
| `hmcheck live-vs-proof`      | `diff` of symlinks between built and live `home-files`                   |
| `hmcheck cleanup`            | Remove the `proof/result-*` gc roots                                     |

It derives the repo root with `git rev-parse --show-toplevel` and `pwd -P`, so
it does not matter whether you call it by path from inside or outside the repo.
`XDG_CACHE_HOME` is exported to `/tmp/nixcache` internally (override with
`HMCHECK_CACHE`).

Gotchas that cost real time while writing this skill:

- `hmcheck build --no-link` is wrong: the out-link is the whole point. Use the
  helper; do not hand-roll `nix build` without `--print-out-paths`.
- Never call `nix` through a shell function inside `$(...)`: `nix` cannot exec a
  function and `timeout 300 nixq ...` fails with `failed to run command 'nixq'`.
- `nix eval` warnings go to **stderr**; `2>&1 | tail` makes a successful eval
  look like output soup, and `--raw` output has no trailing newline.
- `readlink` on `~/.local/state/nix/profiles/home-manager` returns a *relative*
  name (`home-manager-460-link`); always use `readlink -f` before comparing.
- Only one process at a time should run nix: another agent's build holds the
  store lock and `nix build` will block instead of failing. Run nix serially.
