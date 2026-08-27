-- Per-line indicators of how the buffer differs from the git index, and the actions on those hunks.
return {
  "lewis6991/gitsigns.nvim",
  event = "BufReadPre", -- not VeryLazy: that fires after the first frame is painted, which shows
  -- as the sign column popping in and shoving the text sideways
  opts = {
    -- All mappings are declared here rather than in `keys`, because they must be buffer-local:
    -- on_attach runs only for a file inside a git repository, so outside one these keys simply
    -- do not exist instead of existing and erroring.
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- Navigation. Guarded on vim.wo.diff so a buffer in diff mode keeps Neovim's own
      -- next/previous-difference behaviour -- including in the diff gitsigns itself opens,
      -- where losing ]c/[c would leave nothing to navigate it with.
      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next hunk / next diff")

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Previous hunk / previous diff")

      -- Hunk actions under the <leader>h prefix. <leader>h itself is left unbound.
      -- Names checked against the installed gitsigns: v1.0 reworked the staging API.
      map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
      map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")

      -- Called with a line range, stage_hunk and reset_hunk act on exactly those lines rather
      -- than on the hunk enclosing them, which is what makes a partial-hunk stage possible with
      -- no separate API. line(".") is the cursor end of the selection and line("v") the other;
      -- the pair is not normalised because gitsigns handles a reversed range, so a selection made
      -- upward behaves the same as one made downward.
      map("v", "<leader>hs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage selected lines")
      map("v", "<leader>hr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset selected lines")

      -- Distinguished from <leader>hr by case alone, and deliberately so: the wider, more
      -- destructive action should not be reachable by a slip of one key. reset_buffer discards
      -- only *unstaged* changes -- anything already staged stays in the index.
      map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")

      map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
      map("n", "<leader>hb", function()
        gitsigns.blame_line({ full = true })
      end, "Blame line")

      -- The whole file against the index, as opposed to the per-hunk actions above. <leader>g is
      -- the git prefix shared with neogit and Telescope -- see the ownership note in
      -- lua/plugins/neogit.lua.
      map("n", "<leader>gd", function()
        -- Guarded on vim.wo.diff so a second press opens nothing. gitsigns.diffthis returns early
        -- on the same condition, but that is upstream's early return and this does not rest on it.
        if vim.wo.diff then
          return
        end

        -- vertical and split are stated rather than left to gitsigns, which derives `vertical`
        -- from &diffopt. Both defaults already give the wanted layout -- indexed version left,
        -- working buffer right -- but adding `horizontal` to diffopt in lua/config/options.lua
        -- would otherwise turn this split sideways from a file that has nothing to do with git.
        --
        -- Where the cursor ends up is left to gitsigns, which puts it back in this window. The
        -- diff is read from the file it belongs to, and moving between the two halves is what
        -- <leader>ww and <leader>wp are for.
        local from_win = vim.api.nvim_get_current_win()
        gitsigns.diffthis(nil, { vertical = true, split = "aboveleft" }, function(err)
          if err then
            return
          end

          -- diffthis is async: the split does not exist when the call returns, so this runs from
          -- the callback rather than straight-line after it. The revision is found by asking which
          -- windows are in diff mode, not with wincmd h: that would be counting windows on screen
          -- rather than identifying the one holding it, and it would follow `split` silently wrong
          -- if that were ever changed. A conflicted file has two -- :2 and :3 -- and both count.
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if win ~= from_win and vim.wo[win].diff then
              -- gitsigns creates the revision buffer unlisted, but then opens it with :diffsplit,
              -- and an editing command lists the buffer it opens. Left alone, the indexed version
              -- turns up in <leader>bn / <leader>bp while the diff is open. Undone here rather
              -- than upstream because it is a side effect of the split, not something gitsigns
              -- asked for.
              vim.bo[vim.api.nvim_win_get_buf(win)].buflisted = false
            end
          end
        end)
      end, "Diff file against index")
    end,
  },
}
