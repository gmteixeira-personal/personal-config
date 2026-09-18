-- File explorer: yazi, run in the focused window.
--
-- Why this is a config module and not a file under lua/plugins/. There is no plugin. yazi.nvim
-- exists and is maintained, but it draws yazi into a floating window and offers nothing else:
-- every window option it has is floating_window_scaling_factor, yazi_floating_window_winblend,
-- yazi_floating_window_border, yazi_floating_window_zindex. A full-size borderless float looks
-- like a full window until a split is open, at which point it covers both -- and leaving the
-- surrounding splits visible is the one thing the file-explorer spec asks of this. So the binary
-- is driven directly, and lua/plugins/ stays what plugin-management requires it to be: one file
-- per real plugin.
--
-- Why init.lua loads this before the plugin manager. netrw is a built-in plugin, and Neovim
-- sources its built-in plugins after init.lua returns, so vim.g.loaded_netrw has to be set while
-- init.lua is still running. lua/plugins/oil.lua arranged this with `lazy = false`, which worked
-- because oil sets the globals itself from a spec lazy.nvim evaluates early. Nothing here runs
-- that early, so the position in the load order is the mechanism rather than a preference.

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local EXECUTABLE = "yazi"

-- Windows with a yazi job in them, keyed by window handle. Window handles are never reused, so a
-- stale entry for a closed window is only a leak of one boolean -- but on_exit clears it anyway,
-- and it fires for a killed job as well as a quit one.
local running = {}

-- Checked before anything is touched, and that ordering is the point. Start the job first and a
-- missing binary leaves the window already showing an empty scratch buffer, plus a job error, plus
-- a restore that depends on an on_exit which may never run for a failed spawn.
local function available()
  if vim.fn.executable(EXECUTABLE) == 1 then
    return true
  end

  vim.notify(
    EXECUTABLE .. " is not on $PATH. The file explorer runs it directly; install it to use <leader>e.",
    vim.log.levels.ERROR
  )
  return false
end

-- yazi takes a path and hovers it, so the entry to open on is the current buffer's file. fs_stat
-- rather than a name check: a buffer can be named for a file that does not exist yet (`:e new.lua`,
-- never written), and yazi given a nonexistent path starts in it as a directory that is not there.
local function entry_for(buf)
  local name = vim.api.nvim_buf_get_name(buf)

  if name ~= "" and vim.uv.fs_stat(name) then
    return name
  end

  return vim.fn.getcwd()
end

-- The no-selection exit. winrestview and not just the cursor: the spec asks for the scroll position
-- too, and that is the half a cursor restore silently drops.
--
-- The invalid cases are both real. The window is gone when the user closed it while yazi was up,
-- which kills the job and brings us here with nothing to restore into. The buffer is gone when the
-- editor was started on a directory -- the directory buffer is wiped by the autocmd below, so there
-- is no buffer to go back to and an empty one is the answer the spec names.
local function restore(win, prev_buf, view)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  if vim.api.nvim_buf_is_valid(prev_buf) then
    vim.api.nvim_win_set_buf(win, prev_buf)
    vim.api.nvim_win_call(win, function()
      vim.fn.winrestview(view)
    end)
    return
  end

  vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
end

-- The selection exit. --chooser-file can hold more than one line; the first takes the window and
-- the rest go onto the buffer list, where they are reachable by buffer-walking without any of them
-- stealing the window or disturbing the layout.
--
-- :edit rather than nvim_win_set_buf, because the file has to be read: :edit fires the whole
-- BufReadPre/BufReadPost sequence that filetype detection and the LSP attach hang off, and
-- nvim_win_set_buf on a bufadd'd handle would display an empty buffer with no filetype.
local function open_chosen(win, paths)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  vim.api.nvim_win_call(win, function()
    vim.cmd.edit(vim.fn.fnameescape(paths[1]))
  end)

  for i = 2, #paths do
    vim.cmd.badd(vim.fn.fnameescape(paths[i]))
  end
end

-- Opens yazi in the focused window, replacing the buffer shown there.
local function open(path)
  if not available() then
    return
  end

  local win = vim.api.nvim_get_current_win()

  -- Re-entrancy. <leader>e is unreachable from inside yazi -- it owns the keyboard -- but it is
  -- reachable from terminal-normal mode after <C-\><C-n>, and from the BufEnter autocmd below
  -- firing on a buffer this function just put in the window.
  if running[win] then
    return
  end

  local prev_buf = vim.api.nvim_win_get_buf(win)
  local view = vim.fn.winsaveview()
  local chooser = vim.fn.tempname()

  -- Unlisted and scratch from birth, not listed-then-filtered. A listed terminal buffer turns up in
  -- <leader>b buffer-walking, in the telescope buffer picker and in :mksession, and each of those
  -- would need its own exclusion -- lua/config/keymaps.lua already steps around one class of
  -- unlisted scratch buffer for exactly this reason.
  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, term_buf)

  running[win] = true

  -- jobstart with term = true, not vim.fn.termopen: termopen is the older spelling of the same call
  -- and is deprecated as of Neovim 0.11. The terminal attaches to the *current* buffer, which is
  -- why term_buf goes into the window first.
  --
  -- --chooser-file is the whole selection protocol. yazi writes the selected paths there on Enter
  -- and writes nothing at all on q, so an empty file is "the user backed out" -- which is the signal
  -- that replaces the second press of <leader>e that oil had.
  --
  -- --cwd-file is deliberately not passed. Changing Neovim's working directory as a side effect of
  -- browsing reaches outside the window the user acted in, and auto-session keys session identity on
  -- the working directory, so a browse would quietly change which session gets saved on quit.
  vim.fn.jobstart({ EXECUTABLE, path, "--chooser-file", chooser }, {
    term = true,
    on_exit = function()
      -- Deferred because on_exit can run where buffer and window calls are not safe, and because the
      -- job's own buffer is still being torn down at the moment it fires.
      vim.schedule(function()
        running[win] = nil

        local chosen = {}
        if vim.fn.filereadable(chooser) == 1 then
          chosen = vim.fn.readfile(chooser)
        end
        os.remove(chooser)

        -- The job exiting leaves the window in terminal-normal mode, not insert -- but startinsert
        -- below can still be in effect when a spawn fails fast, and landing in insert mode in a
        -- restored file buffer is worse than a redundant stopinsert.
        vim.cmd.stopinsert()

        if #chosen > 0 then
          open_chosen(win, chosen)
        else
          restore(win, prev_buf, view)
        end

        -- Last, and only once the window is showing something else: deleting a displayed buffer
        -- makes Neovim pick a replacement for the window, which is how a restore gets undone.
        if vim.api.nvim_buf_is_valid(term_buf) then
          pcall(vim.api.nvim_buf_delete, term_buf, { force = true })
        end
      end)
    end,
  })

  -- What hands yazi the keyboard. Without it the user lands in terminal-normal mode and the first
  -- keystroke is read by Neovim instead.
  vim.cmd.startinsert()
end

-- netrw is suppressed above, which leaves a directory path opening as an empty buffer named for the
-- directory. This catches that buffer, opens yazi on it, and wipes it so it does not linger in the
-- buffer list.
--
-- BufEnter covers both routes -- `nvim <directory>` and `:edit <directory>` from a running session
-- -- so there is no separate VimEnter path. Arguments are processed after init.lua returns, so this
-- autocmd exists by the time the startup buffer is entered.
--
-- Scheduled because at startup this fires mid-argument-processing, and because open() replaces the
-- window's buffer, which is not a thing to do from inside BufEnter for the buffer being replaced.
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("file_explorer_directories", { clear = true }),
  desc = "Open yazi on a directory buffer instead of leaving netrw's empty replacement",
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)

    -- The terminal buffer open() creates has no name, so it fails this test and cannot recurse.
    if name == "" or vim.fn.isdirectory(name) ~= 1 then
      return
    end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) or vim.api.nvim_get_current_buf() ~= args.buf then
        return
      end

      open(name)

      -- After open(), the directory buffer is displayed nowhere, so wiping it disturbs no window.
      -- It has to go: restore() reads its invalidity as "there was nothing to come back to", which
      -- is the correct answer for an editor started on a directory, and the spec requires the
      -- buffer list not to carry a directory entry.
      if vim.api.nvim_buf_is_valid(args.buf) then
        pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
      end
    end)
  end,
})

-- Declared here rather than in lua/config/keymaps.lua: a mapping lives beside the thing it invokes,
-- and the thing this invokes is this module. "Open", not "Toggle" -- which-key shows this string,
-- and the key no longer closes anything. yazi's own q does that.
vim.keymap.set("n", "<leader>e", function()
  open(entry_for(0))
end, { desc = "Open file explorer" })
