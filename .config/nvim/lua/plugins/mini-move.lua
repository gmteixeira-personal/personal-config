-- Move the selected text around as a unit. The alternative it replaces is `dd` then `p`, which
-- clobbers the unnamed register and needs the cursor moved to the destination first, or `:m` typed
-- out, which needs the destination expressed as a number -- the arithmetic the user was trying to
-- avoid by nudging the block one line at a time and looking at it.
--
-- The keys are <M-h/j/k/l>, which lua/config/keymaps.lua:87-90 already owns as the window-resize
-- block. Not a collision: that block is normal mode only, and this is visual mode only. The
-- directions agree deliberately, so the same four fingers mean the same four directions in both --
-- in normal mode Alt moves the window edge, in visual mode it moves the text. A selection has to
-- exist before it can be moved, so the mode the user is already in is the one that disambiguates.
--
-- A plugin rather than the four-line `:m '>+1<CR>gv=gv` version, which covers about half of this:
-- `:m` is linewise, so it promotes a charwise or blockwise selection to whole lines; it has no
-- sideways equivalent at all; a count in front of it does not do what a user expects; and `gv=gv`
-- reindents unconditionally, including where the reindent is wrong.
return {
  "echasnovski/mini.move", -- the same owner lua/plugins/mini-icons.lua uses; standalone, no deps
  -- keys, not event = "VeryLazy": a tool reached for deliberately, the rule telescope, conform and
  -- vim-visual-multi follow. These entries are NOT the mappings -- mini.move installs its own in
  -- setup(), from the table below, and its own descriptions ("Move left" and friends) with them.
  -- These exist to trigger the load, and their descriptions are what which-key shows in the window
  -- between startup and the first press. The two lists have to be kept in step by hand: nothing
  -- checks that a left-hand side here matches one there.
  keys = {
    { "<M-h>", mode = "v", desc = "Move selection left" },
    { "<M-j>", mode = "v", desc = "Move selection down" },
    { "<M-k>", mode = "v", desc = "Move selection up" },
    { "<M-l>", mode = "v", desc = "Move selection right" },
  },
  opts = {
    mappings = {
      -- Visual mode: move the selection. Written out rather than left to upstream's defaults --
      -- which happen to be the same four keys -- because the local precedent is the resize block,
      -- and a reader should be able to see the two agree without going to look up what upstream
      -- chose.
      left = "<M-h>",
      down = "<M-j>",
      up = "<M-k>",
      right = "<M-l>",

      -- Normal mode: off. An empty string is how mini.move disables a mapping, and all four have
      -- to be disabled: upstream defaults them to these same Alt keys, and setup() runs when
      -- lazy.nvim loads the plugin -- long after config.keymaps has run at startup. Last writer
      -- wins, so leaving these at their defaults would hand mini.move the resize mappings, and it
      -- would do it silently: no error, just <M-j> quietly moving a line where it used to resize.
      -- The same load-order trap lua/config/keymaps.lua:82 documents for the arrow keys and
      -- vim-visual-multi. Do not "tidy" these away.
      line_left = "",
      line_down = "",
      line_up = "",
      line_right = "",
    },
    -- Reindent a linewise move to where it arrives, so a statement moved down past the opening of
    -- a nested block lands at the inner level instead of carrying its old indent. Upstream's
    -- default, written out because it is the behaviour being relied on. It applies to the vertical
    -- moves of a linewise selection only: a horizontal move IS a change of indentation, and a
    -- charwise or blockwise move leaves the surrounding lines alone.
    options = { reindent_linewise = true },
  },
}
