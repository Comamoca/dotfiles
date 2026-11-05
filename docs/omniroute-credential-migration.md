# OpenCode Go 認証管理の移行記録

2026-10-25、上流キーの管理先を sops 同期から OmniRoute の Providers →
`opencode-go` へ変更した。既存の `go-primary` と保存済みキーは保持した。
クライアント接続用の `OMNIROUTE_API_KEY` と aider 等の直接接続用認証は変更していない。

## 適用した変更

- 同期サービスを停止し、ユーザー設定ディレクトリで永続 mask した。
- 同期スクリプト、旧 failover 秘密ファイルと配布・環境変数定義を撤去した。
- OpenCode の設定から旧 failover プラグインを外した。
- 撤去分を `9f61fda` と `e60abeb` に記録した。既存変更と混在する
  OmniRoute 導入設定の全体はコミットしていない。

## 確認結果と未適用事項

OmniRoute API 経由の `glm-5.2` が `OK` を返した。Home Manager の flake 評価でも
旧秘密配布と同期サービスの定義が存在しないことを確認した。

Home Manager 全体の switch は、無関係な未反映変更を含むため実施していない。
稼働中の OpenCode Server とスタンドアロンのセッションも再起動していない。
旧世代の秘密配布定義と、既存プロセスに読み込まれたプラグインは残る。
新規 OpenCode CLI の検証は初期化中に停止し、再試行もタイムアウトした。
検証用プロセスは終了済みだが、停止の根本原因と OpenCode 経由の応答は未確認である。

## 完全反映する際の手順

1. 既存の未コミット・ステージ済み変更を確認し、適用する構成を確定する。
2. `home-manager switch --flake .#Home --impure` を実行する。
3. 作業終了後に `systemctl --user restart opencode-server.service` を実行し、
   スタンドアロン OpenCode も再起動する。
4. 同期サービスの `masked` / `inactive` と、実際の OpenCode 経由の応答を確認する。

同期サービスの mask は解除しない。旧世代への rollback は秘密配布や同期定義を
復活させる可能性があり、Home Manager が管理する unit の変更で mask が
置き換わる可能性にも注意する。switch / rollback 後は必ず状態を再確認する。

上流キーは Docker の `omniroute-data` volume に保存される。DB だけでなく、
復号に必要な設定も安全にバックアップする。今回、volume の復元試験は行っていない。
`docker compose down -v` や volume の削除は行わない。
