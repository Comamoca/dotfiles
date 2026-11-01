---
name: verify-omniroute-combos
description: Use when changing the hysteresis in `meaningful_change()` (bin/scripts/omniroute-combos/omniroute-combos), or when you need to know whether the generated OmniRoute combo lists should be rewritten. Exhaustively enumerates a bounded input domain, runs the real bash+jq function, and compares its verdict against an independent jq specification.
---

# Verifying the OmniRoute combo hysteresis

## What this checks

`meaningful_change()` decides whether the timer overwrites the generated combo
lists. Two things must hold, and each of them fails visibly if it breaks:

| Property | One sentence |
| --- | --- |
| Stability | A list the generator just wrote must not be rewritten when the same list is produced again, otherwise the 30-minute timer churns all three client configs forever. |
| No lost update | A change to the combo id set must always be rewritten, otherwise a model id silently disappears from opencode and dsh and model selection breaks. |

The harm is asymmetric and both harms are real: churn means opencode and dsh
reload model definitions every 30 minutes; a lost update means a model is gone
with no error anywhere.

## How to run it

One command, from the repository root:

```sh
bash .agents/skills/verify-omniroute-combos/run-checks.sh
```

Takes about 10-15 seconds and prints `PASS` with the number of enumerated cases,
or `FAIL` with a counterexample per disagreement. Exit codes: `0` pass, `1`
disagreement, `2` the check could not run.

Useful variants:

```sh
bash .agents/skills/verify-omniroute-combos/run-checks.sh --verbose  # ~10s, one line per case
bash .agents/skills/verify-omniroute-combos/run-checks.sh --deep     # ~20s, 1435 cases
bash .agents/skills/verify-omniroute-combos/run-checks.sh --product /tmp/variant  # check a modified copy
```

`--product` is what makes the check testable: point it at a scratch copy to see
whether an intended change is actually observed, and to prove the check can
fail. Never edit the real script to test it.

## If you do run the generator end to end

The paths the generator writes are resolved through several independent
variables, not just `HOME`: `XDG_CONFIG_HOME` (opencode), `XDG_CACHE_HOME`
(the cache copy) and `DSH_HOME` (dsh). Setting only `HOME` is **not** isolation:
a shell with `XDG_CONFIG_HOME` already exported keeps writing to the real
`~/.config/opencode/omniroute-combos.json`. On 2026-11-01 a test that set only
`HOME` replaced the real 49-combo list with 2 fake combos this way, silently,
with exit 0.

Both directions were re-measured on 2026-11-01. With all four variables pointed
into the sandbox, the real lists kept their hashes (`9aefe860…`) and the run
wrote only sandbox paths. With `HOME` sandboxed but `XDG_CONFIG_HOME` left
pointing outside it, the opencode JSON escaped to that outside path while the
other three stayed in the sandbox. The generator's own output names the escaped
path, so compare the printed paths against the sandbox prefix, not just the
file hashes. Note that `jcode` has no override variable at all: it is always
`$HOME/.jcode/config.toml`, so `HOME` must be sandboxed even when the XDG
variables are set.

Isolate all of them, and drop the rest of the environment so nothing leaks:

```sh
env -i HOME="$V/home" \
  XDG_CONFIG_HOME="$V/home/.config" \
  XDG_CACHE_HOME="$V/home/.cache" \
  DSH_HOME="$V/home/.dsh" \
  OMNIROUTE_URL=http://127.0.0.1:20997 \
  OMNIROUTE_ENV_FILE=/nonexistent \
  PATH=/home/coma/.nix-profile/bin:/run/current-system/sw/bin:/usr/bin:/bin \
  bash "$V/gen"
```

Take a hash of every real target before the run and compare afterwards; check
the output text too, since it names the paths it wrote.

## What is verified, and how

Bash plus jq has no verifier, so there is no model to check here. The check
therefore exercises the **real code with generated inputs** and compares the
result against a second, independently written statement of the same intent
(`spec.jq`). A disagreement means either the product or the spec is wrong; the
section below separates the two.

- **The real function runs.** `run-checks.sh` copies the product verbatim into a
  temporary directory, extracts the `meaningful_change()` definition with `awk`,
  loads it with `eval`, and calls it with `$tmp`/`$old` pointing at scratch
  files. The generator itself is never executed: it contacts OmniRoute and
  writes into `~/.cache/omniroute`, `~/.dsh` and `~/.config/opencode`.
- **The verdict is the exit status.** `jq -e` exits `0` on a true result and
  non-zero otherwise, and the function passes that status through, so
  `exit 0 == rewrite, exit != 0 == keep`.
- **The domain is enumerated, not sampled.** `CTX` holds eleven values per
  field: `0 1 2 3 1000 2001 4001 2000 1000000 1048576 -5 -10 9007199254740993`
  plus JSON `null`. Every contextWindow pair (old x new) is run with maxTokens
  held constant, and every maxTokens pair likewise, plus the same pairs with the
  companion combo dropped so the id check is exercised against tolerated
  resizes. `--deep` additionally interleaves both numeric fields over
  `0 1 2 3 5`, where double arithmetic is exact.
- **Boundary rows are pinned by hand.** Twenty-five `assert_verdict` cases state
  the expected verdict without consulting `spec.jq`, so a misreading shared by
  the product and the spec cannot pass silently.

### The band, precisely

`changed($a; $b)` reports a resize when `$b > $a * 2` or `$b * 2 < $a`, both
strict. So:

| Move | Verdict |
| --- | --- |
| exactly 2x (`1000 -> 2000`, `1 -> 2`) | tolerated, not a change |
| exactly half (`2000 -> 1000`, `2 -> 1`) | tolerated, not a change |
| just over 2x (`1000 -> 2001`) | change |
| just under half (`4001 -> 2000`) | change |
| the observed jitter (`1000000 <-> 1048576`) | tolerated |
| `null -> null` | tolerated |
| `null -> number`, `number -> null` | change |
| `0 -> 0` | tolerated |

## Bounds and scope

In scope and exhaustively enumerated: `changed($a; $b)` and the
`meaningful_change()` body at lines 116-135 of
`bin/scripts/omniroute-combos/omniroute-combos`. Specifically: the numeric band
over the values listed above, the non-number branch, an id set that is added to,
removed from, renamed, emptied or reordered, and both `contextWindow` and
`maxTokens`.

Deliberately out of scope, each for a reason:

- **Network behaviour** (`curl`, retry, `GET /v1/models`) and the jq
  normalisation at lines 81-93. That code runs against a live server; this check
  never touches it. The observed retry count and stderr shape are recorded under
  "Fetch-side guard" below, but only as measurements from a local server, not as
  something `run-checks.sh` asserts.
- **File installation** at lines 157-161: atomicity, permissions, and whether all
  three destinations really receive identical bytes. Measured by hand on
  2026-11-01 and recorded under "Write side" below; still not automated, so
  nothing here fails if a future change writes only two of the three.
- **Consumers**: the opencode plugin `config/opencode/plugins/omniroute-combos.ts`
  and the dsh `models: !!js ...` expression. A correct verdict can still break a
  consumer.
- **Concurrency**: two overlapping timer runs. Nothing here serialises them.
- **Negative values.** The product treats every pair of negative numbers as a
  change: with `$a = -5`, `$a * 2 = -10`, so `$b > -10` is true for every
  `$b > -10`. Context windows and token counts are never negative, so this costs
  nothing, and the check pins the current behaviour rather than calling it a
  bug.
- **Values above 2**53**. `9007199254740993` is in the domain because it is the
  first integer a double cannot represent, but its verdict depends on IEEE
  rounding rather than intent, so it is covered as a crash check, not as a
  semantic one.

## A real bug, or a modelling error?

Before reporting anything as a product bug, decide which side is wrong:

1. **Re-read the intent, not the code.** The intent is the comment block at
   lines 103-115 of the script: a change is "id set differs, or a size moved
   beyond 2x/half". `spec.jq` restates that comment. If the comment and the
   product disagree, the product is wrong.
2. **Reproduce the counterexample with the generator's own output shape.** Every
   combo has exactly the four keys `id`, `name`, `contextWindow`, `maxTokens`,
   ids sorted, and `source: "omniroute"`. If your case needs a shape the
   generator cannot emit (missing `name`, unsorted ids, a `combos` key that is
   not an array), you have found a modelling error.
3. **Check for a fail-open.** The function ends in
   `jq -e ... "$old" >/dev/null 2>&1`. If jq fails to parse the installed file,
   the status is non-zero and that is read as "no change", so the rewrite is
   suppressed. Malformed, empty or wrong-shape installed JSON therefore keeps a
   stale list forever instead of regenerating it. This is a genuine finding, and
   it is reported below rather than being modelled as a violation. To confirm it
   by hand, pass a truncated file as `--product`'s counterpart: an invalid
   `$old` and a completely different `$new` will still print `keep`.
4. **Then check the spec.** Run the same case through `spec.jq` alone and by
   hand. If the spec disagrees with the comment, the spec is wrong and must be
   fixed toward the comment, never toward the product's behaviour.

A disagreement is only a product bug once steps 1-4 all point at the product.

### Known finding: the id-set check carries the removed-id case alone

`select($p != null)` at line 129 is unreachable in any way that would matter. An
exhaustive search over every combination of empty, single, pair, triple and
reordered id sets with `null`, `1`, `2` and `1000` in both numeric fields
returned **zero** inputs where deleting that line changes the verdict. The
reason is that `$p == null` means the id is new, and a new id already forces
`($prev | keys) != ($next | map(.id) | sort)`. The line is harmless documentation
of intent, but it is not load-bearing, so do not "simplify" around it assuming
the id check and this filter cover different cases; the id check covers both.
Removing it cannot make the check fail, which is why the failure demonstration
below uses a different mutation.

### Former finding: an unreadable installed list never regenerated (fixed)

This used to fail open: if `$old` existed but was not valid JSON, or was JSON
without a `combos` array, jq exited non-zero, the function returned non-zero,
and the caller treated that as "already up to date". The stale file was kept, so
a corrupted cache healed only after being deleted by hand.

Confirmed end to end on 2026-11-01, not just by reading the code. Truncating the
dsh list to its first 20 bytes and running the generator gave
`1 combos, already up to date` with exit 0, and `--check` also exited 0. The file
stayed truncated. The three failing shapes were all non-zero at the jq level:
unparseable JSON (jq exit 5), empty file (4), and valid JSON with no `combos`
(5). A missing file was already detected (exit 2), so the asymmetry was only
about corrupt content, not absence.

`meaningful_change()` now validates `$old` first and returns "must rewrite" on
parse failure, printing `<path> is not valid JSON; rewriting it` to stderr.
Re-measured after the fix: a truncated cache and a truncated dsh list each give
`--check` exit 2 and an apply that rewrites the file and exits 0, and the file
parses afterwards. Keep this behavior if you touch the function; the guard must
stay ahead of the hysteresis comparison, not inside it.

## Fetch-side guard: what counts as a usable body

The guard around line 97 is
`jq -e 'type == "object" and (.data | type == "array")'`, and it is deliberately
stricter than `jq -e .`. Validity alone is not enough: `[1,2,3]`, `"string"`,
`{"no_models_key":true}`, `{"data":null}`, `{"data":{}}` and two concatenated
JSON documents are all *valid* JSON, so `jq -e .` accepts them, and the
`.data[]` in the extraction then dies with a raw jq message and **exit 5**
instead of the intended diagnostic.

Observed on 2026-11-01 with a padded local server and every writable root
redirected (`HOME`, `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `DSH_HOME`,
`OMNIROUTE_URL`): before the fix, four of those shapes exited `5` with
`Cannot index array with string ("data")` and similar; after the fix, all
eleven abnormal shapes exit `1` with one message, and no destination file is
touched. The extraction also pipes through `objects`, so a body like
`{"data":[1,null,"x",{...valid combo...}]}` yields the one real combo and
still exits `0`. Treat "exit 5 with a bare jq error" as a regression of this
guard.

HTTP-level failures are separate: `curl -fsS` already fails on 5xx, retries
three times, and then reports `cannot reach ...`, which is also exit `1`.
Measured 2026-11-01 against a local server returning 502: **three** raw
`curl: (22) The requested URL returned error: 502` lines reach stderr (one per
attempt, not suppressed), followed by the single intended
`cannot reach ... (existing lists left untouched)` line. So stdout is empty, the
last line is the diagnostic to match on, and the count of `curl:` lines is the
retry budget. A no-listener run behaves the same with `curl: (7) Failed to
connect ...` and takes about 12 s (2 + 4 + 6 s of backoff); the 502 path takes
about 13 s.

## Write side: what an end-to-end run actually guarantees

These were measured on 2026-11-01 with all four roots redirected, so they are
observations rather than claims derived from reading the code. The automated
check does not cover them; re-measure by running the recipe above, not by
editing the real script.

| Situation | Observed |
| --- | --- |
| `--print` | prints the JSON, writes no file, exit 0 |
| First apply into an empty tree | all three JSON lists created, `config.toml` block appended, exit 0 |
| Apply immediately again | `1 combos, already up to date`, all four files byte-identical |
| `--check` right after apply | exit 0, no output |
| Any destination file missing | `--check` exit 2 (`client lists are stale`), apply recreates it |
| Any destination file truncated | `--check` exit 2 plus `<path> is not valid JSON; rewriting it` on stderr; apply rewrites it (fixed 2026-11-01) |
| Unknown option | exit 64 with `unknown option: --bogus` |

The success message names only the opencode and jcode paths
(`updated N combos -> .../omniroute-combos.json, .../config.toml`), but the
cache copy and the dsh copy are written too. Do not read that message as the
list of files touched; check the files.

A first apply also rewrites the jcode block and reports, on stderr,
`二重定義になる models 宣言を削除した` for any `[[providers.omniroute.models]]`
table that sat outside the block. That is intended deduplication: the block
becomes the single source, and non-block content must survive verbatim (the
fixture's trailing `[tail]` section did).

## Proving the check can fail

Both variants live in scratch copies; the real script is never edited.

```sh
S=.agents/skills/verify-omniroute-combos
cp bin/scripts/omniroute-combos/omniroute-combos /tmp/variant

# Variant A: exact comparison instead of the band.
perl -0pi -e 's/else \(\$b > \$a \* 2\) or \(\$b \* 2 < \$a\)/else \$b != \$a/' /tmp/variant
bash $S/run-checks.sh --product /tmp/variant   # 34 mismatches, exit 1
#   band: exactly 2x is tolerated   expected keep, product rewrite

# Variant B: the id-set comparison removed (loses combo add/remove).
cp bin/scripts/omniroute-combos/omniroute-combos /tmp/variant
perl -0pi -e 's/\(\(\$prev \| keys\) != \(\$next \| map\(\.id\) \| sort\)\) or //' /tmp/variant
bash $S/run-checks.sh --product /tmp/variant   # 54 mismatches, exit 1
#   ids: combo added   expected rewrite, product keep
```

Restore by deleting the scratch copy and running against the real script, which
passes. Removing `select($p != null)` was also tried and produced **0**
mismatches, which is the finding recorded above, not a gap in the check.

## Coverage record

- Files exercised: `bin/scripts/omniroute-combos/omniroute-combos` only, and
  only through the extracted `meaningful_change()` definition.
- Functions exercised: `meaningful_change()` and the inner `changed($a; $b)`
  (lines 116-135). Everything else in the file is out of scope, as listed above.
- Helpers: `.agents/skills/verify-omniroute-combos/run-checks.sh` (driver and
  hand-pinned cases), `.agents/skills/verify-omniroute-combos/spec.jq`
  (independent specification).
- Sync commit: `af379bc68e671ba8af3079bc9ea26be9af99124a`

The sync commit records the product revision this coverage was last confirmed
against. Move it forward **only after** re-running `run-checks.sh` against the
new revision and confirming the bounds above still describe the code. If
`meaningful_change()` grew a new argument, a new field, or a new branch, the
domain must grow with it before the commit is updated; if the function moved,
`run-checks.sh` exits `2` with a message instead of silently checking nothing.

## Tool versions

Verified with `jq-1.8.2`, `GNU bash 5.3.20` and GNU awk on NixOS. The check needs
only `bash`, `jq`, `awk` and `mktemp`; it exits `2` and names the missing tool if
any of them is absent. No network access, no `nix`, and no writes outside the
temporary directory.
