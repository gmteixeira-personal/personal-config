-- Session persistence: the open buffers, the window layout and every cursor position are written on
-- exit and restored on the next bare launch in the same directory. What a session *contains* is
-- 'sessionoptions' in lua/config/options.lua -- that governs Neovim's own :mksession and works with
-- no plugin installed, so config-structure puts it there rather than here.
return {
  "rmagatti/auto-session",
  -- Cannot be lazy-loaded. The decision about whether to restore is made on VimEnter, before any
  -- buffer exists; a `keys` or `event` trigger fires long after the start screen is already up. No
  -- `priority` bump either: at this point every eager plugin is only registering autocommands, and
  -- lazy.nvim's start order does not change the order those autocommands run in on VimEnter.
  lazy = false,
  opts = {
    -- Directories where a restored layout would be wrong rather than helpful. Suppression covers
    -- saving as well as restoring, so a one-off `nvim` from home neither resurrects an old layout
    -- nor leaves a session behind for a directory nobody works in.
    suppressed_dirs = { "~/", "/", "~/Downloads" },

    -- Everything else is upstream's default, and each default is the decision:
    --
    -- use_git_branch off -- session identity is the working directory and nothing else, so checking
    -- out a branch does not swap the layout out from under the user.
    --
    -- root_dir under stdpath("data")/sessions/ -- already outside every project, so no repository
    -- acquires a session file and no .gitignore entry is needed anywhere.
    --
    -- auto_save, auto_restore, auto_create on -- the whole point: the first exit in a new project
    -- produces a session without the user remembering to ask for one.
    --
    -- close_unsupported_windows on -- what keeps a non-float Oil window (from `nvim <directory>`)
    -- out of a save, so a restore cannot stand an empty explorer window up in place of a file.
    -- Floating windows are not recorded by :mksession at all, which covers <leader>e.
    --
    -- No require("telescope").load_extension(...) call: :SessionSearch finds Telescope on its own
    -- and falls back to vim.ui.select without it. Neither file depends on the other, and the picker
    -- inherits telescope.lua's flex layout like every other one.
  },
  -- The session half of <leader>q. The prefix covers the editing session as a whole -- ending it,
  -- restarting it, and persisting it across launches -- which is why these share it with the quit
  -- and restart mappings in lua/config/keymaps.lua rather than taking a prefix of their own.
  --
  -- Saving is the shifted <leader>qW because <leader>qw is taken: it writes every modified buffer
  -- and quits. The near-miss is deliberate and is not a typo to be "fixed" -- w was unavailable.
  --
  -- Bound to the `AutoSession <verb>` commands, not to require("auto-session") functions: they
  -- carry the plugin's own "no session to restore" and "this directory is excluded" reporting,
  -- which the specs require and which this file would otherwise have to write itself.
  --
  -- `AutoSession search`, not `SessionSearch` -- and the same for save, restore and delete. The
  -- one-word forms still work, but only while the plugin's legacy_cmds option is on, and each
  -- prints a deprecation notice over whatever it was about to show.
  --
  -- The search is wrapped rather than bound straight to the command, for two reasons.
  --
  -- First, the picker. auto-session resolves one on the first search -- telescope, fzf, snacks,
  -- then vim.ui.select -- and caches the answer for the rest of the session. Its telescope test is
  -- `vim.fn.exists(":Telescope") == 2`, and telescope loads on `keys` here, so before any telescope
  -- mapping has been pressed that command does not exist and the search falls all the way through
  -- to vim.ui.select: a one-line prompt at the bottom of the screen, for the rest of the session,
  -- even once telescope is loaded. Requiring the module first is what fixes it -- lazy.nvim's
  -- module loader loads the owning plugin on require, so `:Telescope` exists by the time
  -- auto-session looks for it, and the flex layout in lua/plugins/telescope.lua is what draws the
  -- session list.
  --
  -- Second, the empty case. Upstream's vim.ui.select picker (pickers/select.lua) hands an empty
  -- list straight to vim.ui.select when no session has been saved, putting up a "Select a session:"
  -- prompt with nothing to select. Reported here instead, before any picker opens.
  keys = {
    {
      "<leader>qs",
      function()
        local sessions = require("auto-session.lib").get_session_list(require("auto-session").get_root_dir())
        if vim.tbl_isempty(sessions) then
          vim.notify("No saved sessions", vim.log.levels.INFO)
          return
        end
        pcall(require, "telescope") -- see above: loads telescope so auto-session picks it, not vim.ui.select
        vim.cmd("AutoSession search")
      end,
      desc = "Search sessions",
    },
    { "<leader>qW", "<cmd>AutoSession save<CR>", desc = "Save session" },
    { "<leader>qr", "<cmd>AutoSession restore<CR>", desc = "Restore session" },
    { "<leader>qd", "<cmd>AutoSession delete<CR>", desc = "Delete session" },
  },
}
