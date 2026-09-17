# Research & Design Decisions

## Summary

- **Feature**: `denix-module-migration`
- **Discovery Scope**: Complex Integration (フレームワーク導入 + リポジトリ全体の構造変更)
- **Key Findings**:
  - denix の `base` 拡張はホスト種別 (`type` / `isDesktop` / `isLaptop` / `isServer` / `isPC`)、
    任意の機能フラグ (`features` / `<name>Featured`)、`system` (= `nixpkgs.hostPlatform` 自動設定)、
    `displays` の各サブモジュールを自動生成する。`hosts.nix` を手書きする必要はない。
  - `useHomeManagerModule = false` を指定すると `home.*` セクションは NixOS 構成に一切適用されない。
    現行の standalone home-manager 運用をそのまま維持できる。
  - `home` moduleSystem の構成名は `<homeManagerUser>@<hostName>` に固定される。現行の
    `.#Home` / `.#coma` / `.#WSL` は生成されないため、flake 側にエイリアス層が必要。
  - denix モジュール内で `[nixos|home|darwin].[ifEnabled|ifDisabled].imports` を書くと
    infinite recursion になる。外部 nixosModule は必ず `*.always.imports` に置く。
  - `paths` 配下の **全 `.nix` ファイル**が再帰的に import される。`hardware-configuration.nix`
    を素置きできず、`delib.host` でラップする必要がある。
  - sops-nix の home-manager モジュールは secret の `path` 既定値が
    `${xdg.configHome}/sops-nix/secrets/<name>`、マウント元が `%r/secrets.d` (= `$XDG_RUNTIME_DIR`)。
    明示 `path` を外すだけで `/run/user/1000` リテラルを除去できる。
  - `configuration.nix` の impure な nixpkgs 取得2件は新規 input を必要としない。`old-pkgs` は
    完全なデッドコード、`unstable-pkgs` は既に unstable を指す主 `nixpkgs` との重複取得。

## Research Log

### denix のモジュール・ホスト・拡張の実仕様

- **Context**: 提案段階では概要のみ把握していたため、設計に必要な API 詳細 (ホストオプションの
  宣言方法、構成名の決定規則、standalone home-manager との整合) を確定する必要があった。
- **Sources Consulted**:
  - `github:yunfachi/denix` (master, 2026-09-17 時点) を clone し以下を直読
    - `lib/configurations/default.nix` (構成名生成: L248-270)
    - `lib/configurations/apply.nix` (moduleSystem ごとの振り分け)
    - `lib/extensions/base/hosts.nix` (ホストサブモジュール生成)
    - `lib/extensions/args.nix`, `lib/extensions/overlays.nix`
    - `lib/umport.nix` (ファイル自動発見)
    - `docs/src/configurations/structure.md`, `docs/src/hosts/structure.md`,
      `docs/src/modules/structure.md`, `docs/src/troubleshooting.md`,
      `docs/src/getting_started/transfer_to_denix.md`
    - `templates/minimal/**`
  - DeepWiki (`yunfachi/denix`) による補足確認
- **Findings**:
  - `delib.module` のセクションは `{myconfig|nixos|home|darwin}.{always|ifEnabled|ifDisabled}` の
    12 通り。`ifEnabled` / `ifDisabled` は `cfg.enable` の有無と真偽で分岐し、`always` は常に適用。
  - `options` と各セクションは lambda にすると `{name, cfg, parent, myconfig}` を受け取る。
  - `delib.host` は同一 `name` に対して複数ファイルから宣言でき、結果はマージされる
    (テンプレートが `hosts/desktop/default.nix` と `hosts/desktop/hardware.nix` に分けている)。
  - `delib.host` のフィールド: `name`, `system`, `useHomeManagerModule`, `homeManagerUser`,
    `homeManagerSystem`, `rice`, `myconfig`, `nixos`, `home`, `darwin`, および全ホストへ適用される
    `shared.{myconfig,nixos,home,darwin}`。
  - `base` 拡張が生成するホストオプション:
    - `type`: `enumOption ["desktop" "laptop" "server"]` (既定値なし)
    - `isDesktop` / `isLaptop` / `isServer`: `type` から自動導出
    - `isPC`: `type` が `desktop` または `laptop` のとき真
    - `features` / `defaultFeatures` / `<feature>Featured`: 任意の機能フラグ集合。
      `defaultByHostType` でホスト種別ごとの既定値を与えられる
    - `system`: 設定すると `nixos.always` / `darwin.always` で `nixpkgs.hostPlatform` を設定し、
      `homeManagerSystem` の既定値にもなる
    - `displays`: `name` / `primary` / `touchscreen` / `refreshRate` / `width` / `height` / `x` / `y`
  - `args` 拡張は `myconfig.args.{shared,nixos,home,darwin}` を `_module.args` へ流す。
    `base.withConfig { args.enable = true; }` により `host` / `hosts` がモジュール引数として届く。
  - `overlays` 拡張 (`delib.overlayModule`) は overlay を enable 付きモジュール化するヘルパ。
- **Implications**:
  - Requirement 8 (ホストフラグ) は `base` 拡張の `type` + `features` でほぼ充足でき、
    自前の `hosts.nix` 実装は不要。`features` リストの設計が本移行の中心的な設計判断になる。
  - `displays` サブモジュールは既存 spec `niri-external-display-fix` の設定と接続できる余地がある
    (本移行の範囲外だが、将来の統合先として記録)。

### 構成名 (flake output 名) の決定規則

- **Context**: 現行 flake は `homeConfigurations` に `Home` / `WSL` / `coma` / `coma@comabook` /
  `homeConfigHome` / `homeConfigWSL` の6名を公開しており、`nh home switch` の自動検出や
  README の手順がこれらに依存している。
- **Sources Consulted**: `lib/configurations/default.nix` L248-270
- **Findings**:
  - 構成名は
    `"${optionalString (moduleSystem == "home") "${host.homeManagerUser}@"}${hostName}${optionalString (riceName != null) "-${riceName}"}"`
  - すなわち `nixosConfigurations.<host>`、`homeConfigurations."<user>@<host>"`。
  - rice を定義すると **rice ごとに追加の構成が生成される** (`coma@comabook-<rice>`)。
    `delib.rice :: inheritanceOnly` が真の rice は構成を生成しない。
- **Implications**:
  - `homeConfigurations` に後付けのエイリアス (`Home` = `"coma@comabook"` 等) を flake 側で
    合成する必要がある。これを怠ると `home-manager switch --flake .#Home` が壊れる (Requirement 5.2)。
  - rice を導入すると構成数が「ホスト数 × (1 + rice 数)」に増え `nix flake check` の時間も増える。
    本移行では rice を 1 個に限定する。

### standalone home-manager との整合

- **Context**: 現行リポジトリは `home-manager.nixosModules.home-manager` を無効化し、
  standalone HM (`home-manager switch --flake .#Home`) で運用している。Requirement 5.2 で維持が必須。
- **Sources Consulted**: `lib/configurations/apply.nix`、`docs/src/configurations/structure.md`
- **Findings**:
  - `useHomeManagerModule = true` (既定) の場合、`home.*` は nixos/darwin 構成では
    `config.home-manager.users.<user>` へ書き込まれる。
  - `useHomeManagerModule = false` の場合、`home.*` は nixos/darwin 構成では `{}` になり、
    `home` moduleSystem の構成にのみ適用される。
  - HM 構成の `pkgs` は `homeManagerNixpkgs.legacyPackages.${homeManagerSystem}`。
    `legacyPackages` には `allowUnfree` が入らないため、`nixpkgs.config.allowUnfree` を
    HM モジュール側で設定して再 import させる必要がある (現行 `home.nix` も同設定を持つ)。
- **Implications**:
  - `useHomeManagerModule = false` を全体既定とする。これが Requirement 5.2 の実現手段。
  - `allowUnfree` が効くかは Phase 1 の検証項目 (unfree パッケージが多数あるため失敗が即座に判る)。
    効かない場合の代替は `homeManagerNixpkgs` に `{ legacyPackages.<system> = import nixpkgs {...}; }`
    形式の擬似 flake を渡す方法。

### 条件付き import の禁止 (infinite recursion)

- **Context**: 現行構成は外部 nixosModule / homeModule を 15 件以上 import している
  (catppuccin, niri, xremap, nix-index-database, chaotic, nix-ld, dms, hister, sops-nix,
  nixos-wsl, hermes-agent, nixos-hardware, disko, deploy-rs, llm-agents)。
  これらをホストフラグで出し分けたい。
- **Sources Consulted**: `docs/src/troubleshooting.md`
- **Findings**:
  - `[nixos|home|darwin].[ifEnabled|ifDisabled].imports` は infinite recursion になる。
  - 正しい書き方は `*.always.imports` で無条件に import し、当該モジュールの `enable` 等の
    オプション値を `*.ifEnabled` で設定する。
- **Implications**:
  - 外部モジュールの import は常に無条件。つまり「ホストによって import 自体を変える」ことはできない。
    WSL 専用の `nixos-wsl` も全 NixOS ホストで import され、`wsl.enable` をフラグで制御する形になる。
  - この制約は移行時の事故が起きやすい箇所であり、steering に明記する (Requirement 12.4 に関連)。

### ファイル自動発見の範囲

- **Context**: `hardware-configuration.nix` や `_legacy` の扱いを決める必要がある。
- **Sources Consulted**: `lib/umport.nix`、`docs/src/configurations/structure.md`
- **Findings**:
  - `recursive = true` (既定) で `paths` 配下の全 `.nix` ファイルが `lib.fileset` 経由で列挙される。
  - `exclude` 引数で除外パスを指定できる。
  - 列挙された全ファイルが NixOS/HM モジュールとして評価されるため、`delib.module` /
    `delib.host` / `delib.rice` のいずれか、または素の有効なモジュールである必要がある。
- **Implications**:
  - `hosts/comabook/hardware-configuration.nix` は `delib.host { name = "comabook"; nixos = {...}; }`
    でラップする (テンプレートの `hardware.nix` と同じ方式)。
  - Phase 1 の `_legacy` は `paths` に含めたまま、Phase 2 で空になり次第ディレクトリごと削除する。
    `exclude` は使わない (使うと「ファイルがあるのに無効」という agent が誤読する状態を作るため)。

### sops-nix の既定パスと権限オプション

- **Context**: Requirement 10.2 (uid リテラル除去)、10.6 (owner/mode 明示) の実現方法確認。
- **Sources Consulted**: `Mic92/sops-nix` `modules/home-manager/sops.nix`
- **Findings**:
  - home-manager モジュール: secret の `path` 既定値は `${cfg.defaultSymlinkPath}/${name}`
    = `${config.xdg.configHome}/sops-nix/secrets/${name}`。復号世代の実体は `%r/secrets.d`
    (`%r` = `$XDG_RUNTIME_DIR`、darwin では temp ディレクトリ)。
  - home-manager モジュールの secret submodule が持つ権限オプションは `mode` のみ (既定 `"0400"`)。
    `owner` / `group` は **NixOS モジュール側にのみ存在する**。
- **Implications**:
  - home 側は明示 `path` を削除するだけで `/run/user/1000` リテラルが消え、かつ
    `$XDG_RUNTIME_DIR` 由来の tmpfs 上に置かれる (Requirement 10.2)。
  - Requirement 10.6 は「NixOS 側は owner + mode、home 側は mode のみ」と読み替える必要があり、
    requirements.md を該当条件のみ修正した。

### nixpkgs 側ヘルパの可用性

- **Context**: `pkgs/` の一括 overlay 化に使うヘルパの存在確認。
- **Sources Consulted**: ローカル nixpkgs (`nix eval nixpkgs#lib.packagesFromDirectoryRecursive`)
- **Findings**: `lib.packagesFromDirectoryRecursive` は現行 nixpkgs (lib 26.11 系) に存在する。
- **Implications**: `pkgs/` を `callPackage` 規約へ書き換えれば overlay と `packages` output の
  双方を単一の呼び出しで生成できる (Requirement 4.1, 4.2)。

### impure な nixpkgs 取得の実使用状況

- **Context**: Requirement 2.2 は「旧版 nixpkgs を必要とするパッケージが存在する場合は
  flake input として宣言する」としているが、実際に旧版を必要としているかを確認する必要があった。
- **Sources Consulted**: `configuration.nix` (L18, L23, L28, L250)、`hosts/wsl/default.nix` (L10)
- **Findings**:
  - `old-pkgs` は `hyprland-0-35-0` の定義にのみ使われ、`hyprland-0-35-0` の参照は 0 件。
    すなわち `old-pkgs` は完全なデッドコード。
  - `unstable-pkgs` は `services.ollama.package` で使用中。ただし本リポジトリの `nixpkgs` input は
    既に `nixpkgs-unstable` を指しており、同じ内容を二重に取得している。
  - `hosts/wsl/default.nix` の `old-pkgs` はファイル自体が未参照のため無関係。
- **Implications**: 新規 flake input は不要。`old-pkgs` と `hyprland-0-35-0` を削除し、
  `unstable-pkgs.ollama` を `pkgs.ollama` へ置換すれば pure eval が回復する。
  Requirement 2.2 は該当ケースが存在せず vacuously 充足される。

### `home.nix` のラップ可能性の実測

- **Context**: Phase 1 で既存設定を `delib.host` へ載せる際に、機械的コピーで済むかを確認する
  必要があった。
- **Sources Consulted**: `home.nix` (L1-8, L194-196)、
  `nix eval .#homeConfigurations.Home.config.home.stateVersion`
- **Findings**:
  - `home.nix` の本体は `rec` であり、`home.file` の let が `home.homeDirectory` を自己参照している。
  - `let` ブロックは 195 行あり、カスタム Emacs / nvfetcher sources / wallpaper 等を定義して
    本体から参照している。
  - モジュール引数に `overlays` を宣言しているが本体では未使用。`extraSpecialArgs` は `inputs` のみを
    渡しているが、構成は正常に評価される (`stateVersion` = `24.05` を取得できた)。
- **Implications**: ラップは「`let` をファイル先頭へ移し、`rec` 本体をホストセクションへ渡す」形になり、
  完全な機械的コピーではない。Phase 1 のタスクでこの2点を明示する。未使用の `overlays` 引数は
  Phase 2 で該当ファイルを解体する際に併せて除去する。

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
| --- | --- | --- | --- | --- |
| **denix (採用)** | `delib.module` でシステム/home/darwin を単一ファイルに統合し、ホストはフラグのみ宣言 | 1機能1ファイルを standalone HM 運用のまま実現。`base` 拡張でフラグ機構が既製。自動発見で `imports` 不要 | 全モジュールが `delib.module` ラッパ内になり離脱時は全ファイルに手が入る。単一メンテナのプロジェクト | Requirement 5, 6, 8 を直接充足 |
| blueprint | 規約ベースで flake output をディレクトリから自動マッピング | `pkgs/` の output 化と devshell 発見が自動。学習コストが低い | システム設定と home 設定を単一ファイルに統合する手段がない。HM を `hosts/<h>/users/<u>.nix` に置く前提で standalone 運用と噛み合わない。`hosts/` の所有権が denix と衝突 | 本移行の中心課題 (Requirement 5.3, 6.3) を解かないため不採用 |
| 素の NixOS モジュール + 自前 `lib/mkHost.nix` | `options.flags` 名前空間と `listFilesRecursive` を自前実装 | フレームワーク lock-in なし。挙動が完全に自明 | standalone HM で「1モジュールが両系に書き込む」を成立させるには denix の中核 (moduleSystem 振り分け層) を再実装することになる | 保守コストが denix 導入を上回ると判断 |
| flake-parts | flake output のモジュール化 | output 層の整理に有効 | モジュール層 (本課題) は解かない。denix と併用は可能だが今回の課題に対して利得が小さい | 不採用 |

## Design Decisions

### Decision: `useHomeManagerModule = false` を全体既定とする

- **Context**: Requirement 5.2 で standalone home-manager 運用の維持が必須。
- **Alternatives Considered**:
  1. `useHomeManagerModule = true` にして NixOS 構成に home-manager を統合する
  2. `useHomeManagerModule = false` で standalone を維持する
- **Selected Approach**: 2。`denix.lib.configurations` に `useHomeManagerModule = false` を渡し、
  `nixosConfigurations` と `homeConfigurations` を独立に生成する。
- **Rationale**: 現行の適用手順 (`sudo nixos-rebuild switch` と `home-manager switch` の2段) と
  運用感を変えない。移行中の切り戻しも系統ごとに独立して行える。
- **Trade-offs**: NixOS の world-readable な activation と HM の activation が別世代になるため、
  システム側と home 側に跨る機能は2回の適用が必要 (現行と同じ)。
- **Follow-up**: Phase 1 で `nixosConfigurations.comabook` に `home-manager` オプションが
  現れないことを確認する。

### Decision: ホストフラグは `base` 拡張の `type` + `features` で表現する

- **Context**: Requirement 8。ホストは「何であるか」のみを宣言し、有効条件はモジュールが持つ。
- **Alternatives Considered**:
  1. `hosts.nix` を自前で書き `isDesktop` 等を個別に宣言する
  2. `base` 拡張の `type` (desktop/laptop/server) と `features` を使う
- **Selected Approach**: 2。`type` でホストの大分類、`features` で横断的な機能集合を表す。
  `defaultByHostType` により「desktop なら wayland と gui を既定で有効」等を宣言する。
- **Rationale**: 既製の機構であり、`isDesktop` / `<feature>Featured` の導出とホスト名の
  assertion が自動で付く。自前実装分の保守が不要。
- **Trade-offs**: `features` のリストが grow すると一覧性が落ちる。カテゴリ命名規約が必要。
- **Follow-up**: `features` の初期集合を設計段階で確定し、以後の追加は steering の規約に従う。

### Decision: 外部モジュールの import は無条件、有効化のみフラグ制御

- **Context**: `*.ifEnabled.imports` が infinite recursion を起こす (Research Log 参照)。
- **Selected Approach**: 外部 nixosModule / homeModule は各機能モジュールの `*.always.imports` に
  置き、`enable` 系オプションのみ `*.ifEnabled` で設定する。
- **Rationale**: denix の公式トラブルシューティングが示す唯一の正しい形。
- **Trade-offs**: 無効化しても import 自体は評価されるため、評価時間は減らない。また外部モジュールの
  option 定義は全ホストに存在することになる (実害はないが `nixos-wsl` の options が
  comabook にも現れる)。
- **Follow-up**: この制約を `.kiro/steering/structure.md` に明記 (Requirement 12.4)。

### Decision: Phase 1 は `_legacy` 一括ラップで「まず動く denix 構成」を作る

- **Context**: Requirement 1.6 (移行前後で実効設定に意図しない差分を生じさせない) と
  Requirement 1.7 (機能追加と構造変更を混在させない)。
- **Alternatives Considered**:
  1. denix 導入と機能分割を同時に行う (big-bang)
  2. denix 導入時は既存 attrset を丸ごと1モジュールに包み、分割は後続フェーズで行う
- **Selected Approach**: 2。denix の公式移行ガイドが推奨する方式でもある。
- **Rationale**: 「denix 化による差分」と「分割による差分」を分離でき、回帰の原因切り分けが容易。
  Phase 1 完了時点で全ホストがビルド可能になるため、いつでも中断できる。
- **Trade-offs**: `_legacy` が残る中間状態が生じる。Phase 2 完了まで1機能1ファイルの利得は出ない。
- **Follow-up**: Requirement 6.4 で Phase 2 完了時に `_legacy` 不在を検証する。

### Decision: `homeConfigurations` にエイリアス層を設ける

- **Context**: denix は `coma@comabook` 形式のみを生成するが、現行は `.#Home` / `.#coma` /
  `.#WSL` に依存している。
- **Selected Approach**: `mkConfigurations "home"` の結果に対し flake 側で
  `Home` / `coma` / `WSL` のエイリアスを合成して公開する。
- **Rationale**: README の手順、`nh home switch` の自動検出、ユーザーの手元の習慣を壊さない。
- **Trade-offs**: flake.nix にエイリアス定義という denix 外の記述が残る (10 行程度)。
- **Follow-up**: Phase 1 で `home-manager build --flake .#Home` と `.#coma@comabook` の双方を検証。

### Decision: mac は「構造のみ」対応とする

- **Context**: 利用者決定。実機が無い段階で `darwinConfigurations` を作っても検証できない。
- **Selected Approach**: `darwin.*` セクションを書ける構造を整え、ホームディレクトリを
  `pkgs.stdenv.hostPlatform.isDarwin` で分岐させ、`/home/coma` リテラルを排除する。
  `nix-darwin` input の追加と `darwinConfigurations` の公開は行わない。
- **Rationale**: 検証不能な output を増やさず、mac 追加時の差分をホスト定義1件に閉じ込める。
- **Trade-offs**: darwin 経路は当面未検証のまま。
- **Follow-up**: mac 実機導入時に `hosts/mac/default.nix` と `darwinConfigurations` を追加する
  別 spec を起こす。

### Decision: sops の復号鍵は NixOS = SSH ホスト鍵、home = age 鍵の二系統を維持

- **Context**: 利用者決定。
- **Selected Approach**: `modules/secrets/default.nix` で `nixos.always.sops.age.sshKeyPaths` と
  `home.always.sops.age.keyFile` を並行して設定する。`.sops.yaml` の creation_rules は
  ホスト単位に分離し、鍵グループに main age 鍵と各ホスト鍵を列挙する。
- **Rationale**: NixOS 側は鍵配布が不要になり、home 側は既存の運用 (`~/.config/sops/age/keys.txt`)
  を維持できる。移行リスクが最小。
- **Trade-offs**: 鍵管理が二系統になり `.sops.yaml` の鍵グループが増える。
- **Follow-up**: ホスト鍵の age 公開鍵を `ssh-to-age` で取得し `.sops.yaml` に追加する手順を
  タスク化する。

## Risks & Mitigations

- **`allowUnfree` が HM 構成で効かない** — denix は `legacyPackages` を `pkgs` に渡すため。
  Phase 1 の最初の検証で unfree パッケージのエラーとして即座に判明する。代替として
  `homeManagerNixpkgs` に `config` 込みの擬似 flake 属性集合を渡す。
- **`nixpkgs.overlays` の適用先が変わる** — 現行は flake 側で `import nixpkgs { overlays = ... }`。
  移行後は `*.always.nixpkgs.overlays` で設定する。overlay 順序に依存した workaround
  (`libdisplay-info_0_2`, `openldap` の `doCheck`, `stdenv.is*` シャドウ) が壊れる可能性がある。
  Phase 0 で overlay を `overlays/` に切り出して単体で評価可能にし、順序を固定する。
- **ホスト定義が全構成で評価される** — raspi (aarch64) のホスト定義は comabook のビルド時にも
  評価される。ホスト定義にはオプション値のみを置き、パッケージ参照を持ち込まない規約で回避する。
- **`features` の設計ミスによる後戻り** — フラグ体系は後から変えると全モジュールに波及する。
  Phase 1 で初期集合を確定し、Phase 2 の切り出し中は追加のみ許す (削除・改名は行わない)。
- **rice 導入による構成数の増加** — rice ごとに構成が生成され `nix flake check` が線形に伸びる。
  本移行では rice を 1 個 (`catppuccin-mocha`) に限定する。
- **denix の lock-in** — 離脱時は全モジュールの unwrap が必要。各セクションの中身は素の
  NixOS/HM オプションのままに保ち、`delib` のヘルパ (`boolOption` 等) の使用を
  `options` 宣言部に限定することで機械的な unwrap を可能にしておく。
- **`_legacy` の長期滞留** — Phase 2 が途中で止まると `_legacy` と新モジュールの二重管理になる。
  Phase 2 をカテゴリ単位のタスクに分割し、各タスクで `_legacy` から削除した行数を確認する。

## References

- [denix](https://github.com/yunfachi/denix) — 採用するモジュールフレームワーク。本調査では
  master (2026-09-17 時点) のソースと `docs/src/` を直読した
- [denix docs: Configurations Structure](https://denix.ynf.sh/configurations/structure) —
  `delib.configurations` の全引数
- [denix docs: Hosts Structure](https://denix.ynf.sh/hosts/structure) — `delib.host` の全フィールド
- [denix docs: Modules Structure](https://denix.ynf.sh/modules/structure) — セクションと渡される引数
- [denix docs: Troubleshooting](https://denix.ynf.sh/troubleshooting) — 条件付き import の制約
- [denix docs: Transfer to Denix](https://denix.ynf.sh/getting_started/transfer_to_denix) —
  既存構成の段階的移行方針
- [sops-nix](https://github.com/Mic92/sops-nix) — `modules/home-manager/sops.nix` の既定パスと
  権限オプション
- [numtide/blueprint](https://github.com/numtide/blueprint) — 比較対象。不採用
- [Conditional module imports (NixOS Discourse)](https://discourse.nixos.org/t/conditional-module-imports/34863)
  — `imports` を config に依存させられない理由
