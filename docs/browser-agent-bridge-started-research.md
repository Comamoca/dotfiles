# Browser Agent Bridge の bootstrap `started` 到達調査

- 日付: 2026-11-01
- 状態: 読み取り専用調査（実プロファイル・設定は未変更、ライブ Firefox / Marionette / :8766 への新規接続なし）
- 関連: `~/.jcode/browser/`（`browser-agent-bridge.xpi`、`firefox-agent-bridge-host`）

## 問い

NixOS 上の Firefox 158.0.1 で、サイドロード拡張 Browser Agent Bridge
（`browser-agent-bridge@1jehuang.github.io`, v0.9.7）が

1. 「有効（active）」になっているか
2. bootstrap ライフサイクルの `started` 状態に到達しているか

の 2 点を、既存の probe 記録とローカルファイルだけから確定的に判定する。

## 結論

| 判定 | 結果 | 根拠 |
| --- | --- | --- |
| DB 上の有効化 | 有効 | `extensions.json`: `active: true`, `userDisabled: false`, `appDisabled: false`, `location: app-profile`, `installTelemetryInfo.method: sideload` |
| bootstrap `started` | **false**（現在時点） | probe 実行記録（12:31〜15:00, `blb_*` ブロック含む）が一貫して `started: false` |
| 実起動の証拠 | **あり** | 09:48:34 に Firefox が Bridge の native host を子プロセスとして spawn。いまも生存 |

要約すると **「現在の runtime 状態は started ではない。ただし起動自体は 09:48:34 に一度確実に発生している」**。
「有効」と「started 到達」は別の状態で、今回はその 2 つがずれた状態になっている。

観測の注意点として、コンソールには `XPIProvider: addon is missing bootstrap scope` が
複数回記録されており、システムの整合性に疑いが残る状態。

## 証拠一覧

### 1. プロセス（ps -ef）

```
2363631  PPID 2362761(Firefox)  started Sun Nov 1 09:48:34 2026  TIME 00:00:00
  /home/coma/.jcode/browser/firefox-agent-bridge-host \
  /home/coma/.mozilla/native-messaging-hosts/firefox_agent_bridge.json \
  browser-agent-bridge@1jehuang.github.io
  fd0/1/2 = pipe(16394967/68/69)   # Firefox 側も同じ pipe を保持
  fd10 = LISTEN 127.0.0.1:8766     # established 0
```

- native messaging host は、拡張側 background script が `runtime.connectNative` を
  呼んだときにしか Firefox の子プロセスとして生まれない。
- したがって 09:48:34 の spawn は「その瞬間 background script が動いていた」ことの直接証拠。
- host は 5 時間以上生存しつつ CPU 時間 00:00:00、established 接続 0。回収されずに
  残っている状態で、**LISTEN の継続は「Bridge が今も生きている」証拠にならない**。

### 2. プロファイル（`~/.mozilla/firefox/s8hn50g7.default`）

| ファイル | 観測 |
| --- | --- |
| `extensions.json`（mtime 09:18:57） | `active: true`, `userDisabled: false`, `appDisabled: false`, install/update とも `2026-11-01 09:18:43 JST`。Firefox の今回の起動（09:48:28）より約 30 分前。この日中に再インストールされた |
| `prefs.js`（mtime 14:48 flush） | uuid `7579b90c-e14e-4f59-9db2-d374ae99235b` が確認可能 |
| `extensions/browser-agent-bridge@…xpi` | 09:18:43（= `installDate` と一致）、60,055 bytes |
| storage origin `moz-extension+++7579b90c-…` | 09:54 更新。09:48:34 の起動と時刻が符合（`storage.local` 等の初期化） |

### 3. probe 実行記録

- `~/.jcode/scratch/probe-src-recover/probe.js`（node 実行、Marionette 経由）
- `probe_out.txt`(10:13) / `probe-result-full.txt`(13:57) / `probe_run_raw.txt`(15:00)
  - `probe_run_raw.txt`（15:00 時点の live 状態）:
    - `activeAddons`: `started:false`, `pendingDisable:false`, `hasScope:true`, `instanceID: Symbol(...)` あり
    - `scopeOwnKeys: []`
    - `hasExtensionInstance: false`
    - `extensions.webextensions.uuids`（live pref）に Bridge なし（`bridgeInUuidMap: false`, `bridgeUuid: null`）
    - `bridgeInExtensionMap: false`
- `<repo>/decompsrc/xpiprov158.mjs` で `XPIProvider.sys.mjs` の `BootstrapScope` を調査済み:
  - `BootstrapScope` の `started` は `false` で初期化される
  - `callBootstrapMethod()` 内、`aMethod == "startup"` のときに代入が発生（代入前の唯一の early return はセーフモード分岐のみ）
  - `aMethod == "shutdown"` のときに代入が発生
- コンソールには `XPIProvider: addon is missing bootstrap scope` の記録が複数回ある

## `started` が false と言い切れる理由（ソースコード）

`callBootstrapMethod()` の代入点は 2 か所だけ。

- `aMethod == "startup"` → `started = true`（startup を呼ぶ直前、無条件）
- `aMethod == "shutdown"` → `started = false` + `aReason != APP_SHUTDOWN` のとき `_pendingDisable = true`

probe の値は `started: false` かつ `_pendingDisable: false` なので **通常の停止経路では
作れない組合せ**。整合するのは次のどちらか。

1. `startup` 以外の bootstrap 呼び出し（`install` / `update` / `uninstall` 経路）で
   scope だけロードされた。ただし `uninstall` は `unloadBootstrapScope()` でエントリごと
   消えるため、実質 `install` か `update`。
2. `shutdown` を `APP_SHUTDOWN` reason で呼んだ（`_pendingDisable` が立たない唯一の shutdown）

実行継続中のブラウザで 2. は考えにくいため、**XPI の再登録（install/update）で
「scope はあるが未 started」の状態が残った**と見るのが自然。
残る疑問:

- なぜ 09:48:34 の起動が終わったのか（XPI 差し替え?、APP_SHUTDOWN 相当の shutdown 遷移?）
  → 特定には次回 Bridge を触る前の時点で `extensions.webextensions.uuids` と
  `activeAddons` を 1 点ずつ読み取り比較が必要。

## probe の所見の信頼性

probe の所見は内部で揺れている。単独の否定所見はそのまま信用しない。

- `prefs.js`（14:48 flush）には uuid が残っているのに、13:36 と 15:00 の live pref では
  `bridgeInUuidMap: false`。矛盾。
- `scopeOwnKeys: []` は `Extension.getBootstrapScope()` の own property が出ないはずで、
  probe 側の読み取り不備の可能性がある。
- **方向性（Bridge が started 状態にない）は正しい**が、細部の数値には誤差がある。

## `XPIProvider: addon is missing bootstrap scope` の意味（並行調査）

コンソールに複数回記録されている。`AddonManager` から見て `active` な登録が
`XPIProvider.activeAddons` に存在しないことを意味する。

- `AddonRepository` や inbox-service には「この通知自体は安全に無視できる」という
  類似の文言が残っている。
- 一方で今回の Bridge は重複インストールも競合状態もなく、`hasScope: true` なので
  「安全に無視できる」とは言えない。XPIProvider 内部の状態遷移が正常に完了していない
  症状の一部と見るのが自然。

## 参考リンク（覚書）

- 本調査で使用したツール:
  - `~/.jcode/scratch/probe-src-recover/probe.js`
  - `<repo>/decompsrc/xpiprov158.mjs`
