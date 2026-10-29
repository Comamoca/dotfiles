{ pkgs }:
let
  takt = import ../pkgs/takt { inherit pkgs; };
  leaf = import ../pkgs/leaf { inherit pkgs; };

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
  leaf

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
  llm-agents.jcode
  llm-agents.dsh
  # llm-agents.codex は programs.codex.package (home.nix) 経由で入る

  (import ../pkgs/terminal-browser { inherit pkgs; })

  # takt
  hunk
  forgejo-cli
]
