-- The repository, as opposed to the buffer: one view listing everything that differs from the
-- index and from the last commit, from which files and parts of files are staged, commits are
-- written and amended, and branches, remotes, rebases, stashes and the log are driven. Four
-- mappings under <leader>g open it, differing only in where the window goes.
--
-- gitsigns is the other half of git here and is untouched by this file. It marks and stages hunks
-- inside the buffer being edited; this stages across files and does everything that has no
-- per-buffer meaning at all. Both act on the same index, so work staged by either is visible to
-- the other -- see the note on refreshing at the foot of this file.
return {
  "NeogitOrg/neogit",
  dependencies = { "nvim-lua/plenary.nvim" }, -- already installed for Telescope and todo-comments
  -- No event: this paints nothing until it is asked to, so there is none of the first-frame
  -- flicker that puts gitsigns and todo-comments on BufReadPre. `keys` loads it on the mappings
  -- below, and `cmd` makes :Neogit exist before the plugin does, so the command form works on a
  -- session where no mapping has been pressed.
  cmd = "Neogit",
  opts = {
    -- Where a bare :Neogit puts the window. The four mappings each pass their own `kind`, so this
    -- governs the command form alone; "auto" rather than upstream's "tab" so :Neogit and
    -- <leader>gg agree instead of quietly differing.
    kind = "auto",

    -- Stated outright rather than left nil. Upstream resolves a nil integration with
    -- pcall(require, ...), and under lazy.nvim a successful require *loads* the plugin -- so
    -- auto-detection would pull Telescope in as a side effect of detecting it, at whatever moment
    -- this setup runs. Declaring it means the require that loads Telescope happens when a picker
    -- is actually opened, which is a keypress the user made.
    integrations = {
      telescope = true,
      -- diffview.nvim is not installed. Neogit's own expandable diffs inside the status buffer
      -- cover reviewing a change before staging it, which is what this configuration needs; a
      -- second full plugin would bring a second set of buffer-local keys and a second history UI
      -- overlapping <leader>gc. Deferred rather than declined for good: flipping this to true and
      -- adding the dependency is the whole change if the inline diffs prove too cramped.
      diffview = false,
    },

    -- Everything else is upstream's default, deliberately. The status buffer's own keys -- s, u,
    -- c, b, p, P, r, Z, l and the rest -- are taken as they come rather than re-mapped: they are
    -- magit's, they are what every neogit tutorial describes, and ? lists them from inside the
    -- view, which is the discoverability this configuration asks of them. They are buffer-local,
    -- so none of them changes the meaning of a key in an editing buffer.
  },
  -- The placement is an argument to the call, not a setting -- which is the point of having four
  -- mappings instead of one. Which arrangement is wanted depends on what the user is doing at that
  -- moment: the whole window to work through a large status, a vertical split to keep the file in
  -- view while staging it. As a setting that choice would be a config edit; as four two-key
  -- sequences under a prefix which-key already names "Git", it is a keystroke.
  --
  -- <leader>g itself stays unbound, as every prefix in this configuration does, so nothing under
  -- it waits out 'timeoutlen'. Telescope owns <leader>gf, <leader>gs, <leader>gc and <leader>gb;
  -- the two sets divide cleanly -- those four fuzzy-find over the repository, these four open the
  -- view that acts on it.
  --
  -- Written as require("neogit").open(...) rather than as <cmd>Neogit kind=...<CR>: that is the
  -- API the argument belongs to, it is how every other plugin mapping here is written, and it does
  -- not depend on the command's argument parsing.
  keys = {
    {
      "<leader>gg",
      function()
        -- The doubled letter is the one reached without thinking, so it carries the arrangement
        -- that needs no thought: upstream's own width-based choice -- a vertical split when the
        -- window is wide enough for one, a horizontal split when it is not. Left to upstream
        -- rather than reimplemented here against a column count of our own. The other three are
        -- for when a particular placement is wanted.
        require("neogit").open({ kind = "auto" })
      end,
      desc = "Git status (auto-placed)",
    },
    {
      "<leader>gr",
      function()
        require("neogit").open({ kind = "replace" })
      end,
      desc = "Git status (replace window)",
    },
    {
      "<leader>gv",
      function()
        require("neogit").open({ kind = "vsplit" })
      end,
      desc = "Git status (vertical split)",
    },
    {
      "<leader>gh",
      function()
        require("neogit").open({ kind = "split" })
      end,
      desc = "Git status (horizontal split)",
    },
  },

  -- No bridge to gitsigns, on purpose. Staging here rewrites .git/index, and gitsigns watches the
  -- git directory itself (watch_gitdir, on by default), so the sign column follows a stage made
  -- from this view with nothing written here. The alternative -- an autocmd on the
  -- NeogitStatusRefreshed / NeogitCommitComplete user events calling gitsigns.refresh() -- would
  -- duplicate a mechanism that already exists and would go on silently "working" if the index
  -- watcher were ever turned off, hiding the real cause. If the indicators are ever seen to lag,
  -- that autocmd is the fix and it is three lines.
}
