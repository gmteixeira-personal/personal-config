-- Multiple cursors: edit at several places at once. The tool for edits too small to justify
-- :substitute and not semantic enough for an LSP rename -- neither of which this replaces.
--
-- Its leader moves off `\`, which is this config's maplocalleader (lua/config/options.lua sets it
-- explicitly, so a plugin must not quietly take it). The cost is that upstream docs, the help file,
-- and every tutorial describe the default leader. Translation:
--
--     upstream        here
--     \\              <leader>m\    add a cursor at the current position
--     \A              <leader>mA    select every occurrence of the word under the cursor
--     \/              <leader>m/    place cursors by regex search
--     \gS             <leader>mgS   ... and so on for every `\`-prefixed command
--
-- In-mode mappings -- the ones that exist only while cursors are active (<Esc>, n/N, q/Q, [/],
-- <Tab>, S) -- are left at their defaults: they are buffer-local and modal, so they cannot collide
-- with this config's namespace. The one exception is Undo/Redo, below. No highlight config (the
-- plugin links to IncSearch and Visual, which rose-pine defines), and g:VM_mouse_mappings stays
-- off as shipped.
return {
  "mg979/vim-visual-multi",
  init = function()
    -- init, NOT config. lazy.nvim runs init during startup before the plugin loads; config runs
    -- after. The plugin reads g:VM_leader once, in s:build_permanent_maps() at vim start, when it
    -- generates its permanent mappings -- so a value set in config arrives too late and is
    -- silently ignored, leaving the mappings on the default `\`.
    vim.g.VM_leader = "<leader>m"

    -- The only g:VM_maps override, and it exists to bound the blast radius of a mis-aimed edit.
    -- A multi-cursor edit is one undo step PER CURSOR in ordinary undo -- deleting a word at
    -- three cursors takes three `u` to revert -- so without this, correcting a mistake is as
    -- error-prone as the mistake. VM's own Undo jumps the undo tree back to the state before the
    -- edit in one press and restores the cursors with it. It is buffer-local and only exists
    -- while cursors are active: after <Esc>, `u` is ordinary undo again.
    --
    -- Upstream calls it experimental, and it is, so the limits are worth knowing:
    --   * exact for the FIRST multi-cursor edit of a session -- the case this is here for;
    --   * a later edit in the same session usually reverts back to the session's start, i.e.
    --     every edit made since the cursors were placed, not just the last one;
    --   * after successive appends it can land on a state that never existed (trailing spaces
    --     where the appended text was). Press <Esc> and use ordinary undo if that happens.
    -- Redo is deliberately NOT mapped: VM's own restores nothing and leaves E803 in v:errmsg.
    vim.g.VM_maps = { Undo = "u" }
  end,
  -- keys, not event = "VeryLazy": this is a tool reached for deliberately, the case keys
  -- describes, and it matches how telescope and conform load. The in-mode keys are deliberately
  -- absent -- they only exist once the plugin is active, by which point it is loaded.
  keys = {
    { "<C-n>", mode = { "n", "x" }, desc = "Multi-cursor: select occurrence" },
    { "<C-Down>", desc = "Multi-cursor: add cursor below" },
    { "<C-Up>", desc = "Multi-cursor: add cursor above" },
    { "<S-Right>", desc = "Multi-cursor: extend selection right" },
    { "<S-Left>", desc = "Multi-cursor: shrink selection left" },
    -- <leader>m is a prefix only, never a mapping in its own right, so it never waits out
    -- 'timeoutlen' -- the same rule <leader>f, <leader>c, and <leader>h already follow.
    { "<leader>mA", desc = "Multi-cursor: select all occurrences" },
    { "<leader>m/", desc = "Multi-cursor: select by regex" },
    { "<leader>m\\", desc = "Multi-cursor: add cursor here" },
  },
}
