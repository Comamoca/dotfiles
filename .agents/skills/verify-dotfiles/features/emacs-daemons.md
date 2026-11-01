# Emacs daemons

Emacs is the one long-running interactive process this configuration defines. It
runs as a **systemd user template unit**, `emacs@<name>.service`
(`home.nix:1210`), with instances `emacs@coding` (`:1245`) and `emacs@canary`
(`:1266`) declared, and `emacs@main` started by hand. Every instance execs the
same wrapper, `emacs-daemon` (`home.nix:163`, a `pkgs.writeShellScript`), which
takes the instance name as `$1` and does:

```bash
NAME="${1:-main}"
INIT_DIR="/tmp/emacsd-${NAME}"
exec .../emacs --fg-daemon="${NAME}" --init-directory=... --eval "(load ...init-loader.el)"
```

so the unit name *is* the server name, the socket is
`/run/user/$(id -u)/emacs/<name>`, and `emacsclient -s <name>` selects it.

`AGENTS.md` and the `emacsclient-driven-elisp` skill add a policy on top: agents
evaluate elisp **only** against the `coding` daemon, never `main`.

## Sub-features

- The template unit in the generation expands `%I` into the instance name
  (`ExecStart=/nix/store/<hash>-emacs-daemon %I`).
- `emacs@coding.service` is installed via the generation and enabled, and
  `FragmentPath` points through `~/.config/systemd/user/`.
- The running instance uses the wrapper *from the generation*
  (`…-emacs-daemon`, the same hash the template names).
- The socket exists and the daemon answers (`/run/user/1000/emacs/coding`,
  `emacsclient -s coding -e emacs-version`).
- The daemon's init directory is the per-instance `/tmp/emacsd-<name>`, so
  instances cannot clash.
- `main` and `canary` are alive but are not for agent use — the policy is part of
  the observable surface only as "do not touch", not as a check.

## How to get to it (user POV)

The user runs `emacs` (which talks to the `main` daemon via `emacsclient`), or
`systemctl --user restart emacs@coding` after changing `emacs.nix` /
`emacs.d/`. A coding agent's entry point is `emacsclient -s coding -e '...'`.
Symptoms the user reports map straight onto sub-features above: "editing doesn't
stick" → wrong daemon; "`emacsclient` hangs" → socket missing or daemon dead;
"changes need a restart" → the wrapper still points at the old generation.

## Driving it with emacsclient + systemctl --user

Step 1 — generation content:

```bash
L=.agents/skills/verify-dotfiles/proof/result-homeConfigurations.Home.activationPackage
grep -n 'ExecStart' "$L/home-files/.config/systemd/user/emacs@.service"
# ExecStart=/nix/store/sinf9bl7k7f7zhzyh6db04khidd8r72z-emacs-daemon %I
grep -n 'NAME=\|INIT_DIR=\|exec ' /nix/store/sinf9bl7k7f7zhzyh6db04khidd8r72z-emacs-daemon
# NAME="${1:-main}"  /  INIT_DIR="/tmp/emacsd-${NAME}"  /  exec .../emacs --fg-daemon="${NAME}"
```

Step 2 — installed, which file systemd loads, and running:

```bash
systemctl --user show -p FragmentPath --value emacs@coding.service
# -> /home/coma/.config/systemd/user/emacs@coding.service
grep -n ExecStart /home/coma/.config/systemd/user/emacs@coding.service
systemctl --user is-active emacs@coding.service
systemctl --user list-units 'emacs@*' --no-legend | awk '{print $1}'
```

Step 3 — the live daemon answers, through the `coding` socket only:

```bash
timeout 20 emacsclient -s coding -e 'emacs-version'      # -> "32.0.50"
timeout 20 emacsclient -s coding -e '(length (frame-list))'   # -> 1
ls -la /run/user/$(id -u)/emacs/                          # canary, coding, main sockets
```

PASS: the version string comes back, and the socket named `coding` exists with
mode `srwx------`.

Evidence files: `24-emacs-daemon.txt` in
`../evidence/20261027T212035-sync-proof/`.

## Gotchas

- **`emacsclient -s coding -e '(server-name)'` fails** with "Symbol's function
  definition is void: server-name" — `server-name` is a *variable*, not a
  function. Use `(symbol-value 'server-name)` or just ask for
  `emacs-version` / `(length (frame-list))`.
- **The wrapper script path in the unit is the generation's**, so after a
  `home.nix` change that alters `emacs-daemon-script`, the *installed* unit still
  names the old hash until a switch. Comparing
  `grep ExecStart ~/.config/systemd/user/emacs@coding.service` with the
  generation's template is how you show that split honestly.
- **`emacs@main` exists in `list-units`.** Reading it, restarting it or
  evaluating against it is out of bounds for an agent (`AGENTS.md`); a drive that
  needs `main` is a SKIP, not a workaround.
- **`emacs@canary` is not `emacs@canary.service`'s only name.** The catalog may
  also list `emacs@graphical-session` in older docs (the `emacsclient-driven-elisp`
  skill documents it); on this machine `list-units 'emacs@*'` shows exactly
  `emacs@canary`, `emacs@coding`, `emacs@main`. Trust the live list over the doc.
- **Starting a standalone `emacs` for evaluation is forbidden** and also useless
  here: it would not use `/tmp/emacsd-<name>` and would not be observable through
  the unit. Do not do it as a "quick check".
- **The wrapper's `INIT_DIR` is only expandable at runtime.** `grep 'INIT_DIR'`
  on the wrapper shows `/tmp/emacsd-${NAME}` literally. To see the expansion,
  read the running process:

  ```bash
  tr '\0' '\n' < /proc/$(systemctl --user show -p MainPID --value emacs@coding.service)/cmdline
  # --fg-daemon=coding
  # --init-directory=/tmp/emacsd-coding
  # --eval
  # (load "/home/coma/.emacs.d/init-loader.el")
  ```
- **A dead `coding` daemon is not a failure of the configuration.** It is a
  runtime state; check `systemctl --user status emacs@coding` and report it
  before blaming the change under test. Do not fall back to `main`.
