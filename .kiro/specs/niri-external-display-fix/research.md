# 調査・設計判断ログ

## サマリー
- **フィーチャー**: `niri-external-display-fix`
- **ディスカバリースコープ**: Extension（既存システムの拡張・修正）
- **主な発見事項**:
  - `disable-monitor-names` はniri 0.1.9/0.1.10の同一make/model/serialモニター接続時クラッシュの回避策であり、現在のバージョンでは不要な可能性がある
  - `geometry-corner-radius` + `clip-to-geometry` が異なるスケーリングファクターのマルチディスプレイ環境で問題を引き起こす可能性がある（Gist調査レポートに基づく）
  - `wait-for-frame-completion-before-queueing` デバッグオプションが外部モニターのフリッカー問題を解決するケースが報告されている

## 調査ログ

### disable-monitor-names デバッグオプション
- **コンテキスト**: 現在のconfig.kdlでこのオプションが有効化されている理由の調査
- **参照先**: [niri Debug Options](https://yalter.github.io/niri/Configuration:-Debug-Options.html), [niri Wiki](https://github.com/YaLTeR/niri/wiki/Configuration:-Debug-Options)
- **発見事項**:
  - niri 0.1.9/0.1.10で、同一のmake/model/serialを持つ2台のモニターを接続した際にクラッシュするバグが存在
  - `disable-monitor-names` はEDIDからのモニター名読み取りを無効化する回避策
  - このバグは後続バージョンで修正された可能性がある
- **影響**: 現在のniriバージョンでこのオプションが依然必要かどうか検証が必要

### geometry-corner-radius とマルチディスプレイクラッシュ
- **コンテキスト**: Gistレポート（https://gist.github.com/Comamoca/2baa860a7245448688b3e40b8c01d0c5）での調査結果
- **参照先**: ユーザー自身のGist調査レポート
- **発見事項**:
  - `geometry-corner-radius 12` + `clip-to-geometry true` のウィンドウルールが有効な状態でマルチディスプレイ（異なるスケーリング）接続時にクラッシュ
  - `prefer-no-csd` との組み合わせでさらに問題が悪化
  - 現在のconfig.kdlでは角丸は有効のままだが、コメントで「マルチディスプレイのホットプラグクラッシュを修正するため無効化」と記載しつつも実際にはコメントアウトされていない
- **影響**: 角丸設定の無効化（`/-` でコメントアウト）が必要な可能性

### force-disable-connectors-on-resume デバッグオプション
- **コンテキスト**: モニターが復帰時に映らない問題の対策
- **参照先**: [niri Debug Options](https://yalter.github.io/niri/Configuration:-Debug-Options.html)
- **発見事項**:
  - TTY切り替えやサスペンド復帰後にモニターが映らない場合、全出力を一旦無効化してから再接続する
  - ホットプラグ問題とは直接関係ないが、外部モニターが映らない症状に関連する可能性
- **影響**: サスペンド復帰後に映らない場合の追加回避策として検討可能

### wait-for-frame-completion-before-queueing
- **コンテキスト**: 外部モニター接続時のフリッカー対策
- **参照先**: [GitHub Issue #2477](https://github.com/YaLTeR/niri/issues/2477)
- **発見事項**:
  - 複数の外部モニターを接続した際に激しいフリッカーが発生するケースがある
  - このデバッグオプションを有効にすると、フレームのレンダリング完了を待ってからDRMに渡すようになり、フリッカーが解消される
  - パフォーマンスへの若干の影響がある可能性
- **影響**: フリッカーが原因で「映らない」と認識されている場合に有効

### i915カーネルパラメータ
- **コンテキスト**: configuration.nixに設定されているIntel GPUの安定性パラメータ
- **参照先**: Linux i915ドライバドキュメント
- **発見事項**:
  - `i915.enable_psr=0`: Panel Self Refreshを無効化（ディスプレイ表示の安定性向上）
  - `i915.enable_fbc=0`: Frame Buffer Compressionを無効化
  - `i915.enable_dc=0`: Display C-statesを無効化
  - これらはIntel GPUの省電力機能を無効化し、ディスプレイの安定性を優先する設定
- **影響**: 既に適用済み。電力消費が増える代わりにディスプレイの安定性が向上

## アーキテクチャパターン評価

| オプション | 説明 | 強み | リスク/制限 |
|-----------|------|------|------------|
| 角丸無効化のみ | `geometry-corner-radius` ウィンドウルールをコメントアウト | 最も安定、変更最小 | ビジュアルの劣化 |
| デバッグオプション追加 | `wait-for-frame-completion-before-queueing` 等を追加 | 角丸維持可能 | パフォーマンス影響、根本解決でない可能性 |
| 段階的適用 | まず角丸無効化で安定性確認、その後デバッグオプションで角丸復活を試行 | 問題の切り分けが可能 | 検証手順が複雑 |

## 設計判断

### Decision: 角丸ウィンドウルールの扱い
- **コンテキスト**: `geometry-corner-radius 12` がマルチディスプレイクラッシュの原因と特定されている
- **検討した代替案**:
  1. 角丸を完全無効化（`/-` でコメントアウト）
  2. 角丸を維持しつつデバッグオプションで回避
  3. 段階的に検証して最適解を見つける
- **選択したアプローチ**: 段階的適用（オプション3）
- **根拠**: Gistレポートの調査はClaude Codeによるもので、`geometry-corner-radius` がクラッシュの直接原因かどうかは確定的ではない。段階的に検証することで正確な原因特定が可能
- **トレードオフ**: 検証手順が増えるが、不要な設定変更を避けられる
- **フォローアップ**: 各段階での検証結果をドキュメント化

### Decision: デバッグオプションの追加
- **コンテキスト**: 外部ディスプレイの問題に対する追加のデバッグオプション
- **検討した代替案**:
  1. `wait-for-frame-completion-before-queueing` の追加
  2. `force-disable-connectors-on-resume` の追加
  3. 両方の追加
- **選択したアプローチ**: 必要に応じて追加（角丸無効化後もまだ問題がある場合）
- **根拠**: まず最もシンプルな変更から試し、必要に応じてデバッグオプションを追加
- **トレードオフ**: 解決までの手順が増える可能性があるが、不要な設定を減らせる

## リスクと緩和策
- `disable-monitor-names` を削除すると、実際に同一make/model/serialのモニターを使用している場合にクラッシュが再発する → 削除前にモニター構成を確認
- 角丸の無効化だけでは外部ディスプレイ問題が解決しない可能性 → デバッグオプションの段階的追加で対応
- カーネルパラメータの変更はNixOS再ビルドが必要 → 既に適用済みのため追加変更は不要

## 参考資料
- [niri Debug Options (公式)](https://yalter.github.io/niri/Configuration:-Debug-Options.html) — デバッグオプションの全リストと説明
- [niri Wiki: Debug Options](https://github.com/YaLTeR/niri/wiki/Configuration:-Debug-Options) — コミュニティWikiでの説明
- [GitHub Issue #2477: Screen tearing/flickering](https://github.com/YaLTeR/niri/issues/2477) — 外部モニターフリッカー問題
- [GitHub Issue #942: Workspace scrambling after hotplugging](https://github.com/YaLTeR/niri/issues/942) — ホットプラグ後のワークスペース問題
- [ユーザーGist調査レポート](https://gist.github.com/Comamoca/2baa860a7245448688b3e40b8c01d0c5) — 角丸+CSDの問題調査
