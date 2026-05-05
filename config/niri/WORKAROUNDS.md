# niri 外部ディスプレイ回避策一覧

niriで外部ディスプレイのホットプラグ時にクラッシュ・フリッカー・ブラックアウトが発生する問題に対して、以下の回避策を適用している。

## 回避策一覧

### 1. 角丸ウィンドウルールの無効化

- **ファイル**: `config/niri/config.kdl`
- **設定**: `/-window-rule { geometry-corner-radius 12; clip-to-geometry true }` （`/-` で無効化）
- **理由**: 異なるスケーリングファクターを持つマルチディスプレイ環境で、角丸のレンダリングパイプラインがホットプラグ時にクラッシュを引き起こす
- **参考**: https://gist.github.com/Comamoca/2baa860a7245448688b3e40b8c01d0c5
- **削除条件**: niriのリリースノートで角丸+マルチスケーリングのクラッシュが修正された旨が記載された場合

### 2. disable-monitor-names デバッグオプション

- **ファイル**: `config/niri/config.kdl`
- **設定**: `debug { disable-monitor-names }`
- **理由**: niri 0.1.9/0.1.10で、同一のmake/model/serialを持つ2台のモニターを接続した際にクラッシュするバグの回避策
- **参考**: https://yalter.github.io/niri/Configuration:-Debug-Options.html
- **削除条件**: niri 0.1.11以降で修正が確認された場合。同一型番のモニターを使用していない場合も削除可能

### 3. wait-for-frame-completion-before-queueing デバッグオプション

- **ファイル**: `config/niri/config.kdl`
- **設定**: `debug { wait-for-frame-completion-before-queueing }`
- **理由**: 外部モニター接続時のフリッカー（画面のちらつき）を防止する。フレームのレンダリング完了を待ってからDRMに渡すことで表示を安定させる
- **参考**: https://github.com/YaLTeR/niri/issues/2477
- **削除条件**: niriのフレーム同期処理が改善され、フリッカーが発生しなくなった場合
- **注意**: パフォーマンスに若干の影響がある可能性

### 4. i915カーネルパラメータ

- **ファイル**: `configuration.nix`
- **設定**:
  - `i915.enable_psr=0` — Panel Self Refreshを無効化
  - `i915.enable_fbc=0` — Frame Buffer Compressionを無効化
  - `i915.enable_dc=0` — Display C-statesを無効化
- **理由**: Intel GPUの省電力機能がディスプレイのホットプラグ処理と干渉し、ブラックアウトや表示崩れを引き起こすため
- **削除条件**: カーネルのi915ドライバが改善され、省電力機能有効時でもホットプラグが安定した場合
- **注意**: 無効化により電力消費が増加する

### 5. early KMS (initrdでのi915ロード)

- **ファイル**: `configuration.nix`
- **設定**: `boot.initrd.kernelModules = [ "i915" ]`
- **理由**: niriがDRMデバイスに早期アクセスできるようにし、ディスプレイのホットプラグ検出を安定させる
- **削除条件**: 基本的に削除不要。early KMSはベストプラクティスであり、回避策というよりも推奨設定

---

## niriバージョンアップ時の検証手順

niriのバージョンが更新された場合、以下の手順で回避策の必要性を検証する。
**重要**: 1つずつ変更し、各段階で全テストを実行すること。

### 事前準備

- 現在のconfig.kdlとconfiguration.nixのバックアップを取る
- 外部ディスプレイを用意する（可能であれば内蔵と異なる解像度/スケールのもの）

### ステップ1: 角丸ウィンドウルールの再有効化

1. `config/niri/config.kdl` で `/-window-rule` の `/-` を削除して有効化する
2. niriを再起動する（`niri msg action quit` またはログアウト→ログイン）
3. 以下を確認:
   - [ ] 外部ディスプレイをHDMI/USB-Cで接続 → クラッシュしない
   - [ ] 外部ディスプレイを切断 → 内蔵ディスプレイに正常復帰
   - [ ] 異なるスケーリングのディスプレイ間でウィンドウ移動 → 正常
4. **問題が発生した場合**: `/-` を戻して角丸を無効化に戻す

### ステップ2: disable-monitor-names の削除

1. `config/niri/config.kdl` の `debug {}` から `disable-monitor-names` を削除する
2. niriを再起動する
3. 以下を確認:
   - [ ] 外部ディスプレイを接続 → クラッシュしない
   - [ ] `niri msg outputs` でモニター名が正常に表示される
4. **問題が発生した場合**: `disable-monitor-names` を復元する

### ステップ3: wait-for-frame-completion-before-queueing の削除

1. `config/niri/config.kdl` の `debug {}` から `wait-for-frame-completion-before-queueing` を削除する
2. niriを再起動する
3. 以下を確認:
   - [ ] 外部ディスプレイを接続 → フリッカーが発生しない
   - [ ] 長時間使用でフリッカーが出ない
4. **問題が発生した場合**: `wait-for-frame-completion-before-queueing` を復元する

### ステップ4: カーネルパラメータの削除（慎重に）

1. `configuration.nix` のカーネルパラメータを1つずつ削除する（推奨順序: `enable_dc=0` → `enable_fbc=0` → `enable_psr=0`）
2. `sudo nixos-rebuild switch` でリビルドして再起動する
3. 以下を確認:
   - [ ] 外部ディスプレイの接続/切断 → 正常
   - [ ] サスペンド → 復帰後に外部ディスプレイが映る
   - [ ] 長時間使用でブラックアウトが発生しない
4. **問題が発生した場合**: 削除したパラメータを復元して `sudo nixos-rebuild switch`

### 全テスト完了後

全ステップが問題なく完了した場合:
- 削除した回避策のコメントと関連ドキュメントを整理する
- このWORKAROUNDS.mdから該当項目を削除する
- 動作確認済みのniriバージョンをメモする
