# issue 駆動エージェントオーケストレータ maestro を systemd user service として
# 常駐させる。ローカル Forgejo (forgejo.service) の issue を 30 秒ポーリングし、
# `maestro` ラベル付き issue ごとに git worktree を切って opencode を自律実行する。
#
# 本体は Gleam 実装で ~/ghq/github.com/Comamoca/maestro から gleam run する
# (nix 化は maestro README のロードマップ項目)。初回は hex 取得があるため
# 事前に `nix-shell --run 'gleam build'` でビルドキャッシュを暖めておくこと。
#
# 環境変数:
#   MAESTRO_WORKFLOW   読み込む WORKFLOW.md(dotfiles リポジトリの実ファイル。
#                      maestro は実行中の動的再読込に対応している)
#   FORGEJO_TOKEN      WORKFLOW.md の tracker.provider.token_var。
#                      sops (secrets/forgejo.env) から注入される。
#                      worktree での push / PR 作成 / issue クローズにも
#                      同一変数が agent 経由で使われる。
{
  config,
  pkgs,
  lib,
  ...
}: let
  maestroDir = "${config.home.homeDirectory}/ghq/github.com/Comamoca/maestro";
  dotfilesDir = "${config.home.homeDirectory}/.ghq/github.com/Comamoca/dotfiles";
  path = lib.makeBinPath [
    pkgs.erlang
    pkgs.rebar3
  ];
in {
  systemd.user.services.maestro = {
    Unit = {
      Description = "maestro (issue-driven coding agent orchestrator)";
      After = ["network.target" "forgejo.service" "sops-nix.service"];
      Wants = ["forgejo.service"];
    };
    Service = {
      WorkingDirectory = maestroDir;
      Environment = [
        "MAESTRO_WORKFLOW=${dotfilesDir}/WORKFLOW.md"
        "HOME=${config.home.homeDirectory}"
        # /bin/sh -c 経由で git / opencode / curl を解決するため、
        # HM profile + システムパスに erlang/rebar3 を足した PATH を渡す
        "PATH=${path}:${config.home.profileDirectory}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/etc/profiles/per-user/coma/bin:/run/wrappers/bin:/usr/bin:/bin"
      ];
      EnvironmentFile = [ "${config.sops.secrets.forgejo.path}" ];
      # gleam overlay はバージョン集合なので bin.latest を使う
      ExecStart = "${pkgs.gleam.bin.latest}/bin/gleam run";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };
}
