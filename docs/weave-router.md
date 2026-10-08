# weave-os router

ローカルで動く LLM モデルルーター。クライアント (Claude Code / pi など) は
`http://127.0.0.1:18080` を指し、ルーターがリクエストごとに実行モデルを決めて
上流へ転送する。

- 上流: [weave-os/router](https://github.com/weave-os/router) (flake 入力
  `weave-router`、タグ `router-v0.2.28` にピン留め)
- 常駐: `weave-os.nix` が定義する systemd ユーザーユニット `weave-os.service`
  (docker compose: postgres + pubsub エミュレータ + server)
- 上流プロバイダ: OpenCode Go (`secrets/weave-os.env` の `OPENROUTER_*`)

## 起動 / 確認

```sh
systemctl --user status weave-os.service
curl -s http://127.0.0.1:18080/health    # {"status":"ok"}
curl -s http://127.0.0.1:18080/readyz    # {"status":"ok"}
```

**異常時の挙動 (検証済み)** — サーバ・postgres・pubsub-emulator のいずれも
クラッシュ (プロセス強制終了) で **1〜3秒に自動復帰**する
(`restart: unless-stopped`。postgres はボリューム `weave-os_router_postgres_data`
にデータが残るためキー等も無傷)。一方 `docker stop` / `docker kill` で**手動**停止
した場合はポリシーが効かず**復帰しない** (service は "active" のままなので
見かけ上の稼働になる)。手動で止めたときは
`systemctl --user restart weave-os.service` で戻すこと。
コンテナの docker ログは `json-file` で **10m×3ファイルに回転**する
(無制限に増えない)。

ログは `journalctl --user -u weave-os.service` と
`docker logs weave-os-server-1` (リクエストごとの `decision_model` /
`decision_reason` が入る)。non-stream 応答には `X-Router-Cost-Usd` などの
コスト/決定ヘッダも付く。

## ルーターキー (rk_...)

`~/.local/share/weave-os/seed.sh` を実行すると新しい `rk_...` キーを発行して
**一度だけ**表示する (発行は冪等ではなく、DB にキーが増える)。

```sh
~/.local/share/weave-os/seed.sh
```

疎通確認:

```sh
curl -s -H 'Authorization: Bearer rk_...' http://127.0.0.1:18080/validate
```

## 配線済みのクライアント

### Claude Code

`npx @weave-os/router --claude --base-url http://127.0.0.1:18080` で配線済み。
`~/.claude/settings.json` に以下が入っている。

- `env.ANTHROPIC_BASE_URL = http://127.0.0.1:18080`
- `env.ANTHROPIC_CUSTOM_HEADERS` に `X-Weave-Router-Key: rk_...`
- `~/.claude/commands/` に `/router-status` `/router-off` `/router-on`
  `/force-model` (`/fm`) `/router-models` などのスラッシュコマンド

Claude のプラン認証はそのままクライアント側に残っているので、ルーターが
Anthropic を選んだときはプランの利用枠がそのまま使われる。既存の
ステータスライン (`~/.claude/statusline.sh`) はインストーラが自動で守るが、
**`attribution` (commit/PR クレジット) は install / update のたびに Weave Router
付きへ書き換わる**ので、空にしたい場合は毎回あとで空へ戻す必要がある
(`update --claude` で確認済み・非冪等)。env (base URL / ヘッダ) は冪等。

### pi

`npx @weave-os/router --pi --base-url http://127.0.0.1:18080` で配線済み。

- `~/.pi/agent/models.json` に `weave` プロバイダ (Anthropic Messages 形式)
- `~/.pi/agent/settings.json` で `defaultProvider: "weave"`,
  `defaultModel: "claude-haiku-4-5"` (拡張機能が登録するモデル ID に必須)
- `~/.pi/agent/.weave_router_key` にルーターキー
- 拡張機能 `npm:@weave-os/router` (Loom 表示、`/fm`、subagent dispatch 等)

pi の昇格ハンドオフ (`POST /v1/route/handoff`) は
`ROUTER_PI_HANDOFF_SECRET` (≥32 bytes、`secrets/weave-os.env`) が無いと 503
になる。設定無いと pi はリクエストを中断するので注意。

### jcode

`jcode login --provider openai-compatible` で配線済み (2026-10-08)。**jcode の
デフォルトプロバイダ**になっている。

- `~/.config/jcode/openai-compatible.env` に base URL
  (`JCODE_OPENAI_COMPAT_API_BASE=http://127.0.0.1:18080/v1`) とルーターキー
- `~/.jcode/config.toml` の `[provider]` で
  `default_provider = "openai-compatible"`, `default_model = "auto"`
- ログイン時の検証 (`provider_smoke`) は **失敗するが正常**: ルーターの
  `/v1/models` がルーターキー (Bearer) を拒否して x-api-key を要求するため
  モデル一覧が取得できないだけ。推論 (`/v1/chat/completions`) は正常に
  動作し、`auto` 指定でリクエストごとのモデル選択が効く (検証済み)
- 直結 (OpenCode Go) に戻す場合は `default_provider` を `opencode-go` へ
  戻すか、セッション内で `/model` で切り替える
- jcode は Anthropic 資格を持たないので、OpenCode Go が落ちると
  Anthropic ベースラインフェイルオフは効かずエラーになる

## 未配線のクライアント (任意)

いずれも有効化するか切り離すかは自由。無効化は
`npx @weave-os/router off --<target>` / `--uninstall --<target>`。

```sh
# Codex (既定では home.nix の方針どおりプロバイダを pin しないので未配線)
npx @weave-os/router --codex --base-url http://127.0.0.1:18080

# opencode (インストーラは v2 必須。この環境は v1 なので未配線)
npx @weave-os/router --opencode --base-url http://127.0.0.1:18080
```

## ルーター側のローカル設定 (`weave-os.nix`)

1. **ソースパッチ (x-opencode-session 注入)**
   `OPENROUTER_BASE_URL` は OpenCode Go (`https://opencode.ai/zen/go/v1`) を
   指すが、このエンドポイントは `x-opencode-session` の無いリクエストを
   1件も通さない。ルーターは受信ヘッダを上流へ転送しないため、
   `internal/providers/openaicompat/client.go` に注入処理を当てている。
   置換は `--replace-fail` なのでタグを上げるとビルドが落ち、パッチの再確認
   を促す。

2. **`ROUTER_MODEL_ID_MAP`**
   カタログ ID (`deepseek/deepseek-v4-flash` 等) を OpenCode Go の ID
   (`deepseek-v4-flash`) へ書き換える。無しでは upstream が
   `Model is unavailable` で400を返す。

3. **`ROUTER_EXCLUDED_MODELS`**
   OpenRouter 紐付けのうち OpenCode Go が持たないモデル、および
   chat/completions 非対応の `minimax/minimax-m2.7` を除外。無しでは
   スコアラーがこれらを選び400で落ちる。対象はタグ更新時に
   `internal/router/catalog/catalog.go` と
   `https://opencode.ai/zen/go/v1/models` の突き合わせで見直すこと。
   (効き目はリクエスト時に確認するしかない: 除外モデルへの `x-weave-force-model`
   は400で拒否される。`npx @weave-os/router models --claude` の一覧は
   selfhosted では除外を反映せず「ルーターが扱える全モデル」を出すだけ。)

4. **Anthropic ベースラインフェイルオフの認証ゲート**
   ルーティング先 (OpenCode Go) が失敗すると、ルーターは要求モデルを
   Anthropic で再試行する。リクエスト元が Anthropic の資格情報を持っていない
   クライアント (pi / jcode 等) では、その再試行がルーターキーを x-api-key
   として上流へ渡し、401 がそのまま返って本来のエラーも隠れる。
   `internal/proxy/service.go` の `baselineViable` に
   「Anthropic へ出せる資格情報が在る」条件を足してある。Claude Code は
   OAuth 資格を持つので従来どおりフォールバックできる。

5. **`WV_CAPTURE_CONTENT=hashed`** (原因調査時だけ入れる一時設定)
   上流エラーの本文 (`body_preview`) をログに出すための設定。`hashed` でも
   `... start` 系ログ行の `prompt_preview` に先頭約200文字が入るので、
   調査が終わったら設定を削除して `off` に戻すこと (container 再作成で
   これまでのログも捨てられる)。調査に使った手順は下の節を参照。

## 既知の問題: Claude Code の Threads とルーターの衝突

**症状** — Claude Code をルーター経由で使うと、まれに Anthropic 上流から
400 / 404 が返る (2026-10-08 の約90分で6件、うち2件は Claude Code 側に
「selected model ... may not exist」という合成エラーとして表示)。以降のターンは
続行できる (再試行で通る)。

**原因 (WV_CAPTURE_CONTENT=hashed で本文を取得して特定)** — Claude Code は
Anthropic の **Threads** 機能 (`previous_message_id`) を使うが、ルーターは
ターンごとに `model` / `system` / `thinking` / `anthropic-beta` /
`cache_control` を書き換える (モデル選択・planner のスイッチ・beta の自動付与)。
結果、Anthropic 側のスレッド指紋と一致しなくなり:

```json
{"type":"invalid_request_error","message":"thread: the request does not match
the stored Thread for the requested `previous_message_id`; differing field(s):
anthropic-beta, cache_control, ..., model, ..., system, thinking. ...",
 "details":{"error_code":"thread_fingerprint_mismatch"}}
```

`previous_message_id` が参照するスレッドが無い場合は404で返る。
ルーター v0.2.28 には Threads 概念自体が無い (`previous_message_id` の参照ゼロ)
ので、設定では解消できない。当方のパッチ (OpenCode Go 経路・フェイルオフの
ゲート) は Anthropic 経路に触れていない。

**影響範囲** — 対話セッションの一部ターンのみ。単発の `claude -p` では発生しない
(スレッドが作られないため)。pi / OpenCode Go 経路は無関係。

**回避** — 影響が大きいときは Claude Code の配線を切り外す (設定は残る):

```sh
npx @weave-os/router off --claude    # Claude Code を直結に戻す
npx @weave-os/router on --claude     # 再開
```

上流で Threads 対応が入ったらタグを上げてパッチ4つを再確認すると解消見込み。

設定変更後はイメージ再ビルドと再起動が必要:

```sh
ln -sfn "$(nix build --no-link --print-out-paths \
  '.#homeConfigurations."Home".config.home.file.".local/share/weave-os/docker-compose.yml".source')" \
  ~/.local/share/weave-os/docker-compose.yml   # home-manager switch でも同じ結果
DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock \
  docker compose -f ~/.local/share/weave-os/docker-compose.yml build server
systemctl --user restart weave-os.service
```

## 動作確認 (curl)

```sh
K=rk_...
# OpenAI 形式
curl -s http://127.0.0.1:18080/v1/chat/completions \
  -H "Authorization: Bearer $K" -H 'content-type: application/json' \
  -d '{"model":"auto","messages":[{"role":"user","content":"ping"}]}'
# Anthropic 形式
curl -s http://127.0.0.1:18080/v1/messages \
  -H "x-api-key: $K" -H 'anthropic-version: 2023-06-01' \
  -H 'content-type: application/json' \
  -d '{"model":"auto","max_tokens":32,"messages":[{"role":"user","content":"ping"}]}'
# ルーティング判断だけ見る
curl -s http://127.0.0.1:18080/v1/route \
  -H "Authorization: Bearer $K" -H 'content-type: application/json' \
  -d '{"model":"auto","messages":[{"role":"user","content":"fix the test"}]}'
```
