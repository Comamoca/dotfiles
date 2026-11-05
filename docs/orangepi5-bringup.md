# Orange Pi 5 (RK3588S) NixOS 立ち上げ記録

作成: 2026-11-01 / 対象: `orangepi5/` 配下のモジュールと SD イメージ

## 現状サマリ

> **2026-11-04 追記**: このファイルの「PHY が MDIO に居ない」「open-drain が
> 原因」という結論は、その後の実機観測 (eth1 が up していた) と矛盾する。
> 最新の整理は末尾の「2026-11-04 追記」を参照。以下の経緯は当時の記録として
> 残す。

| 項目                | 状態 (2026-11-01 時点)                        |
| ------------------- | --------------------------------------------- |
| SD からの起動       | 成功 (HDMI でコンソール確認済み)              |
| 有線 eth0 リンク    | **未確立** (`carrier: 0`、`operstate: down`)  |
| LAN / SSH 到達      | 不可 (fallback の `192.168.10.50` にも不通)   |
| gmac (MAC) の probe | 成功。`stmmac-0` の MDIO バスは生成されている |
| PHY の認識          | **失敗**。MDIO バス上に PHY デバイスが 0 台   |

当時は故障箇所を「MAC と PHY の間の MDIO 通信」に絞り、PHY の reset-gpio (実際は
**gpio3 RK_PB2 = pin 10**。当時のメモは RK_PA2 と誤記) が open-drain に
設定されていないことを疑った。この仮説は後に否定されている。

## 経緯

### 1. rx_delay 警告は無害と確定

起動ログに毎回出る次の 2 行は**正常**。

```
rk_gmac-dwmac fe1c0000.ethernet: Can not read property: rx_delay.
rk_gmac-dwmac fe1c0000.ethernet: set rx_delay to 0x10
```

mainline の `rk3588s.dtsi` は gmac1 を `phy-mode = "rgmii-rxid"` +
`tx_delay = <0x42>` で定義しており、RX 側のディレイは PHY
側が持つ設計。`rx_delay` を書かないのが正しく、 この警告は原因ではない。

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

`flake.nix` から `orangepi5.rescue.fallbackAddress = "192.168.10.50/24"`
を指定し、 リンクアップしたら NetworkManager を `managed no` にして固定 IP
を振る (コミット `d8c2789`)。**リンクさえ上がれば DHCP
無しでも到達できる**状態にしてある。

### 4. イメージのビルドと焼き込み

- nixbuild.net のリモートビルダー (`ssh://authtoken@eu.nixbuild.net`)
  でビルド成功 (1975 秒)
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
`master-slave cfg: preferred slave`, `Speed: Unknown!` を返しており、 MAC
ドライバは enable 済みで PHY の応答待ち、という状態。

## 調査で判明したこと

### カーネルとモジュール構成

- カーネル: `linuxPackages_latest` = **7.3.1** (aarch64)
- `stmmac` / `stmmac-platform` / `dwmac-rk` / `pcs_xpcs` / `phylink` はすべて
  モジュールとしてロード済み
- ただし `linux-7.3.1-modules` の `modules.dep` には **`kmod` 依存の記載が無い**
  (`grep -c kmod modules.dep` が 0)。GENERIC_PHY (MOTORCOMM_PHY, REALTEK_PHY
  など) が実カーネルでどこに居るかは実機の `lsmod` で要確認

### 検討したが否定・保留にした説

| 説                            | 判定     | 根拠                                                 |
| ----------------------------- | -------- | ---------------------------------------------------- |
| `rx_delay` 警告が原因         | 否定     | mainline の設計通り。rgmii-rxid では書かない         |
| DTB 不一致 (Wrong DTB)        | ほぼ否定 | U-Boot の defconfig は正しい。DTB も mainline に存在 |
| `phy-supply` の欠落           | 否定     | mainline の orangepi-5 dts でも書かれていない        |
| PHY チップが Motorcomm YT8531 | 推定     | 下記参照。確証は `phy_id` の実測待ち                 |
| AP isolation / VLAN 分離      | 保留     | carrier が 0 のため、まだ上位層の話に到達していない  |
| MAC アドレスの一意ローカル性  | 保留     | リンク確立とは無関係。ただし気には留める             |

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
            reset-gpios = <&gpio3 10 GPIO_ACTIVE_LOW>;   /* RK_PB2 (pin 10) */
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
現れない、という症状は「**PHY
がリセット状態から抜けられていない**」ときに典型的。 `reset-gpios`
が定義されている場合、`mdio_device` の probe は次の順で進む:

1. `reset-assert-us` (20 ms) のあいだ GPIO を assert (低レベル = リセット)
2. `reset-deassert-us` (100 ms) のあいだ deassert (High-Z または High)
3. MDIO で PHY ID を read → 失敗すると `-ENODEV` で probe 中断

RK3588 の PHY リセット線は典型的に **open-drain 接続 + 10 kΩ プルアップ**で、
PHY 内部にもプルアップがある。ここで GPIO を push-pull の「High 出力」にすると、
PHY 側のプルダウン /
内部バイアスと**ドライバ衝突を起こしてリセットが解除されない**
(または中間電位に張り付く)。結果、PHY ID が読めず MDIO 上にデバイスが現れない。

gmac1 の `pinctrl-0` は次の 5 つだけで、**GPIO の電気特性 (drive / open-drain)
を 設定するノードは含まれていない**（実 DTB から確認）:

```
gmac1-miim, gmac1-tx-bus2, gmac1-rx-bus2, gmac1-rgmii-clk, gmac1-rgmii-bus
```

つまり reset 線 `gpio3 RK_PB2` (pin 10) の電気特性は、RK3588 の GPIO
コントローラ 既定値（push-pull）のまま使われる。ここを open-drain
にするには、DTS に `pinctrl` サブノードを足して `pinctrl-0` に加える必要がある。

> **2026-11-04 追記**: この仮説は否定された。Rockchip の pinctrl ドライバは
> `PIN_CONFIG_DRIVE_OPEN_DRAIN` を実装しておらず、DTS では指定できない。
> また当時のパッチは RK_PA2 (pin 2) を触っており、実際の reset 線 RK_PB2
> (pin 10) と一致していなかった。パッチ/overlay はビルドに配線も
> されていない。`orangepi5/patches/` と `orangepi5/dts/` のファイルは
> 未使用の実験として残っているが、適用しないこと。

> **注意**: この節は現時点では**仮説**であり、実機で PHY の `phy_id` が読めない
> ことの説明として妥当、というレベル。open-drain が本当に必要かは PHY チップの
> 型番とボードの回路図で確定させるべき。確認せずにパッチを当てると、
> 別の原因（PHY ドライバ未ロード、`reg` アドレス違い）を隠してしまう。

### 確認方法（キーボード無しで可能）

1. **HDMI のログで `--- mdio bus / phy devices ---` を再確認**
   - PHY が 1 台も出ない = PHY が MDIO に応答していない (本仮説と整合)
   - `phy_id=0x...` が出る = 別の原因 (MAC 側の設定 or リンク)
2. **`ethtool eth0` の `Speed` が `Unknown!` のまま** = auto-negotiation が PHY
   と会話できていない
3. **`reset-gpios` の有効性を確認**: 実機で `cat /sys/kernel/debug/gpio`
   (debugfs マウント要) を見ると `gpio-«N» (PHY reset)`
   のようなラベルが確認できるはず。ラベルが無ければ `reset-gpios`
   が無視されている = DTS がリセット線を拾えていない

## 環境メモ

| 項目             | 値                                                                     |
| ---------------- | ---------------------------------------------------------------------- |
| リポジトリ       | `/home/coma/.ghq/github.com/Comamoca/dotfiles`                         |
| 救援モジュール   | `orangepi5/rescue.nix`                                                 |
| イメージ定義     | `orangepi5/image.nix` (GPT + raw U-Boot、16 MiB 予約)                  |
| カーネル         | `linuxPackages_latest` = 7.3.1                                         |
| リモートビルダー | `ssh://authtoken@eu.nixbuild.net`                                      |
| 主ホスト         | `192.168.10.7` (wlo1)、GW は `.1`、Tailscale は `100.71.62.7`          |
| SSH              | 鍵認証のみ。`PasswordAuthentication = false`、`PermitRootLogin = "no"` |
| コンソール       | `console=tty1` (HDMI) と `console=ttyS2,1500000` (UART)                |

## 2026-11-04 追記: 原因の再整理

### 観測し直した事実

- PC (`eno2`) と Pi の直結で、PC 側は `carrier=1` / 1000 Mbps full duplex。
  ケーブルと Pi の PHY は生きている。
- しかし 15 秒間のカウンタサンプルで Pi からのフレームは **RX 0 / TX 0**。
  tcpdump でも Pi 由来の ARP / DHCP / IPv6 は一切出ない。
- DHCP サーバ (dnsmasq) は停止中で、leases も空。直結区間に DHCP サーバが
  居ないため、直結で DHCP が取れないのは Pi の状態以前に当然。
- 実機は過去に **eth1 が up** していた (コミット `706e8e9`)。 「eth0
  が無い」ため fallback の `eth0` 決め打ちが外れていた、という記録がある。
  これは「PHY が MDIO に居ない」という当時の結論と矛盾する。

### 原因の整理

1. **Pi が起動しきっていない / ブートループ** (最有力) PHY は給電だけで
   auto-negotiation するため、PC 側の link up は OS 起動の 証拠にならない。0
   フレームはネットワークスタック非稼働の直接証拠。 電源不足・SD 破損・U-Boot
   相性が候補。
2. **起動しているが有線 netdev が up しない** (carrier 0 / MDIO 不整合)
3. **設定バグで DHCP が走らない** fallback サービスが
   `nmcli device set <if> managed no` を実行し、 復旧スクリプトは `eth0`
   固定で戻そうとしたため、実機の `eth1` が unmanaged
   のまま残った。これが「直結では .50 で入れたのに、ルータへ 移すと DHCP
   が取れない」の直接原因として最も筋が通る。

### 2026-11-04 に行った修正

- `flake.nix` から `orangepi5.rescue.fallbackAddress` を外した (既定の null)。
  有線は NetworkManager の DHCP に一本化する。fallback を有効にすると
  `managed no` が残り、DHCP を妨げるため。
- `orangepi5/rescue.nix` の fallback オプション説明とサービス定義に、
  `managed no` がサービス停止後も残る旨の警告を追加した。
- PHY reset の open-drain 仮説は否定。`orangepi5/patches/` と `orangepi5/dts/`
  の実験ファイルは未使用のまま残しているが、適用しない。

### 固定 IP 設定 (2026-11-04)

DHCP 依存を避けるため、有線 LAN に `192.168.10.250/24` を固定で設定した。

- 管理方式は既存の NetworkManager のまま。dhcpcd / systemd-networkd
  は追加しない。
- `networking.networkmanager.ensureProfiles.profiles` で `orangepi5-lan-eth0` /
  `orangepi5-lan-eth1` の 2 プロファイルを宣言する。 mainline DTS では有線 IF が
  eth0 / eth1 のどちらにもなり得るため。
- ゲートウェイと DNS は Aterm (`192.168.10.1`)。
- Aterm の DHCP 配布範囲と `.250` の重複は管理画面で未確認。DHCP 範囲外の 未使用
  IP であることを前提にしている。
- `nixos-rebuild build --flake .#orangepi5` と
  `nix build .#nixosConfigurations.orangepi5.config.system.build.sdImage`
  は成功。
- 実機への焼き直し・再起動後の SSH / インターネット確認は未実施。

## 次にやること

優先度順。

1. **物理層と電源**: Pi の電源 LED / LAN LED を確認。5V/4A 以上の良質な電源に
   交換。SD を最新イメージで焼き直す。
2. **シリアルコンソール** (`ttyS2`, 1500000) で起動ログを取る。
   `console=ttyS2,1500000` は既に設定済み。これが最短の切り分け。
3. **直結で試す場合の PC 側の前提**:
   - `eno2` に `192.168.10.51/24` を付ける。ただし `wlo1` も `192.168.10.0/24`
     なので、一時的に `wlo1` のアドレスを外すか、 fallback
     を別サブネットにする。
   - `dnsmasq` を `eno2` で起動する。
   - `tcpdump -ni eno2` とカウンタで Pi の送信有無を確認する。
4. **Pi のコンソールで確認**:
   - `ip -br link` / `cat /sys/class/net/*/carrier`
   - `ls -d /sys/class/mdio_bus/*/*`
   - `dmesg | grep -iE 'stmmac|dwmac|mdio|phy|link'`
   - `nmcli device status`
5. **DHCP が取れたら**: fallback が無効なことを確認し、必要なら
   `orangepi5-watch` のログでリンク状態を追う。

## 未解決の疑問

- MAC アドレスが `ee:5c:7e:c0:99:e6` になっている。先頭オクテット `0xee` (ビット
  0 = マルチキャスト、ビット 1 = ローカル管理) が立っており、 OTP 由来の MAC
  ではなく**ランダム生成されたもの**と判断できる。 DTB に `local-mac-address` /
  `nvmem-cells` が無いため。 リンク確立の阻害要因ではないが、DHCP
  のリースや運用上は固定したい (U-Boot の `ethaddr` か DTS の `nvmem-cells`
  で解決できる)。
- `linux-7.3.1-modules` の `modules.dep` に `kmod` が無い件。GENERIC_PHY が
  組み込みなら問題ないが、モジュールなら PHY ドライバがロードされていない
  可能性がある。実機の `lsmod | grep -E 'motorcomm|realtek|phylib'`
  で確認したい。
