-- nvim-lzn: nix (neovimUtils.packDir) + lz.n による試用環境
-- 既存 ~/.config/nvim (dpp) とは完全に別環境:
--   alias nvl='NVIM_APPNAME=nvim-lzn nvim'
--
-- プラグインは以下に絞る (pkgs/nvim-lzn-plugins/default.nix):
--   mini.nvim, snacks.nvim, telescope.nvim, lsp (nvim-lspconfig),
--   treesitter, oil.nvim, fern.nvim
-- 既存プラグインの設定は config/nvim (dpp.toml / dpp_lazy.toml / lua/) から流用。

if vim.loader then
  vim.loader.enable()
end

----------------------------------------------------------------
-- 基本設定 (config/nvim/init.lua 流用)
----------------------------------------------------------------
vim.cmd([[const mapleader = " "]])
vim.cmd([[let maplocalleader = ' ']])
vim.cmd("inoremap jj <C-[>")
vim.cmd("nnoremap <C-[><C-[> <cmd>noh<CR>")
vim.cmd("nnoremap sv <cmd>vs<CR>")
vim.cmd("nnoremap s <C-w>")
vim.cmd("set ignorecase")
vim.cmd("set termguicolors")
vim.cmd("au FileType * setlocal formatoptions-=r")
vim.cmd("au FileType * setlocal formatoptions-=o")

vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.virtualedit = "none"
vim.opt.completeopt:append("noinsert")

----------------------------------------------------------------
-- keymap (config/nvim/lua/configs/keymap.lua 流用)
-- ddu / dpp のみに依存した要件は snacks.picker に置き換えて移植
----------------------------------------------------------------
do
  local opts = { silent = true }
  local keymap = vim.keymap.set

  keymap("n", "<C-[><C-[>", ":noh<CR>", opts)

  keymap("n", "s", "<C-w>", opts)
  keymap("n", "sl", "<c-w>l", opts)
  keymap("n", "sh", "<c-w>h", opts)

  keymap("i", "jj", "<ESC>", opts)
  keymap("i", "<C-g>", "<C-[><C-[>")

  keymap("n", "<c-p>", "{", opts)
  keymap("n", "<c-n>", "}", opts)

  keymap("n", "<C-f>", "<cmd>close<CR>", opts)

  keymap("n", "<C-k>", "<C-u>")
  keymap("n", "<C-j>", "<C-d>")

  -- for Emacs compatibility
  keymap("n", "<C-g>", "<ESC>")

  keymap("t", "<Esc>", [[<C-\><C-n>]])

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "help",
    callback = function()
      vim.api.nvim_buf_set_keymap(0, "n", "gd", "<C-]>", { silent = true })
    end,
  })
end

----------------------------------------------------------------
-- treesitter (start に入っている: nvim-treesitter.withAllGrammars)
-- 設定は dpp_lazy.toml の lua_source 流用
----------------------------------------------------------------
do
  -- nvim-treesitter (main) puts queries under runtime/queries/ instead of queries/
  -- so we need to add that subdirectory to runtimepath
  local ts_plugin_files = vim.api.nvim_get_runtime_file("plugin/nvim-treesitter.lua", false)
  if #ts_plugin_files > 0 then
    local ts_runtime = vim.fn.fnamemodify(ts_plugin_files[1], ":h:h") .. "/runtime"
    vim.opt.runtimepath:append(ts_runtime)
  end

  -- Enable highlighting via autocmd (manual activation required on main branch)
  local group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "*",
    callback = function(args)
      local filetype = vim.bo[args.buf].filetype
      if filetype and filetype ~= "" then
        pcall(vim.treesitter.start, args.buf)
      end
    end,
  })

  -- Disable highlighting for large files
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = group,
    callback = function(args)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
      if ok and stats and stats.size > max_filesize then
        vim.api.nvim_create_autocmd("FileType", {
          buffer = args.buf,
          once = true,
          callback = function()
            vim.treesitter.stop(args.buf)
          end,
        })
      end
    end,
  })
end

----------------------------------------------------------------
-- lsp (lua/configs/lsp.lua 流用)
-- ddu 依存の keymap (ga, gs) は nvim に合わせて置き換え
----------------------------------------------------------------
local function setup_lsp()
  -- astro: home.nix で pkgs.typescript を ~/.cache/nvim-lsp/typescript に配置済み
  vim.lsp.config("astro", {
    cmd = { "astro-ls", "--stdio" },
    init_options = {
      typescript = {
        tsdk = vim.fn.expand("~/.cache/nvim-lsp/typescript"),
      },
    },
  })
  vim.lsp.enable("astro")

  -- ts_ls: package.json があるプロジェクトでのみ起動
  vim.lsp.config("ts_ls", {
    root_markers = { "package.json", "tsconfig.json" },
  })
  vim.lsp.enable("ts_ls")

  -- denols: deno.json があるプロジェクトでのみ起動
  vim.lsp.config("denols", {
    root_markers = { "deno.json", "deno.jsonc" },
  })
  vim.lsp.enable("denols")

  -- lsp keymaps
  vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
  vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.format()<CR>")
  vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
  vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
  vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
  vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
  vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
  vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
  vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")

  vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
  vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
  vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
end

----------------------------------------------------------------
-- lz.n (opt プラグインは cmd トリガーで packadd)
----------------------------------------------------------------
require("lz.n").load({
  -- start (常時ロード)
  {
    "mini.nvim",
    lazy = false,
    after = function()
      require("mini.basics").setup()
    end,
  },
  {
    "snacks.nvim",
    lazy = false,
    after = function()
      -- 試用環境では dashboard は無効 (既存 config は scratch のみ使用)
      require("snacks").setup({
        dashboard = { enabled = false },
      })

      -- ddu に依存していた picker keymap の snacks.picker 置換
      local opts = { silent = true }
      local picker = require("snacks.picker")
      vim.keymap.set("n", "<C-u>", function()
        picker.grep()
      end, opts) -- search sources (ddu source 相当)
      vim.keymap.set("n", "<C-o>", function()
        picker.files()
      end, opts) -- file open (ddu file_external 相当)
      vim.keymap.set("n", "<C-i>", function()
        picker()
      end, opts) -- buffer (ddu buffer / コメント済み snacks 相当)
      vim.keymap.set("n", "<C-l>", function()
        picker.lines()
      end, opts) -- ddu line 相当
      vim.keymap.set("n", "<leader>l", function()
        vim.lsp.buf.code_action()
      end, opts) -- ddu lsp_codeAction 相当
    end,
  },

  -- opt (遅延ロード)
  {
    "telescope.nvim",
    cmd = { "Telescope" },
    after = function()
      require("telescope").setup({})

      vim.keymap.set("n", "<leader>pf", "<cmd>Telescope find_files<CR>")
      vim.keymap.set("n", "<leader>pg", "<cmd>Telescope live_grep<CR>")
      vim.keymap.set("n", "<leader>pb", "<cmd>Telescope buffers<CR>")
    end,
  },
  {
    "oil.nvim",
    cmd = { "Oil" },
    after = function()
      -- dpp.toml の oil 設定を流用
      require("oil").setup({
        default_file_explorer = true,
        keymaps = {
          ["l"] = "actions.select",
          ["<C-p>"] = "actions.preview",
          ["-"] = "actions.parent",
        },
        preview = {
          max_width = 0.9,
          min_width = { 40, 0.4 },
          width = nil,
          max_height = 0.9,
          min_height = { 5, 0.1 },
          height = nil,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
          update_on_cursor_moved = true,
        },
      })

      vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>")
    end,
  },
  {
    -- NOTES: packDir のディレクトリ名は pname なので "vim-fern" (fern.vim ではない)
    "vim-fern",
    cmd = { "Fern" },
    after = function()
      local function fern_mapping()
        -- dpp_lazy.toml の fern keymap を流用 (width=23)
        vim.keymap.set("n", "<leader>f", "<cmd>Fern . -reveal=% -drawer -toggle -width=23<CR>", { silent = true })
      end
      fern_mapping()
      -- ファイルを開いた後も `<leader>f` を使えるようにする
      vim.api.nvim_create_autocmd("User", {
        pattern = "FernInit",
        callback = function()
          fern_mapping()
        end,
      })
    end,
  },

  -- lsp
  -- nvim-lspconfig は最初のバッファ読み込み (BufReadPre) で lz.n 経由で
  -- packadd する: vim.lsp.enable の FileType hook 登録が FileType 発火前に済む
  {
    "nvim-lspconfig",
    event = { "BufReadPre", "BufNewFilePre" },
    after = setup_lsp,
  },

  -- colorscheme (dpp.toml の kanagawa 設定を流用)
  {
    "kanagawa.nvim",
    lazy = false,
    after = function()
      require("kanagawa").setup({
        -- compile = true にするとキャッシュに overrides が反映されず
        -- NormalFloat の透過が消えるため無効
        transparent = true,
        overrides = function()
          return {
            NormalFloat = { bg = "none" },
            FloatBorder = { bg = "none" },
          }
        end,
      })
      vim.cmd("colorscheme kanagawa")
    end,
  },
})
