# 固定した上流ソースから skills root を組み立てる。
# 個別の SKILL.md は URL と hash で取得し、本文はこのリポジトリに vendoring しない。
#
# URL は内容が固定される形 (gist なら raw の revision 付き URL、GitHub なら
# タグ・コミット) を選ぶこと。可動 URL を指定すると上流更新のたびに hash
# mismatch でビルドが壊れる。
#
# 追加手順:
#   1. 個別 SKILL.md は下の remote に fetchurl を追加する
#   2. 複数ファイルを含むスキルは directory に fetchFromGitHub で追加する
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
  # 単一ファイルの SKILL.md (fetchurl で取得)
  remote = {
    # 日本語技術文書の文章規範 (k16shikano / Unlicense)
    japanese-tech-writing = pkgs.fetchurl {
      name = "japanese-tech-writing-SKILL.md";
      url = "https://gist.githubusercontent.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d/raw/8f2d57610a73efc97d743c9b0b0ecb1002e09fa4/SKILL.md";
      hash = "sha256-rTUODm9WMP2U2KuYpq7hlAU7AJb9yUTCPicdbfoJ7mg=";
    };
  };

  # 複数ファイルを含むスキル (リポジトリ全体を fetch してサブディレクトリをコピー)
  directory = {
    # 芋づる式リサーチスキル (MaryCache/imozuru / MIT)
    imozuru = pkgs.stdenv.mkDerivation {
      name = "imozuru-skill";
      dontBuild = true;
      src = pkgs.fetchFromGitHub {
        owner = "MaryCache";
        repo = "imozuru";
        rev = "14635fb74a1f68e5c138379c3a6e4ec823b7cb59";
        hash = "sha256-75kYs0RkYr+VJmTA8K1WyCRAvMQGC4TzaqeBsg+kYrg=";
      };
      installPhase = ''
        mkdir -p "$out"
        cp -r skills/imozuru "$out/"
      '';
    };
  };

  # 複数の skill ディレクトリを 1 ソースからまとめて供給する (src の skills/ を丸ごと展開)。
  # <name>/SKILL.md を並べた store path を直接作る点が directory と異なる。
  bundle = {
    # Lauren Tan (poteto) のエンジニアリング skill 集 (backnotprop/pstack / MIT)。
    # skills/<name>/SKILL.md が 58 個入っている。poteto-mode などは他の pstack skill を
    # 相互参照するため、絞らず skills/ を丸ごと配置する。
    # 上流は活発に更新されるので rev を固定し、更新時は rev/hash を差し替える。
    #   hash: nix-prefetch-url --unpack --type sha256 \
    #           https://github.com/backnotprop/pstack/archive/<rev>.tar.gz
    #         → SRI: nix hash convert --hash-algo sha256 --to sri <base32>
    pstack = pkgs.stdenv.mkDerivation {
      name = "pstack-skills";
      dontBuild = true;
      src = pkgs.fetchFromGitHub {
        owner = "backnotprop";
        repo = "pstack";
        rev = "18b6c36e6e201b110acc62472de987416ac4e23b";
        hash = "sha256-hsGfW8S58TL5QPv9VbhQ5/V1JyPhz52y4we914LELOI=";
      };
      installPhase = ''
        mkdir -p "$out"
        cp -r skills/. "$out/"
      '';
    };
  };

  install = name: src: ''
    mkdir -p "$out/${name}"
    cp ${src} "$out/${name}/SKILL.md"
  '';

  installDir = name: src: ''
    cp -r "${src}/${name}" "$out/${name}"
  '';

  # bundle のソースは既に <name>/SKILL.md を並べた tree なので中身をそのまま重ねる。
  installBundle = _: src: ''
    cp -r "${src}/." "$out/"
  '';
in
pkgs.runCommand "agent-skills-remote" { } (
  ''
    mkdir -p "$out"
  ''
  + lib.concatStringsSep "\n" (lib.mapAttrsToList install remote)
  + lib.concatStringsSep "\n" (lib.mapAttrsToList installDir directory)
  + lib.concatStringsSep "\n" (lib.mapAttrsToList installBundle bundle)
)
