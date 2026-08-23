# Wacom ペンタブのマウス操作化 実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** NixOS + niri 環境で Wacom
ペンタブの側面ボタンを右クリック・中クリックとして使えるようにする。

**Architecture:** NixOS の `services.input-remapper` を有効化し、evdev レベルで
`BTN_STYLUS` / `BTN_STYLUS2` を `BTN_RIGHT` / `BTN_MIDDLE`
に再マップする。プリセット JSON と自動ロード設定は Home Manager
で宣言的に管理し、デバイス名の自動検出は home.activation スクリプトで行う。

**Tech Stack:** NixOS, Home Manager, input-remapper, evtest

---

## ファイル構成

| ファイル                                 | 役割                                                                  |
| ---------------------------------------- | --------------------------------------------------------------------- |
| `configuration.nix`                      | input-remapper サービス、ユーザー権限グループを設定                   |
| `home.nix`                               | input-remapper パッケージ導入、プリセット設置用 activation スクリプト |
| `config/input-remapper/wacom-mouse.json` | ペンボタン → マウスボタンの mapping 定義                              |

---

## Task 1: input-remapper サービスを有効化する

**Files:**

- Modify: `configuration.nix`

- [ ] **Step 1: `services.input-remapper` を追加する**

`configuration.nix` 内の適切な場所（他の `services.*`
設定の近く）に以下を追加する。

```nix
services.input-remapper = {
  enable = true;
};
```

- [ ] **Step 2: Nix 式を検証する**

Run: `nixos-rebuild build --flake .#NixOS` Expected: エラーなくビルドが完了する

---

## Task 2: ユーザーが input デバイスにアクセスできるようグループを確認・修正する

**Files:**

- Modify: `configuration.nix:364-375`

- [ ] **Step 1: 現在の extraGroups を確認する**

既存の設定:

```nix
users.users.coma = {
  isNormalUser = true;
  description = "Comamoca";
  extraGroups = [
    "networkmanager"
    "wheel"
    "kvm"
    "adbusers"
    "plugdev"
    "inputs"
    "video"
  ];
  # ...
};
```

- [ ] **Step 2: `"inputs"` が正しいか確認し、必要なら `"input"` に修正する**

NixOS 標準の入力デバイスグループ名は `"input"`
である。実際に使用しているグループ名を確認するには以下を実行する。

Run: `getent group | grep -E '^input|^inputs'` Expected:
実際に存在するグループ名が表示される

存在するグループ名を採用する。もし `"input"`
グループが存在し、ユーザーが含まれていない場合は以下のように修正する。

```nix
extraGroups = [
  "networkmanager"
  "wheel"
  "kvm"
  "adbusers"
  "plugdev"
  "input"        # 必要に応じて "inputs" から変更
  "video"
];
```

もし `"inputs"`
がカスタムグループとして意図的に作成されている場合はそのままにしてもよいが、input-remapper
が動作しない場合は `"input"` への変更を検討する。

---

## Task 3: input-remapper パッケージを Home Manager で追加する

**Files:**

- Modify: `home.nix:240-268`

- [ ] **Step 1: `home.packages` に `pkgs.input-remapper` を追加する**

```nix
home.packages =
  (import ./packages/development.nix { inherit pkgs; })
  ++ (import ./packages/editors.nix { inherit pkgs emacs' nurpkgs; })
  ++ (import ./packages/terminal.nix { inherit pkgs; })
  ++ (import ./packages/utilities.nix { inherit pkgs; })
  ++ (import ./packages/gui-apps.nix { inherit pkgs nurpkgs; })
  ++ (import ./packages/system.nix { inherit pkgs; })
  ++ (import ./packages/git.nix { inherit pkgs; })
  ++ (import ./packages/security.nix { inherit pkgs; })
  ++ (import ./packages/wayland.nix { inherit pkgs; })
  ++ (import ./packages/fonts.nix { inherit pkgs; })
  ++ (import ./packages/misc.nix { inherit pkgs nurpkgs; })
  ++ (with pkgs; [
    # Additional packages
    ni
    asar
    nak
    vim-startuptime
    spotify
    input-remapper  # Wacom ペンボタンをマウス化

    rclone-sync
    rclone-resync
  ])
  ++ [
    emacs'
  ]
  ++ treefmt-packages;
```

---

## Task 4: プリセット JSON を作成する

**Files:**

- Create: `config/input-remapper/wacom-mouse.json`

- [ ] **Step 1: プリセットファイルを作成する**

```json
[
  {
    "input_combination": [
      { "type": 1, "code": 331 }
    ],
    "target_uinput": "mouse",
    "output_symbol": "BTN_RIGHT"
  },
  {
    "input_combination": [
      { "type": 1, "code": 332 }
    ],
    "target_uinput": "mouse",
    "output_symbol": "BTN_MIDDLE"
  }
]
```

上記の設定は以下の対応関係を表す。

| 入力イベント       | 意味                          | 出力         | 意味       |
| ------------------ | ----------------------------- | ------------ | ---------- |
| `type:1, code:331` | `BTN_STYLUS`（下側面ボタン）  | `BTN_RIGHT`  | 右クリック |
| `type:1, code:332` | `BTN_STYLUS2`（上側面ボタン） | `BTN_MIDDLE` | 中クリック |

---

## Task 5: Home Manager activation でプリセットを自動設置する

**Files:**

- Modify: `home.nix`
- Reference: `config/input-remapper/wacom-mouse.json`

- [ ] **Step 1: `home.file` にプリセットのソースを追加する**

`home.file` ブロック内に以下を追加する。

```nix
".config/input-remapper-2/presets/_wacom-mouse-template/wacom-mouse.json".source =
  /${dotfiles}/config/input-remapper/wacom-mouse.json;
```

- [ ] **Step 2: activation スクリプトを追加する**

`home.nix` 内の `home.activation` セクション（または新規に追加）に、Wacom
デバイスを検出してテンプレートを正しい preset ディレクトリにコピーし、autoload
設定を更新するスクリプトを追加する。

```nix
home.activation.setupWacomInputRemapper = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
  PRESET_SRC="${home.homeDirectory}/.config/input-remapper-2/presets/_wacom-mouse-template/wacom-mouse.json"
  CONFIG_DIR="${home.homeDirectory}/.config/input-remapper-2"

  # Wacom デバイス名を検出する
  DEVICE_NAME=$(${pkgs.input-remapper}/bin/input-remapper-control --list-devices 2>/dev/null | \
    ${pkgs.gnugrep}/bin/grep -i wacom | ${pkgs.coreutils}/bin/head -n 1 | ${pkgs.coreutils}/bin/cut -d: -f2 | ${pkgs.coreutils}/bin/xargs)

  if [ -z "$DEVICE_NAME" ]; then
    echo "No Wacom device found for input-remapper preset."
    exit 0
  fi

  echo "Setting up input-remapper preset for: $DEVICE_NAME"

  # デバイス別 preset ディレクトリを作成し、テンプレートをコピーする
  ${pkgs.coreutils}/bin/mkdir -p "$CONFIG_DIR/presets/$DEVICE_NAME"
  ${pkgs.coreutils}/bin/cp -f "$PRESET_SRC" "$CONFIG_DIR/presets/$DEVICE_NAME/wacom-mouse.json"

  # autoload 設定を更新する（既存設定は保持）
  ${pkgs.coreutils}/bin/mkdir -p "$CONFIG_DIR"
  ${pkgs.python3}/bin/python3 - "$CONFIG_DIR/config.json" "$DEVICE_NAME" <<'PY'
import json
import sys

config_path = sys.argv[1]
device_name = sys.argv[2]

try:
    with open(config_path) as f:
        config = json.load(f)
except FileNotFoundError:
    config = {}

config.setdefault("version", "2.2.0")
config.setdefault("autoload", {})
config["autoload"][device_name] = "wacom-mouse"

with open(config_path, "w") as f:
    json.dump(config, f, indent=4)
    f.write("\n")
PY
'';
```

- [ ] **Step 3: Nix 式を検証する**

Run: `home-manager build --flake .#Home` Expected: エラーなくビルドが完了する

---

## Task 6: 適用と動作確認

**Files:**

- N/A（実行と検証）

- [ ] **Step 1: NixOS 設定を適用する**

Run: `sudo nixos-rebuild switch --flake .#NixOS` Expected:
リビルドが成功し、input-remapper サービスが起動する

- [ ] **Step 2: input-remapper サービス状態を確認する**

Run: `systemctl status input-remapper` Expected: `active (running)` と表示される

- [ ] **Step 3: Wacom デバイスが認識されているか確認する**

Run: `input-remapper-control --list-devices` Expected: Wacom
デバイス名が一覧に含まれる

- [ ] **Step 4: ペンボタンのイベントを確認する**

タブレットを接続した状態で以下を実行する。

Run: `evtest` し、Wacom
デバイスのイベントファイルを選択して、下ボタン・上ボタンを押す Expected:
下ボタンで `BTN_STYLUS` (code 331)、上ボタンで `BTN_STYLUS2` (code 332)
のイベントが表示される

- [ ] **Step 5: プリセットがロードされているか確認する**

Run: `input-remapper-control --list-presets` Expected: Wacom デバイス名の preset
として `wacom-mouse` が表示される

- [ ] **Step 6: デスクトップ上でクリック動作を確認する**

1. テキストエディタやブラウザ上で、ペン先をタッチ →
   左クリック（通常選択）として動作することを確認
2. 下側面ボタンを押す → コンテキストメニュー（右クリック）が開くことを確認
3. 上側面ボタンを押す → 中クリックとして動作することを確認（例:
   ブラウザのタブを閉じる、ペーストなど）

---

## Self-Review

### Spec coverage

- ペン先の左クリック: 現状維持、追加設定不要 ✓
- 下側面ボタンの右クリック: Task 4 の preset JSON で対応 ✓
- 上側面ボタンの中クリック: Task 4 の preset JSON で対応 ✓
- NixOS 宣言的管理: Task 1, 3, 5 で対応 ✓
- 自動ロード: Task 5 の activation スクリプトで対応 ✓

### Placeholder scan

- "TBD" / "TODO" / "implement later" は含まれていない ✓
- ハードウェア依存の値（デバイス名）は実行時に検出するスクリプトで対応 ✓
- ファイルパスはすべて絶対パスまたはリポジトリルート相対で記述 ✓

### Type consistency

- input-remapper の preset JSON は公式ドキュメントの形式に沿っている ✓
- NixOS / Home Manager のオプション名は既存コードの形式に合わせている ✓
