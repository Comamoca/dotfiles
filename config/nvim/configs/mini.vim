lua << EOF

require('mini.fuzzy').setup(
{
  -- Maximum allowed value of match features (width and first match). All
  -- feature values greater than cutoff can be considered "equally bad".
  cutoff = 100,
}
)

-- require('mini.starter').setup(
-- {
--   -- Whether to open starter buffer on VimEnter. Not opened if Neovim was
--   -- started with intent to show something else.
--   autoopen = true,
-- 
--   -- Whether to evaluate action of single active item
--   evaluate_single = false,
-- 
--   -- Items to be displayed. Should be an array with the following elements:
--   -- - Item: table with <action>, <name>, and <section> keys.
--   -- - Function: should return one of these three categories.
--   -- - Array: elements of these three types (i.e. item, array, function).
--   -- If `nil` (default), default items will be used (see |mini.starter|).
--   items = nil,
-- 
--   -- Header to be displayed before items. Converted to single string via
--   -- `tostring` (use `\n` to display several lines). If function, it is
--   -- evaluated first. If `nil` (default), polite greeting will be used.
--   header = nil,
-- 
--   -- Footer to be displayed after items. Converted to single string via
--   -- `tostring` (use `\n` to display several lines). If function, it is
--   -- evaluated first. If `nil` (default), default usage help will be shown.
--   footer = nil,
-- 
--   -- Array  of functions to be applied consecutively to initial content.
--   -- Each function should take and return content for 'Starter' buffer (see
--   -- |mini.starter| and |MiniStarter.content| for more details).
--   content_hooks = nil,
-- 
--   -- Characters to update query. Each character will have special buffer
--   -- mapping overriding your global ones. Be careful to not add `:` as it
--   -- allows you to go into command mode.
--   query_updaters = 'abcdefghijklmnopqrstuvwxyz0123456789_-.',
-- }
-- )

function diagnostics_table(args)
  local info = vim.b.coc_diagnostic_info
  if MiniStatusline.is_truncated(args.trunc_width) or info == nil then
    return {}
  end
  local table = {}
  table.e = (info['error'] or 0) > 0 and 'E'..info['error'] or ''
  table.w = (info['warning'] or 0) > 0 and 'W'..info['warning'] or ''
  table.h = (info['hint'] or 0) > 0 and 'H'..info['hint'] or ''
  table.i = (info['information'] or 0) > 0 and 'I'..info['information'] or ''
  table.s = vim.g.coc_status
  return table
end

function status_config()
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  local git           = MiniStatusline.section_git({ trunc_width = 75 })
  local diagnostics   = diagnostics_table({ trunc_width = 75 })
  local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
  local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
  local location      = MiniStatusline.section_location({ trunc_width = 75 })

  return MiniStatusline.combine_groups({
  { hl = mode_hl,                  strings = { mode } },
  { hl = 'MiniStatuslineDevinfo',  strings = { git, diagnostics['s'] } },
  { hl = 'MiniStatuslineError',  strings = { diagnostics['e'] } },
  { hl = 'MiniStatuslineWarning',  strings = { diagnostics['w'] } },
  { hl = 'MiniStatuslineInfo',  strings = { diagnostics['i'] } },
  { hl = 'MiniStatuslineHint',  strings = { diagnostics['h'] } },
  '%<', -- Mark general truncate point
  { hl = 'MiniStatuslineFilename', strings = { filename } },
  '%=', -- End left alignment
  { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
  { hl = mode_hl,                  strings = { location } },
  })
end

require('mini.statusline').setup({
  content = {
    active = status_config
  },
})


-- require('mini.jump2d').setup(
   -- {
   -- 特定の行のジャンプスポット（バイトインデックス）を生成する関数。
   -- 詳細については、|Minirump2d.start|を参照してください。
   -- `nil`（デフォルト）の場合-|MiniJump2d.default_spotter|を使用します
   -- spotter = nil,
 
   -- ジャンプスポットのラベルに使用される文字（指定された順序で）
   -- labels = 'abcdefghijklmnopqrstuvwxyz',
 
   -- -- スポットの計算に使用されるライン
   -- allowed_lines = {
   --   blank = true, -- Blank line (not sent to spotter even if `true`)
   --   cursor_before = true, -- Lines before cursor line
   --   cursor_at = true, -- Cursor line
   --   cursor_after = true, -- Lines after cursor line
   --   fold = true, -- Start of fold (not sent to spotter even if `true`)
   -- },
 
   -- -- 現在のタブページのどのウィンドウが表示線に使用されているか
   -- allowed_windows = {
   --   current = true,
   --   not_current = true,
   -- },
 
   -- 特定のイベントで実行される関数
  --  hooks = {
  --    before_start = nil, -- Before jump start
  --    after_jump = nil, -- After jump was actually done
  --  },
 
   -- モジュールマッピング。 1つを無効にするには、 `''`（空の文字列）を使用します。
   -- mappings = {
   --   start_jumping = '<leader>',
   -- },
   -- }
-- )


-- require('mini.indentscope').setup({
--   draw = {
--     -- Delay (in ms) between event and start of drawing scope indicator
--     delay = 100,
-- 
--     -- Animation rule for scope's first drawing. A function which, given next
--     -- and total step numbers, returns wait time (in ms). See
--     -- |MiniIndentscope.gen_animation()| for builtin options. To not use
--     -- animation, supply `require('mini.indentscope').gen_animation('none')`.
--     --<function: implements constant 20ms between steps>,
--     -- animation = true
--   },
-- 
--   -- Module mappings. Use `''` (empty string) to disable one.
--   mappings = {
--     -- Textobjects
--     object_scope = 'ii',
--     object_scope_with_border = 'ai',
-- 
--     -- Motions (jump to respective border line; if not present - body line)
--     goto_top = '[i',
--     goto_bottom = ']i',
--   },
-- 
--   -- Options which control computation of scope. Buffer local values can be
--   -- supplied in buffer variable `vim.b.miniindentscope_options`.
--   options = {
--     -- Type of scope's border: which line(s) with smaller indent to
--     -- categorize as border. Can be one of: 'both', 'top', 'bottom', 'none'.
--     border = 'both',
-- 
--     -- Whether to use cursor column when computing reference indent. Useful to
--     -- see incremental scopes with horizontal cursor movements.
--     indent_at_cursor = true,
-- 
--     -- Whether to first check input line to be a border of adjacent scope.
--     -- Use it if you want to place cursor on function header to get scope of
--     -- its body.
--     try_as_border = false,
--   },
-- 
--   -- Which character to use for drawing scope indicator
--   symbol = '╎',
-- })
-- 
-- 
require('mini.comment').setup(
-- {
--   -- Module mappings. Use `''` (empty string) to disable one.
--   -モジュールマッピング。 1つを無効にするには、 `''`（空の文字列）を使用します。
--   mappings = {
--     -- Toggle comment (like `gcip` - comment inner paragraph) for both
--     -- Normal and Visual modes
--     -- 両方のコメントを切り替えます（ `gcip`のように-内側の段落にコメントします）
--     -- 通常モードとビジュアルモード
--     comment = 'gc',
-- 
--     -- Toggle comment on current line
--     -- 現在の行のコメントを切り替えます
--     comment_line = 'gcc',
-- 
--     -- Define 'comment' textobject (like `dgc` - delete whole comment block)
--     --'comment' textobjectを定義します（ `dgc`のように-コメントブロック全体を削除します）
--     textobject = 'gc',
--   },
--   -- Hook functions to be executed at certain stage of commenting
--   -- コメントの特定の段階で実行されるフック関数
--   hooks = {
--     -- Before successful commenting. Does nothing by default.
--     -- コメントを成功させる前に。デフォルトでは何もしません。
--     pre = function() end,
--     -- After successful commenting. Does nothing by default.
--     -- コメントに成功した後。デフォルトでは何もしません。
--     post = function() end,
--   },
-- }
)

-- require('mini.jump').setup(
-- {
--   -- Module mappings. Use `''` (empty string) to disable one.
--   mappings = {
--     forward = 'f',
--     backward = 'F',
--     forward_till = 't',
--     backward_till = 'T',
--     repeat_jump = ';',
--   },
-- 
--   -- Delay values (in ms) for different functionalities. Set any of them to
--   -- a very big number (like 10^7) to virtually disable.
--   delay = {
--     -- Delay between jump and highlighting all possible jumps
--     highlight = 250,
-- 
--     -- Delay between jump and automatic stop if idle (no jump is done)
--     idle_stop = 10000000,
--   },
-- }
-- )
EOF
