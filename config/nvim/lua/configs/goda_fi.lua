-- goda-fi.vim の設定。ddu.vim の設定 (ddu.lua) を段階的に置き換えるため、
-- 同じ UI 名・同じキーマップで揃えてある。
--
-- オプションの大半 (UI のレイアウト、matcher、kind の既定アクション、
-- セッション名と source の対応) は Go 側の config/nvim/goda-fi/main.go が
-- patch_global / patch_local で持っている。ここでは Vim 側でしか決められない
-- ものだけを重ねる (Vim のパッチは Go の設定に深くマージされる)。
local keymap = vim.keymap.set
local keymap_opt = { buffer = true, silent = true }

-- バイナリは dpp が config/nvim/goda-fi/build.sh でビルドしたものを使う
-- (Home Manager は経由しない)。ビルドはプラグインの更新時に走るので、
-- 設定を変えたあとは :DppUpdate か、build.sh を直接叩けば反映される。
-- g.goda_fi#binary に届かない場合は goda-fi.vim 側の既定
-- (~/.cache/nvim/goda-fi/goda-fi) と同じ場所を指す。
vim.g["goda_fi#binary"] = vim.fn.expand("~/.cache/nvim/goda-fi/goda-fi")

vim.fn["goda_fi#custom#patch_global"]({
  -- sources はここで指定しない。Go 側 (fi/plugin.go の engine.options) は
  --   builder.global -> builder.local[name] -> vimGlobal -> vimLocal[name] -> user
  -- の順にマージするので、patch_global に sources を書くと全セッションの
  -- PatchLocal を上書きしてしまう。source の対応は main.go の PatchLocal が持つ。
  sourceParams = {
    -- fd で列挙する。main.go の fileexternal (git ls-files) より優先される。
    fileexternal = {
      cmd = { vim.fn.expand("~/.nix-profile/bin/fd"), ".", "-H", "-E", ".git", "-t", "f" },
    },
  },
})

-- ddu の custom:buf_delete 相当。buffer item は action に bufnr を持つ
-- (ext/source/buffer が Action: file.ActionData{BufNr: ...} を返す)。
vim.fn["goda_fi#custom#action"]("ui", "ff", "custom:buf_delete", function()
  local item = vim.fn["goda_fi#ui#get_item"]()
  local bufnr = item and item.action and item.action.bufNr or nil

  if bufnr and bufnr > 0 then
    vim.cmd("bd " .. bufnr)
  end

  return 1
end)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "goda-fi-ff",
  callback = function()
    keymap("n", "<CR>", "<Cmd>call goda_fi#ui#do_action('itemAction')<CR>", keymap_opt)
    keymap("n", "<Space>", "<Cmd>call goda_fi#ui#do_action('toggleSelectItem')<CR>", keymap_opt)
    keymap("n", "i", "<Cmd>call goda_fi#ui#do_action('openFilterWindow')<CR>", keymap_opt)
    keymap("n", "q", "<Cmd>call goda_fi#ui#do_action('quit')<CR>", keymap_opt)

    -- buffer source のときだけ削除を有効にする (ddu.lua と同じ条件)。
    local current = vim.fn["goda_fi#custom#get_current"]()
    local sources = current and current.sources or {}

    if #sources == 1 and sources[1].name == "buffer" then
      keymap("n", "d", "<Cmd>call goda_fi#ui#do_action('custom:buf_delete')<CR>", keymap_opt)
    end

    -- カーソル移動のたびにプレビューする (ff の autoAction を補う)。
    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = 0,
      callback = function()
        vim.fn["goda_fi#ui#do_action"]("preview")
      end,
    })
  end,
})

-- :GodaFi <session>。セッション名は main.go の PatchLocal で定義したもの。
vim.api.nvim_create_user_command("GodaFi", function(args)
  vim.fn["goda_fi#start"]({ name = args.args })
end, {
  nargs = 1,
  complete = function()
    return { "files", "gitfiles", "buffers", "lines", "rg", "histories" }
  end,
})
