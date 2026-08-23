# Wacom ペンタブのマウス操作化設計書

## 背景と問題

現在の環境は NixOS + niri（Wayland）である。Wacom
ペンタブを接続した際、ペン先によるカーソル移動と左クリックは libinput
経由で既に動作している。しかし、ペン側面のボタンはマウスの右クリック・中クリックとして機能しておらず、通常のデスクトップ操作で使いにくい状態にある。

## 目標

ペン側面のボタンを以下のようにマッピングし、マウスと同様の操作感を実現する。

| 物理ボタン   | 振る舞い               |
| ------------ | ---------------------- |
| ペン先       | 左クリック（現状維持） |
| 下側面ボタン | 右クリック             |
| 上側面ボタン | 中クリック             |

## 非目標

- タブレット本体の ExpressKeys などの設定（今回はペンボタンのみ対象）
- ペンタブの描画領域や筆圧曲線の調整
- X11 環境での動作保証（niri / Wayland を対象）

## 採用アプローチ：input-remapper

NixOS の `services.input-remapper` を有効化し、evdev
レベルで入力イベントを再マップする。これにより niri や libinput
の制限に依存せず、ペンボタンをマウスボタンとして扱える。

### 理由

- Wayland / niri に依存せず動作する。
- 設定は宣言的に管理できる。
- 将来タブレット本体のボタンを追加する際も同じ仕組みで拡張可能。
- サービスは 1 つ増えるが、設定が単純で確実。

## ボタンイベントの対応

input-remapper 上でのイベント対応は以下の通り。

| 物理ボタン   | 入力イベント  | 再マップ後                 |
| ------------ | ------------- | -------------------------- |
| ペン先       | `BTN_LEFT`    | 変更なし（左クリック）     |
| 下側面ボタン | `BTN_STYLUS`  | `BTN_RIGHT`（右クリック）  |
| 上側面ボタン | `BTN_STYLUS2` | `BTN_MIDDLE`（中クリック） |

## 変更ファイル

1. `configuration.nix`
   - `services.input-remapper.enable = true;` を追加
   - 必要に応じて `users.users.coma.extraGroups` を確認・修正
2. `home.nix`
   - `pkgs.input-remapper` を `home.packages` に追加
   - input-remapper のプリセット JSON を `~/.config/input-remapper-2/presets/`
     配下に配置

## 設定概要

### NixOS サービス

```nix
services.input-remapper = {
  enable = true;
};
```

### Home Manager プリセット

`~/.config/input-remapper-2/presets/<device-name>/wacom-mouse.json`
を生成する。ファイル名と内容は実際に接続する Wacom デバイスに依存する。

```json
{
  "mapping": {
    "<BTN_STYLUS の入力コード>": ["<BTN_RIGHT の出力コード>"],
    "<BTN_STYLUS2 の入力コード>": ["<BTN_MIDDLE の出力コード>"]
  }
}
```

実装時に `evtest` または `input-remapper-gtk`
を使って、デバイスのイベントコードを特定し、正確な値に置き換える。

### グループ権限

input-remapper は `input` グループに属する必要がある。現在
`users.users.coma.extraGroups` には `"inputs"`
が含まれているが、標準のデバイスグループ名は `"input"`
であるため、動作確認の上で修正する。

## 検証手順

1. `nixos-rebuild switch --flake .#Home` を実行
2. `input-remapper-control --list-devices` で Wacom
   デバイスが認識されていることを確認
3. `evtest /dev/input/eventX` でペンボタンが `BTN_STYLUS` / `BTN_STYLUS2`
   として検出されることを確認
4. デスクトップ上で下ボタンが右クリック、上ボタンが中クリックとして動作することを確認

## 今後の拡張

- タブレット本体の ExpressKeys
  をマウスショートカットやキーボードショートカットに割り当て可能。
- input-remapper のプリセットに追加するだけで対応できる。

## 代替案

### niri ネイティブの TabletStylus バインド

niri の新しいバージョンでは `TabletStylusPrimary` / `TabletStylusSecondary`
トリガーが追加されている。しかし、マウスクリックを発生させるには `ydotool`
などの追加ツールが必要で、設定が input-remapper より複雑。

### OpenTabletDriver

ペンタブ専用ドライバで高機能だが、今回の目的に対しては大げさ。サービス増加と
libinput との競合リスクがある。

## 決定事項

input-remapper を採用し、NixOS サービスと Home Manager
プリセットで宣言的に管理する。
