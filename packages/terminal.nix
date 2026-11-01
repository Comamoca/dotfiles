{ pkgs }:
let
  takt = import ../pkgs/takt { inherit pkgs; };
  leaf = import ../pkgs/leaf { inherit pkgs; };

  # python3.14-posthog 7.71.0 は mcp >= 2 で meta.broken = true かつテストも
  # 1 件落ちてビルドできない状態。aider-chat は posthog を直接 import しない
  # (analytics 送信のみ) ため、依存リストから外してビルドを通す。
  # posthog を dependencies と propagatedBuildInputs の両方から除去する必要がある
  # (片方だけだと propagatedBuildInputs 経由でビルドが走る)。
  aiderChatNoPosthog =
    let
      dropPosthog =
        deps:
        builtins.filter (
          d:
          !(
            builtins.elem (d.pname or d.name or "") [
              "posthog"
              "mixpanel"
            ]
          )
        ) deps;
    in
    pkgs.aider-chat.overridePythonAttrs (old: {
      dependencies = dropPosthog (old.dependencies or [ ]);
      propagatedBuildInputs = dropPosthog (old.propagatedBuildInputs or [ ]);
      doCheck = false;
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
  herdr
  leaf

  # File managers
  felix-fm
  ranger
  thunar
  ghostty

  aiderChatNoPosthog
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
