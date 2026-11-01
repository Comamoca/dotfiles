# Features of the dotfiles configuration

This directory maps the surfaces of this repository that are worth verifying,
one file per surface. Every file follows the same contract so that a run is
reproducible: the four H2 sections appear in the same order and mean the same
thing.

## Baseline preconditions

Anything in this directory assumes `hmcheck doctor` printed `DOCTOR: OK` in the
current session. Concretely:

- `XDG_CACHE_HOME` is writable (`/tmp/nixcache`); `~/.cache/nix` is read-only on
  this host and any nix command without the override fails.
- `nix`, `jq`, `fish`, `emacsclient` and `systemctl --user` exist. `python3` does
  not — do not reach for it.
- `.agents/skills/verify-dotfiles/proof/result-homeConfigurations.Home.activationPackage`
  exists, i.e. `hmcheck build` has run at least once this session.
- The user session is up (`systemctl --user is-active emacs@coding.service`
  returns `active`), because several drives read the live session.

If `hmcheck doctor` fails, there is nothing to verify: report the failing block
instead of a result.

## Driving conventions

- **Drive the generation, not your editor buffer.** A change is verified when it
  shows up in the built generation (`hmcheck files`, `hmcheck units`,
  `hmcheck resolve`) or in the process that consumes it, never when it merely
  appears in the file you edited.
- **Freshness first.** `hmcheck fresh` decides where a drive may read from.
  `FRESH` → `~/` is trustworthy. `STALE` → everything under `~/` shows the *old*
  configuration; drive `proof/.../home-files/...` via `hmcheck resolve` and
  record the divergence. Reading a new behaviour out of `~/` on a `STALE`
  checkout is the single easiest way to produce a false pass.
- **Cheapest observable wins, in this order:** `nix eval` → generation contents
  → read-only runtime query → runtime by construction (edit behind an
  out-of-store symlink, observe, restore) → full build. Say which rung you used.
- **No activation.** `home-manager switch` and `nixos-rebuild switch` are out of
  scope. They mutate the user's desktop; a check that needs them is reported as
  NOT VERIFIED with the reason.
- **Serialise nix.** Only one nix command at a time in the session; a second one
  waits on the store lock and looks like a hang. Wrap anything slow in
  `timeout 300`.
- **Restore in the same step.** Any drive that writes goes with its restore and
  its `cmp` immediately, before the next command.

## Proof and skip reporting

Every run leaves a directory `evidence/<UTC-ish timestamp>-<feature>/` with
numbered, self-describing files: `01-…json`, `02-…-before.txt`,
`03-…-after.txt`, `04-…-restored.txt`. Report per sub-feature as one of:

- **PASS** — quote the command and the line of output that decided it, and name
  the evidence file.
- **FAIL** — quote the command, the expected line and the actual line. Do not
  re-run hoping for a different answer.
- **SKIP** — say what would have been needed (a switch, a restart, network, a
  secret, a GUI) and why that was not done. A skip is a legitimate result; a
  weakened journey is not.

Never weaken a journey to make it pass. If a sub-feature here turns out to be
unobservable in the current session, the honest answer is SKIP plus the reason —
and if that means this file is wrong, fix this file in a separate change, not
inside the verification run.

## Feature entry contract

Each file is named after the surface (`home-and-flake.md`,
`out-of-store-symlinks.md`, …) and contains exactly these four H2s, in order:

| H2                                | Contains                                                                                        |
| --------------------------------- | ----------------------------------------------------------------------------------------------- |
| `Sub-features`                    | The individually observable behaviours on this surface, as short bullets                         |
| `How to get to it (user POV)`     | What the user does or sees: which key, which file, which unit, which command they would run      |
| `Driving it with <harness>`       | The exact commands to run, in order, with the output line that decides PASS, and the evidence file |
| `Gotchas`                         | Traps found the hard way: false failures, host-specific quirks, things that look like a pass     |

`<harness>` names what actually does the driving — `hmcheck`, `systemctl
--user`, `emacsclient`, `fish`, `nix eval`.

## Index

| File                                                   | Drives through                   | One-line check                                             |
| ------------------------------------------------------ | -------------------------------- | ---------------------------------------------------------- |
| [home-and-flake.md](home-and-flake.md)                 | `nix eval`, `hmcheck`            | the flake evaluates and the activation package builds      |
| [out-of-store-symlinks.md](out-of-store-symlinks.md)   | `readlink`, `fish`               | editing `config/…` reaches `~/…` without a switch          |
| [systemd-user-units.md](systemd-user-units.md)         | `hmcheck units`, `systemctl --user` | the unit you changed is installed and the one that runs    |
| [agent-skills.md](agent-skills.md)                     | `hmcheck`, bundle inspection     | `~/.agents/skills` is the bundle the generation installs   |
| [emacs-daemons.md](emacs-daemons.md)                   | `emacsclient`, `systemctl --user` | the `coding` daemon runs the wrapper from the generation   |

Verified end to end in one session on 2026-10-27 (HEAD `af379bc-dirty`, live
generation `sxx4pl2v…`, built generation identical). The full transcript is in
`../evidence/20261027T212035-sync-proof/`.
