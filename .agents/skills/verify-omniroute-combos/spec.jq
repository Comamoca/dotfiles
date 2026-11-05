# Independent specification of the intended rewritability decision for the
# OmniRoute combo lists.
#
# Deliberately written WITHOUT calling the product's `changed($a; $b)` helper,
# WITHOUT the product's `select($p != null)` construction, and with an explicit
# reduce instead of the product's list-and-count pipeline. Same intent,
# different code, so a typo in one is unlikely to be mirrored in the other.
# If you edit this file, edit it toward the intent in
# bin/scripts/omniroute-combos/omniroute-combos lines 103-135, never toward
# whatever the product currently happens to compute.
#
# Defined as a function so run-checks.sh can call it with its own inputs:
#   jq -n --slurpfile o "$old" --slurpfile n "$new" \
#      -r "$(cat spec.jq) spec(\$o[0]; \$n[0]) | .rewrite"
# (a bare `-f` program cannot see --slurpfile variables, hence the function.)
#
# spec($old; $new) -> one JSON object
#   rewrite     : boolean, the spec's verdict for `meaningful_change`
#                 (false == "already up to date, keep the installed lists")
#   ids_changed : boolean, the combo id set differs
#   resized_ids : ids whose contextWindow or maxTokens moved beyond the band
#
# Semantics (the hysteresis is a BAND, not a strict >2x):
#   a numeric field is "resized" when  new > 2*old  or  new < old/2
#   exact 2x and exact half are INSIDE the band, i.e. tolerated, not a change.
#   a non-numeric field (null included) is a change iff the two values differ
#   (null -> null is tolerated; null -> number and number -> null are changes).

def is_num: type == "number";

# within($old; $new): true when the move is small enough to be ignored.
def within($old; $new):
  if ($old | is_num) and ($new | is_num) then
    ($new <= ($old * 2)) and (($new * 2) >= $old)
  else
    $old == $new
  end;

def spec($old; $new):
  (($old.combos // []) | map({key: .id, value: .}) | from_entries) as $by_id
  | [($new.combos // [])[]] as $next_combos
  | ([$next_combos[].id] | sort | unique) as $next_ids
  | ([$old.combos[]?.id] | sort | unique) as $old_ids
  | (reduce $next_combos[] as $m ({};
       $by_id[$m.id] as $p
       | if $p == null then .
         elif (within($p.contextWindow; $m.contextWindow)
               and within($p.maxTokens; $m.maxTokens)) then .
         else .[$m.id] = true
         end
     ) | keys) as $resized
  | {
      ids_changed: ($old_ids != $next_ids),
      resized_ids: $resized,
      rewrite: (($old_ids != $next_ids) or (($resized | length) > 0))
    };
