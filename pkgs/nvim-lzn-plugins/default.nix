# nvim-lzn: NVIM_APPNAME=nvim-lzn 用のプラグイン packDir
#
# home-manager の programs.neovim は ~/.config/nvim と ~/.local/share/nvim/site
# をハードコードしていて appName を変えられないため、生の neovimUtils.packDir を
# 使って ~/.local/share/nvim-lzn/site/pack/nix/{start,opt} を作る。
#
# packDir はプラグインの pname をディレクトリ名にする (lz-n → lz.n, oil-nvim →
# oil.nvim) ので、lz.n のプラグイン名指定とそのまま一致する。
#
# 注意:
# - pnpm/luarocks 由来の依存は packpath から解決されないので、依存プラグインを
#   明示的に start に足すこと (telescope には plenary が必要)。
# - lze など lz.n が動く本体だけを start に置き、残りは opt で遅延ロード。
{
  pkgs,
  # 試用段階のプラグイン (config/nvim-lzn に合わせる):
  # mini.nvim, snacks.nvim, telescope.nvim, lsp, treesitter, oil.nvim, fern.nvim
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
        plenary-nvim # telescope などの依存
        nvim-treesitter.withAllGrammars
      ];
      opt = optPlugins;
    };
  };

  # ~/.local/share/nvim-lzn/site/pack になる derivation。
  # home.packages に入れれば ~/.nix-profile/share が packpath に入る (generation
  # のロールバックがそのまま効く)。
in
pkgs.runCommand "nvim-lzn-plugins" { } ''
  mkdir -p $out/share/nvim-lzn/site
  ln -s ${packDir}/pack $out/share/nvim-lzn/site/pack
''
