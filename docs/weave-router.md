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

ログは `journalctl --user -u weave-os.service` と
`docker logs weave-os-server-1` (リクエストごとの `decision_model` /
`decision_reason` が入る)。

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
ステータスライン (`~/.claude/statusline.sh`) と `attribution` (空) は
インストーラが上書きしない/した後に元に戻してある。

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

## 未配線のクライアント (任意)

いずれも有効化するか切り離すかは自由。無効化は
`npx @weave-os/router off --<target>` / `--uninstall --<target>`。

```sh
# Codex (既定では home.nix の方針どおりプロバイダを pin しないので未配線)
npx @weave-os/router --codex --base-url http://127.0.0.1:18080

# opencode (インストーラは v2 必須。この環境は v1 なので未配線)
npx @weave-os/router --opencode --base-url http://127.0.0.1:18080

# jcode (OpenAI 互換プロバイダとして追加)
jcode login --provider openai-compatible
#   base URL: http://127.0.0.1:18080/v1
#   API key : rk_...
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

4. **Anthropic ベースラインフェイルオフの認証ゲート**
   ルーティング先 (OpenCode Go) が失敗すると、ルーターは要求モデルを
   Anthropic で再試行する。リクエスト元が Anthropic の資格情報を持っていない
   クライアント (pi / jcode 等) では、その再試行がルーターキーを x-api-key
   として上流へ渡し、401 がそのまま返って本来のエラーも隠れる。
   `internal/proxy/service.go` の `baselineViable` に
   「Anthropic へ出せる資格情報が在る」条件を足してある。Claude Code は
   OAuth 資格を持つので従来どおりフォールバックできる。

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
