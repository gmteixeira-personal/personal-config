-- The repository's whole difference against a revision: a panel listing every file that differs
-- and, beside it, the selected file's two versions side by side. Also one file's difference on its
-- own, that file's history as the commits that touched it, and the three-way view a merge conflict
-- is resolved in, which nothing else here provides.
--
-- Three of the four <leader>g diff keys are this plugin's. <leader>gd was gitsigns' -- it opened
-- the buffer against the index with gitsigns.diffthis -- and is diffview's now, scoped to the
-- current file. One plugin doing both the one-file and the every-file case means one set of
-- in-view keys and one way to dismiss either, instead of two that behaved differently.
--
-- <leader>gh was neogit's fourth status arrangement, the horizontal split, and is taken from it
-- here -- see the note in lua/plugins/neogit.lua.
--
-- neogit also reaches this plugin without going through the mappings below -- see the diff_viewer
-- and integrations settings there -- so these are the user's entry points, not the only ones.

-- Every mapping below toggles: one key, two states, the view is up or it is not.
--
-- Openness is asked of diffview's own registry of views, each of which knows the tabpage it
-- occupies. Deliberately not inferred from the windows on screen: <leader>b hides the file panel
-- from inside the view, and a check that looked for the panel's window -- or counted diff windows,
-- or matched a buffer name -- would decide the view was closed and open a second one on top of it.
-- The registry is the plugin's own answer and does not change when the panel is toggled.
--
-- Each key matches only the views it is responsible for, because a key that closed whichever view
-- happened to be up would let one mapping dismiss what another opened. Two things separate them:
-- class.__name, which tells a repository diff from a file history, and path_args, which is empty
-- for the whole-repository view and holds the path for the single-file one.
-- Tabbing through a view loads a buffer per file and lists it -- File:_create_local_buffer :edits
-- the file in a temporary window when no buffer for it exists yet, and re-lists it when one does.
-- Read twenty files in a view and twenty buffers join <leader>bn, outliving the view that loaded
-- them; a session written afterwards records them too, so the next launch reopens files that were
-- only ever glanced at.
--
-- So the buffers listed before the first view opened are remembered, and when the last one closes
-- anything that joined the list since is dropped. Snapshotting is the whole trick: a buffer the
-- user already had open is in it and is left alone, whatever the view did with it.
--
-- Two guards on top of that, for the file opened out of a view with gf and then worked on: a
-- buffer with a window, or with unsaved changes, is never dropped.
local buffers_before_first_view = nil

local function remember_buffers()
  if buffers_before_first_view then
    return -- a view is already open; the first snapshot is the one that predates all of them
  end

  local listed = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then
      listed[buf] = true
    end
  end
  buffers_before_first_view = listed
end

local function forget_buffers_the_views_loaded()
  local before = buffers_before_first_view
  buffers_before_first_view = nil
  if not before then
    return
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.bo[buf].buflisted
      and not before[buf]
      and not vim.bo[buf].modified
      and vim.fn.bufwinid(buf) == -1
    then
      pcall(vim.api.nvim_buf_delete, buf, {})
    end
  end
end

local function toggle(matches, open)
  return function()
    local lib = require("diffview.lib")

    local current = lib.get_current_view()
    if current and matches(current) then
      vim.cmd.DiffviewClose()
      return
    end

    -- The view lives in its own tabpage, and gf inside it opens a file back in the previous one --
    -- so the user can be looking at an ordinary buffer with a view still open behind them. Two
    -- states means that press closes it rather than standing a second view up beside the first.
    -- :DiffviewClose acts on the current tabpage, hence the switch.
    for _, view in ipairs(lib.views) do
      if matches(view) and vim.api.nvim_tabpage_is_valid(view.tabpage) then
        vim.api.nvim_set_current_tabpage(view.tabpage)
        vim.cmd.DiffviewClose()
        return
      end
    end

    remember_buffers()
    open()
  end
end

local function is_diff(view)
  return view.class ~= nil and view.class.__name == "DiffView"
end

local function whole_repository(view)
  return is_diff(view) and #(view.path_args or {}) == 0
end

local function single_file(view)
  return is_diff(view) and #(view.path_args or {}) > 0
end

return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" }, -- already installed for Telescope, neogit and todo-comments
  -- No event, for the same reason as neogit: this paints nothing until it is asked to, so there is
  -- none of the first-frame flicker that puts gitsigns on BufReadPre.
  --
  -- `keys` rather than buffer-local mappings in an on_attach, which is how gitsigns' mappings have
  -- to be declared. None of these is per-buffer: they act on the repository containing the working
  -- directory, so a global mapping is both correct and a real lazy trigger.
  --
  -- `cmd` is for the command form typed by hand, not for neogit -- neogit's integration requires
  -- diffview's modules directly, and lazy.nvim's module loader loads the plugin on that require
  -- with nothing declared here. The commands are also where the argument-taking forms live:
  -- :DiffviewOpen with a revision range, :DiffviewFileHistory with a path other than this buffer's.
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewFileHistory",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
  },
  opts = {
    -- The file panel lists the files that differ, which is the point of the whole-repository view
    -- and is a one-entry list in the single-file one -- a column of screen spent restating the
    -- name of the file already on screen. It is closed for those, and only those.
    --
    -- Done from view_opened rather than in the <leader>gd mapping because this is a property of
    -- the view, not of how it was asked for: :DiffviewOpen -- some/file typed by hand gets the
    -- same treatment. The hook fires once the view is laid out, which is why the panel is there to
    -- close by the time it runs.
    --
    -- <leader>b reopens it from inside the view, as it closes it in the other one.
    hooks = {
      view_opened = function(view)
        -- The fallback snapshot, for :DiffviewOpen typed by hand rather than pressed. Less exact
        -- than the mapping's -- the first file may already be loaded by now -- but the mapping is
        -- the common path and takes its snapshot before the command runs at all.
        remember_buffers()

        if single_file(view) then
          view.panel:close()
        end
      end,
      view_closed = function()
        -- Scheduled because the view is still in lib.views while this runs: it is disposed of
        -- after close() returns. The cleanup waits for the last view to go, so closing one of two
        -- open views does not drop the other's buffers.
        vim.schedule(function()
          if #require("diffview.lib").views == 0 then
            forget_buffers_the_views_loaded()
          end
        end)
      end,
    },
    -- Everything else is upstream's default, deliberately, and the defaults are the decision. The
    -- view's own keys -- <tab> and <s-tab> between files, gf to open the real file, the <leader>co
    -- / ct / cb / ca conflict choices, g? for the list -- are taken as they come rather than
    -- re-mapped: they are what diffview's documentation describes, g? lists them from inside the
    -- view, and they are buffer-local, so none changes the meaning of a key in an editing buffer.
  },
  keys = {
    {
      "<leader>gd",
      toggle(single_file, function()
        -- The file in this buffer against the last commit. Read before opening, because once a
        -- view is up the current buffer is one of diffview's own; the toggle only reaches here
        -- when no single-file view is open, so % is still the user's file.
        local file = vim.fn.expand("%:p")
        if file == "" then
          vim.notify("No file in this buffer to diff", vim.log.levels.WARN)
          return
        end
        -- After `--`, so diffview reads it as a path rather than as a revision.
        vim.cmd("DiffviewOpen -- " .. vim.fn.fnameescape(file))
      end),
      desc = "Toggle git diff (this file)",
    },
    {
      "<leader>gm",
      toggle(whole_repository, function()
        -- No argument: the working tree against the last commit, which is the view wanted before
        -- staging or before writing a commit message. Ranges and single commits are reachable from
        -- neogit's diff popup, which sends them here.
        vim.cmd.DiffviewOpen()
      end),
      desc = "Toggle git diff (repository)",
    },
    {
      "<leader>gr",
      function()
        -- Not a toggle: it acts on a view that is already up rather than standing one up. The
        -- view watches the repository and refreshes itself, so this is for the case that watch
        -- cannot see -- an index rewritten by something outside this editor.
        vim.cmd.DiffviewRefresh()
      end,
      desc = "Refresh git diff",
    },
    {
      "<leader>gh",
      toggle(function(view)
        return view.class ~= nil and view.class.__name == "FileHistoryView"
      end, function()
        vim.cmd.DiffviewFileHistory()
      end),
      desc = "Toggle git file history",
    },
  },
}
