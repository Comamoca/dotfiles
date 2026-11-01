# dsh tui → dsh web attach: feasibility research

Research date: 2026-10-26
Target harness: `dsh` 0.2.1-rc.3 (`/nix/store/3amp9yg3163yz8p0lz9z06m0yjniqg0q-dsh-0.2.1-rc.3`)
Question: can `dsh tui` attach to an already-running `dsh web` server, the way
`opencode attach` does?

Verdict summary:

- **Today: no.** `dsh tui` has no client/attach mode. It boots the entire
  harness in-process from the `tui` profile.
- **The server side is already capable.** The running `dsh web` exposes a
  complete, authenticated, streaming-capable RPC API. No server change is
  needed.
- **A client can be written against that API**, and this was verified live
  against the running instance (see [Live verification](#live-verification)).
  This is new code, not configuration. No `cordis.patch.yml` edit can produce
  attach behaviour.

## 1. Why configuration cannot solve this

`dsh` separates *surfaces* into separate profiles, each a separate process:

| Profile          | Bundle root               | Process            |
| ---------------- | ------------------------- | ------------------ |
| `~/.dsh/profiles/web`  | `dsh-web-app`       | `dsh web` server   |
| `~/.dsh/profiles/tui`  | `@deepseek-harness-tui/dsh-tui` | `dsh tui` |

`dsh-tui` v0.17.0 states in its README that "DSH loads in process as the
first-party backend". `cli/args.mjs` accepts `--cwd`, `--profile`, `--patch`,
`--dsh-bin`, `--timeout`, `--output-format`, `--session-id`, `--resume`,
`--limit`, `--provider`, `--model`, `--permission-mode`, `-p/--print`,
`--json`, `-c/--continue`, `--all`, `-h/--help`. There is no URL, port, or
attach option.

The only cross-process sharing today is the `~/.dsh` session store (append-only
JSONL). Each session carries a `session.lock` POSIX `flock(2)` single-writer
fence (`@deepseek-ai/node-addon-system/flock`; Win32 uses the named semaphore
`Local\dsh-session-lock-<sha256>`). A second process that opens the same session
fails with `SessionAlreadyOwnedError`. Opening one session in both `dsh web` and
`dsh tui` simultaneously is therefore explicitly unsupported, and the `dsh-tui`
README instructs the user to release the writer in the other process.

`dsh-tui`'s "mixed Web+TUI profile" support is a red herring. Its
`cordis.patch.yml` rows (`dsh-tui-webserver`, `dsh-tui-workspace`,
`dsh-tui-code-runtime`, `dsh-tui-auth`, …) self-disable when the official
counterpart row is enabled. That composes the Web *stack* into the same process;
it does not make the TUI a client of a remote server. Its WebSocket usage is
limited to the VS Code IDE channel (`DSH_TUI_IDE_PORT`, `DSH_TUI_IDE_TOKEN`,
`~/.dsh-tui/ide/*.lock`) and the Codex backend RPC — neither touches `dsh web`.

## 2. What the running server actually exposes

`dsh-web.service` runs:

```
dsh web --no-open --host 127.0.0.1 --port 14198 \
  --public-url https://dsh.comamoca.dev --trusted-host dsh.comamoca.dev
```

with `DSH_PERMISSION_MODE=danger-full-access`. The host/port and hop
constraints are in `home.nix` (`systemd.user.services.dsh-web`).

`dsh-client-connection` admits requests against three policies: loopback,
the listener bind IP, and each `--trusted-host` value. An advertised public URL
contributes nothing to admission. Authentication is a launch token embedded in
the module; there is no off switch.

### 2.1 Auth flow

1. `dsh web` prints a URL carrying `?token=<43-char token>`
   (recoverable via `journalctl --user -u dsh-web`).
2. `GET /?token=…` answers `303 See Other` with
   `Set-Cookie: dsh-auth-<id>=v1.<payload>.<sig>; Max-Age=2592000; HttpOnly; SameSite=Strict`.
   The payload binds `authority` (`127.0.0.1:14198`) and `expiresAt` (30 days).
3. The cookie authorizes subsequent `/` and `/api` requests. Without it,
   `/` returns `401`.

Verified: unauthenticated `/` → `401`; token exchange → `303` + cookie; with
cookie `/` → `200`.

### 2.2 Unary RPC

`POST /api/<endpoint>` with `Content-Type: application/json`:

```json
{ "type": "client-request", "rpcId": "<id>", "method": "<endpoint>", "payload": { "args": { … } } }
```

Response:

```json
{ "type": "server-response", "rpcId": "<id>", "result": { "ok": true, "value": … } }
{ "type": "server-response", "rpcId": "<id>", "result": { "ok": false, "error": { "code": …, "message": …, "details": … } } }
```

`method` must equal the endpoint in the path or the server answers
`gateway/bad-request`. The outbound body is JSON; large payloads are
base64-expanded in-memory with a carrier cap sized around a 200 MiB aggregate
image limit.

Endpoint names come from `dsh-api-remotes` / `dsh-api-session-controller`. The
Session namespace used by the Web UI:

| Endpoint | Purpose |
| -------- | ------- |
| `session/list` | Session roster with projections (title, goal, token usage, running flag, cwd) |
| `session/create` | Create a session (`cwd` xor `workspaceId`, optional reusable blank `sessionId`, `agentPreset`) |
| `session/prompt` | Admit one prompt (`sessionId`, `mode: queue\|steer`, `content[]` blocks) |
| `session/page` | Read a cold-safe, message-aligned history page (`address`, `throughSeq`, `beforeSeq`, `maxMessages`, `turnWindow`) |
| `session/follow` | **Stream:** live session events (stream mode) |
| `session/control` | **Stream:** live control channel (stream mode) |
| `session/search` | Search sessions |
| `session/cancel` | Cancel the running turn |
| `session/fork` | Fork a session |
| `session/rename` | Rename |
| `session/modelCatalog` | Available providers/models + default |
| `session/selectModel` | Switch model |
| `session/projections` | **Stream:** projections |
| `session/attachment` | Read a session attachment (URL) |
| `session/updateQueue` | Edit the prompt queue |

Argument names are per-descriptor and not uniform. `session/list` takes
`{ "_request": {} }` while `session/page`, `session/prompt`, `session/create`,
and `session/search` take `{ "request": { … } }`. The Gateway validates exact
field names and returns `gateway/arguments-invalid` naming the missing or
unexpected field, so the contract is self-describing at runtime.

Important: `session/page` requires `throughSeq` — the inclusive log cut handed
out by the corresponding `session/follow` opening frame. Passing `address`
alone fails boundary validation.

### 2.3 Streaming

`GET /api/remote.mux` with a normal WebSocket upgrade (`Cookie` +
`Origin: http://127.0.0.1:14198`). Verified: `101 Switching Protocols`.

Every logical stream shares that one socket. Client → Host:

```ts
{ type: 'open',   streamId, endpoint, payload }  // payload = { args: {…} }
{ type: 'item',   streamId, value? }             // uplink
{ type: 'end',    streamId }                      // uplink half-close
{ type: 'cancel', streamId }
```

Host → Client:

```ts
{ type: 'item',  streamId, value? }
{ type: 'error', streamId, error: { code, message, details } }
{ type: 'end',   streamId }
```

The Host Pings every `websocketHeartbeatIntervalMs` (2 s default) and the peer
answers Pong at the protocol layer, so idle connections survive intermediate
proxies. A socket with no activity across two Ping intervals is terminated.
Connection owns the retry schedule and asks the mux to cancel the candidate
socket before each retry, so exactly one fresh physical attempt happens per
retry.

`session/follow` sends a `snapshot` frame first (`{type:"snapshot", header:{version:4, id:…}, …}`)
followed by incremental events. This is the whole basis for a live-updating
attach client.

Streaming methods cannot be invoked as unary: the Gateway rejects with
`gateway/signature-invalid` ("stream Remote methods must be opened through the
stream carrier"). Unary methods cannot be opened on the mux.

### 2.4 Peer model and authorization

Every call names a Peer. The Gateway injects `remoteAccess` and resolves the
resources a call touches, then asks
`ctx.remoteAccess.decide({ principal, action, resources, args })` unless the
caller's principal *is* the owner. A refused call throws
`remote-access/denied` before it activates any Session. Owner calls skip
resource resolution entirely.

Consequence: a local client on the Web instance's own Peer is the owner and
needs no extra policy work; a non-owner principal would need an
`remote-access` policy written for it.

## 3. Live verification

Run against the live `dsh-web.service` on 2026-10-26. All assertions below are
observed responses, not inferences from types.

1. Token exchange → cookie: OK.
2. `POST /api/session/list` with `{"args":{"_request":{}}}` →
   `result.ok = true`, 31 sessions, each with `sessionId`, `cwd`, `updatedAt`,
   `running`, `projections.values.title/goal/tokenUsage`.
3. `POST /api/session/modelCatalog` with `{"args":{}}` → `ok: true`,
   `default {provider: "omniroute", model: "static-thrifty"}`,
   `routableProviders ["opencode-go","omniroute"]`, full model groups.
4. `POST /api/session/page` with
   `{"request":{"address":{"kind":"session","sessionId":…},"maxMessages":5,"throughSeq":0}}`
   → `ok: true`, `records[]` beginning with `{"type":"event","event":{"type":"permission/preset","seq":0,…}}`.
5. WebSocket upgrade on `/api/remote.mux` → `101`.
6. `session/follow` open on that socket → first frame
   `{"type":"item","value":{"type":"snapshot","header":{"version":4,"id":"session-…"}}}`
   — a complete live session snapshot.

So: listing, history, model catalog, and live event streaming all work from a
plain Node process with nothing but `fetch` and `WebSocket`. The remaining gap
is entirely client UX, not protocol.

## 4. Implementation options

### Option A — standalone attach CLI (recommended)

Small CLI (e.g. `dsh-attach`) that speaks the API above: list sessions, open
one, render history, stream new events, send prompts.

- Cost: moderate; the protocol is proven and the code surface is one file plus a
  TUI layer if wanted.
- Risk: the API is not a public compatibility contract. `dsh` is at
  `0.2.1-rc.3` and predicate names, arg shapes, and projections may change
  between releases. A hand-rolled client is pinned to whatever version is
  installed.
- No `dsh` changes, so no patch to carry across upgrades.
- Auth needs the launch token, recoverable from `journalctl`. Token rotation on
  restart implies a re-exchange step, or caching the 30-day cookie.

### Option B — fork `dsh-tui` and swap the backend

Replace its in-process DSH backend adapter with a remote HTTP/WebSocket
backend. Keeps the existing React/Ink rendering, keybindings, and dialogs.

- Cost: high and ongoing. Upstream (`github.com/ccch1mneyyy/dsh-TUI`) moves
  quickly at v0.17.0, and the adapter is the part most likely to break.
- Benefit: the full TUI UX for free.
- Realistically a long-lived fork with merge burden, for one feature.

### Option C — upstream the feature

`dsh-tui` already owns a client-side abstraction (its WebSocket IDE channel and
Codex RPC prove it can talk to a remote process). An attach mode upstream is
architecturally coherent: the backend interface would gain a remote
implementation.

- Cost: writing a proposal and a patch against a third-party repo, then
  waiting on its maintainer.
- Benefit: no local fork, benefits all users, survives upstream releases.
- This is the only option that ends with a maintained attach mode rather than a
  private one.

### Comparison

| | A: standalone CLI | B: fork dsh-tui | C: upstream |
| --- | --- | --- | --- |
| Initial cost | Low–medium | High | Medium |
| Ongoing cost | Bump on `dsh` upgrades | Continuous merge burden | Near zero |
| UX fidelity | Whatever we build | Full TUI | Full TUI |
| Touches dsh or dsh-tui | No | Yes (fork) | Yes (PR) |
| Blocks on third party | No | No | Yes |

## 5. Constraints that any option must respect

- **Trust boundary.** The Web instance runs `DSH_PERMISSION_MODE=danger-full-access`
  and is reachable at `dsh.comamoca.dev` through a Cloudflare Tunnel, guarded by
  a Cloudflare Access app (IdP Cloudflare, allow-list `comamoca.dev@gmail.com`,
  24 h session). DSH's own launch token is deliberately retained as a second
  layer. An attach client that stores or forwards that cookie hands owner-level
  RCE to whatever can read it — cookie files must be `0600`, never logged.
- **Keep the bind on `127.0.0.1`.** The loopback bind is what keeps the token
  exchange off the network.
- **Do not remove the session lock.** The `flock` fence is the only thing
  preventing two writers from corrupting one session log. A remote client
  avoids the problem by design (the Web process stays the sole writer), which
  is a genuine argument in favour of attach over "open the same session in both".
- **Never hand-edit OmniRoute model lists.** If an attach client exposes model
  selection it should read `session/modelCatalog`, not embed a list.

## 6. Recommendation

Pick **Option A** if the goal is a working attach now with contained risk;
pick **Option C** if the goal is to have attach permanently and the fork in
Option B is unacceptable.

Option B is the only one that reproduces `opencode attach`'s exact UX, and it
is also the most expensive to keep working. Given that the protocol is already
proven and self-describing at runtime, Option A reaches a usable attach client
without owning a fork.

Treat the API as unstable: pin the client to the installed `dsh` version and
re-run the checks in [Live verification](#live-verification) after each `dsh`
upgrade. `gateway/arguments-invalid` naming the exact bad field means a broken
client announces its own breakage clearly rather than failing obscurely.

## 7. Reproduction

The probes used during this research, for re-running after an upgrade:

```sh
# 1. token → cookie
TOKEN=$(journalctl --user -u dsh-web --no-pager -o cat \
  | grep -o 'token=[A-Za-z0-9_-]*' | tail -1 | cut -d= -f2)
curl -s -c /tmp/ck.txt -o /dev/null "http://127.0.0.1:14198/?token=$TOKEN"

# 2. unary call
curl -s -b /tmp/ck.txt -H 'Content-Type: application/json' \
  -d '{"type":"client-request","rpcId":"r1","method":"session/list","payload":{"args":{"_request":{}}}}' \
  http://127.0.0.1:14198/api/session/list | head -c 400

# 3. mux upgrade
curl -s -b /tmp/ck.txt -i -N --max-time 3 \
  -H 'Connection: Upgrade' -H 'Upgrade: websocket' \
  -H 'Sec-WebSocket-Version: 13' -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
  -H 'Origin: http://127.0.0.1:14198' \
  http://127.0.0.1:14198/api/remote.mux | head -5
```

A `101` on step 3 plus `"ok":true` on step 2 means the attach surface is intact.
