-- Surround edits: the pair of delimiters around a piece of text treated as one thing. ys<motion><char>
-- adds a pair, ds<char> deletes the nearest one, cs<old><new> swaps it. The complement to
-- lua/plugins/nvim-autopairs.lua -- that one pairs text being typed, this one pairs text already there.
-- Neither maps a key the other maps.
--
-- opts = {} is deliberate, not a placeholder: every requirement in the spec is default behaviour.
-- The aliases (q for whichever quote is there, b for whichever bracket), tag support, padded versus
-- unpadded by naming the opening or the closing half, dot-repeat with no vim-repeat dependency, and
-- one undo step per edit all ship on. Passing the default keymaps table back in would only make
-- upstream's documentation stop matching this file.
--
-- Visual-mode S is shadowed. In stock Neovim it is a synonym for linewise change, reachable as V
-- then c, or as R. That is the only key here with a built-in meaning: s is not a motion, so ys, ds,
-- and cs are errors in stock Neovim, and bare s in normal mode is untouched.
--
-- The cost of mapping ys/ds/cs is that a bare y, d, or c now waits out 'timeoutlen' before falling
-- through to the operator. Only a bare one: yw, yy, dd, ciw and every other real sequence resolve on
-- the second key with no wait. The wait is the same whether the plugin is loaded or lazy.nvim is
-- holding a stub for it, so keys costs nothing that event = "VeryLazy" would avoid.
return {
  "kylechui/nvim-surround",
  version = "*", -- tagged releases; upstream's own recommendation, and main carries breaking changes
  opts = {},
  -- keys, matching how vim-visual-multi, telescope, and conform load: a tool reached for
  -- deliberately, not something needed before it is first pressed.
  keys = {
    { "ys", desc = "Surround: add around motion" },
    { "yss", desc = "Surround: add around line" },
    { "yS", desc = "Surround: add on own lines around motion" },
    { "ds", desc = "Surround: delete" },
    { "cs", desc = "Surround: change" },
    { "cS", desc = "Surround: change, new pair on own lines" },
    { "S", mode = "x", desc = "Surround: add around selection" },
    { "gS", mode = "x", desc = "Surround: add around selection on own lines" },
  },
}
