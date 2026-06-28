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
  llm-agents.bernstein 

  # takt 
]
