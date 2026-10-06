---
name: consult-gpt6-sol
description: Use when a difficult implementation needs a second opinion from a stronger model. Consults gpt-6-sol through the Codex CLI (`codex exec`) and reports its answer back. Covers the exact command, stdin usage for long briefs, and failure handling. Uses the default ChatGPT subscription auth — no API keys.
---

# Consulting gpt-6-sol via Codex CLI

For hard design questions, delegate reasoning to gpt-6-sol through the Codex
CLI. The local session model formulates the brief; Codex does the thinking.

## The command

```bash
codex exec --skip-git-repo-check -m gpt-6-sol "<brief>"
```

Why each piece:

- Auth comes from the ChatGPT Plus subscription (`~/.codex/auth.json`,
  auth_mode = "chatgpt"). No API key and no `-c` provider override is
  needed. Do NOT route this through OpenCode Zen / `OPENCODE_API_KEY`:
  that burns the paid opencode quota instead of the subscription.
- `~/.codex/config.toml` is a read-only symlink managed by home-manager
  (`programs.codex` in `home.nix`); the model is passed via `-m`, never
  by editing the config file.
- `--skip-git-repo-check` avoids the "not in a git repo" prompt in
  non-interactive shells.

## Long briefs (recommended)

Long context gets mangled by shell quoting. Pipe it through stdin instead:

```bash
echo "$BRIEF" | codex exec --skip-git-repo-check -m gpt-6-sol
```

Codex reads the prompt from stdin when the positional argument is empty.

## Brief content

The brief must be fully self-contained — Codex starts with no repo context and
cannot read your conversation. Include:

1. The goal in one sentence.
2. Relevant constraints, decisions already made, and code snippets.
3. The specific question, phrased so a one-shot answer is possible.

Ask for the answer in the language you will report back in (default: Japanese
for this user).

## Output handling

- With `--json` you get JSONL events; useful lines are
  `item.completed` (`agent_message` for the actual answer, `error` for
  problems) and `turn.completed` (usage).
- Without it, stdout is the final answer text; ignore stderr noise
  (`failed to refresh available models`, `Model metadata for 'gpt-6-sol' not
  found` are harmless here).
- Observed 2026-09-26: a trivial prompt cost 2,160 tokens and ~3.6 s. Real
  briefs with cold cache cost more and take longer; follow-ups are faster.

## Failure handling

- `402 Payment Required: ... Insufficient account funds` on
  `opencode.ai/zen/v1/responses` → you are on the Zen provider. It means the
  Zen plan has no balance, NOT that auth failed. Do not retry and do not hunt
  for a different key in `~/.local/share/opencode/auth.json` (the `opencode` and
  `opencode-go` keys both 402 there). Drop the `-c model_providers.zen` and
  `-c model_provider=zen` overrides entirely and re-run; the ChatGPT
  subscription route is independent of that balance.
- `Missing environment variable: OPENCODE_API_KEY` → a `-c` provider override
  is present but no such variable is exported. Agent shells do not inherit it;
  fix is to remove the override, not to source a key.
- `Upstream request failed: Model is unavailable` → the subscription may
  temporarily lack the model, or auth has drifted; report it instead of
  silently falling back to another provider.
- Retry once on transient errors; then report the failure with the exact
  command used so the user can debug.

## Boundaries

Consultation only: never let this skill authorize file edits. Codex runs with
its own sandbox settings from the user's config; keep briefs phrased as
questions, not tasks to execute.
