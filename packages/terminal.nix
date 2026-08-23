{ pkgs }:
let
  takt = import ../pkgs/takt { inherit pkgs; };

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
  herdr

  # File managers
  felix-fm
  ranger
  thunar
  ghostty

  aider-chat
  claude-agent-acp

  llm-agents.claude-code
  llm-agents.opencode
  llm-agents.oh-my-opencode
  llm-agents.gemini-cli
  llm-agents.crush
  llm-agents.bernstein
  llm-agents.agent-browser
  llm-agents.fence

  # takt
  hunk
]
