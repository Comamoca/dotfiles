# systemd user units

A large part of this configuration is not files at all: `home.nix` defines the
systemd **user** units that make the desktop work — the `emacs@` template plus
`emacs@canary` / `emacs@coding`, `dsh-web`, `opencode-server`,
`cloudflared-{dsh,omniroute,opencode}`, `omniroute` and its two timers,
`rclone-sync{,.timer}`, `niri-scratchpad-daemon`, `spotifyd`, `sops-nix`,
`wl-clip-persist`, `cloudflare-os`, `forgejo`, `hister`, `maestro`, `omnigent`
and a few more. They land in `home-files/.config/systemd/user/` and are linked
into `~/.config/systemd/user/`.

Verification has two separate halves, and conflating them is the usual mistake:
**what the generation would install** (`hmcheck units`, pure generation
content) and **what the running system actually has** (`systemctl --user`).

## Sub-features

- The generation produces the unit file you changed, with the `ExecStart` you
  expect (`hmcheck units --json`, then read the file).
- The unit is *installed* in `~/.config/systemd/user/` and enabled
  (`systemctl --user is-enabled`).
- The unit is the **same file** systemd would load (`systemctl --user show -p
  FragmentPath`), so there is no shadow copy winning over the generation.
- Template units expand correctly (`emacs@.service` with `%I` →
  `emacs@coding.service`, `emacs@canary.service`).
- A unit is actually running when it is supposed to be (`is-active`).
- Timers are armed (`rclone-sync.timer`, `omniroute-combos.timer`).

## How to get to it (user POV)

The user's entry points are `systemctl --user status emacs@coding`,
`systemctl --user restart opencode-server`, `journalctl --user -u dsh-web`. The
desktop exposes them indirectly too: the `emacs` launcher, the opencode server
that the editor talks to on `127.0.0.1:4096`, the DSH web UI (this session's GUI)
on `127.0.0.1:14198` behind `dsh.comamoca.dev`.

The user cares about one unit at a time: "if I restart `emacs@coding`, does it
come back with the new `ExecStart`?" — which is exactly the
generation-vs-installed-vs-running triple below.

## Driving it with hmcheck + systemctl --user

Step 1 — what the generation installs (no live access):

```bash
.agents/skills/verify-dotfiles/scripts/hmcheck units --json | jq -r '.[].unit' | grep emacs
.agents/skills/verify-dotfiles/scripts/hmcheck units --json | jq length        # 24
L=.agents/skills/verify-dotfiles/proof/result-homeConfigurations.Home.activationPackage
grep -n 'ExecStart' "$L/home-files/.config/systemd/user/emacs@.service"
```

PASS: `emacs@.service`, `emacs@coding.service`, `emacs@canary.service` are
listed and the template line is
`ExecStart=/nix/store/<hash>-emacs-daemon %I`.

Step 2 — installed and enabled:

```bash
systemctl --user list-unit-files 'emacs@*' --no-legend
systemctl --user is-enabled rclone-sync.timer rclone-sync.service
```

Step 3 — the file systemd would actually load:

```bash
systemctl --user show -p FragmentPath --value emacs@coding.service
# -> /home/coma/.config/systemd/user/emacs@coding.service
```

PASS: the path goes through `~/.config/systemd/user/`, i.e. home-manager's link,
not a hand-written unit in `~/.config/systemd/user/` that shadowed it.

Step 4 — running:

```bash
systemctl --user is-active emacs@coding.service emacs@canary.service dsh-web.service
systemctl --user list-units --type=service --state=running --no-legend \
  | awk '{print $1}' | grep -E '^(emacs@|dsh-web|opencode-server|omniroute|cloudflared-)'
```

Observed after a healthy boot: `cloudflared-dsh`, `cloudflared-omniroute`,
`cloudflared-opencode`, `dsh-web`, `emacs@canary`, `emacs@coding`, `emacs@main`,
`omniroute`, `opencode-server` all running.

Evidence files: `07-built-units.txt`, `08-installed-units.txt`,
`09-running-units.txt`, `19-rclone-sync-state.txt` in
`../evidence/20261027T212035-sync-proof/`.

## Gotchas

- **`list-units` and `list-unit-files` disagree, and neither is wrong.**
  `systemctl --user list-units` only shows units systemd has *loaded*; units it
  knows about but was never asked to start appear as `list-unit-files … enabled
  ignored`. Filtering `list-units` output therefore under-reports. Compare
  `hmcheck units` against `list-unit-files`, and use `is-enabled`/`is-active` for
  the verdict on a specific unit.
- **`is-enabled` prints `enabled` and `is-active` prints `inactive` for the same
  unit, both with exit code 0 in a pipeline.** Read the word, not the exit code,
  or a dead timer looks alive. `rclone-sync.service` is `enabled` and
  `inactive` while `rclone-sync.timer` is `active` — that pair is *correct*
  (oneshot behind a timer), not a failure.
- **`emacs@.service` is not addressable.** `systemctl --user show -p FragmentPath
  emacs@.service` fails with "neither a valid invocation ID nor unit name".
  Always ask about an *instance* (`emacs@coding.service`) or read the template
  file from the generation.
- **Dangling leftovers exist and look like units.** `~/.config/systemd/user/`
  contains links into store paths from older generations that no longer exist —
  `rclone-sync-watcher.service`, `r2-mount.service`, `litellm.service`,
  `default.target.wants/rclone-sync.service`, `~/.config/kanshi`. `ls` shows them
  as entries; `systemctl --user status` says "Unit … could not be found" and
  `list-unit-files` labels them `bad`. They are pre-existing orphan links, not
  something this skill created — do not "clean them up" during a verification run
  and do not report them as a failure of the change under test. Mention them if
  the change under test *touches* those units. Evidence: `20-orphan-links.txt`.
- **`rclone-sync.service` also appears in `default.target.wants` pointing at a
  *third* store path.** Wanted-links are per-generation; a stale one is normal
  and does not affect `is-active`.
- **A unit that is `enabled` in the generation is not restarted by a build.**
  This skill never restarts units; if the change under test is a unit file, a
  running unit keeps the old `ExecStart` until the user restarts it. Report that
  split explicitly rather than marking the feature failed.
- **`cloudflare-os`, `forgejo`, `maestro`, `hister`, `omnigent` are declared but
  not running**, and they are deliberately filtered out of the "installed" list
  by name patterns in the drives above. If you write your own
  `comm`-style diff, expect "built but not installed" for exactly this set and
  check each one with `is-enabled` before believing it.
