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
    end,
  },
}
