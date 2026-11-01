<div align="center">

![Repository Stars](https://img.shields.io/github/stars/Comamoca/dotfiles?style=flat-square)
![Last commit](https://img.shields.io/github/last-commit/Comamoca/dotfiles?style=flat-square)
![Issues](https://img.shields.io/github/issues/Comamoca/dotfiles?style=flat-square)
![Open Issues](https://img.shields.io/github/issues-raw/Comamoca/dotfiles?style=flat-square)
![Bug Issues](https://img.shields.io/github/issues/Comamoca/dotfiles/bug?style=flat-square)

<img src="https://emoji2svg.deno.dev/api/🦊" alt="eyecatch" height="100">

# Dotfiles

This is Comamoca's dotfiles repository.

<img src="https://r2.comamoca.dev/unixporn-nixos.jpg" alt="Desktop Image" width="400">

<br>
<br>

</div>

<div align="center">

</div>

## 🔧 Stack

- NixOS
- Niri
- fish
- Neovim
- and more...

## ⬆️ How to update

### ❄ Flake

```sh
nix flake update
```

## ✨ Apply changes

### ❄ NixOS

```sh
sudo nixos-rebuild switch --flake .#Home
```

### 🏠 Home manager

```sh
home-manager switch --flake .#Home
```

## 🧭 Local services

- [OmniRoute](omniroute.nix) — LLM ゲートウェイ / dashboard
  (`http://127.0.0.1:20128`)。外部からは `https://omniroute.comamoca.dev`
  (Cloudflare Tunnel `cloudflared-omniroute` + Access アプリ `omniroute`。
  許可は `comamoca.dev@gmail.com` のみ)
  - combo は dashboard で追加するだけでよい。`omniroute-combos.timer` (30
    分間隔) が `GET /v1/models` から一覧を生成し、opencode
    (`omniroute-combos.ts` プラグイン) と dsh (`cordis.patch.yml` の
    `models: !!js ...`) に配る。手で回すなら
    `~/.bin/scripts/omniroute-combos/omniroute-combos`（`--check` で差分確認）。
    opencode は次回起動、dsh は再起動で反映。

## 📖 License

Unlicense

### catppuccin

- [nix](https://github.com/catppuccin/nix)
- [fish](https://github.com/catppuccin/fish)
- [swaync](https://github.com/catppuccin/swaync)
- [bat](https://github.com/catppuccin/bat)
- [kitty](https://github.com/catppuccin/kitty)
- [rofi](https://github.com/catppuccin/rofi)
