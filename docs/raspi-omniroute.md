# Raspberry Pi 3 での OmniRoute 常駐

`raspi` (aarch64, Pi 3, 928MiB) で OmniRoute を rootless Docker + systemd user
service で常駐させる。設定は `raspi/omniroute.nix` (NixOS モジュール)、秘密は
`secrets/raspi/omniroute.yaml` (sops) にある。

## 構成

| 項目 | 値 |
| --- | --- |
| 稼働ユーザー | `coma` (linger 有効) |
| user unit | `omniroute.service`, `omniroute-pricing.service` |
| Docker | rootless (`unix://%t/docker.sock`)、rootful dockerd は無効 |
| dashboard + `/v1` | `0.0.0.0:20128` (firewall は `tailscale0` のみ許可) |
| server API | `127.0.0.1:20129` (Pi 内部からのみ) |
| データ | named volume `omniroute-data` (`/app/data`) |
| Node ヒープ | `--max-old-space-size=384` |
| swap | zram (RAM の 50%) |

`services.tailscale` は `authKeyFile` に sops の `TAILSCALE_AUTH_KEY` を使う。
Pi は tailnet 経由でのみ到達でき、LAN からは 20128 に届かない。

## ビルド

aarch64 のビルドは comabook の binfmt エミュレーションで行う
(`boot.binfmt.emulatedSystems = [ "aarch64-linux" ]`)。

```bash
# 評価だけで確認する
nix eval --impure --raw .#nixosConfigurations.raspi.config.system.build.toplevel.drvPath

# toplevel の実ビルド
nix build .#nixosConfigurations.raspi.config.system.build.toplevel --no-link -L

# SD イメージ (nixos-image-sd-card-*.img.zst)
# --out-link で result とは別の名前にする。home-manager の build が result を
# 取り違えるのを避けるため。
nix build .#nixosConfigurations.raspi.config.system.build.sdImage -L --out-link result-raspi
```

`sdImage` の成果物は `result-raspi` (`/nix/store/...-nixos-image-sd-card-*.img.zst`)
に置かれる。`readlink -f result-raspi` で store path を確認してから書き込む。
実体は `sd-image/nixos-image-sd-card-*.img.zst` として store に並ぶ。

Pi 3 のカーネルは nixos-hardware の `raspberry-pi-3` が選ぶ vendor カーネル
(`linux-rpi`) をそのまま使う。mainline に上げると HDMI 無出力や U-Boot での停止を
起こすため上書きしない。ブートは firmware → U-Boot → extlinux → kernel の順で、
`hardware.raspberry-pi.firmware.uboot.enable` が `config.txt` とファームウェア
パーティションを用意する。

## SD カードへの書き込み

イメージを書いたあと、**必ず SSH ホスト鍵を注入する**。sops の復号鍵
(`age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]`) はこのホスト鍵から
導出されており、`.sops.yaml` の `&raspi` は `~/.config/raspi/` にある鍵の
公開鍵と一致している。Pi が新しいホスト鍵を生成すると、WiFi パスワードも
Tailscale の認証キーも復号できず、ネットワークに出られないまま止まる。

```bash
lsblk                       # 書き込み先を確認する (以下 /dev/sdX とする)
zstd -dc result-raspi/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
sync
```

```bash
sudo mkdir -p /mnt/rootfs
sudo mount /dev/sdX2 /mnt/rootfs
sudo install -d -m 755 /mnt/rootfs/etc/ssh
sudo install -m 600 ~/.config/raspi/ssh_host_ed25519_key     /mnt/rootfs/etc/ssh/
sudo install -m 644 ~/.config/raspi/ssh_host_ed25519_key.pub /mnt/rootfs/etc/ssh/
sudo umount /mnt/rootfs
```

`sops.age.sshKeyPaths` が指す鍵の指紋を変える場合 (ホスト鍵を作り直した場合) は、
`.sops.yaml` の `&raspi` を更新して `secrets/raspi/*.yaml` を `sops updatekeys`
で再暗号化する。Pi の `age` 公開鍵は次で得る。

```bash
nix run nixpkgs#ssh-to-age -- -i ~/.config/raspi/ssh_host_ed25519_key.pub
```

## SSH アクセス

tailnet 経由の SSH は `services.tailscale.extraUpFlags = [ "--ssh" ]` により、
tailscaled が持つ SSH サーバーが受け持つ。接続を試すと追加チェック用の URL が
表示され、ブラウザで承認するまでセッションは開かない。

```text
# Tailscale SSH requires an additional check.
# To authenticate, visit: https://login.tailscale.com/a/<nonce>
```

`services.openssh` も有効だが `PasswordAuthentication = false` なので、
パスワードでの SSH ログインはできない。`openssh.authorizedKeys.keys` の
`coma@comabook` が Tailscale SSH の鍵認証に使われる。

接続元の `~/.ssh/known_hosts` に古い Raspberry Pi のエントリが残っていると、
`REMOTE HOST IDENTIFICATION HAS CHANGED` で接続が拒まれる。焼き直したイメージの
ホスト鍵指紋は次の値で照合する。

```bash
ssh-keygen -lf ~/.config/raspi/ssh_host_ed25519_key.pub
# 256 SHA256:u6N6JFoOuKiddlpgByHHU6EbSG/1V7E9lPjq3v8imJU raspi (ED25519)
```

```bash
ssh-keygen -R raspi
ssh-keygen -R raspi.tailbd3ca7.ts.net
ssh-keygen -R 100.96.42.88
```

## 初回起動の確認

シリアルか HDMI でコンソールに入る。`users.users.coma.initialPassword` は
`changeme` なので、初回ログイン後に `passwd` で変更する。このパスワードは
コンソール専用で、SSH のパスワード認証は `PasswordAuthentication = false` の
ため効かない (`initialPassword` は初回起動時にだけ適用される)。

なお `secrets/raspi/omniroute.yaml` の `INITIAL_PASSWORD` は
`/run/secrets/rendered/omniroute-env` に描画されるだけで、ユーザアカウントの
パスワードには使われていない。コンソールのパスワードも sops 側に寄せたい場合は
`users.users.coma.initialPassword` を `sops.placeholder` に置き換える必要が
ある (現状は未対応)。

```bash
# 秘密の復号と配置
sudo ls -l /run/secrets/rendered/omniroute-env
systemctl status sops-install-secrets

# user unit
systemctl --user status omniroute
journalctl --user -u omniroute -b --no-pager | tail -50

# コンテナ (docker CLI は rootless なので socket を明示する)
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
docker-compose -f /etc/omniroute/docker-compose.yml ps
docker ps
```

nixpkgs の `docker` には compose プラグインが同梱されないので、`docker compose`
ではなく `docker-compose` を使う (`raspi/configuration.nix` の
`environment.systemPackages` に入っている)。socket は rootless デーモンの
`unix:///run/user/1000/docker.sock` で、対話シェルでは `DOCKER_HOST` を自分で
設定する必要がある。

`ExecStartPre` は sops が envFile を描画するまで最大 3 分待つ (user unit と
system unit は manager が別で、起動順序が保証されないため)。この待ちで
タイムアウトする場合は `sops-install-secrets` の失敗、つまりホスト鍵の不一致を
先に疑う。

HTTP の疎通は API キーで確認する。`REQUIRE_API_KEY=true` なので未認証の
`/v1/models` は 401 を返す。

```bash
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:20128/v1/models          # 401
curl -sS -H "Authorization: Bearer $OMNIROUTE_API_KEY" \
  http://raspi:20128/v1/models | jq '.data | length'
```

## クライアント側の接続先

Pi の OmniRoute は comabook のインスタンスと同じ API 形状 (`/v1`,
OpenAI 互換, `OMNIROUTE_API_KEY`) なので、クライアントの `baseURL` を
`http://raspi:20128/v1` (MagicDNS) か `http://100.96.42.88:20128/v1` に変えるだけで
切り替わる。認証キーは Pi 側の `OMNIROUTE_API_KEY` を使う。

### 現状 (2026-11-01)

すべてのクライアントは comabook ローカルの OmniRoute (`http://127.0.0.1:20128/v1`)
を指している。Pi のインスタンスは build 済みだが、クライアントはまだそちらを
参照していない。

| 利用者 | 参照先 | 変更方法 |
| --- | --- | --- |
| dsh (`tui` / `headless` / `web` / `acp`) | `~/.dsh/profiles/<profile>/cordis.patch.yml` の `provider.omniroute.baseURL` | ファイルを編集 |
| OpenCode | `~/.config/opencode/opencode.json` の `provider.omniroute.options.baseURL` | ファイルを編集 |
| OpenCode の combos プラグイン | `config/opencode/plugins/omniroute-combos.ts` の `BASE_URL` | `OMNIROUTE_BASE_URL` 環境変数で上書き可 |
| OmniGent | `omnigent.nix` の `omnirouteBase` | `home-manager switch --flake .#Home --impure` |
| jcode | `~/.jcode/config.toml` の `[[providers.omniroute]]` | ファイルを編集 |
| combos の生成 (`omniroute-combos`) | `bin/scripts/omniroute-combos/omniroute-combos` | `OMNIROUTE_URL` / `OMNIROUTE_ENV_FILE` |

`~/.jcode/config.toml` の `[[providers.omniroute.models]]` は `omniroute-combos` が
マーカー区間の中だけ書き換える (`# >>> omniroute-combos (jcode models) >>>` から
`# <<< omniroute-combos (jcode models) <<<` まで)。jcode には設定の include 機構が
無いので、区間の外に同じ id を宣言すると TOML の二重定義になって読み込みが失敗する。
区間の外へ手でモデルを足さないこと。jcode は `config.toml` を監視しないので、
生成後はデーモンの再起動が要る。

`dsh` の `acp` / `web` / `headless` プロファイルは `provider.omniroute` を
持っているが、`tui` は既定の provider (OmniRoute ではない) を使う。

### Pi へ切り替える手順

1. Pi の API キーを comabook 側で環境変数へ読み込む。

```bash
cd /home/coma/.ghq/github.com/Comamoca/dotfiles
export OMNIROUTE_API_KEY="$(nix run nixpkgs#sops -- -d secrets/raspi/omniroute.yaml 2>/dev/null \
  | awk -F': ' '/^OMNIROUTE_API_KEY/ {print $2}')"
# 値を標準出力に出さないこと
```

2. 上の表の接続先を `http://raspi:20128/v1` に変更する。
3. OpenCode の combos プラグインは `OMNIROUTE_BASE_URL=http://raspi:20128/v1` を
   付けて起動する (プラグインは環境変数を優先する)。
4. 疎通を確認する。

```bash
curl -sS -H "Authorization: Bearer $OMNIROUTE_API_KEY" \
  http://raspi:20128/v1/models | jq '.data | length'
```

Pi 側のモデル一覧は comabook と独立している。combo を増やす場合は Pi の
ダッシュボードで追加したうえで、クライアントの一覧を再生成する。

## 運用

- 価格表の更新: `systemctl --user list-timers omniroute-pricing.timer`、
  実行ログは `journalctl --user -u omniroute-pricing`。
- イメージ更新: `raspi/omniroute.nix` の `image` タグを上げて `sdImage` を焼き直す。
  データは volume にあるので、`docker-compose down -v` や volume の削除はしない。
- バックアップ: `omniroute-data` volume と sops の復号に必要なホスト鍵
  (`~/.config/raspi/ssh_host_ed25519_key`) の両方が必要。鍵を失うと復号できない。

## トラブルシュート

| 症状 | 見る場所 |
| --- | --- |
| `Tailscale SSH requires an additional check` | 表示された URL をブラウザで承認する (承認前はセッション確立しない) |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` | `ssh-keygen -R <host>` で古い known_hosts エントリを削除する |
| `ExecStartPre` が 3 分で失敗 | `systemctl status sops-install-secrets`、ホスト鍵の指紋 |
| unit が `activating` のまま | `journalctl --user -u omniroute`、`docker-compose logs` |
| OOM で落ちる | `journalctl -k` の OOM killer ログ、`NODE_OPTIONS` と zram |
| 20128 に外から届かない | `tailscale status`、`nft list ruleset` の `tailscale0` |
| compose が起動しない | `docker-compose -f /etc/omniroute/docker-compose.yml config` |

## チェックリスト

実機投入時に順に確認する。

- [ ] SD イメージの build が完了し、`result-raspi` が正しい store path を指している。
- [ ] SD カードへ書き込み後、`ssh_host_ed25519_key` と `.pub` を
      `/etc/ssh/` に配置した。
- [ ] Pi を起動し、コンソールまたは Tailscale SSH で到達できる。
- [ ] Tailscale SSH の追加 Web 認証を完了し、`ssh raspi` が通る。
- [ ] `sudo ls -l /run/secrets/rendered/omniroute-env` の権限を確認し、
      `systemctl status sops-install-secrets` が成功している。
- [ ] `systemctl --user status omniroute omniroute-pricing` が active になっている。
- [ ] `DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock docker ps` でコンテナが
      Up している。
- [ ] `127.0.0.1:20128/v1/models` は 401、`OMNIROUTE_API_KEY` 付きではモデル一覧が
      返る。
- [ ] `ss -tlnp` で `20128` が `0.0.0.0`、`20129` が `127.0.0.1` のみ listen して
      いる。
- [ ] OpenCode / dsh / OmniGent の `baseURL` を `http://raspi:20128/v1` に変更する。
- [ ] クライアントから実際にリクエストが飛び、応答が返る。
- [ ] ロールバック用に、動作していた SD カードまたは store path を保管する。

## ロールバック

SD イメージを焼き直す運用なので、戻す単位はイメージ単位になる。

1. 焼く前のイメージか、動作していた SD カードを保管しておく。
2. Pi 上で戻す場合は `sudo nixos-rebuild switch --rollback` か、`/boot` の
   extlinux から旧世代を選ぶ。
3. 旧世代に戻すと `omniroute.service` の定義も戻る。volume は unit 削除では
   消えないので、データは残る。
