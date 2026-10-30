# Omnigent の NixOS 常駐構成

Omnigent (<https://omnigent.ai/>) は複数のコーディングエージェント (Claude Code
/ Codex / Pi など) を 1 つのサーバーと Web UI で扱う
メタハーネスである。このリポジトリでは Python パッケージ (`omnigent` 0.19.1) を
Nix でビルドし、systemd user unit として常駐させる。

- パッケージ: `pkgs/omnigent/`
- home-manager モジュール: `omnigent.nix`(`home.nix` から import)
- flake の overlay: `flake.nix` の `omnigent`(home-manager 用の `pkgs`
  にだけ入れる)

## 待ち受けポート

**14197**(`127.0.0.1` のみ)。

14159 番は TCP のプロセス回収ポートとして予約されているので、その帯だけを
避け、アプリ名のアルファベット順位を下 2 桁に埋めた専用番号にした (`OMNIG` の
G=7)。`dsh-web` の 14198 と同じ命名則である。一般的な Web 開発 ポート (3000 /
4200 / 5173 / 8000 / 8080 …) とは重ならない。

TCP のポートは 65535 までなので、桁数を増やす方向の「専用化」(6 桁の番号)
はできない。

上流の `omni server` の既定は 6767 番なので、ユニット定義では必ず `--port`
を渡している。環境変数 `PORT` も同じ値を設定する。

## 構成要素

| 種別              | パス                                     | 役割                                                               |
| ----------------- | ---------------------------------------- | ------------------------------------------------------------------ |
| systemd user unit | `omnigent.service`                       | `omni server --host 127.0.0.1 --port 14197`                        |
| 設定              | `~/.omnigent/config.yaml`                | 接続先 URL、`providers.omniroute`、`acp.agents`(activation が書く) |
| 状態              | `~/.local/share/omnigent`                | SQLite(`chat.db`)、artifacts、logs                                 |
| 秘密              | `/run/user/1000/omniroute.env`           | sops の `omniroute`(`OMNIROUTE_API_KEY`)                           |
| 鍵ストア          | `~/.omnigent/secrets.json`               | activation が sops から流し込む (0600, `keychain:omniroute`)       |
| トンネル unit     | `cloudflared-omnigent.service`           | `omnigent.comamoca.dev` → `http://127.0.0.1:14197`                 |
| トンネル秘密      | `~/.config/cloudflared/omnigent-token`   | sops の `omnigent-cloudflared-token`(0600)                         |
| CLI ラッパー      | `~/.nix-profile/bin/omni`(`makeWrapper`) | `OMNIGENT_DATABRICKS_EXTRA_HEADERS`(Access ヘッダ)を起動時に注入   |

`~/.omnigent/config.yaml` は Omnigent 自身も書き換える (host の `host_id` /
`name` を追記する)。Nix ストアへの symlink にすると
`OSError: [Errno 30] Read-only file system` で host デーモンが落ちるため、
activation スクリプトが実体ファイルとして作り、宣言部分 (`server` / `providers`
/ `acp.agents`) だけを書き直す。`omni config set` が足したキーは残る。

`omnigent.service` は `omniroute.service` の後に起動する。`X-SwitchMethod` は
`keep-old` なので、`home-manager switch` しても稼働中のサーバーは
落ちない(次回起動時に新しい定義が効く)。

## LLM プロバイダ

プロバイダは OmniRoute(<http://127.0.0.1:20128/v1>)だけを使い、既定モデルを
`static-thrifty` にする。OmniRoute 側の combo が実体モデルを割り当てるので、
Omnigent 側でモデルを増やす操作はしない。

- `providers.omniroute`(`config.yaml`): `kind: gateway`、`default: true`、
  `base_url` は OmniRoute の `/v1`、`api_key_ref: keychain:omniroute`、
  既定モデル `static-thrifty`、`wire_api: responses`
- `OPENAI_BASE_URL` / `OPENAI_API_KEY`: ユニットの `Environment` で
  `OPENAI_BASE_URL` を設定し、`OPENAI_API_KEY` を `${OMNIROUTE_API_KEY}` に
  展開する。鍵そのものは `EnvironmentFile`(sops の `omniroute`)だけに置き、 Nix
  のストアや generation には書かない
- `OMNIGENT_MODEL`: `static-thrifty`

鍵は `config.yaml` に書かない。`keychain:omniroute` 参照で Omnigent 自身の
シークレットストアから読み、その実体は `~/.omnigent/secrets.json`
(0600、`OMNIGENT_DISABLE_KEYRING=1` で keyring を使わずファイルに固定) に置く。
activation が sops の `/run/user/1000/omniroute.env` から
`omni-secret omniroute` で流し込む。

環境変数参照 (`api_key_ref: env:...`) を使わないのは、CLI が `--server` を
指定してホストデーモンを立てるとき、そのデーモンが「リモート扱い」になり
プロバイダの鍵を環境から受け取らないためである。`keychain:` 参照なら
ランナーが自分でストアを読めるので、サーバーとランナーのどちらでも解決できる。

`OPENAI_*` を設定しているので、OpenAI 互換のクライアントを使うハーネス (Codex /
openai-agents) は同じ上流を継承する。Anthropic 系のハーネス
(`claude-sdk`)を使う場合は、OmniRoute の `/v1` を指す `ANTHROPIC_BASE_URL` と
`ANTHROPIC_AUTH_TOKEN` をユニットの `Environment` に足す。

## ハーネス

Omnigent から起動するエージェントは次の 7 つで、`omni run --harness <名前>` で
選ぶ。

| ハーネス         | `--harness`            | 経路             | 実体                   |
| ---------------- | ---------------------- | ---------------- | ---------------------- |
| Claude Code      | `claude`               | ネイティブ       | `claude` CLI           |
| Codex            | `codex`                | ネイティブ       | `codex` CLI            |
| OpenCode         | `opencode`             | ネイティブ       | `opencode` CLI(1.19.4) |
| DeepSeek Harness | `acp:deepseek-harness` | ユーザー ACP     | `dsh --profile acp`    |
| jcode            | `acp:jcode`            | ユーザー ACP     | `jcode acp`            |
| pi               | `pi` / `acp:pi`        | ネイティブ / ACP | `pi` CLI / `pi-acp`    |
| oh-my-pi         | `acp:oh-my-pi`         | ユーザー ACP     | `omp acp`              |

ネイティブ 4 種は各自の CLI のログイン状態をそのまま使うので、Omnigent 側での
追加設定は要らない。ACP 側は `omnigent.nix` の `acpAgents` で宣言し、 activation
が `~/.omnigent/config.yaml` の `acp.agents` に書き込む。

ACP エージェントの起動環境は既定でほぼ空なので、鍵が要るものは `env_passthrough`
に `OMNIROUTE_API_KEY` を挙げる。pi (`pi-acp`) は `~/.pi/agent/models.json` の
`apiKey` コマンドが自分で `omniroute.env` を読む ため不要。jcode も
`~/.jcode/config.toml` の `env_file` で自前で読む。

`command` は絶対パスで書く。ユニットの `PATH` に `~/.bin` / `~/.bun/bin` /
`~/.local/bin` は入っていないため、`omp` や `pi-acp`
を裸名で書くと見つからない。

上流の組み込み ACP 行 (`acp:jcode`) はこの構成では runner から解決できず
`ACP agent 'jcode' is not configured on this runner` になった。そのため
`acpAgents` に明示的な行を足して上書きしている。

### OpenCode のバージョン上限

上流 0.19.1 は OpenCode を `>=1.17.7, <1.19.0` に縛っている
(`omnigent/harnesses/opencode_native/client.py`)。この構成の opencode は
`llm-agents` 由来の 1.19.4 なので、そのままだと readiness 判定が False になり
`harness 'opencode-native' is not configured on host` で起動できない。
`default.nix` の `postPatch` で上限を `1.20.0` に広げている。

### MCP 中継と `-I`

ACP エージェントには Omnigent の MCP サーバーが
`python -I -m omnigent.harnesses.claude_native.bridge serve-mcp`
の形で渡される。 `-I` は `PYTHONPATH` を無視し `sitecustomize`
も読まないので、Nix で `PYTHONPATH` に依存を並べるだけの構成では
`ModuleNotFoundError: No module named
'omnigent'` で落ちる。

対策として `$out/libexec/python3.14`(stdlib への symlink)と、その隣に
`python3.14._pth` を置き、`lib-dynload` / stdlib / 全依存パスを列挙している。
`lib-dynload` を先頭に書かないと `hashlib`(`unsupported hash type shake_256`)や
`_ssl` の import が壊れる。`$out/bin/omni` はこのバイナリをラップするので、
`sys.executable` が `_pth` を持つパスになり、子プロセスの `-I` 起動でも依存が
解決できる。

### 鍵の供給

鍵の正本は sops の `omniroute`(`/run/user/1000/omniroute.env`)だけである。

- `omnigent.service`: `EnvironmentFile` で読み、`OPENAI_API_KEY` /
  `OMNIGENT_OMNIROUTE_API_KEY` を `${OMNIROUTE_API_KEY}` に展開する
- `omni` ラッパー: 環境に鍵が無ければ `omniroute.env`
  から読んでから本体を起動する
- `~/.omnigent/secrets.json`: activation が同じファイルから
  `omni-secret
  omniroute` で流し込み、`api_key_ref: keychain:omniroute`
  がこれを引く

ストアの鍵名は `keychain:omniroute` の `omniroute` と一致させる必要がある。
以前は `omnigent` という名前で書いていたため、Codex / pi が
`could not read secret 'omniroute'` で落ちていた。

## パッケージの組み立て

`pkgs/omnigent/default.nix` は上流タグ `v0.19.1` の `uv.lock` を基に、 既定依存
82 個のバージョンと URL を `deps.nix` に固定している。nixpkgs の
`python314Packages` に同じ名前があっても使わない。nixpkgs 側の更新で omnigent
が壊れるのを避けるためである。例外は `cryptography` で、Rust の `cargo vendor`
解決が重いため nixpkgs のビルド済みパッケージを使う (`site-packages`
の配置だけ揃える)。

- CPython 3.14 の manylinux wheel がある依存は、wheel を展開して
  `site-packages/` に置く。`cp314t`(free-threaded)用の wheel しか無いものは
  sdist からビルドする(`psutil`, `argon2-cffi-bindings`)。実行系は free-threaded
  でない `python314` に揃える。
- 無い依存は PyPI の sdist から `python -m build --no-isolation` で wheel
  を作る。 C 拡張を含むもの(`protobuf`, `psutil`, `argon2-cffi-bindings`)だけは
  `stdenv.cc` を足す。
- ビルドバックエンド(setuptools / hatchling / flit-core / poetry-core /
  pdm-backend)は nixpkgs の Python 3.14 パッケージから供給する。割り当ては
  `default.nix` の `backends` attrset にある。
- omnigent 本体と `omnigent-client` / `omnigent-ui-sdk`(モノレポ内の workspace
  パッケージ、PyPI には無い)は、上流タグのソースから組み立てる。
- Web UI はソースからのビルドに Node.js と pnpm が要るので、PyPI sdist に
  同梱されたビルド済み資産を `omnigent/server/static` に重ね、
  `OMNIGENT_SKIP_WEB_UI=true` で wheel を作る。
- `omni` は `python -m omnigent` を呼ぶラッパーで、`PYTHONPATH` に 自分 +
  workspace パッケージ + 依存を並べる。`python3.withPackages` の
  解法器は通さない(nixpkgs の Python 依存木を引き込まないため)。
- 実行ファイルは 3 段構えである。`$out/bin/omni-bin` が
  `$out/libexec/python3.14`(`_pth` 付き)をラップし、`$out/bin/omni` がその前に
  `omniroute.env` から鍵を読むシェルスクリプトとして挟まる。MCP 中継の `-I`
  起動を成立させるには前者が、端末起動時の鍵解決には後者が要る。さらに
  `omnigent.nix` が `makeWrapper` で包んだ `omnigent-cli` が
  `~/.nix-profile/bin/omni` に入り、認証ヘッダの環境変数を足す(「認証」の節)。

### 上流へのパッチ

`pkgs/omnigent/` は上流に 2 か所の手当てをしている。どちらもバージョンを上げた
ときに当たり直すので、`default.nix` のコメントと合わせて確認する。

- `chat-server-headers.patch`: `_server_headers` に `server_url` を渡し、
  `cli_auth.databricks_request_headers` の結果を返すようにする。上流は空 dict を
  返していたため、`OmnigentClient` を使う経路 (セッション作成・参照・`omni run`)
  だけ `OMNIGENT_DATABRICKS_EXTRA_HEADERS` が乗らず、ヘッダ認証のサーバーで
  `401 Unauthorized` になっていた (詳細は「認証」の節)。
- `postPatch` の `substituteInPlace`: opencode ネイティブハーネスが `client.py`
  に直書きしている CLI 版の上限 `1.19.0` を `1.20.0` に広げる。 この構成の
  opencode は 1.19 系で、上限のままだと host の readiness 判定が False になり
  `harness 'opencode-native' is not configured on host` で起動できない。

依存を更新するときは次の 3 つを揃えて書き換える。

1. `default.nix` の `version`、`src`(GitHub タグ)、`sdist`(Web UI 用)
2. `deps.nix` の全エントリ
3. `backends` / `cExtensions` / `fromNixpkgs` の割り当て(新しい依存を足したとき)

## 操作

```sh
# 状態とログ
systemctl --user status omnigent.service
journalctl --user -u omnigent.service -f

# 再起動 (設定変更やパッケージ更新の後)
systemctl --user restart omnigent.service

# 到達確認
curl -sS http://127.0.0.1:14197/ | head
```

CLI(`omni`)は `~/.omnigent/config.yaml` の `server` を見て既存のサーバーに
接続する。`omni server` を CLI から直接起動するとポートの取り合いになるので、
常駐させたいときは systemd 側を再起動する。

## 認証

待ち受けはループバックのみ。サーバーは `OMNIGENT_AUTH_PROVIDER=header` と
`OMNIGENT_AUTH_HEADER=Cf-Access-Authenticated-User-Email` で起動しており、その
ヘッダの値を利用者 ID として扱う。`omnigent.nix` の `localUserId` には Access
アプリが許可しているメールアドレスを置いてある。ヘッダの値は検証されないので、
この信頼は「`127.0.0.1` にしか開いておらず、到達経路が Cloudflare Tunnel だけ」
(systemd の待ち受け + `cloudflared-omnigent`)であることに依存する。
トンネルを開けている間は、Access を通ったリクエストに Cloudflare がこの
ヘッダを付ける。

Access を通らないローカルの `omni` CLI は、このヘッダを自分で送らないと `401`
になる。`omnigent.nix` は `makeWrapper` で `omni` を包み、起動時に
`OMNIGENT_DATABRICKS_EXTRA_HEADERS`(JSON オブジェクト)へ同じヘッダを入れる。
`cli_auth.databricks_request_headers` がこれをリクエストに折り込む。

この値は `home.sessionVariables` ではなくラッパーが持つ。home-manager は
`export NAME="VALUE"` を素で書き出すので JSON の `"` がシェルの引用符として
食われ、`{Cf-...:...}` という壊れた値が残る。上流の `_databricks_extra_headers`
は壊れた JSON を例外にせず黙って `{}` に落とす。 そのため CLI からは原因不明の
`401` に見える。`makeWrapper` は値を単一引用符で 囲むので、bash / fish /
非対話シェルのどれから起動しても JSON がそのまま渡る。
ホストデーモンとランナーは `omni` から起動されて env を引き継ぎ、
`host/connect.py` の allowlist がこの名前を通すので、ランナーのトンネルも同じ
ヘッダを載せる。

ただし上流の `_server_headers` はこの値を読まずに空 dict を返していた。そのため
`databricks_request_headers` を通る経路だけが認証に成功し、SDK クライアント
(`OmnigentClient`)を使う `omni run` などの主要経路は `401 Unauthorized` で
落ちていた。`chat-server-headers.patch` がこの差を埋めている
(「上流へのパッチ」の節)。

確認は次の 2 つで行う。どちらも `OK` が返れば認証は通っている。

```sh
omni run --harness claude-sdk -p 'Reply with exactly OK.'
omni run --harness codex -p 'Reply with exactly OK.'
```

`codex` ハーネスは Responses API 固定なので、`providers.omniroute` の `wire_api`
は `responses` のままにする(上流は `chat` を指定すると
`requires an OpenAI Responses API endpoint` で即座に落ちる)。

外部に出す場合は OmniRoute と同じく Cloudflare Tunnel と Access で前段を守る。
このリポジトリでは `cloudflared-omnigent.service` が `omnigent.comamoca.dev` を
`127.0.0.1:14197` に繋ぎ、ingress と Access の ポリシーは Cloudflare
側で設定する。

### DNS レコード

ingress と Access が Cloudflare 側に残っていても、DNS レコードが無いと
`omnigent.comamoca.dev` は解決できない。ブラウザでは「サーバーが見つかりません」
になり、`curl` は `Could not resolve host` で落ちる。

必要なのは `<tunnel-id>.cfargotunnel.com` への proxied CNAME 1 本だけで、
このトンネルの id は `af3ac346-6175-4e95-a6f9-e6ef582a9320`(トンネルトークンの
`t`)。レコードが消えていたら Cloudflare の DNS で作り直すと、トンネルや
Access の設定を触らずに復旧する。

修正直後は手元のリゾルバが NXDOMAIN を SOA の 1800 秒ぶんキャッシュして
いるため、最大 30 分は解決に失敗し続ける。このキャッシュは NextDNS の
デバイス単位のもので、`tailscaled` を再起動しても消えない(2026-10-30 に
再起動して、`100.100.100.100` が依然 NXDOMAIN を返すことを確認)。
キャッシュを待たずに反映を確かめるなら、`/resolve` はキャッシュを通らない
のでこちらを使う。

```sh
curl -sS -H 'accept: application/dns-json' \
  'https://dns.nextdns.io/f23b72/resolve?name=omnigent.comamoca.dev&type=A'
```

`Status: 0` と Cloudflare の A レコードが返れば直っている。同じ NextDNS でも
デバイス指定なしの `?name=...&type=A` は別のキャッシュを見るため、こちらが
`Status: 0` を返していても端末側はまだ NXDOMAIN のことがある。端末側の
最終確認は `getent hosts omnigent.comamoca.dev` で行う。

### ACP エージェントの起動

`omni run` の位置引数はエージェント YAML かディレクトリで、ハーネス名は
`--harness` に渡す。`omni run jcode` は `Agent path not found: jcode`、
`omni jcode` は `No such command: 'jcode'` で落ちる。正しくは次のどちらか。

```sh
omni run --harness acp:jcode -p 'Reply with just: OK'   # CLI
omni run --server http://127.0.0.1:14197                # ピッカーから選ぶ
```

`--server local` は「ローカルにサーバーを起動する」指定なので、稼働中の
サーバー(`omnigent.service`)に繋ぎたいときは URL をそのまま渡す。この形で
引数なしにすると、サーバーが持つエージェントのピッカーが出る。

`--harness` のヘルプ一覧には ACP 行が載っていないが、`acp:<name>` は
`acp.agents` の宣言をそのまま引くので指定できる。Web UI の新規セッション
ピッカーでは `acp-jcode` という名前で出る。

ヘッダ認証のため、ブラウザで `127.0.0.1:14197` を直接開くと `401` になる。
ローカルの UI を見たい場合も `https://omnigent.comamoca.dev`(Access 通過後)
を使う。
