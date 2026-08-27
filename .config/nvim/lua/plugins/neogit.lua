-- The repository, as opposed to the buffer: one view listing everything that differs from the
-- index and from the last commit, from which files and parts of files are staged, commits are
-- written and amended, and branches, remotes, rebases, stashes and the log are driven. One mapping
-- under <leader>g toggles it, in the window the user is already in.
--
-- gitsigns marks and stages hunks inside the buffer being edited and is untouched by this file;
-- this stages across files and does everything that has no per-buffer meaning at all. Both act on
-- the same index, so work staged by either is visible to the other -- see the note on refreshing
-- at the foot of this file. diffview is the third and is reached from here as well as from its own
-- mapping: it is where this view sends a change too large to read inline, and where it sends a
-- conflict.
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
      -- diffview.nvim, installed in lua/plugins/diffview.lua. This was false for as long as the
      -- inline diffs above were enough; they are not, for a change spanning several files, and
      -- they can do nothing at all with a merge conflict. Turning it on is what gives the diff
      -- popup somewhere to send a change, and what makes staging a conflicted file open a
      -- three-way view instead of reporting "Conflicts must be resolved before staging" -- both
      -- are branches neogit already has and could not reach.
      --
      -- Its file history is still not mapped anywhere: :DiffviewFileHistory exists, but a key for
      -- it would sit beside Telescope's <leader>gc listing the same commits differently. That
      -- overlap was the real half of the old argument here and it is unresolved, so it stays a
      -- command.
      diffview = true,
    },

    -- Which of the two viewers neogit hands a diff to. Stated rather than left nil for the reason
    -- above -- a nil viewer is auto-detected, and auto-detection's second candidate is codediff,
    -- which means another pcall(require, ...) for a plugin this configuration does not install,
    -- run on the code path reached by pressing d in the status buffer. Naming it skips the search.
    -- It also means installing codediff later cannot quietly change which viewer neogit picks.
    diff_viewer = "diffview",

    -- Everything else is upstream's default, deliberately. The status buffer's own keys -- s, u,
    -- c, b, p, P, r, Z, l and the rest -- are taken as they come rather than re-mapped: they are
    -- magit's, they are what every neogit tutorial describes, and ? lists them from inside the
    -- view, which is the discoverability this configuration asks of them. They are buffer-local,
    -- so none of them changes the meaning of a key in an editing buffer.
  },
  -- One mapping, where there were four. The placement is still an argument to the call rather than
  -- a setting, but it is no longer a choice made at the moment of opening: <leader>gg replaces the
  -- current window and that is the arrangement.
  --
  -- The other three keys went to the diff views, which are pressed far more often than a placement
  -- is reconsidered: <leader>gh is diffview's file history, <leader>gr its refresh, and <leader>gv
  -- is unbound. Every arrangement is still reachable by asking for it outright -- :Neogit kind=auto,
  -- kind=vsplit, kind=split -- which is where a choice made once in a while belongs.
  --
  -- <leader>g itself stays unbound, as every prefix in this configuration does, so nothing under
  -- it waits out 'timeoutlen'. The prefix now divides three ways rather than four: Telescope owns
  -- <leader>gf, <leader>gs, <leader>gc and <leader>gb, which fuzzy-find over the repository;
  -- diffview owns <leader>gd, <leader>gm, <leader>gh and <leader>gr -- one file, every file, one
  -- file's history, and refresh; and this owns <leader>gg, the view that acts on the repository as
  -- a whole. gitsigns owns nothing here any more -- its <leader>gd went to diffview -- and keeps
  -- its per-hunk actions under <leader>h.
  --
  -- Written as require("neogit").open(...) rather than as <cmd>Neogit kind=...<CR>: that is the
  -- API the argument belongs to, it is how every other plugin mapping here is written, and it does
  -- not depend on the command's argument parsing.
  keys = {
    {
      "<leader>gg",
      function()
        -- A toggle, as every other key under <leader>g is: one key, two states, the view is up or
        -- it is not. is_open() and the instance's close() are the status buffer module's own
        -- answers -- deliberately not a search for a window with the NeogitStatus filetype, for
        -- the same reason lua/plugins/diffview.lua asks a registry rather than the screen.
        --
        -- close() keeps the fold state, the cursor line and the view position, so reopening lands
        -- where the user left off rather than at the top.
        local status = require("neogit.buffers.status")
        if status.is_open() then
          status.instance():close()
          return
        end

        -- kind = "replace": the whole of the current window, which is the arrangement a status
        -- buffer wants -- it is a tall list, and reading it beside the file it describes means
        -- reading both in half the width. The three other placements each had a key once; the
        -- comment above records where they went. :Neogit kind=... still asks for any of them.
        require("neogit").open({ kind = "replace" })
      end,
      desc = "Toggle git status",
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
