# nvl: 自己完結した Neovim パッケージ (NVIM_APPNAME=nvl)
#
# プラグインと設定を Nix store に閉じ込め、home-manager に依存しない。
#   nix run .#nvl          -- そのまま起動
#   nix build .#nvl        -- ./result/bin/nvim で起動
{
  pkgs,
  neovim,
  configSrc ? ./config,
  optPlugins ? with pkgs.vimPlugins; [
    telescope-nvim
    oil-nvim
    vim-fern
    snacks-nvim
    mini-nvim
    nvim-lspconfig
    kanagawa-nvim
  ],
}:
let
  packDir = pkgs.neovimUtils.packDir {
    nix = {
      start = with pkgs.vimPlugins; [
        lz-n
        plenary-nvim
        nvim-treesitter.withAllGrammars
      ];
      opt = optPlugins;
    };
  };

  # XDG_CONFIG_HOME 相当: NVIM_APPNAME=nvl なので nvl/init.lua に配置。
  configHome = pkgs.runCommand "nvl-config" { } ''
    mkdir -p $out/nvl
    cp ${configSrc}/init.lua $out/nvl/init.lua
  '';

  # XDG_DATA_DIRS は NVIM_APPNAME=nvl で nvl/site を探すため、
  # --cmd set packpath+= で nvim/site パスを明示注入する。
  dataDir = pkgs.runCommand "nvl-data" { } ''
    mkdir -p $out/share/nvim/site
    ln -s ${packDir}/pack $out/share/nvim/site/pack
  '';
in
pkgs.writeShellScriptBin "nvim" ''
  export XDG_CONFIG_HOME="${configHome}"
  export NVIM_APPNAME="nvl"
  exec ${neovim}/bin/nvim \
    --cmd "set packpath+=${dataDir}/share/nvim/site" \
    "$@"
''