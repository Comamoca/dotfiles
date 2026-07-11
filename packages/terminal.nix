{ pkgs }:
let
  takt = import ../pkgs/takt { inherit pkgs; };

  # Patch bernstein to not hardcode model="opus" for the initial manager task.
  # Upstream server_launch.py forces opus, which OpenCode doesn't recognise.
  # Replace with seed.model so the bernstein.yaml model field is respected.
  bernstein-patched = pkgs.llm-agents.bernstein.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/bernstein/core/server/server_launch.py \
        --replace-fail '"model": "opus"' '"model": seed.model or "sonnet"'
    '';
  });
in
with pkgs;
[
  yazi
  # Terminal emulators
  wezterm
  alacritty
  kitty

  # Shell tools
  starship
  just
  zellij
  tmux

  # File managers
  felix-fm
  ranger
  thunar
  ghostty

  aider-chat
  claude-code-acp

  llm-agents.claude-code
  llm-agents.opencode
  llm-agents.oh-my-opencode
  llm-agents.gemini-cli
  llm-agents.crush
  bernstein-patched

  # takt 
]
