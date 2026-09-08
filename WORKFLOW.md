---
tracker:
  kind: github
  provider:
    owner: Comamoca
    repo: dotfiles
    token_var: GITHUB_TOKEN
  active_states: [open]
  terminal_states: [closed]
  required_labels: [maestro]
polling:
  interval_ms: 30000
workspace:
  root: ~/.local/state/maestro/workspaces
  repo_path: /home/coma/.ghq/github.com/Comamoca/dotfiles
  base_ref: main
agent:
  driver: opencode
  command: opencode run --format json
  max_turns: 20
  max_concurrent_agents: 1
---

issue: {{ issue.identifier }}
title: {{ issue.title }}
labels: {{ issue.labels }}
attempt: {{ attempt }}

{{ issue.description }}

手順:
1. 現在のディレクトリはこの issue 専用の git worktree です。その中だけで作業する
2. このリポジトリは NixOS + home-manager の dotfiles です。設定は Nix 式(*.nix)と config/ 配下で管理されている
3. 変更をコミットし、push して `gh pr create` で PR を作成する(コミットメッセージは Conventional Commits)
4. PR 作成後、対応する issue をクローズする
5. 完了したら追加の説明はせず終了してよい
