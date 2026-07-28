---
name: emacsclient-driven-elisp
description: Use when evaluating or applying Emacs Lisp changes in this dotfiles repository. Emacs runs as a daemon, so all elisp evaluation must go through emacsclient.
---

# Emacs Lisp Evaluation via emacsclient

## Context

This dotfiles setup runs multiple Emacs daemons as systemd units (`emacs@<name>.service`).
When modifying Emacs configuration (`init.el`, files under `emacs.d/lisp/`, etc.),
configuration changes must be applied through the running daemon.

## Architecture: Named Emacs Daemons

This dotfiles runs multiple independent Emacs daemons via systemd template
units (`emacs@<name>.service`). Each daemon is a fully isolated Emacs process
with its own socket, init directory, and lifecycle.

### Why Multiple Daemons?

- `main` — your daily driver. Manual editing, `M-x` everything.
- `graphical/session` — bound to the Wayland graphical session lifecycle.
  Started/stopped with the desktop session.
- `coding` — sandbox for AI coding agents (OpenCode, etc.) to evaluate
  elisp, reload configs, test snippets — without touching `main`.

Separating `coding` from `main` means agents can freely experiment without
corrupting buffers, breaking undo history, or crashing your primary session.

### How It Works

Each daemon starts via a shared wrapper script (`emacs-daemon <name>`):

```
emacs-daemon main       → --fg-daemon=main       → /run/user/1000/emacs/main       → /tmp/emacsd-main
emacs-daemon coding     → --fg-daemon=coding     → /run/user/1000/emacs/coding     → /tmp/emacsd-coding
emacs-daemon graphical/session → ...              → /run/user/1000/emacs/graphical/session → /tmp/emacsd-graphical/session
```

| Component | What it is |
|---|---|
| `--fg-daemon=<name>` | Server name. Determines `$HOME/.emacs.d/server/<name>` socket path (symlinked to the actual socket file in `/run/user/<uid>/emacs/`) |
| `--init-directory=/tmp/emacsd-<name>` | Separate user-emacs-dir per daemon. Prevents autosave / custom.el / elp-area conflicts between instances. |
| `--eval (load "...init-loader.el")` | All daemons share the same `~/.emacs.d/init.el` config tree. Init state is independent per process. |

The systemd template is defined in `home.nix`:

```nix
systemd.user.services."emacs@" = {
  Service = {
    ExecStart = "${emacs-daemon-script} %I";
  };
};
```

Instances are started via `systemctl --user start emacs@<name>` and
follow `graphical-session.target` lifecycle.

### Socket Layout

```
/run/user/1000/emacs/
├── coding              → coding daemon
├── graphical/
│   └── session         → graphical/session daemon
└── main                → main daemon
```

The `-s <name>` flag to `emacsclient` maps directly to these socket names.

## Daemon Targeting Policy (CRITICAL)

Currently running daemons:

| Systemd Unit | Socket Name | Purpose |
|---|---|---|
| `emacs@coding.service` | `coding` | **Coding agent use only** |
| `emacs@main.service` | `main` | User's primary session — **DO NOT TOUCH** |
| `emacs@graphical-session.service` | `graphical/session` | GUI session — **DO NOT TOUCH** |

- **Coding agents MUST target the `coding` daemon** using `emacsclient -s coding`.
- **Coding agents MUST NOT evaluate expressions against `main` or `graphical/session`**.
- If the `coding` daemon is not running, check with `systemctl --user status emacs@coding` — do not fall back to `main`.

### Checking Running Daemons

```bash
# List active Emacs daemons
systemctl --user list-units 'emacs@*'

# Check a specific daemon status
systemctl --user status emacs@coding

# List server sockets (alternative check)
ls /run/user/$(id -u)/emacs/
```

## Rule

When asked to evaluate, apply, or test Emacs Lisp changes:

- **Always use `emacsclient`** to evaluate or load elisp.
- **Always specify the target daemon** with `-s <socket-name>` (default is `coding`).
- Do **not** start a standalone `emacs` process for evaluation.
- Do **not** leave application of changes to the user; apply them via `emacsclient` and verify the result.

## Common Commands

```bash
# Reload init.el on the coding daemon
emacsclient -s coding -e '(load-file "~/.emacs.d/init.el")'

# Evaluate an arbitrary expression on the coding daemon
emacsclient -s coding -e '(progn (message "test") t)'

# Load a specific elisp file on the coding daemon
emacsclient -s coding -e '(load-file "~/.emacs.d/lisp/my-file.el")'

# Call a function on the coding daemon
emacsclient -s coding -e '(my-function)'
```

## Verification

After applying changes, verify the expected effect:

1. Check the return value of the `emacsclient` command (`t` indicates success).
2. Inspect variables with `emacsclient -s coding -e "(symbol-value '<variable>)"`.
3. Verify functions are defined with `emacsclient -s coding -e "(functionp '<function>)"`.
4. Check the `*Messages*` buffer with `emacsclient -s coding -e '(with-current-buffer "*Messages*" (buffer-string))'`.

## GUI vs TTY Frames

When modifying frame-related behavior (e.g., `server-after-make-frame-hook`, dashboard, scratch buffer):

- GUI frames: `(display-graphic-p)` is non-nil.
- TTY frames: `(display-graphic-p)` is nil.
- Test with the actual frame type the user is using.

## Nix Rebuilds

After changing `emacs.nix` or Nix-related Emacs package definitions, the daemon's package set must be rebuilt:

```bash
home-manager switch --flake .#Home --impure
```

Then restart the Emacs daemon or reload its configuration as needed.
