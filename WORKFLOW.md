---
tracker:
  kind: forgejo
  provider:
    owner: coma
    repo: dotfiles
    url: http://localhost:3300
    token_var: FORGEJO_TOKEN
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
3. トラッカーはローカル Forgejo (http://localhost:3300) です。worktree の origin は GitHub を指しているため、push は次のように Forgejo へ明示的に行う(FORGEJO_TOKEN 環境変数を利用):

   git push http://coma:$FORGEJO_TOKEN@localhost:3300/coma/dotfiles.git <ブランチ名>

4. push したら PR を作成する(コミットメッセージは Conventional Commits):

   curl -s -X POST -H "Authorization: token $FORGEJO_TOKEN" -H 'Content-Type: application/json' \
     -d '{"title":"<PRタイトル>","head":"<pushしたブランチ>","base":"main"}' \
     http://localhost:3300/api/v1/repos/coma/dotfiles/pulls

5. PR 作成後、対応する issue をクローズする:

   curl -s -X PATCH -H "Authorization: token $FORGEJO_TOKEN" -H 'Content-Type: application/json' \
     -d '{"state":"closed"}' http://localhost:3300/api/v1/repos/coma/dotfiles/issues/{{ issue.id }}

6. 完了したら追加の説明はせず終了してよい
