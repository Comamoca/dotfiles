# Requirements Document

## Project Description (Input)

denix を採用した Nix モジュール構成の段階的移行。

現状 `flake.nix` (352行) / `configuration.nix` (719行) / `home.nix` (1143行) /
`home-manager/wsl/default.nix` (854行、`home.nix` のフォーク) /
`raspi/configuration.nix` (289行) が巨大な単一 attrset でモジュール分割されておらず、
2台目以降のホストがコピーで増えている。`packages/*.nix` はリスト返し関数で
`pkgs` / `emacs'` / `nurpkgs` を手リレーしており、ホスト別 on/off ができない。
`pkgs/*/default.nix` は全て `{ pkgs }:` 規約で `callPackage` 非互換かつ flake
`packages` に未公開。`configuration.nix` に `builtins.fetchTarball` による impure な
nixpkgs 取得があり pure eval が壊れている。`/home/coma` が6ファイル24箇所に
ハードコードされ mac 対応が不可能。sops は消費側ファイルに埋め込まれ
`/run/user/1000` のマジックナンバーや平文 `cp` + `chmod` の activationScript が残る。
デッドコード (`agent.nix`, `hosts/wsl/`, `catppuccin.nix`, `containers.nix`) も存在する。

これを denix (yunfachi/denix) の `delib.module` / `delib.host` / `myconfig` フラグ方式へ
移行し、`modules/{core,hardware,desktop,programs,services,bundles,secrets}` +
`hosts/{comabook,raspi,wsl,mac}` + `overlays/` + `rices/` の構成にする。
standalone home-manager 運用を維持したまま1機能1ファイルでシステム側 (`nixos.*`) と
home 側 (`home.*`) を同一モジュールに書けるようにすることが主目的。

移行は動作を保ちながら段階的に行い、各フェーズ末で `nix flake check` と
`nixos-rebuild build` が通る状態を維持する。

- Phase 0: デッドコード削除 / impure fetch 撤去 / `pkgs` の `callPackage` 化と
  overlay + flake `packages` 公開
- Phase 1: denix 導入し既存設定を `modules/_legacy` に丸ごと包んでまず動かす
- Phase 2: `_legacy` から機能単位で切り出し (constants 導入でハードコードパス解消)
- Phase 3: secrets モジュール化とホスト鍵統一・`.sops.yaml` のホスト別分離
- Phase 4: WSL をフォークからフラグへ、mac ホスト追加
- Phase 5: `.kiro/steering/structure.md` に agent 向け構造規約を明文化し
  `checks` に各ホストの toplevel ビルドを登録

目的は raspi / mac など他 OS の整理、`packages` / `pkgs` の共通化とボイラープレート削減、
coding agent が迷いにくい構造、設定改善のしやすさ、sops のセキュア化。


## Introduction

本仕様は、Comamoca の dotfiles リポジトリにおける Nix 設定を
[denix](https://github.com/yunfachi/denix) のモジュール方式へ段階的に移行するための要件を定義する。

現行構成は `configuration.nix` (719行) / `home.nix` (1143行) を筆頭に、
ホストごとの巨大な単一 attrset で構成されている。2台目以降のホスト
(`home-manager/wsl/default.nix`, `hosts/wsl/default.nix`) は既存ファイルの
フォークとして増えており、共通設定が2〜3重に存在する。加えて
`builtins.fetchTarball` による impure な nixpkgs 取得、`/home/coma` の
ハードコード (6ファイル24箇所)、消費側ファイルに埋め込まれた sops 宣言、
および複数のデッドコードが存在する。

移行後は denix の `delib.module` / `delib.host` / `myconfig` フラグ方式により、
1機能を1ファイルに閉じ、システム側 (`nixos.*`) と home 側 (`home.*`) を
同一モジュール内に記述する。standalone home-manager 運用
(`home-manager switch --flake .#Home`) は維持する。

移行は動作を保ちながら Phase 0 〜 Phase 5 の段階で進め、各フェーズ末で
検証が通る状態を維持する。

### EARS 主語の定義

本仕様の受け入れ条件で用いる主語を以下に定義する。

| 主語 | 指すもの |
| --- | --- |
| **dotfiles flake** | `flake.nix` とその outputs (`nixosConfigurations`, `homeConfigurations`, `packages`, `checks`, `devShells`, `formatter`) |
| **denix module layer** | `modules/` 配下の `delib.module` 群 |
| **host definition** | `hosts/<name>/default.nix` の `delib.host` 定義 |
| **package overlay** | `overlays/` 配下のオーバーレイ群 |
| **secrets module** | `modules/secrets/` 配下のモジュール群 |
| **migration process** | 各フェーズの移行作業とその完了判定 |
| **repository documentation** | `.kiro/steering/` および `README.md` |

### 用語

- **フラグ**: `myconfig.host.*` に定義されるホスト特性のブール値 (例: `isDesktop`, `isServer`)
- **`_legacy` モジュール**: Phase 1 で既存設定を中身そのままで包んだ暫定モジュール
- **パッケージ束 (bundle)**: 現行 `packages/*.nix` の後継となる、option で on/off 可能なパッケージ群モジュール

## Requirements

### Requirement 1: 段階的移行の安全性と検証可能性

**Objective:** リポジトリ保守者として、各フェーズ末に検証可能な形で移行を進めたい。これにより大規模な構成変更を行っても、いつでも動作する状態に戻れる。

#### Acceptance Criteria

1. The migration process shall Phase 0 から Phase 5 までを独立したコミット可能な単位として実施する
2. When あるフェーズの作業が完了したとき, the dotfiles flake shall `nix flake check` を成功させる
3. When あるフェーズの作業が完了したとき, the dotfiles flake shall 移行対象の全 NixOS ホストについて `nixos-rebuild build --flake .#<host>` を成功させる
4. When あるフェーズの作業が完了したとき, the dotfiles flake shall `home-manager build --flake .#Home` を成功させる
5. If あるフェーズで検証が失敗した場合, the migration process shall 次フェーズへ進まず当該フェーズ内で修正する
6. The migration process shall 移行前後で comabook ホストの実効設定に意図しない差分を生じさせない
7. When 移行の各フェーズを実施するとき, the migration process shall 機能追加と構造変更を同一の変更に混在させない

### Requirement 2: pure eval とビルド再現性の回復

**Objective:** リポジトリ保守者として、flake.lock 外の暗黙的な依存を排除したい。これにより CI・リモートビルド・将来の darwin 構成で同一の評価結果が得られる。

#### Acceptance Criteria

1. The dotfiles flake shall `builtins.fetchTarball` および `builtins.fetchurl` による nixpkgs 取得を含まない
2. Where 旧バージョンの nixpkgs を必要とするパッケージが存在する場合, the dotfiles flake shall 当該 nixpkgs を flake input として宣言し `flake.lock` に固定する
3. When `nix flake check --no-impure` を実行したとき, the dotfiles flake shall 評価エラーを発生させない
4. The dotfiles flake shall `--impure` フラグなしで全ホストの構成を評価可能とする
5. If 現行構成が `--impure` を前提とする箇所を含む場合, the migration process shall 当該箇所を flake input または overlay へ置換する

### Requirement 3: デッドコードと重複定義の除去

**Objective:** リポジトリ保守者として、参照されていない設定ファイルを除去したい。これにより coding agent および人間が現行構成を読む際の誤読を防げる。

#### Acceptance Criteria

1. The migration process shall `flake.nix` から到達不能なファイルを除去または移行対象として明示する
2. The migration process shall `agent.nix` を除去する
3. The migration process shall `hosts/wsl/default.nix` を除去する
4. The migration process shall `catppuccin.nix` を除去する
5. The migration process shall 空の attrset を返す `containers.nix` とその import を除去する
6. Where 参照されていないが将来利用の可能性がある設定が存在する場合, the denix module layer shall 当該設定をフラグ無効状態のモジュールとして保持する
7. When デッドコードを除去したとき, the migration process shall 除去対象が未参照であることを事前に確認する

### Requirement 4: カスタムパッケージの callPackage 化と flake 公開

**Objective:** リポジトリ保守者として、`pkgs/` 配下の自作パッケージを標準的な `callPackage` 規約で扱いたい。これにより引数の手渡しを廃し、単体ビルドと CI 検証が可能になる。

#### Acceptance Criteria

1. The package overlay shall `pkgs/` 配下の全パッケージを `callPackage` 規約で評価する
2. The dotfiles flake shall `pkgs/` 配下の全パッケージを `packages.<system>.<name>` として公開する
3. When `nix build .#<package-name>` を実行したとき, the dotfiles flake shall 当該パッケージをビルドする
4. The denix module layer shall `pkgs/` 配下のパッケージを `import ./pkgs/<name> { inherit pkgs; }` 形式で参照しない
5. The migration process shall `packages/opensrc.nix`, `packages/picoclaw.nix`, `packages/shinycolors-jacket.nix` の再 export シムを除去する
6. Where パッケージが `homeDirectory` などの構成依存値を必要とする場合, the package overlay shall 当該値を実行時に解決する形へ変更する
7. The package overlay shall `nurpkgs` および カスタム Emacs を `pkgs` 名前空間の属性として提供する

### Requirement 5: denix モジュール層の導入と standalone home-manager の維持

**Objective:** リポジトリ保守者として、システム設定と home 設定を同一モジュールに記述したい。これにより1機能に関する変更が1ファイルで完結する。

#### Acceptance Criteria

1. The dotfiles flake shall `denix.lib.configurations` により `nixosConfigurations` と `homeConfigurations` を生成する
2. The dotfiles flake shall `home-manager switch --flake .#Home` による standalone 運用を維持する
3. The denix module layer shall 1つのモジュール内に `nixos.*` セクションと `home.*` セクションを併記可能とする
4. When `moduleSystem` が `home` であるとき, the denix module layer shall `home.*` セクションの内容を home-manager の `config` 直下へ適用する
5. The denix module layer shall `modules/` 配下のファイルを自動発見し、明示的な `imports` リストの記述を不要とする
6. When Phase 1 を完了したとき, the denix module layer shall 既存の `configuration.nix` および `home.nix` の内容を `_legacy` モジュールとして保持したまま動作する
7. The dotfiles flake shall denix 導入後も `packages`, `overlays`, `devShells`, `formatter`, `checks` の各 output を提供する

### Requirement 6: 機能単位のモジュール分割

**Objective:** リポジトリ保守者として、設定を機能単位のファイルへ分割したい。これにより特定機能の改善時に読むべき範囲が限定される。

#### Acceptance Criteria

1. The denix module layer shall `modules/core`, `modules/hardware`, `modules/desktop`, `modules/programs`, `modules/services`, `modules/bundles`, `modules/secrets` のカテゴリ構成を持つ
2. The denix module layer shall 1つのモジュールファイルに1つの機能関心のみを含む
3. When ある機能がシステム側と home 側の両方の設定を必要とするとき, the denix module layer shall 両者を同一ファイル内に記述する
4. When Phase 2 を完了したとき, the denix module layer shall `_legacy` モジュールを含まない
5. The denix module layer shall 各モジュールに対して有効・無効を制御する option を提供する
6. Where 現在使用していない設定 (Hyprland 系) が存在する場合, the denix module layer shall 当該設定を隔離したディレクトリに配置しフラグを無効とする
7. The migration process shall `_legacy` からの切り出しを機能単位で行い、1回の変更で複数カテゴリを同時に移動させない

### Requirement 7: アイデンティティの定数化とマルチプラットフォーム対応

**Objective:** リポジトリ保守者として、ユーザー名やホームディレクトリを単一の定数から導出したい。これにより mac (`/Users/<user>`) を含む他プラットフォームへ展開できる。

#### Acceptance Criteria

1. The denix module layer shall ユーザー名、ホームディレクトリ、dotfiles リポジトリのパスを共有定数として提供する
2. The denix module layer shall `/home/coma` をリテラルとして含まない
3. When プラットフォームが darwin であるとき, the denix module layer shall ホームディレクトリを `/Users/<username>` として導出する
4. The denix module layer shall dotfiles リポジトリのパスを out-of-store symlink の生成に共有定数経由で使用する
5. The denix module layer shall ホスト名をリテラルとしてモジュール内に含まない
6. Where モジュールが darwin 固有設定を必要とする場合, the denix module layer shall `darwin.*` セクションに当該設定を記述する

### Requirement 8: ホストフラグによる構成選択

**Objective:** リポジトリ保守者として、ホストごとの差分をフラグの組み合わせで表現したい。これにより新規ホストの追加が既存ファイルのコピーを伴わない。

#### Acceptance Criteria

1. The host definition shall ホスト特性を表すフラグと、ハードウェア固有設定および stateVersion のみを含む
2. The host definition shall パッケージリストおよび services の設定を直接含まない
3. The denix module layer shall 各モジュールの有効条件をモジュール自身が宣言する
4. When ホストが `isDesktop = false` を宣言したとき, the denix module layer shall `modules/desktop` 配下のモジュールを無効とする
5. When 新規ホストを追加するとき, the migration process shall 既存ホスト定義のコピーを作成しない
6. The denix module layer shall 同一フラグ集合を宣言した2つのホストに対して同一のモジュール集合を適用する

### Requirement 9: パッケージ束の option 化とボイラープレート削減

**Objective:** リポジトリ保守者として、パッケージ群をホスト別に on/off したい。これにより引数の手渡しを廃し、raspi などで不要なパッケージ束を外せる。

#### Acceptance Criteria

1. The denix module layer shall パッケージ束を option を持つモジュールとして提供する
2. The denix module layer shall `{ pkgs }: with pkgs; [ ... ]` 形式のリスト返し関数によるパッケージ定義を含まない
3. The denix module layer shall パッケージ束の定義において `pkgs` 以外の引数を呼び出し側から受け取らない
4. When ホストがあるパッケージ束を無効としたとき, the denix module layer shall 当該束のパッケージを当該ホストの closure に含めない
5. The denix module layer shall システム寄りのパッケージ群を `environment.systemPackages` 側に配置する
6. The denix module layer shall home 寄りのパッケージ群を `home.packages` 側に配置する

### Requirement 10: sops 管理のセキュア化

**Objective:** リポジトリ保守者として、機密情報の宣言と消費を同一モジュールに閉じ、平文が経由する経路を減らしたい。これにより漏洩経路と侵害時の影響範囲を限定できる。

#### Acceptance Criteria

1. The secrets module shall secret の宣言を、当該 secret を消費するモジュールと同一ファイル内に配置する
2. The secrets module shall secret の配置先パスに uid のリテラル (`1000`) を含まない
3. The secrets module shall secret の消費側において `config.sops.secrets.<name>.path` または `config.sops.templates.<name>.path` を参照する
4. The secrets module shall 平文の secret をファイルシステムへ複製する activationScript を含まない
5. While NixOS ホストとして動作している間, the secrets module shall 復号鍵としてホストの SSH ホスト鍵を使用する
6. The secrets module shall `sops.templates` に対して、NixOS 側では owner と mode を、home 側では mode を明示する
7. The dotfiles flake shall `.sops.yaml` の creation_rules をホスト単位のパスで分離する
8. The denix module layer shall パスワードを平文リテラルとして含まない
9. If secret の復号に失敗した場合, the secrets module shall 当該 secret を必要とするサービスの起動を阻止する
10. While standalone home-manager 構成として動作している間, the secrets module shall 復号鍵として age 鍵ファイルを使用する
11. The secrets module shall NixOS 側の SSH ホスト鍵と home 側の age 鍵の双方を並行して維持する

### Requirement 11: ホスト展開 (WSL のフラグ化と mac 対応)

**Objective:** リポジトリ保守者として、WSL をフォークからフラグ構成へ移し mac ホストを追加したい。これにより全ホストが単一のモジュール集合を共有する。

#### Acceptance Criteria

1. The migration process shall `home-manager/wsl/default.nix` を除去し、WSL の設定をホストフラグと差分のみで表現する
2. The host definition shall WSL ホストについて GUI 関連モジュールを無効とする
3. When WSL ホストと comabook ホストが同一の機能を必要とするとき, the denix module layer shall 当該機能の定義を単一のファイルから提供する
4. The denix module layer shall darwin 向け設定を記述可能な構造 (`darwin.*` セクションおよび darwin 対応のホームディレクトリ導出) を備える
5. The migration process shall 本移行において `darwinConfigurations` および mac 実機向けホスト定義を追加しない
6. The migration process shall 同一設定が複数のホスト向けファイルに重複して存在する状態を解消する

### Requirement 12: coding agent 向け構造規約と自動検証

**Objective:** リポジトリ保守者として、構造上の判断規則を明文化し自動検証したい。これにより coding agent が配置場所に迷わず、規約違反を機械的に検出できる。

#### Acceptance Criteria

1. The repository documentation shall `.kiro/steering/structure.md` にモジュール配置規約を記載する
2. The repository documentation shall 新機能追加時の手順を「`modules/<category>/` にファイルを1つ追加する」として記載する
3. The repository documentation shall ホスト定義に記述してよい内容と記述してはならない内容を記載する
4. The repository documentation shall `imports` を手書きしない方針を記載する
5. The dotfiles flake shall `checks.<system>` に各ホストの toplevel ビルドを登録する
6. When `nix flake check` を実行したとき, the dotfiles flake shall 全ホストの構成が評価可能であることを検証する
7. The repository documentation shall `README.md` の適用コマンドを移行後の構成に合わせて更新する

## 対象外 (Out of Scope)

- `config/` 配下の素の dotfiles (niri, nvim, fish 等の設定ファイル自体) の内容変更
- Emacs 設定 (`emacs.d/`, `init.el`) の内容変更
- denix 以外のフレームワーク (blueprint, flake-parts 等) の導入
- 新規パッケージの追加および既存パッケージのバージョン更新
- `raspi` ホストで動作する picoclaw 等のアプリケーション自体の機能変更
- mac 実機向けホスト定義および `darwinConfigurations` output の追加 (本移行では darwin 対応可能な
  構造の整備までとする)
- WSL ホストの廃止 (WSL は維持し、フォークからフラグ構成へ移行する)
- sops 復号鍵方式の一本化 (NixOS 側の SSH ホスト鍵と home 側の age 鍵は双方維持する)
