# Orange Pi 5 (RK3588S) NixOS 立ち上げ記録

作成: 2026-11-01 / 対象: `orangepi5/` 配下のモジュールと SD イメージ

## 現状サマリ

| 項目 | 状態 |
| --- | --- |
| SD からの起動 | 成功 (HDMI でコンソール確認済み) |
| 有線 eth0 リンク | **未確立** (`carrier: 0`、`operstate: down`) |
| LAN / SSH 到達 | 不可 (fallback の `192.168.10.50` にも不通) |
| gmac (MAC) の probe | 成功。`stmmac-0` の MDIO バスは生成されている |
| PHY の認識 | **失敗**。MDIO バス上に PHY デバイスが 0 台 |

結論として、故障箇所は「MAC と PHY の間の MDIO 通信」に絞られている。
一番疑わしいのは **PHY の reset-gpio (gpio3 PA2) が open-drain に設定されていない**こと。

## 経緯

### 1. rx_delay 警告は無害と確定

起動ログに毎回出る次の 2 行は**正常**。

```
rk_gmac-dwmac fe1c0000.ethernet: Can not read property: rx_delay.
rk_gmac-dwmac fe1c0000.ethernet: set rx_delay to 0x10
```

mainline の `rk3588s.dtsi` は gmac1 を `phy-mode = "rgmii-rxid"` + `tx_delay = <0x42>`
で定義しており、RX 側のディレイは PHY 側が持つ設計。`rx_delay` を書かないのが正しく、
この警告は原因ではない。

### 2. 診断の強化

キーボードの無い実機で切り分けるため、`orangepi5/rescue.nix` の診断を拡張した
(コミット `3e73d36`)。

- `/sys/class/net/eth0/{carrier,operstate,speed,duplex,address}` を直接読む
- `/sys/class/mdio_bus/*` を列挙して `phy_id` を表示
- `ethtool eth0` を表示
- dmesg の grep に `mdio` / `fe1c0000` を追加
- 救援モード時のみ `ethtool` / `iproute2` / `usbutils` / `pciutils` を追加
- watch ループにも PHY / GMAC の行を追加

### 3. DHCP 失敗時の保険

`flake.nix` から `orangepi5.rescue.fallbackAddress = "192.168.10.50/24"` を指定し、
リンクアップしたら NetworkManager を `managed no` にして固定 IP を振る
(コミット `d8c2789`)。**リンクさえ上がれば DHCP 無しでも到達できる**状態にしてある。

### 4. イメージのビルドと焼き込み

- nixbuild.net のリモートビルダー (`ssh://authtoken@eu.nixbuild.net`) でビルド成功 (1975 秒)
- 成果物: `~/.jcode/scratch/nixos-image-orangepi5.img.zst` (1.59 GB)
- 焼き込みはユーザーが手動で実施。エージェントからの `/dev/mmcblk0` への
  リダイレクトは保護路径由でブロックされるため、
  `zstdcat <img.zst> | sudo tee /dev/mmcblk0 > /dev/null` で書き込んだ
- 4.6 GiB の書き込み完了後、`mmcblk0p1` が 4.1 GB ext4 / LABEL `NIXOS_SD` として
  認識されることを確認
- Pi を SD から起動した

### 5. 起動後の観測

Pi は HDMI では起動しているが、ネットワークに出てこない。

```
carrier: 0
operstate: down
speed: -1
address: ee:5c:7e:c0:99:e6   # ← MAC アドレスがランダムで一意ローカル
```

MDIO バスの状態:

```
/sys/class/mdio_bus/fixed-0 -> /sys/class/mdio_bus/stmmac-0
/sys/class/mdio_bus/stmmac-0/of_node ...
```

`stmmac-0` (gmac1 の MDIO バス) は存在するが、**子に PHY デバイスが居ない**。
`ethtool` 側は `PHYAD: 1`, `Transceiver: external`, `Auto-negotiation: on`,
`master-slave cfg: preferred slave`, `Speed: Unknown!` を返しており、
MAC ドライバは enable 済みで PHY の応答待ち、という状態。

## 調査で判明したこと

### カーネルとモジュール構成

- カーネル: `linuxPackages_latest` = **7.3.1** (aarch64)
- `stmmac` / `stmmac-platform` / `dwmac-rk` / `pcs_xpcs` / `phylink` はすべて
  モジュールとしてロード済み
- ただし `linux-7.3.1-modules` の `modules.dep` には **`kmod` 依存の記載が無い**
  (`grep -c kmod modules.dep` が 0)。GENERIC_PHY (MOTORCOMM_PHY,
  REALTEK_PHY など) が実カーネルでどこに居るかは実機の `lsmod` で要確認

### 検討したが否定・保留にした説

| 説 | 判定 | 根拠 |
| --- | --- | --- |
| `rx_delay` 警告が原因 | 否定 | mainline の設計通り。rgmii-rxid では書かない |
| DTB 不一致 (Wrong DTB) | ほぼ否定 | U-Boot の defconfig は正しい。DTB も mainline に存在 |
| `phy-supply` の欠落 | 否定 | mainline の orangepi-5 dts でも書かれていない |
| PHY チップが Motorcomm YT8531 | 推定 | 下記参照。確証は `phy_id` の実測待ち |
| AP isolation / VLAN 分離 | 保留 | carrier が 0 のため、まだ上位層の話に到達していない |
| MAC アドレスの一意ローカル性 | 保留 | リンク確立とは無関係。ただし気には留める |

### 実 DTB の解析（`dtc` で展開して確認）

`/nix/store/acb44r1wmpi9i7gjjsrnirb9np6k59ak-linux-7.3.1/dtbs/rockchip/rk3588s-orangepi-5.dtb`
を展開した結果、gmac1 は次の構成:

```dts
gmac1: ethernet@fe1c0000 {
    compatible = "rockchip,rk3588-gmac", "snps,dwmac-4.20a";
    status = "okay";
    clock_in_out = "output";
    phy-handle = <&rgmii_phy1>;
    phy-mode = "rgmii-rxid";
    tx_delay = <0x42>;

    mdio1: mdio {
        compatible = "snps,dwmac-mdio";
        #address-cells = <1>;
        #size-cells = <0>;

        rgmii_phy1: ethernet-phy@1 {
            compatible = "ethernet-phy-ieee802.3-c22";
            reg = <0x01>;
            reset-assert-us = <20000>;
            reset-deassert-us = <100000>;
            reset-gpios = <&gpio3 10 GPIO_ACTIVE_LOW>;   /* RK_PA2 */
        };
    };
};
```

- `phy-mode = "rgmii-rxid"` → RX ディレイは PHY 側
- `clock_in_out = "output"` → MAC が 125 MHz を PHY に供給
- `tx_delay = 0x42` (66) → TX 側は MAC で遅延
- `reg = <0x01>` → **MDIO アドレス 1** (ethtool の `PHYAD: 1` と一致)
- `reset-gpios = <gpio3 10 active-low>` → ハードウェア リセット線付き

## 最有力仮説: reset-gpio の open-drain 未設定

### なぜこれが効くか

`phy-handle` と `reg = <1>` が正しく、MAC も probe しているのに MDIO 上に PHY が
現れない、という症状は「**PHY がリセット状態から抜けられていない**」ときに典型的。
`reset-gpios` が定義されている場合、`mdio_device` の probe は次の順で進む:

1. `reset-assert-us` (20 ms) のあいだ GPIO を assert (低レベル = リセット)
2. `reset-deassert-us` (100 ms) のあいだ deassert (High-Z または High)
3. MDIO で PHY ID を read → 失敗すると `-ENODEV` で probe 中断

RK3588 の PHY リセット線は典型的に **open-drain 接続 + 10 kΩ プルアップ**で、
PHY 内部にもプルアップがある。ここで GPIO を push-pull の「High 出力」にすると、
PHY 側のプルダウン / 内部バイアスと**ドライバ衝突を起こしてリセットが解除されない**
(または中間電位に張り付く)。結果、PHY ID が読めず MDIO 上にデバイスが現れない。

gmac1 の `pinctrl-0` は次の 5 つだけで、**GPIO の電気特性 (drive / open-drain) を
設定するノードは含まれていない**（実 DTB から確認）:

```
gmac1-miim, gmac1-tx-bus2, gmac1-rx-bus2, gmac1-rgmii-clk, gmac1-rgmii-bus
```

つまり reset 線 `gpio3 RK_PA2` の電気特性は、RK3588 の GPIO コントローラ既定値
（push-pull）のまま使われる。ここを open-drain にするには、DTS に
`pinctrl` サブノードを足して `pinctrl-0` に加える必要がある。

> **注意**: この節は現時点では**仮説**であり、実機で PHY の `phy_id` が読めない
> ことの説明として妥当、というレベル。open-drain が本当に必要かは PHY チップの
> 型番とボードの回路図で確定させるべき。確認せずにパッチを当てると、
> 別の原因（PHY ドライバ未ロード、`reg` アドレス違い）を隠してしまう。

### 確認方法（キーボード無しで可能）

1. **HDMI のログで `--- mdio bus / phy devices ---` を再確認**
   - PHY が 1 台も出ない = PHY が MDIO に応答していない (本仮説と整合)
   - `phy_id=0x...` が出る = 別の原因 (MAC 側の設定 or リンク)
2. **`ethtool eth0` の `Speed` が `Unknown!` のまま** = auto-negotiation が
   PHY と会話できていない
3. **`reset-gpios` の有効性を確認**: 実機で
   `cat /sys/kernel/debug/gpio` (debugfs マウント要) を見ると
   `gpio-«N» (PHY reset)` のようなラベルが確認できるはず。ラベルが無ければ
   `reset-gpios` が無視されている = DTS がリセット線を拾えていない

## 環境メモ

| 項目 | 値 |
| --- | --- |
| リポジトリ | `/home/coma/.ghq/github.com/Comamoca/dotfiles` |
| 救援モジュール | `orangepi5/rescue.nix` |
| イメージ定義 | `orangepi5/image.nix` (GPT + raw U-Boot、16 MiB 予約) |
| カーネル | `linuxPackages_latest` = 7.3.1 |
| リモートビルダー | `ssh://authtoken@eu.nixbuild.net` |
| 主ホスト | `192.168.10.7` (wlo1)、GW は `.1`、Tailscale は `100.71.62.7` |
| SSH | 鍵認証のみ。`PasswordAuthentication = false`、`PermitRootLogin = "no"` |
| コンソール | `console=tty1` (HDMI) と `console=ttyS2,1500000` (UART) |

## 次にやること

優先度順。

1. **HDMI の診断ログで `--- mdio bus / phy devices ---` を再確認**
   PHY が 0 台なら本仮説で確定に近づく。
2. **PHY の reset 線を open-drain にする DTS オーバーレイを試す**
   - 一時: `/boot/overlays` ではなく U-Boot の `fdt apply` か、`boot.kernelPatches`
     で `rk3588s-orangepi-5.dts` にパッチを当てる
   - あるいは `dtbo` を `extlinux.conf` の `devicetree` 行で差し替える
3. **代替: `snps,dwmac-mdio` の PHY アドレスを走査する**
   `reg = <1>` が合っているか、0〜31 を sweep する診断を rescue に足す。
   (PHY が別アドレスに居る、という可能性を潰す)
4. **代替: MAC の `phy-mode` を `rgmii-id` に変えて試す**
   RX ディレイを MAC 側で生成するモード。PHY 側の設定が効いていない場合の回避策。
5. **リンクが上がったら上位層の切り分け**
   - `carrier: 1` になったら `192.168.10.50` で ping
   - 不通なら AP isolation / VLAN / スイッチポートを疑う
   - `tcpdump` は rescue に入れていないので、必要なら追加

## 未解決の疑問

- MAC アドレスが `ee:5c:7e:c0:99:e6` になっている。先頭オクテット `0xee`
  (ビット 0 = マルチキャスト、ビット 1 = ローカル管理) が立っており、
  OTP 由来の MAC ではなく**ランダム生成されたもの**と判断できる。
  DTB に `local-mac-address` / `nvmem-cells` が無いため。
  リンク確立の阻害要因ではないが、DHCP のリースや運用上は固定したい
  (U-Boot の `ethaddr` か DTS の `nvmem-cells` で解決できる)。
- `linux-7.3.1-modules` の `modules.dep` に `kmod` が無い件。GENERIC_PHY が
  組み込みなら問題ないが、モジュールなら PHY ドライバがロードされていない
  可能性がある。実機の `lsmod | grep -E 'motorcomm|realtek|phylib'` で確認したい。
