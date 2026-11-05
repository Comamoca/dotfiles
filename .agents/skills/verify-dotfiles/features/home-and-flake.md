# Home and flake

The flake is the front door: `home.nix`, `configuration.nix`, `emacs.nix`,
`fish.nix`, `omniroute.nix` and `packages/*.nix` are all reached through
`nix build .#homeConfigurations.Home.activationPackage`, and that same
derivation is what CI builds (`.github/workflows/ci.yaml`) and what a switch
would activate. Everything else in this skill assumes this feature passes:
if the flake does not evaluate, no other surface can be verified.

## Sub-features

- The flake has metadata and resolves its inputs (`nix flake metadata --json`).
- `homeConfigurations.Home` evaluates: `drvPath`, `config.home.username`,
  `config.home.homeDirectory`, `config.home.stateVersion`.
- The activation package builds and yields a store path with an `activate`
  script, a `home-files` directory and an `extra-dependencies` file.
- The attribute tree a change lives in is still addressable — `home.file` holds
  142 entries, `home.packages` builds, a `packages.<system>.<name>` output still
  builds.
- The generation the checkout builds is the generation `~/` uses
  (`hmcheck fresh`), which is what makes every other drive meaningful.

## How to get to it (user POV)

There is no app to open. The user-facing entry points are:

- `home-manager switch --flake .#Home` (documented in `README.md`) — the thing
  this feature verifies *without* running.
- `sudo nixos-rebuild switch --flake .#Home` for the NixOS side.
- `nix flake check` / the CI job, which produce the same verdict as
  `hmcheck doctor` on a clean checkout.

A user asking "did my `home.nix` edit break anything?" is asking this feature.

## Driving it with hmcheck + nix eval

```bash
export XDG_CACHE_HOME=/tmp/nixcache
cd /home/coma/.ghq/github.com/Comamoca/dotfiles
.agents/skills/verify-dotfiles/scripts/hmcheck doctor
.agents/skills/verify-dotfiles/scripts/hmcheck build
.agents/skills/verify-dotfiles/scripts/hmcheck fresh
```

PASS lines, in order:

```
DOCTOR: OK
building .#homeConfigurations.Home.activationPackage -> .../proof/result-homeConfigurations.Home.activationPackage
/nix/store/<hash>-home-manager-generation
FRESH: built home-files == live home-files (<hash>-home-manager-files)
```

Individual value checks, when the change is a single option:

```bash
nix eval --raw .#homeConfigurations.Home.config.home.username      # -> coma
nix eval --json .#homeConfigurations.Home.config.home.file --apply builtins.attrNames | jq length   # -> 142
```

and the shape of the built generation:

```bash
L=.agents/skills/verify-dotfiles/proof/result-homeConfigurations.Home.activationPackage
test -x "$L/activate" && readlink -f "$L/home-files" && ls "$L"
```

Evidence files: `00-doctor.txt`, `01-home-file-attrnames.json` in
`../evidence/20261027T212035-sync-proof/`.

## Gotchas

- **`nix eval` writes warnings to stderr.** A run looks broken because of
  `warning: Git tree ... is dirty` and two `Using saved setting for
  'extra-substituters ...'` lines. They are not errors: the tree really is
  dirty, and the trusted-settings lines come from
  `~/.local/share/nix/trusted-settings.json`. Drop `2>&1 | tail` from your
  pipeline if you expect to read `--raw` output — it has no trailing newline and
  gets glued to the last warning line.
- **`hmcheck doctor` compares *names*, not full store paths, on purpose.** The
  profile link `~/.local/state/nix/profiles/home-manager` is a *relative* link
  to `home-manager-460-link`, so a bare `readlink` returns a name that never
  equals a store path. Use `readlink -f` everywhere before comparing.
- **`home-files` equality is not generation equality.** `hmcheck fresh`
  compares `home-files`, which is where all dotfiles live. A change to a systemd
  unit's *content*, an environment variable or `home.path` can leave
  `home-files` identical while the live unit is still old — for those, also read
  `hmcheck units` and `systemctl --user show -p FragmentPath` (see
  [systemd-user-units.md](systemd-user-units.md)).
- **A dirty tree is normal and it is *the* input.** `hmcheck doctor` reports
  `head: af379bc-dirty` and the flake path is a `/nix/store/…-source` copy of the
  working tree. The built generation therefore describes uncommitted edits —
  that is exactly why it is worth comparing against `~/`.
- **Do not run two nix commands at once.** One was observed blocking on the
  store lock for minutes (another agent was building); wrap in `timeout 300` and
  keep nix serial.
- **`nix build --no-link` gives you nothing to inspect.** Always let
  `hmcheck build` keep the out-link under `proof/`; a bare store path is usable
  once but hard to relate back to "this run".
