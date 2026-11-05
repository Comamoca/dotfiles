{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchurl,
  python314,
  python314Packages,
  makeWrapper,
  runCommand,
  runtimeShell,
}:

# Omnigent (https://omnigent.ai/) — meta-harness for coding agents.
#
# 依存は上流がテストした組み合わせ (v0.19.1 タグの uv.lock、既定依存のみ) を
# PyPI から固定する。nixpkgs の Python パッケージに追従させると、nixpkgs 側の
# 更新で omnigent が壊れるため。
#
# 本体は上流タグのソースから、ビルド済み web UI は PyPI sdist から取るので、
# ビルドに Node.js / pnpm は不要。
#
# deps.nix を更新するときは、上流タグの uv.lock を CPython 3.14 / x86_64-linux で
# 解決し直し、各配布物のバージョン・URL・ハッシュを書き換える (docs/omnigent.md)。

let
  version = "0.19.1";

  # 上流タグのソース (モノレポ)。PyPI の sdist と違い、workspace パッケージ
  # (`sdks/python-client` = omnigent-client, `sdks/ui` = omnigent-ui-sdk) も
  # 入っているので、これらを同じバージョンで組み立てられる。
  #
  # ただしこのソースは web UI をビルドしないと `omni server` が UI を配れない
  # (Node.js + pnpm が要る)。そこでビルド済み UI だけ PyPI の sdist から
  # 取り出す (`webUi`)。
  src = fetchFromGitHub {
    owner = "omnigent-ai";
    repo = "omnigent";
    tag = "v${version}";
    hash = "sha256-Mv1rZS9YNZBbhy/dh6TYsLCns0rNn2jU4SGrG8n7Vzk=";
  };

  # ビルド済み web UI (dist) を含む PyPI sdist。
  sdist = fetchurl {
    url = "https://files.pythonhosted.org/packages/b6/37/3563468c0b14b167393bcd5e2fa696f9a2544184d52cf855b77eef42d2cb/omnigent-${version}.tar.gz";
    hash = "sha256-SUVttI0RWxfqpdb/ZDdAAx/kzY+pvBEQRWtg5c/5CLw=";
  };

  webUi = runCommand "omnigent-${version}-web-ui" { nativeBuildInputs = [ python314 ]; } ''
    mkdir -p $out
    tar -xzf ${sdist} --strip-components=1 -C $out "omnigent-${version}/omnigent/server/static"
  '';

  spec = v: url: hash: {
    inherit v url hash;
  };

  allDeps = import ./deps.nix { inherit spec; };

  # Rust 拡張でビルドが重いものは nixpkgs のビルド成果物を使う (API 互換)。
  # 上流は cryptography>=42 を要求するが、omnigent が使うのは X.509 と RSA
  # だけで、nixpkgs の 50 系で足りる。
  fromNixpkgs = {
    cryptography = py.cryptography;
  };

  deps = removeAttrs allDeps (builtins.attrNames fromNixpkgs);

  py = python314Packages;

  # sdist を wheel にするバックエンド。上流の pyproject.toml の
  # `[build-system] requires` に対応させる。ここに無いものは setuptools として
  # 扱う (setup.py だけを含む古いアーカイブ)。
  backendDrvs = {
    hatchling = with py; [
      hatchling
      hatch-vcs
      hatch-fancy-pypi-readme
    ];
    hatchVcs = [
      py.hatchling
      py.hatch-vcs
    ];
    flit = [ py.flit-core ];
    poetry = [ py.poetry-core ];
    pdm = [ py.pdm-backend ];
    setuptools = [ ];
  };

  # パッケージ名 -> バックエンド。deps.nix はバージョンと URL だけを持つので、
  # バックエンドの割り当てはここで行う。未指定は setuptools。
  backends = {
    # hatchling (+ hatch-vcs / hatch-fancy-pypi-readme)
    annotated-types = "hatchling";
    argon2-cffi = "hatchling";
    attrs = "hatchling";
    cel-python = "hatchling";
    claude-agent-sdk = "hatchling";
    ftfy = "hatchling";
    griffelib = "hatchling";
    httpcore = "hatchling";
    httpx = "hatchling";
    jsonschema = "hatchling";
    jsonschema-specifications = "hatchling";
    mcp = "hatchling";
    openai = "hatchling";
    openai-agents = "hatchling";
    opentelemetry-api = "hatchling";
    pydantic = "hatchling";
    pydantic-settings = "hatchling";
    pygments = "hatchling";
    python-multipart = "hatchling";
    referencing = "hatchling";
    starlette = "hatchling";
    typing-inspection = "hatchling";
    urllib3 = "hatchling";
    uvicorn = "hatchling";
    wcwidth = "hatchling";
    filelock = "hatchVcs";

    # flit_core
    click = "flit";
    idna = "flit";
    markdown-it-py = "flit";
    mdurl = "flit";
    more-itertools = "flit";
    packaging = "flit";
    typing-extensions = "flit";

    # poetry-core
    rich = "poetry";
    tomlkit = "poetry";

    # pdm-backend
    annotated-doc = "pdm";
    fastapi = "pdm";
  };

  # sdist に C 拡張が含まれていてコンパイラが要るもの (cp314 の wheel が
  # 無いか、cp314t 用しか無いためソースからビルドする)。
  cExtensions = [
    "argon2-cffi-bindings"
    "protobuf"
    "psutil"
  ];

  materialize =
    name: entry:
    py.callPackage ./dependency.nix {
      # ABI は `python314` (非 free-threaded) に揃える。`python314Packages.python`
      # は `python314t` (free-threaded) なので、cp314 manylinux wheel と
      # 共存できない。
      pythonAtRoot = python314;
      pname = name;
      inherit (entry) url hash;
      version = entry.v;
      nativeBuildInputs = backendDrvs.${backends.${name} or "setuptools"};
      wantCC = lib.elem name cExtensions;
    };

  # 依存の drv はすべて `$out/site-packages` に中身を持つ形に揃える
  # (`PYTHONPATH` に並べるため)。nixpkgs 由来のものは配置が違うので貼り直す。
  flatten =
    drv:
    runCommand "${drv.name}-flat" { } ''
      # `cp -a` はパーミッションも写すので、先に `__pycache__` を落としてから
      # コピーする (コピー後は読み取り専用で消せない)。
      mkdir -p $out/site-packages
      cp -a ${drv}/lib/python*/site-packages/. $out/site-packages/
      chmod -R u+w $out/site-packages
      find $out -name '__pycache__' -prune -exec rm -rf {} +
    '';

  depsDrvs = lib.mapAttrs materialize deps // lib.mapAttrs (_: flatten) fromNixpkgs;

  # モノレポ内の workspace パッケージ。PyPI には無いので同じタグから組む。
  # - omnigent-client: omnigent 本体が `omnigent_client._http` などを import する
  # - omnigent-ui-sdk: TUI (REPL) のテーマ・状態管理
  buildWorkspacePackage =
    {
      pname,
      subdir,
      backend,
    }:
    buildPythonPackage {
      inherit pname version;
      src = "${src}/${subdir}";
      format = "pyproject";
      dontUsePypaBuildHook = true;
      buildPhase = ''
        runHook preBuild
        ${py.python.interpreter} -m build --wheel --no-isolation --skip-dependency-check --outdir dist .
        runHook postBuild
      '';
      nativeBuildInputs = [
        py.setuptools
        py.wheel
        py.build
      ]
      ++ backend;
      dontCheckRuntimeDeps = true;
      doCheck = false;
    };

  workspaceDrvs = {
    omnigent-client = buildWorkspacePackage {
      pname = "omnigent-client";
      subdir = "sdks/python-client";
      backend = [ py.hatchling ];
    };
    omnigent-ui-sdk = buildWorkspacePackage {
      pname = "omnigent-ui-sdk";
      subdir = "sdks/ui";
      backend = [ py.hatchling ];
    };
  };

  workspacePythonPath = map (d: "${d}/lib/python3.14/site-packages") (lib.attrValues workspaceDrvs);

  # `omni` は上流の entry point (`omnigent.cli:main`) を呼ぶ薄いラッパー。
  # 依存はすべて PYTHONPATH で渡す (`--prefix` 相当の動き) ので、
  # `python3.withPackages` の解法器は通さない (nixpkgs の巨大な Python 依存木を
  # 引き込まずに済む)。
  pythonPath = map (d: "${d}/site-packages") (lib.attrValues depsDrvs);

  pkg = buildPythonPackage {
    pname = "omnigent";
    inherit version src;

    # web UI はビルド済みのものを使い、Node.js でのビルドはスキップする。
    # wheel 化は `--no-isolation` で同梱の setuptools を使う。
    format = "pyproject";
    dontUsePypaBuildHook = true;
    buildPhase = ''
      runHook preBuild
      cp -a ${webUi}/omnigent/server/static/. omnigent/server/static/
      OMNIGENT_SKIP_WEB_UI=true ${py.python.interpreter} -m build --wheel --no-isolation \
        --skip-dependency-check --outdir dist .
      runHook postBuild
    '';

    nativeBuildInputs = with py; [
      setuptools
      wheel
      build
      packaging
      tomlkit
      pip
    ];

    # `omni` CLI からローカルサーバーへ Cloudflare Access のメールヘッダを
    # 届ける。上流の `_server_headers` は空 dict を返し、SDK クライアント
    # (`OmnigentClient`) は `databricks_request_headers` を通らない。そのため
    # `OMNIGENT_DATABRICKS_EXTRA_HEADERS` は CLI の主力経路 (セッション作成・
    # 参照・`omni run`) だけ落ち、ヘッダ認証を要求するサーバーでは 401 に
    # なる。上流の他の経路 (`_remote_headers`) と同じく、server_url を渡して
    # 同じヘルパを通す。
    patches = [ ./chat-server-headers.patch ];

    # opencode ネイティブハーネスは CLI の版を `>=1.17.7, <1.19.0` に縛って
    # いる。上流は 1.19 系を「イベント/API 形状を未検証」として弾いているだけ
    # で、`client.py` に定数として直書きされている。この構成の opencode は
    # llm-agents 由来で 1.19.x なので、そのままだと host 側の readiness 判定が False になり
    # `harness 'opencode-native' is not configured on host` で起動できない。
    # 上限だけ 1.20.0 に広げて 1.19 系を許し、実際の起動は都度確かめる。
    postPatch = ''
      substituteInPlace omnigent/harnesses/opencode_native/client.py \
        --replace-fail 'OPENCODE_MAX_VERSION_EXCLUSIVE = "1.19.0"' \
                       'OPENCODE_MAX_VERSION_EXCLUSIVE = "1.20.0"'
    '';

    # 依存はすべてここで配るので、PyPI のメタデータから依存を引き直さない。
    pythonRelaxDeps = [ ];
    dontCheckRuntimeDeps = true;

    doCheck = false;
    pythonImportsCheck = [ "omnigent" ];

    meta = {
      description = "Meta-harness for building, governing, and collaborating on AI agents";
      homepage = "https://omnigent.ai/";
      license = lib.licenses.asl20;
      mainProgram = "omni";
      platforms = lib.platforms.linux;
    };
  };
in
runCommand "omnigent-${version}"
  {
    nativeBuildInputs = [ makeWrapper ];
    passthru = {
      inherit pythonPath;
      pythonModule = py.python;
    };
    meta = pkg.meta;
    # 依存の C 拡張は `python314Packages` (ABI タグ cp314) 向けにビルドされて
    # いるので、実行系も同じインタプリタを使う。
    buildInputs = [
      python314
      pkg
    ];
  }
  ''
    mkdir -p $out/bin $out/lib/python3.14/site-packages
    # 上流 wheel の中身 (omnigent/, dist-info) を置く。
    cp -a ${pkg}/lib/python3.14/site-packages/. $out/lib/python3.14/site-packages/
    chmod -R u+w $out/lib
    # PYTHONPATH は「自分 + workspace パッケージ + 依存」。依存側の
    # `PYTHONPATH` (withPackages 由来の前後付) に負けないよう `--set` で固定する。
    omniPythonPath="$out/lib/python3.14/site-packages:${lib.concatStringsSep ":" workspacePythonPath}:${lib.concatStringsSep ":" pythonPath}"

    # `sys.executable` 経由で子プロセスを起こす箇所がある。MCP ブリッジが
    # その代表で、`python -I -m omnigent.harnesses.claude_native.bridge` と
    # **`-I` 付き** で起動される。`-I` は PYTHONPATH も sitecustomize も無視する
    # ので、そのままでは `ModuleNotFoundError: No module named 'omnigent'` で
    # ACP の session/new が落ちる (claude 系とすべての `acp:` ハーネスが影響を
    # 受ける)。
    #
    # 対処として、`-I` でも効く `python3.14._pth` を持つ実行ファイルを作り、
    # `omni` はそれを経由して動かす。こうすると `sys.executable` がこの
    # ラッパーになり、子プロセスにもパスが引き継がれる。`_pth` があると
    # sys.path はそのファイルの列挙だけで決まるので、stdlib と拡張モジュール
    # (`lib-dynload`。これが無いと hashlib/_ssl が壊れる) も明示する。
    mkdir -p $out/libexec
    ln -s ${python314.interpreter} $out/libexec/python3.14
    {
      echo "${python314}/lib/python3.14/lib-dynload"
      echo "${python314}/lib/python3.14"
      tr ':' '\n' <<< "$omniPythonPath"
    } > $out/libexec/python3.14._pth

    # `omni` は薄いシェルラッパー。鍵 (OMNIROUTE_API_KEY) を設定ファイルに
    # 書かず env 参照 (`env:OMNIROUTE_API_KEY`) で読むため、sops が復号した
    # `omniroute.env` を「未設定のときだけ」読み込んでから本体を起動する。
    # ホストデーモンは起動元シェルの環境を丸ごとは引き継がないので、これが
    # 無いとシェル以外から起動したときに鍵が解決できない。ランナーまで
    # 名前を転送するため OMNIGENT_RUNNER_ENV_PASSTHROUGH にも載せる。
    makeWrapper $out/libexec/python3.14 $out/bin/omni \
      --add-flags "-m omnigent" \
      --set PYTHONPATH "$omniPythonPath"
    ln -s omni $out/bin/omnigent

    # Omnigent のシークレットストア (`keychain:<name>` 参照の実体) に値を
    # 書き込む CLI。activation が sops の env ファイルから鍵を流し込む。
    cat > $out/bin/omni-secret <<EOF
    #!${python314.interpreter} -I
    import sys

    sys.path[:0] = "$out/lib/python3.14/site-packages:${lib.concatStringsSep ":" workspacePythonPath}:${lib.concatStringsSep ":" pythonPath}".split(":")

    from omnigent.onboarding import secrets

    if len(sys.argv) != 3:
        sys.exit("usage: omni-secret NAME VALUE")

    secrets.store_secret(sys.argv[1], sys.argv[2])
    EOF
    chmod +x $out/bin/omni-secret


    # `~/.omnigent/config.yaml` の宣言部分 (`server` と `providers.omniroute`)
    # を書き直す CLI。Omnigent が追記するキー (host_id など) はそのまま残す。
    # activation から呼ぶ。
    cat > $out/bin/omni-config <<EOF
    #!${python314.interpreter} -I
    import json
    import os
    import sys

    sys.path[:0] = "$out/lib/python3.14/site-packages:${lib.concatStringsSep ":" workspacePythonPath}:${lib.concatStringsSep ":" pythonPath}".split(":")

    import yaml

    if len(sys.argv) != 6:
        sys.exit("usage: omni-config CONFIG PORT BASE_URL MODEL ACP_AGENTS_JSON")

    path, port, base_url, model, acp_json = sys.argv[1:6]
    acp_agents = json.loads(acp_json)

    try:
        with open(path) as f:
            cfg = yaml.safe_load(f) or {}
    except FileNotFoundError:
        cfg = {}
    if not isinstance(cfg, dict):
        cfg = {}

    cfg["server"] = f"http://127.0.0.1:{port}"

    # OmniRoute の /v1 を OpenAI 互換プロバイダとして登録する。鍵は設定
    # ファイルに書かず、Omnigent 自身のシークレットストアから読む
    # (`keychain:omniroute` 参照)。`env:` 参照は、CLI が `--server` で
    # リモート扱いのデーモンを立てたときに鍵が届かず解決に失敗するため使わない。
    providers = cfg.setdefault("providers", {})
    entry = providers.setdefault("omniroute", {})
    entry["kind"] = "gateway"
    entry["default"] = True
    entry["openai"] = {
        "base_url": base_url,
        "api_key_ref": "keychain:omniroute",
        "models": {"default": model},
        # OmniRoute は Chat Completions と Responses の両方を受ける
        # (`/v1/chat/completions` と `/v1/responses`)。codex ハーネスは
        # Responses 固定なので、両対応のこちらを宣言する。claude / pi は
        # wire_api に依存しないので、切り替えても影響しない。
        "wire_api": "responses",
    }
    for other, body in providers.items():
        if other != "omniroute" and isinstance(body, dict):
            body.pop("default", None)

    # ACP エージェント。omnigent は `acp.agents` の各行を slug 化した名前で
    # `--harness acp:<slug>` として引く。上流の acp_agents_settings() と同じ
    # 形に合わせ、既定値 (falsy) は省く。
    agents = []
    for a in acp_agents:
        item = {"name": a["name"], "command": a["command"]}
        if a.get("model"):
            item["model"] = a["model"]
        if a.get("inject_system_prompt") is False:
            item["inject_system_prompt"] = False
        if a.get("env_passthrough"):
            item["env_passthrough"] = list(a["env_passthrough"])
        agents.append(item)
    acp = cfg.get("acp")
    if not isinstance(acp, dict):
        acp = {}
        cfg["acp"] = acp
    acp["agents"] = agents

    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        yaml.safe_dump(cfg, f, default_flow_style=False, sort_keys=True, allow_unicode=True)
    os.chmod(tmp, 0o600)
    os.replace(tmp, path)
    EOF
    chmod +x $out/bin/omni-config
  ''
