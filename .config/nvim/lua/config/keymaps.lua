-- General keymaps only; mappings that invoke a plugin live with it in lua/plugins/.

-- Without this, a bare <Space> falls through to its default "move cursor right".
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- Line boundaries on H and L, in two steps outward: H to the first non-blank character and then to
-- column zero, L to the last non-blank character and then past any trailing whitespace to the true
-- end of the line. Shift plus the h/l that already mean left and right, because the ends of a line
-- are wanted constantly and ^, 0, g_ and $ are all awkward to reach.
--
-- The stock screen-top/screen-bottom motions these displace are GIVEN UP, not rehomed anywhere. M
-- still reaches the middle of the screen and zt/zz/zb still position the view; nothing here should
-- quietly put H and L back. H and L also stop being jump commands, so '' no longer returns from one.
--
-- Expression mappings that RETURN a built-in motion, rather than functions that move the cursor
-- themselves. Everything that makes a motion a motion then comes for free: an operator consumes it
-- (dL deletes to the end of the line, dH at the first non-blank deletes the indent), a visual
-- selection extends by it, visual-block $ keeps its ragged right edge, and $ sets curswant so a
-- following j stays at the end of each line. nvim_win_set_cursor loses all four.
--
-- The step is chosen from where the cursor IS, not from a press counter. No press is counted and no
-- state is carried, so the rule reads identically in all three modes -- operator-pending has no
-- "again" to count -- and ^ followed by H reaches column zero exactly as H followed by H does.
--
-- <Home> rather than "0" for column zero: a returned digit fuses with a count typed before the key,
-- so 3H would offer Vim a 3 and a 0 and mean a count of thirty with no motion at all. <Home> is the
-- same exclusive motion to column one and cannot be read as part of a count.
--
-- vim.fn.match rather than a Lua %S pattern, compared in bytes because bytes are what
-- nvim_win_get_cursor reports. Vim's regex is character-aware, so \S\ze\s*$ yields the FIRST byte of
-- the last non-blank character; the Lua equivalent yields its last byte, which never equals the
-- cursor column on a multibyte character and would leave L unable to reach its second step.
--
-- Modes are n/x/o, not v: v is visual AND select, and select mode must keep replacing the selection
-- with a typed H or L -- that is how a snippet placeholder is overwritten.
--
-- A negative match is a line with no non-blank character on it at all. There is no inner step to
-- stop at, so the two steps collapse into one: on an empty line neither key moves, and on an
-- all-whitespace line each reaches its real end in a single press.
local function line_start()
  local col = vim.fn.match(vim.api.nvim_get_current_line(), [[\S]])
  if col < 0 or col == vim.api.nvim_win_get_cursor(0)[2] then
    return "<Home>"
  end
  return "^"
end

local function line_end()
  local col = vim.fn.match(vim.api.nvim_get_current_line(), [[\S\ze\s*$]])
  if col < 0 or col == vim.api.nvim_win_get_cursor(0)[2] then
    return "$"
  end
  return "g_"
end

vim.keymap.set({ "n", "x", "o" }, "H", line_start, {
  expr = true,
  replace_keycodes = true,
  desc = "First non-blank, then column zero",
})
vim.keymap.set({ "n", "x", "o" }, "L", line_end, {
  expr = true,
  replace_keycodes = true,
  desc = "Last non-blank, then end of line",
})

-- Window focus. Unprefixed, because focus is adjusted constantly and a <C-w> per press is the
-- cost this set exists to remove. Normal mode only: insert-mode <C-h> stays backspace, and
-- <C-l>'s redraw remains reachable as :redraw!.
map("n", "<C-h>", "<C-w>h", "Focus window left")
map("n", "<C-j>", "<C-w>j", "Focus window below")
map("n", "<C-k>", "<C-w>k", "Focus window above")
map("n", "<C-l>", "<C-w>l", "Focus window right")

-- Window size. The same four directions as the focus mappings, one modifier apart. Each key grows
-- the focused window toward the direction its letter names and shrinks it away from that direction
-- -- k up, j down, l right, h left -- whichever side of the layout the window happens to sit on.
--
-- Alt, not the <C-Up>/<C-Down> arrow set: those belong to vim-visual-multi, and init.lua loads
-- config.keymaps before config.lazy, so lazy.nvim's stubs are installed after this file runs and
-- would silently overwrite an arrow-key resize here. 2 per press rather than 1, so one press
-- produces a visible change instead of the user holding the key.
map("n", "<M-k>", "<cmd>resize +2<CR>", "Increase window height")
map("n", "<M-j>", "<cmd>resize -2<CR>", "Decrease window height")
map("n", "<M-l>", "<cmd>vertical resize +2<CR>", "Increase window width")
map("n", "<M-h>", "<cmd>vertical resize -2<CR>", "Decrease window width")

-- <C-w>\ maximize toggle. Prefixed despite being interactive, because it *extends* the built-in
-- window-command prefix rather than competing with it: \ is unbound under <C-w>, so no built-in
-- <C-w> command is delayed by it.
--
-- The stored value is winrestcmd() -- the command string that reproduces the current window sizes
-- -- rather than an equalize, because equalizing is not restoring: a 30-column file tree beside a
-- wide editor comes back as two equal halves. Keyed by tab page handle, so a maximize in one tab
-- cannot restore into another.
local saved_layout = {}

local function toggle_maximized()
  local tab = vim.api.nvim_get_current_tabpage()
  local restore = saved_layout[tab]
  saved_layout[tab] = nil -- cleared on every toggle, whether the restore below succeeds or not

  if restore then
    -- winrestcmd() names window numbers that may no longer exist if a window was opened or
    -- closed while maximized. A stale command must fail silently, not raise.
    pcall(vim.cmd, restore)
    return
  end

  -- With one window, maximizing is a no-op; storing a restore command for it would "restore"
  -- into a layout the user never had. winnr("$") counts this tab page's windows, floats excluded.
  if vim.fn.winnr("$") < 2 then
    return
  end

  saved_layout[tab] = vim.fn.winrestcmd()
  vim.cmd("wincmd _") -- maximum height
  vim.cmd("wincmd |") -- maximum width
end

map("n", "<C-w>\\", toggle_maximized, "Toggle window maximized")

-- <leader>w mirrors the built-in <C-w> prefix: the same window commands under the same letters,
-- reachable without a Ctrl chord. Two sets are deliberate -- <C-w> keeps working untouched, and
-- this is the one which-key names and lists.
--
-- Two families of <C-w> keys are left out on purpose:
--
--   * the incremental resizes (+ - < > _ |). <M-h>/<M-j>/<M-k>/<M-l> above own resizing, and they
--     repeat on a held key; a <leader> sequence per 2 columns does not.
--   * the window *moves* (H J K L). Directional focus is unprefixed on Ctrl, so the lowercase half
--     of that pair is absent here too, and a lone uppercase set that drags windows around would be
--     the only h/j/k/l in the menu. <C-w>H and friends are unchanged for when a move is meant.
map("n", "<leader>ws", "<C-w>s", "Split window horizontally")
map("n", "<leader>wv", "<C-w>v", "Split window vertically")
map("n", "<leader>wn", "<C-w>n", "New window")
map("n", "<leader>wc", "<C-w>c", "Close window")
map("n", "<leader>wq", "<C-w>q", "Quit window")
map("n", "<leader>wo", "<C-w>o", "Close other windows")

-- h/j/k/l are absent: <C-h>/<C-j>/<C-k>/<C-l> above already move focus directionally, and they
-- are the mappings that exist because directional focus is too frequent to prefix at all.
map("n", "<leader>ww", "<C-w>w", "Focus next window")
map("n", "<leader>wW", "<C-w>W", "Focus previous window")
map("n", "<leader>wp", "<C-w>p", "Focus last-accessed window")
map("n", "<leader>wt", "<C-w>t", "Focus top-left window")
map("n", "<leader>wb", "<C-w>b", "Focus bottom-right window")

-- Rearranging without resizing: x swaps two windows in place, r/R rotate the row or column.
map("n", "<leader>wx", "<C-w>x", "Exchange window with next")
map("n", "<leader>wr", "<C-w>r", "Rotate windows downwards/rightwards")
map("n", "<leader>wR", "<C-w>R", "Rotate windows upwards/leftwards")

-- = equalizes, exactly as <C-w>= does: a layout command, not one of the incremental resizes the
-- Alt set owns.
map("n", "<leader>w=", "<C-w>=", "Equalize window sizes")

-- The maximize toggle, on e as well as the \\ that <C-w>\\ uses above. e is added under <C-w> too,
-- so the two prefixes stay interchangeable; \\ and e are both unbound built-ins, so no <C-w>
-- command is shadowed or delayed by either.
map("n", "<leader>we", toggle_maximized, "Toggle window maximized")
map("n", "<leader>w\\", toggle_maximized, "Toggle window maximized")
map("n", "<C-w>e", toggle_maximized, "Toggle window maximized")

map("n", "<leader>wT", "<C-w>T", "Move window to new tab")

-- Dismiss the search highlight. 'hlsearch' is on (see lua/config/options.lua), so this is what
-- clears it. nohlsearch, not a new search: the pattern and the search history survive, so n and N
-- still work and re-highlight. The cursor does not move.
--
-- This is the riskiest mapping in the file: terminals encode arrow and function keys as
-- escape-prefixed sequences, and 'ttimeoutlen' (50ms by default) is what separates those from a
-- hand-typed <Esc>. If a key starts misbehaving, suspect this first.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

-- Shift and re-select, so a selection can be shifted repeatedly without re-selecting it. A count
-- still applies: 3> shifts three levels and keeps the selection.
map("v", "<", "<gv", "Outdent and keep selection")
map("v", ">", ">gv", "Indent and keep selection")

-- Terminate a line with a semicolon from wherever the cursor is, then carry on after it. The
-- cursor is almost never at end of line when the semicolon is wanted, and the position it came
-- from is deliberately not restored: the key is pressed when the statement is finished.
--
-- The line is rewritten and the target column computed, rather than <End>; being fed: <End> lands
-- past any trailing whitespace, which would leave `foo  ;` where `foo;  ` is wanted, and fed keys
-- would go through whatever else claims them.
--
-- Alt rather than Ctrl, which is what the chord wants to be: <C-;> has no representation in the
-- legacy terminal key encoding, so it reaches Neovim only from a terminal speaking the Kitty
-- keyboard protocol (kitty, WezTerm, Ghostty, foot, Alacritty 0.14+) or a GUI such as Neovide.
-- Under Windows Terminal, which this configuration is used from, the press arrives as a plain `;`
-- and no mapping is reached at all. Alt sends a leading <Esc>, which every terminal encodes.
--
-- Returns the byte column just past the semicolon on `lnum`, 0-based, or nil when the line was
-- skipped. `skip_blank` is off for a single line -- terminating the line the cursor is on is
-- unambiguous even when it is blank -- and on for a selection, where appending a semicolon to the
-- empty lines inside it is never what was meant.
local function terminate_line(lnum, skip_blank)
  local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]

  -- Split the trailing whitespace off, so the semicolon goes after the code rather than after the
  -- blanks. A line that is entirely blank has no code to go after, so all of it counts as body and
  -- its indentation is kept in front of the semicolon.
  local body, trailing = line:match("^(.-)(%s*)$")
  if body == "" then
    if skip_blank then
      return nil
    end
    body, trailing = line, ""
  end

  if body:sub(-1) == ";" then
    return #body -- already terminated; only the cursor moves
  end

  vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, true, { body .. ";" .. trailing })
  return #body + 1 -- #body is the semicolon itself, so one past it is the character after
end

local function terminate_current_line()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_win_set_cursor(0, { lnum, terminate_line(lnum, false) })
end

map("i", "<M-;>", terminate_current_line, "Terminate line with ;")

-- Every line the selection touches, linewise regardless of how the selection was made: a semicolon
-- belongs at the end of a statement, not at the end of the columns that happened to be highlighted.
--
-- The range is read before leaving visual mode, since line("v") is only meaningful there. Visual
-- mode is then left rather than kept, because the cursor move below would otherwise drag the
-- selection along with it.
local function terminate_selection()
  local first, last = vim.fn.line("v"), vim.fn.line(".")
  if first > last then
    first, last = last, first
  end
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)

  local target
  for lnum = first, last do
    local col = terminate_line(lnum, true)
    if col then
      target = { lnum, col }
    end
  end

  vim.api.nvim_win_set_cursor(0, target or { last, 0 })
end

map("v", "<M-;>", terminate_selection, "Terminate selected lines with ;")

-- Save from any editing mode. Insert and visual leave their mode first, so the buffer is never
-- written mid-insert with a pending undo entry; the trailing mode is normal in all three cases.
-- <cmd>w<CR> rather than :w<CR>, so no mode is left partially exited and the mapping needs no
-- <silent>.
--
-- Under a terminal with legacy XON/XOFF flow control, <C-s> never reaches Neovim at all. That is
-- fixed with `stty -ixon` in the shell profile; nothing here can fix it.
map("n", "<C-s>", "<cmd>w<CR>", "Save buffer")
map({ "i", "v" }, "<C-s>", "<Esc><cmd>w<CR>", "Save buffer")

-- Buffer commands. Each one is a built-in Ex command, so no buffer-removal plugin is loaded:
-- mini.bufremove and bufdelete.nvim exist to delete a buffer *without* closing the windows showing
-- it, and that behaviour is declined below, which leaves them nothing to do here.
--
-- :bnext and :bprevious wrap at both ends of the buffer list on their own, so no arithmetic and no
-- wrap logic is needed for the next-after-last or the previous-before-first case.
map("n", "<leader>bn", "<cmd>bnext<CR>", "Next buffer")
map("n", "<leader>bp", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "<leader>bf", "<cmd>bfirst<CR>", "First buffer")
map("n", "<leader>bl", "<cmd>blast<CR>", "Last buffer")

-- Alternate buffer. With none, :buffer # reports E23 rather than failing silently.
map("n", "<leader>bb", "<cmd>buffer #<CR>", "Alternate buffer")

-- c for "create", not the n that <C-w>n uses for a new window: n is "next" here, which is the more
-- frequent operation and the letter :bnext itself carries.
map("n", "<leader>bc", "<cmd>enew<CR>", "New empty buffer")

-- :confirm on all three deletions, never a bare :bdelete and never :bdelete!. A bare :bdelete aborts
-- with E89 on a modified buffer, failing in exactly the situation where the user needs to be told
-- something; :bdelete! discards the changes, losing work to a two-key sequence. :confirm turns that
-- E89 into the save/discard/cancel dialog, once per modified buffer.
--
-- :bdelete also closes every window displaying the buffer, so deleting a buffer shown in a vsplit
-- drops back to one window. Kept rather than worked around: <leader>w and <C-w> are where layout is
-- the subject, and a buffer mapping that quietly rearranges windows does that job badly.
map("n", "<leader>bd", "<cmd>confirm bdelete<CR>", "Delete buffer")

-- The two bulk deletions name the buffers they delete rather than taking a range. % on :bdelete is
-- the line range 1,$ read as buffer *numbers*, so it covers every buffer that exists -- including
-- the unlisted scratch buffers plugins keep alive (smear-cursor's pooled floats, oil:// directories,
-- blink.cmp's menu, telescope's previewer, which-key's popup, help, quickfix). :bnext and the
-- telescope picker both mean the buffer list instead, so :%bd reported "18 buffers deleted" in a
-- session showing two. No range modifier filters on 'buflisted'; getbufinfo does.
--
-- One :bdelete with the whole list, not a loop: :confirm keeps its per-modified-buffer dialog across
-- a list of buffer numbers, and cancelling one leaves that buffer listed while the rest still go.
-- The built-in also emits the one "N buffers deleted" that a loop would have to reconstruct.
--
-- The empty-list return is a guard, not an optimisation: :bdelete with no argument deletes the
-- *current* buffer, so concatenating an empty list would turn "nothing to clear" into its opposite.
local function delete_listed_buffers(keep)
  local targets = {}
  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if buf.bufnr ~= keep then
      targets[#targets + 1] = buf.bufnr
    end
  end

  if #targets == 0 then
    return
  end

  vim.cmd("confirm bdelete " .. table.concat(targets, " "))
end

map("n", "<leader>bO", function()
  delete_listed_buffers()
end, "Delete all buffers")

-- "Every buffer but this one" is the same set with the current buffer left out of it, so that buffer
-- is never deleted and never re-edited: its undo history, its buffer-local marks and its cursor
-- position all survive. The :%bd|e#|bd# idiom this replaces deleted it along with the rest and then
-- re-opened the file, which cost all three -- a trade-off recorded and accepted when these mappings
-- were added, and retired here because it came from the same % that was overreaching.
map("n", "<leader>bo", function()
  delete_listed_buffers(vim.api.nvim_get_current_buf())
end, "Delete other buffers")

-- Leaving the editor. The prefix covers the editing session as a whole -- the session mappings in
-- lua/plugins/auto-session.lua persist it across launches -- but never one window or one buffer:
-- <leader>wq and <C-w>q are still how a single window is closed, and they are a different sequence.
--
-- :confirm on both, for the reason the :bdelete block above spells out: the bare command aborts
-- with an error in exactly the situation the user needs to be told about, the banged one throws the
-- work away, and :confirm turns that error into the save/discard/cancel dialog, once per buffer.
-- Cancelling abandons the quit with every buffer still loaded and the layout unchanged.
--
-- :xall rather than :wqall for the write-and-quit: :xall writes only the buffers that were modified,
-- where :wqall writes every buffer whether it changed or not, updating modification times on
-- untouched files and tripping file watchers and build tools for nothing. :confirm still earns its
-- place on top of it -- a modified buffer with no filename, a read-only file or a failed write would
-- otherwise abort the whole quit, and instead the user is asked about that one buffer while the
-- rest are already written.
map("n", "<leader>qq", "<cmd>confirm qall<CR>", "Quit all")
map("n", "<leader>qw", "<cmd>confirm xall<CR>", "Write all and quit")

-- Under <leader>q with the quit mappings and auto-session's: the prefix is the editing session as
-- a whole, and rebuilding the process is one more way of ending the current one.
--
-- Restart, not re-source. init.lua is three require calls and require is memoized, so sourcing it
-- again re-runs nothing; clearing package.loaded and re-sourcing appears to work but leaves
-- deleted mappings mapped, autocommands duplicated and plugin setup() un-re-entered. :restart is a
-- Neovim 0.12 built-in and gives a genuinely fresh process.
--
-- Confirmed first, because a restart tears down and rebuilds the whole editor process and a
-- mistyped <leader>q-something should not do that on one keystroke. The prompt no longer says the
-- session is discarded: auto-session saves the buffers and layout on the way out and restores them
-- on the way back up, so that stopped being true. :restart, never :restart! -- the bang discards
-- modified buffers, and refusing while one exists is exactly the safety wanted here.
map("n", "<leader>qc", function()
  if vim.fn.confirm("Restart Neovim? The editor process is rebuilt from scratch.", "&Yes\n&No", 2) == 1 then
    vim.cmd("restart")
  end
end, "Restart Neovim (reload config)")
