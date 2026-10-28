{
  lib,
  stdenvNoCC,
  fetchurl,
  pythonAtRoot,
  python314Packages,
  stdenv,
  pname,
  version,
  url,
  hash,
  # バックエンド固有のビルド依存 (default.nix の `backendDrvs` 参照)。
  nativeBuildInputs ? [ ],
  # C 拡張を含む sdist 用。既定は空 (コンパイラを引きずらない)。
  wantCC ? false,
}@args:

# 1 つの依存を PyPI の固定 URL からマテリアライズする。
#
# - `.whl`: 展開して `$out/site-packages` に置く。CPython 3.14 の manylinux
#   wheel はそのまま置けるので `installer` / pip を経由しない。
# - `.tar.gz`: 上流の pyproject.toml が宣言するバックエンドで wheel を作る。
#   隔離ビルドはしないので、バックエンドは nixpkgs の Python 3.14 パッケージ
#   から `nativeBuildInputs` として明示的に供給する。
let
  isWheel = builtins.match ".*\\.whl" url != null;
  py = python314Packages;

  # どの sdist のビルドにも必要な共通のもの。
  common = with py; [
    build
    packaging
  ];
in
if isWheel then
  stdenvNoCC.mkDerivation {
    inherit pname version;
    src = fetchurl { inherit url hash; };
    # manylinux wheel は ELF を含んでも GNU/Linux 上ではそのまま動く。
    unpackPhase = ''
      runHook preUnpack
      mkdir -p wheel
      ${pythonAtRoot.interpreter} -m zipfile -e "$src" wheel
      runHook postUnpack
    '';
    installPhase = ''
      runHook preInstall
      # 親 (omnigent) が依存を PYTHONPATH で並べるので、sdist 組と同じく
      # `site-packages/` の下に置いてレイアウトを揃える。
      mkdir -p "$out/site-packages"
      cp -a wheel/. "$out/site-packages/"
      find "$out" -name '__pycache__' -prune -exec rm -rf {} +
      runHook postInstall
    '';
  }
else
  stdenvNoCC.mkDerivation {
    inherit pname version;
    src = fetchurl { inherit url hash; };

    # アーカイブの大半は setuptools 系 (setup.py のみを含むものも) なので既定で
    # 入れておく。hatchling / flit-core / poetry-core などは呼び出し側が
    # nativeBuildInputs として足す。C 拡張を含むものだけコンパイラを足す。
    #
    # C 拡張を含むものは `pythonAtRoot` を先頭に置く。`nativeBuildInputs` の
    # 順序が `PATH` を決めるので、`pythonAtRoot` (cp314) の python と setuptools
    # が優先され、`python314Packages.python` (cp314t) 向けの拡張子で
    # ビルドされるのを避けられる。
    nativeBuildInputs =
      lib.optional wantCC pythonAtRoot
      ++ lib.optional wantCC stdenv.cc
      ++ common
      ++ nativeBuildInputs
      ++ (with py; [
        setuptools
        wheel
        pip
      ]);

    buildPhase = ''
      runHook preBuild
      ${pythonAtRoot.interpreter} -m build --wheel --no-isolation --skip-dependency-check --outdir dist .
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      # ビルド環境に同じバージョンが入っていると pip は "already installed" で
      # 何もしないので、必ず --ignore-installed を付ける。
      ${pythonAtRoot.interpreter} -m pip install --no-deps --no-index --no-compile \
        --no-build-isolation --no-cache-dir --ignore-installed \
        --prefix "$out" dist/*.whl
      # pip は `$out/lib/pythonX.Y/site-packages` に入れる。呼び出し側は
      # `$out` 全体を参照パスに加えるので動くが、レイアウトを揃えておく。
      if [ -d "$out/lib/python"*"/site-packages" ]; then
        mv "$out"/lib/python*/site-packages "$out/site-packages"
        rm -rf "$out/lib"
      fi
      find "$out" -name '__pycache__' -prune -exec rm -rf {} +
      runHook postInstall
    '';
  }
