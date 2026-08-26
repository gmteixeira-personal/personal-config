-- The status line. Replaces the stock one -- a filename, a modified flag and the ruler -- with a
-- line reporting the editing mode, the git branch and working-tree change summary, a summary of the
-- repository's uncommitted work and unpushed commits, per-severity diagnostic counts, the file's
-- name and state, its type, and the cursor's position.
--
-- Upstream's defaults are taken as they come. The separators, icons and theme are all lualine's
-- own, deliberately not written out here -- the same reasoning which-key.lua records for
-- preset = "modern" and noice.lua for taking `presets` over an expanded routes table. TWO
-- presentation choices are made here and no more: the recording indicator in lualine_x, and the
-- repository summary in lualine_b. Each costs its section's upstream defaults being respelled
-- alongside it, because lualine replaces a named section wholesale; see the comments on both.
--
-- laststatus is not touched either, so each window keeps a status line of its own exactly as
-- before. lualine's own `globalstatus` default derives from whatever laststatus already is.

-- ---------------------------------------------------------------------------------------------
-- The repository summary
--
-- `+N` untracked files, `●N` files with unstaged changes, `◆N` files with staged changes, `↑N`
-- commits not yet on the branch's upstream. Each segment is dropped when its count is zero, so a
-- clean and fully pushed repository renders as the empty string and takes no width.
--
-- This block lives at file scope rather than in a `lua/util/` module because the statusline
-- capability requires the whole of itself to be one file under lua/plugins/ -- deleting this file
-- must return the editor to its stock line. Nothing here runs at file scope: these are a table, a
-- few locals and some function definitions, so lazy.nvim's spec collection pays nothing for them.
-- Everything that actually *does* something -- the autocmds, the timer, the first refresh -- is
-- created inside `opts` below, for the reason `opts` gives for being a function.
-- ---------------------------------------------------------------------------------------------

-- Rendered strings, keyed by repository root: the component returns one of these and does nothing
-- else, so a redraw never spawns, never walks the filesystem and never requires. A table rather
-- than a single string so that two repositories open at once each keep their own answer.
local summaries = {}

-- The repository the focused buffer is in, resolved on BufEnter and DirChanged and stored.
-- vim.fs.root walks upward through the filesystem, which is cheap once per buffer change and
-- wasteful sixty times a second, so it is never called from the component. nil means the focused
-- buffer is not inside a repository, and the component then draws nothing.
local active_root = nil

-- Per-root single-flight state. A refresh requested while one is already running for that root
-- sets the re-run flag instead of spawning a second git, and the flag is honoured when the running
-- one returns -- so a burst can never overlap and the final state is never missed.
local inflight = {}
local rerun = {}

-- The debounce timer, created on first use rather than at file scope so spec collection allocates
-- no libuv handle.
local timer = nil

-- One `git status --porcelain=v2 --branch -uall` yields all four counts:
--
--   # branch.ab +1 -0                              -> ↑, and present only when # branch.upstream is,
--                                                     which is what makes "no upstream, no ↑" fall
--                                                     out of the parse instead of needing a second
--                                                     `git rev-parse @{u}` whose error must be eaten
--   1 MM ... path        ordinary change           -> XY: X is index-vs-HEAD, Y is worktree-vs-index,
--   2 R. ... new<NUL>old rename                       `.` meaning unchanged. So a file staged and
--                                                     then edited again counts in both ● and ◆ with
--                                                     no special case
--   u UU ... path        unmerged                  -> counted in ●: a conflict is work owed before
--                                                     committing, and porcelain v2 gives it its own
--                                                     record type so it is not also a `1 ` line to
--                                                     be double-counted
--   ? path               untracked                 -> +
--
-- v1 --porcelain carries no ahead/behind pair, and separate diff/ls-files calls would be three or
-- four spawns for what one already answers, observed at different instants and free to disagree.
local function parse(stdout)
  local untracked, unstaged, staged, ahead = 0, 0, 0, 0
  for line in stdout:gmatch("[^\n]+") do
    local kind = line:sub(1, 2)
    if kind == "? " then
      untracked = untracked + 1
    elseif kind == "u " then
      unstaged = unstaged + 1
    elseif kind == "1 " or kind == "2 " then
      if line:sub(3, 3) ~= "." then
        staged = staged + 1
      end
      if line:sub(4, 4) ~= "." then
        unstaged = unstaged + 1
      end
    elseif kind == "# " then
      local a = line:match("^# branch%.ab %+(%d+)")
      if a then
        ahead = tonumber(a)
      end
    end
  end
  return untracked, unstaged, staged, ahead
end

-- Zero-suppression, spacing and symbol choice all happen here, once when the counts arrive, rather
-- than once per redraw. The component gets a finished string.
local function render(untracked, unstaged, staged, ahead)
  local parts = {}
  if untracked > 0 then
    parts[#parts + 1] = "+" .. untracked
  end
  if unstaged > 0 then
    parts[#parts + 1] = "●" .. unstaged
  end
  if staged > 0 then
    parts[#parts + 1] = "◆" .. staged
  end
  if ahead > 0 then
    parts[#parts + 1] = "↑" .. ahead
  end
  return table.concat(parts, " ")
end

local function spawn(root)
  if inflight[root] then
    rerun[root] = true
    return
  end
  inflight[root] = true

  -- -uall rather than git's default -unormal. -unormal collapses an untracked directory to one
  -- entry, so a new directory of six files would report `+1` -- and the spec says `+N` counts
  -- files. The cost is descending into untracked directories; git still does not descend into
  -- ignored ones, so a .gitignore'd node_modules costs nothing, and the invocation is off the main
  -- loop and debounced besides.
  local ok = pcall(vim.system, { "git", "status", "--porcelain=v2", "--branch", "-uall" }, {
    cwd = root,
    text = true,
  }, function(result)
    -- Runs off the main loop, so everything that touches editor state is scheduled.
    local rendered = ""
    if result.code == 0 then
      rendered = render(parse(result.stdout or ""))
    end
    vim.schedule(function()
      inflight[root] = nil
      local previous = summaries[root] or ""
      summaries[root] = rendered ~= "" and rendered or nil
      -- Redraw only when the answer actually changed. Most refreshes -- FocusGained on a repository
      -- nobody touched -- change nothing and should cost no repaint.
      if previous ~= rendered and root == active_root then
        vim.cmd("redrawstatus")
      end
      if rerun[root] then
        rerun[root] = nil
        spawn(root)
      end
    end)
  end)

  -- A non-zero exit, a spawn failure and a missing `git` are all the same thing: no summary. The
  -- entry is cleared and nothing is drawn -- no notification, no error, no trace. (vim.system
  -- raises rather than returning on ENOENT, which is why the call is wrapped.)
  if not ok then
    inflight[root] = nil
    summaries[root] = nil
  end
end

-- Every trigger goes through one timer restarted at 150ms, so a burst -- ten buffers written by
-- :wall, neogit firing NeogitStatusRefreshed alongside NeogitCommitComplete -- spawns git once.
local function refresh()
  timer = timer or vim.uv.new_timer()
  timer:start(
    150,
    0,
    vim.schedule_wrap(function()
      if active_root then
        spawn(active_root)
      end
    end)
  )
end

-- Returns true when the active repository changed, so the caller can decide whether a refresh is
-- warranted. Falls back to the working directory for a buffer with no name of its own, which is
-- what makes :cd into a repository from a scratch buffer resolve at all.
local function update_root(bufnr)
  local ok, root = pcall(vim.fs.root, bufnr, ".git")
  if not ok or not root then
    ok, root = pcall(vim.fs.root, vim.uv.cwd() or ".", ".git")
  end
  root = ok and root or nil
  if root == active_root then
    return false
  end
  active_root = root
  -- The previous repository's counts must stop being shown at once, whether or not the new
  -- repository has an answer yet -- including when there is no new repository at all.
  vim.cmd("redrawstatus")
  return true
end

return {
  "nvim-lualine/lualine.nvim",
  -- No dependencies entry. lualine's filetype component asks for nvim-web-devicons, which
  -- mini.icons already mocks; lua/plugins/mini-icons.lua is where that is arranged and says the
  -- real one must never be installed. noice is likewise already present and eager.
  lazy = false,
  -- Behind themery (1000), noice (950) and mini.icons (900), and for two separate reasons:
  --
  --   * lualine's default theme is "auto", which reads vim.g.colors_name and the live highlight
  --     groups at load. Setting up before a colorscheme is applied would resolve against no theme
  --     at all, so themery has to have run first.
  --   * the filetype component asks for nvim-web-devicons, which exists only once mini.icons has
  --     registered its mock.
  --
  -- Eager rather than VeryLazy because the status line is painted in the first frame: deferring it
  -- would show as the stock line being replaced after the editor is already on screen. Same
  -- reasoning gitsigns.lua and noice.lua record for their own load points.
  priority = 800,

  -- opts as a function, not a table. The recording component below calls require("noice"), and in
  -- a bare table literal that require would run when lazy.nvim reads this file -- during spec
  -- collection, before any plugin has loaded -- dragging noice in ahead of the colorscheme and
  -- defeating the priority ordering above. As a function it runs when lualine itself loads, by
  -- which point noice is up. The repository summary's autocmds and its first refresh are created
  -- here for exactly the same reason: at file scope they would run during spec collection.
  opts = function()
    local group = vim.api.nvim_create_augroup("statusline_git_summary", { clear = true })

    -- Re-resolve the repository as the focus moves. A refresh only when it actually changed --
    -- moving between two files of one repository cannot have changed the counts.
    vim.api.nvim_create_autocmd("BufEnter", {
      group = group,
      callback = function(ev)
        if update_root(ev.buf) then
          refresh()
        end
      end,
    })

    -- The events that can change the answer. FocusGained and VimResume are the catch-all: they
    -- pick up whatever was done in another terminal, which is why there is no polling timer -- one
    -- would spawn git forever in a repository nobody is touching, to cover the case these two
    -- already cover. DirChanged re-resolves as well as refreshing.
    vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained", "VimResume", "DirChanged" }, {
      group = group,
      callback = function(ev)
        if ev.event == "DirChanged" then
          update_root(ev.buf)
        end
        refresh()
      end,
    })

    -- gitsigns staged, unstaged or reset something. GitSignsChanged is the index-touching event
    -- (gitsigns/git.lua emits it from stage_lines, unstage_file and the hunk operations).
    -- GitSignsUpdate is deliberately NOT listened for: gitsigns/status.lua fires it on every buffer
    -- diff recomputation -- on essentially every keystroke -- and it reports nothing this component
    -- shows.
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "GitSignsChanged",
      callback = function()
        refresh()
      end,
    })

    -- Any neogit operation completed -- commit, push, pull, fetch, checkout, revert, and the
    -- fifteen others. A glob rather than the exact names: neogit sends every one of them as
    -- "Neogit" .. name (neogit/lib/event.lua) plus four spelled out in full in client.lua, and
    -- that list is neogit's to change. The prefix will not. An extra refresh from an event that
    -- turns out to have changed nothing costs one debounced spawn and renders an identical string,
    -- which is not redrawn.
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "Neogit*",
      callback = function()
        refresh()
      end,
    })

    -- One refresh at load, so the summary is there without waiting for the first event.
    update_root(vim.api.nvim_get_current_buf())
    refresh()

    return {
      -- lualine's config merge replaces each section it is given wholesale and leaves every section
      -- it is NOT given at the default -- so lualine_a (mode), lualine_c (filename, with its [+]
      -- and [-] flags), lualine_y (progress) and lualine_z (location) are absent here on purpose
      -- and arrive as upstream ships them. lualine_b and lualine_x are named only because
      -- something is being placed in each, and the cost of naming them is that their defaults have
      -- to be respelled alongside the addition, or they would be dropped.
      sections = {
        lualine_b = {
          -- lualine's own lualine_b default, first, restated because naming the section replaces
          -- it.
          "branch",
          {
            -- The repository summary, between `branch` and `diff` to keep the two `+N` apart.
            -- `branch` is repository-scoped and so is this, so they group; `diff` and
            -- `diagnostics` are buffer-scoped and group after. Putting this after `diff` would
            -- render `-1 +2` -- a buffer's removed lines hard against a repository's untracked
            -- files, the one adjacency worth avoiding.
            --
            -- Both `+N` staying on one line is deliberate: lualine's `diff` reports the FOCUSED
            -- BUFFER's added, changed and removed lines, this reports the WHOLE REPOSITORY's file
            -- counts. They answer different questions and both are wanted; do not "fix" this by
            -- deleting one.
            --
            -- The function returns a string that was rendered when the counts arrived. Nothing is
            -- computed here: this runs on every redraw of the line.
            function()
              return active_root and summaries[active_root] or ""
            end,
            -- With no cond, an all-zero repository would still cost the section its padding and
            -- its separator. This makes a clean, fully pushed tree report by silence.
            cond = function()
              return active_root ~= nil and summaries[active_root] ~= nil
            end,
            -- No color table and no highlight group, so the segments take lualine_b's own. lualine
            -- colours `diff` because it has to: `+3 ~2 -1` are three bare numbers told apart only
            -- by punctuation. Here the four symbols already carry the meaning, and colour would
            -- add a fourth palette to the line and a set of highlight groups to keep in step with
            -- every colorscheme -- against this file's rule of configuring no further than it
            -- needs to, and against theme-following, which currently costs nothing precisely
            -- because nothing is spent on it.
          },
          -- lualine's remaining lualine_b defaults, in upstream's order.
          "diff",
          "diagnostics",
        },
        lualine_x = {
          {
            -- `recording @a`, and one of this file's two reasons to exist.
            --
            -- noice's default route table matches msg_showmode with opts = { skip = true }, so the
            -- message reaches no view -- and with cmdheight = 0 there is no last row for Neovim to
            -- fall back to either. That skip is not a gap: noice suppresses mode messages from
            -- views precisely because it expects a status line to carry them, and noice.api.status
            -- is filtered on exactly the event the route drops. The message survives the skip --
            -- Manager.add writes it to both _messages and _history, the router's skip branch
            -- bypasses only view:push, and the status API reads _history -- so it is already here
            -- for the asking and nowhere else.
            --
            -- Nothing here decides when it disappears: noice's on_showmode calls Manager.remove
            -- when the event fires with empty content, which is the moment recording stops.
            --
            -- Two things on this line are now called "mode" and they are not the same. lualine's
            -- own `mode` component, in the default lualine_a, reports NORMAL/INSERT/VISUAL.
            -- noice's status.mode carries the msg_showmode message, which is what recording @a is.
            -- Both names are upstream's; both are wanted.
            require("noice").api.status.mode.get,
            cond = require("noice").api.status.mode.has,
          },
          -- lualine's own lualine_x defaults, restated because naming the section replaces it.
          "encoding",
          "fileformat",
          "filetype",
        },
      },

      -- options is absent entirely, and theme with it. "auto" is already the default, and it is
      -- what makes the theme requirement cost nothing: it resolves lua/lualine/themes/<colors_name>.lua
      -- off the runtimepath, and where a colorscheme ships no such file it synthesizes a palette
      -- from the live highlight groups instead. setup_theme() then registers
      -- `autocmd lualine ColorScheme * lua require'lualine'.setup()`, so every :colorscheme --
      -- which is what Themery issues, both on a switch and on its startup bootstrap -- re-runs the
      -- whole resolution.
      --
      -- Worth knowing for kanagawa specifically: both its variants report colors_name "kanagawa"
      -- and so share one lualine theme file, but it still tracks the variant, because load_theme
      -- uses dofile rather than require and the file re-reads the active palette each time.
      --
      -- globalstatus, separators, icons, winbar, tabline and extensions are all left alone for the
      -- same reason the sections are.
    }
  end,
}
