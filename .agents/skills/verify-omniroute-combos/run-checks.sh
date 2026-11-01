#!/usr/bin/env bash
# verify-omniroute-combos: exhaustive differential check of the hysteresis in
# `meaningful_change()` (bin/scripts/omniroute-combos/omniroute-combos 116-135).
#
# Bash+jq has no verifier, so this exercises the REAL function and compares its
# verdict against spec.jq (an independent statement of the intent) over a fully
# enumerated, bounded domain. No sampling: every element of CTX below is run.
#
# The generator is never executed here: it contacts OmniRoute, writes into
# ~/.cache, ~/.dsh and ~/.config/opencode, and this check must never touch those.
# Instead the product file is copied (unmodified) into a scratch directory and
# only its `meaningful_change` definition is loaded, with $tmp/$old redirected at
# scratch files.
#
# usage: run-checks.sh [--product PATH] [--verbose] [--deep]
# exit:  0 = every enumerated case matches the spec
#        1 = at least one case disagrees with the spec (real bug or spec bug)
#        2 = the check could not run (bad path, function not found, jq missing)
set -uo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd -- "$here/../../.." && pwd)
product="$repo_root/bin/scripts/omniroute-combos/omniroute-combos"
spec="$here/spec.jq"
verbose=0
deep=0

while (($#)); do
  case $1 in
    --product) product=${2:?--product needs a path}; shift 2 ;;
    --verbose | -v) verbose=1; shift ;;
    --deep) deep=1; shift ;;
    -h | --help) sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "run-checks.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done

for bin in jq awk mktemp; do
  command -v "$bin" >/dev/null || {
    echo "run-checks.sh: missing tool: $bin" >&2
    exit 2
  }
done
[[ -r $product ]] || { echo "run-checks.sh: cannot read $product" >&2; exit 2; }
[[ -r $spec ]] || { echo "run-checks.sh: cannot read spec.jq (corrupt skill)" >&2; exit 2; }

work=$(mktemp -d "${TMPDIR:-/tmp}/verify-omniroute-combos.XXXXXX") || exit 2
trap 'rm -rf "$work"' EXIT

# The predicate definition is loaded from a copy; the copy is never edited here.
cp -- "$product" "$work/product.copy"
awk '/^meaningful_change\(\) \{/ {f=1}
     f {print}
     f && /^\}$/ {exit}' "$work/product.copy" >"$work/fn.bash"
if ! grep -q 'def changed(' "$work/fn.bash"; then
  echo "run-checks.sh: meaningful_change()/changed() not found in $product" >&2
  echo "run-checks.sh: the predicate moved or was renamed; update this skill's coverage record." >&2
  exit 2
fi

tmp= # set per case
old=$work/old.json
new=$work/new.json
eval "$(cat "$work/fn.bash")"

# ---------------------------------------------------------------------------
# Domain of a single numeric field (contextWindow or maxTokens).
# The values aim at every branch and every interval edge of `changed($a; $b)`,
# not at realism. OMNIROUTE_NULL is JSON null, the value a combo without
# context_length reports.
#   0                0*2 -> 0 and 0/2 -> 0 stay inside the band
#   1,2,3            integral edges: 1->2 is exactly 2x, 2->1 exactly half
#   1000,2001        straddle exact 2x (just over)
#   4001,2000        straddle exact half (just under)
#   1000000,1048576  the jitter pair the comment at line 105 describes
#   -5,-10           negative: both orderings of the margin
#   9007199254740993 2**53+1, first integer an IEEE double cannot hold
#   null             the non-number branch, both directions
# ---------------------------------------------------------------------------
CTX=(0 1 2 3 1000 2001 4001 2000 1000000 1048576 -5 -10 9007199254740993 OMNIROUTE_NULL)

json_val() { if [[ $1 == OMNIROUTE_NULL ]]; then printf 'null'; else printf '%s' "$1"; fi; }

# emit_snapshot <file> <id:ctx:max>... ; entries are written in the given order
emit_snapshot() {
  local file=$1 entry id ctx max first=1
  shift
  {
    printf '{"source":"omniroute","combos":['
    for entry in "$@"; do
      [[ -n $entry ]] || continue
      IFS=: read -r id ctx max <<<"$entry"
      ((first)) || printf ','
      first=0
      printf '{"id":"%s","name":"%s","contextWindow":%s,"maxTokens":%s}' \
        "$id" "$id" "$(json_val "$ctx")" "$(json_val "$max")"
    done
    printf ']}\n'
  } >"$file"
}

checked=0
failures=0
fail_log=$work/failures.txt
: >"$fail_log"

# assert_verdict <label> <expected: keep|rewrite> <old "id:ctx:max" list> <new list>
# Hand-written cases where the expected answer is stated independently of
# spec.jq too, so that a shared misreading cannot pass silently.
assert_verdict() {
  local label=$1 want=$2 old_spec=$3 new_spec=$4 rc got
  # shellcheck disable=SC2086 # entry lists are split on purpose
  emit_snapshot "$old" $old_spec
  # shellcheck disable=SC2086
  emit_snapshot "$new" $new_spec
  tmp=$new
  meaningful_change "$old"
  rc=$?
  got=keep
  ((rc == 0)) && got=rewrite
  checked=$((checked + 1))
  if [[ $got != "$want" ]]; then
    failures=$((failures + 1))
    {
      printf 'MISMATCH  %s\n' "$label"
      printf '  expected: %s   product: %s   (product exit %s)\n' "$want" "$got" "$rc"
      printf '  old: %s\n' "$(tr -d '\n' <"$old")"
      printf '  new: %s\n' "$(tr -d '\n' <"$new")"
    } >>"$fail_log"
  elif ((verbose)); then
    printf 'ok  %-58s %s\n' "$label" "$got"
  fi
}

# --- property 1: stability / idempotence ------------------------------------
# A snapshot the generator itself can emit (ids sorted by its jq pipeline, the
# four fixed keys) must not be rewritten against itself. Without this the timer
# rewrites all three client lists every 30 minutes forever.
assert_verdict "stability: plain snapshot"         keep \
  "a:1000000:1048576 b:1048576:1048576 c:1:1" "a:1000000:1048576 b:1048576:1048576 c:1:1"
assert_verdict "stability: null contextWindow"     keep \
  "a:OMNIROUTE_NULL:1048576 b:1000:OMNIROUTE_NULL" "a:OMNIROUTE_NULL:1048576 b:1000:OMNIROUTE_NULL"
assert_verdict "stability: zero values"            keep \
  "a:0:0 b:0:1000" "a:0:0 b:0:1000"
assert_verdict "stability: only combo null/null"   keep \
  "a:OMNIROUTE_NULL:OMNIROUTE_NULL" "a:OMNIROUTE_NULL:OMNIROUTE_NULL"
# Negative sizes never occur (context_length and max_tokens are >= 0), and the
# product treats every negative pair as a change (see "No lost update is not
# violated by negatives" in SKILL.md). Pinned to the product on purpose so an
# edit to the band shows up here as a diff rather than passing unnoticed.
assert_verdict "negatives: every negative pair rewrites" rewrite \
  "a:-5:-10 b:-10:-5" "a:-5:-10 b:-10:-5"

# --- property 2: no lost update --------------------------------------------
# A change in the combo id set must always be reported, whatever the numbers say.
assert_verdict "ids: combo added"                  rewrite \
  "a:1000000:1048576" "a:1000000:1048576 b:1000000:1048576"
assert_verdict "ids: combo removed"                rewrite \
  "a:1000000:1048576 b:1000000:1048576" "a:1000000:1048576"
assert_verdict "ids: combo renamed"                rewrite \
  "a:1000000:1048576" "z:1000000:1048576"
assert_verdict "ids: last combo removed"           rewrite \
  "a:1000000:1048576" ""
assert_verdict "ids: combo added, null fields"     rewrite \
  "a:OMNIROUTE_NULL:OMNIROUTE_NULL" \
  "a:OMNIROUTE_NULL:OMNIROUTE_NULL b:OMNIROUTE_NULL:OMNIROUTE_NULL"
assert_verdict "ids: combo added, sibling jitters" rewrite \
  "a:1000000:1048576" "a:1048576:1048576 b:1000000:1048576"
assert_verdict "ids: same set, order swapped"      keep \
  "a:1:1 b:1:1" "b:1:1 a:1:1"

# --- the documented resize band, boundary rows explicit --------------------
assert_verdict "band: exactly 2x is tolerated"     keep    "a:1000:1048576" "a:2000:1048576"
assert_verdict "band: exactly half is tolerated"   keep    "a:2000:1048576" "a:1000:1048576"
assert_verdict "band: just over 2x rewrites"       rewrite "a:1000:1048576" "a:2001:1048576"
assert_verdict "band: just under half rewrites"    rewrite "a:4001:1048576" "a:2000:1048576"
assert_verdict "band: 1 -> 2 is exactly 2x"        keep    "a:1:1048576" "a:2:1048576"
assert_verdict "band: 2 -> 1 is exactly half"      keep    "a:2:1048576" "a:1:1048576"
assert_verdict "band: 0 -> 1000000 rewrites"       rewrite "a:0:1048576" "a:1000000:1048576"
assert_verdict "band: the observed jitter is kept" keep    "a:1000000:1048576" "a:1048576:1048576"
assert_verdict "band: maxTokens shrink rewrites"   rewrite "a:1000:1048576" "a:1000:8192"
assert_verdict "band: null -> number rewrites"     rewrite "a:OMNIROUTE_NULL:1048576" "a:1048576:1048576"
assert_verdict "band: number -> null rewrites"     rewrite "a:1048576:1048576" "a:OMNIROUTE_NULL:1048576"
assert_verdict "negatives: -5 -> -10 rewrites"      rewrite "a:-5:1048576" "a:-10:1048576"
assert_verdict "negatives: -5 -> -11 rewrites"      rewrite "a:-5:1048576" "a:-11:1048576"
assert_verdict "negatives: -10 old, any new rewrites" rewrite "a:-10:1048576" "a:-5:1048576"

# ---------------------------------------------------------------------------
# Tier 1 (exhaustive, batched): every contextWindow value against every other
# contextWindow value, and likewise for maxTokens, with the id set unchanged;
# then the same pair again with the companion combo dropped, so the id check is
# exhaustively shown to dominate a tolerated resize.
# ---------------------------------------------------------------------------
tier1_cases=$work/tier1.tsv
: >"$tier1_cases"

# 'a' carries the pair under test; 'b' is constant, so any verdict is attributable to a.
for field in ctx max; do
  for ((i = 0; i < ${#CTX[@]}; i++)); do
    for ((j = 0; j < ${#CTX[@]}; j++)); do
      if [[ $field == ctx ]]; then
        # The companion combo holds FIXED values on both sides: only the value
        # under test may differ, so a verdict is attributable to that pair alone.
        emit_snapshot "$old" "a:${CTX[i]}:1048576" "b:1000:1000"
        emit_snapshot "$new" "a:${CTX[j]}:1048576" "b:1000:1000"
      else
        emit_snapshot "$old" "a:1000:${CTX[i]}" "b:1000:1000"
        emit_snapshot "$new" "a:1000:${CTX[j]}" "b:1000:1000"
      fi
      printf 'pair %s %s->%s, ids unchanged\t%s\t%s\n' \
        "$field" "${CTX[i]}" "${CTX[j]}" \
        "$(tr -d '\n' <"$old")" "$(tr -d '\n' <"$new")" >>"$tier1_cases"
      if [[ $field == ctx ]]; then
        emit_snapshot "$new" "a:${CTX[j]}:1048576"
      else
        emit_snapshot "$new" "a:1000:${CTX[j]}"
      fi
      printf 'pair %s %s->%s, companion combo dropped\t%s\t%s\n' \
        "$field" "${CTX[i]}" "${CTX[j]}" \
        "$(tr -d '\n' <"$old")" "$(tr -d '\n' <"$new")" >>"$tier1_cases"
    done
  done
done

# ---------------------------------------------------------------------------
# Tier 2 (exhaustive, --deep only): the two numeric paths interleaved on a
# small integral set, where float arithmetic is exact, so a disagreement names
# a counterexample a human can re-check by hand.
# ---------------------------------------------------------------------------
tier2_cases=$work/tier2.tsv
: >"$tier2_cases"
if ((deep)); then
  SMALL=(0 1 2 3 5)
  for ((ci = 0; ci < ${#SMALL[@]}; ci++)); do
    for ((cj = 0; cj < ${#SMALL[@]}; cj++)); do
      for ((mi = 0; mi < ${#SMALL[@]}; mi++)); do
        for ((mj = 0; mj < ${#SMALL[@]}; mj++)); do
          emit_snapshot "$old" "a:${SMALL[ci]}:${SMALL[mi]}" "b:1000000:1048576"
          emit_snapshot "$new" "a:${SMALL[cj]}:${SMALL[mj]}" "b:1048576:1048576"
          printf 'interleaved a.ctx %s->%s a.max %s->%s\t%s\t%s\n' \
            "${SMALL[ci]}" "${SMALL[cj]}" "${SMALL[mi]}" "${SMALL[mj]}" \
            "$(tr -d '\n' <"$old")" "$(tr -d '\n' <"$new")" >>"$tier2_cases"
        done
      done
    done
  done
fi

# ---------------------------------------------------------------------------
# Compare: one enumerated case, one verdict from the product, one from spec.jq.
# spec.jq is invoked once per case (a few ms); nothing here re-derives the
# scratch copy, and --verbose only adds one printf per case.
# ---------------------------------------------------------------------------
compare_file() { # <cases-file>
  local label old_json new_json real_rc real specv
  while IFS=$'\t' read -r label old_json new_json; do
    printf '%s\n' "$old_json" >"$old"
    printf '%s\n' "$new_json" >"$new"
    tmp=$new
    meaningful_change "$old"
    real_rc=$?
    if ((real_rc == 0)); then real=rewrite; else real=keep; fi
    specv=$(jq -n --slurpfile o "$old" --slurpfile n "$new" -r \
      "$(cat "$spec") spec(\$o[0]; \$n[0]) | if .rewrite then \"rewrite\" else \"keep\" end") || {
      echo "run-checks.sh: spec.jq failed on: $label" >&2
      exit 2
    }
    checked=$((checked + 1))
    if [[ $real != "$specv" ]]; then
      failures=$((failures + 1))
      {
        printf 'MISMATCH  %s\n' "$label"
        printf '  product: %s   spec: %s   (product exit %s)\n' "$real" "$specv" "$real_rc"
        printf '  old: %s\n' "$old_json"
        printf '  new: %s\n' "$new_json"
      } >>"$fail_log"
    elif ((verbose)); then
      printf 'ok  %-58s %s\n' "$label" "$real"
    fi
  done <"$1"
}

compare_file "$tier1_cases"
if ((deep)); then compare_file "$tier2_cases"; fi

echo "verify-omniroute-combos: $checked cases enumerated, $failures mismatch(es)"
echo "  product: ${product#"$repo_root"/}"
echo "  spec   : ${spec#"$repo_root"/} (independent statement of the intent)"
echo "  depth  : $([[ $deep == 1 ]] && echo deep || echo default)"
if ((failures)); then
  echo
  sed -n '1,150p' "$fail_log"
  ((failures > 25)) && echo "  ... $failures mismatches total, first 25 shown"
  echo
  echo "FAIL: the installed predicate and the intended predicate disagree."
  echo "Separate a real bug from a modelling error with 'A real bug, or a modelling error?' in SKILL.md."
  exit 1
fi
echo "PASS: every enumerated case matches the spec (bounds in SKILL.md)."
