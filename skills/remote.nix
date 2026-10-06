# 固定した上流ソースから skills root を組み立てる。
# 個別の SKILL.md は URL と hash で取得し、本文はこのリポジトリに vendoring しない。
#
# URL は内容が固定される形 (gist なら raw の revision 付き URL、GitHub なら
# タグ・コミット) を選ぶこと。可動 URL を指定すると上流更新のたびに hash
# mismatch でビルドが壊れる。
#
# 追加手順:
#   1. 個別 SKILL.md は下の remote に fetchurl を追加する
#   2. 固定リポジトリのスキル群は flake.nix に pinned input を追加し、ここでコピーする
#   3. hash は `nix store prefetch-file --json <url> | jq -r .hash` で取得
#
# 注意: codex 系 skill (codex-cli-runtime / codex-result-handling /
# gpt-5-4-prompting) はここでは扱わない。単体では機能せず codex:codex-rescue
# サブエージェントと codex-companion スクリプトを必要とするため、
# home.nix で codex プラグインごと Claude Code に配置している。
#
# 戻り値は <skill-name>/SKILL.md を並べたディレクトリで、
# home.nix の programs.agent-skills.sources.remote.path から参照する。
# (store path を source にするため discoverCatalog は IFD になる。
#  nix build / home-manager switch では既定で許可されているので問題ない。)
{ pkgs, lib }:
let
  remote = {
    # 日本語技術文書の文章規範 (k16shikano / Unlicense)
    japanese-tech-writing = pkgs.fetchurl {
      name = "japanese-tech-writing-SKILL.md";
      url = "https://gist.githubusercontent.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d/raw/8f2d57610a73efc97d743c9b0b0ecb1002e09fa4/SKILL.md";
      hash = "sha256-rTUODm9WMP2U2KuYpq7hlAU7AJb9yUTCPicdbfoJ7mg=";
    };
  };

  install = name: src: ''
    mkdir -p "$out/${name}"
    cp ${src} "$out/${name}/SKILL.md"
  '';
in
pkgs.runCommand "agent-skills-remote" { } (
  ''
    mkdir -p "$out"
  ''
  + lib.concatStringsSep "\n" (lib.mapAttrsToList install remote)
)
