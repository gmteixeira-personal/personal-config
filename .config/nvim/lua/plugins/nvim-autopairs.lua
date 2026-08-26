-- Automatic pairing: an opening delimiter brings its closing half with it, a closing delimiter
-- typed where one already sits moves over it, and backspacing an empty pair takes both halves.
-- Acts only on delimiters a person physically types -- text already in the buffer is
-- nvim-surround's half of this, in lua/plugins/nvim-surround.lua.
--
-- The default rule table does the work: apostrophe after a word character stays an apostrophe,
-- a quote before a word character is not paired, a quote after a backslash is escaped rather
-- than opened, and an opening bracket adds nothing when an unmatched close already stands later
-- on the line. No Rule() of our own -- inventing pairing rules is how insert mode gets a
-- keystroke wrong on every line.
--
-- The nvim-cmp integration (cmp_autopairs) is deliberately absent. It exists to stop nvim-cmp's
-- accept keystroke and autopairs from both inserting brackets; blink.cmp does not send
-- keystrokes -- it edits the buffer directly when an item is accepted -- so no keystroke passes
-- through here and there is nothing to deduplicate. Wiring it up would require nvim-cmp, which
-- this config does not have.
return {
  "windwp/nvim-autopairs",
  -- Its entire surface is insert mode, and lazy.nvim fires InsertEnter before the first character
  -- is typed, so the first keystroke of the first insert is already paired.
  event = "InsertEnter",
  opts = {
    -- Off (also the default): check_ts asks a treesitter parser whether the cursor is in a string
    -- or a comment before pairing. There is no nvim-treesitter in this config, so there is no tree
    -- to consult. If one is ever added, turning this on changes no requirement -- only how often
    -- the bracket rules fire where they should not.
    check_ts = false,
    -- These three match the current upstream defaults and are written out anyway: each has moved
    -- upstream before, and each protects input that is not a person typing. A pairing rule that
    -- fires inside a recording, a block insert, or replace mode corrupts a bulk edit silently --
    -- the one failure mode here that is not visible on the line in front of you.
    disable_in_macro = true,
    disable_in_visualblock = true,
    disable_in_replace_mode = true,
    -- map_cr, enable_check_bracket_line, and fast_wrap are left at their defaults (all on, wrap on
    -- <M-e>) and so are not written out.
    --
    -- map_cr is the one with a dependency outside this file: it maps <CR> so that pressing it
    -- between a pair opens the pair out onto three lines. That is safe only because
    -- lua/plugins/blink-cmp.lua uses keymap = { preset = "default" }, which binds <C-y> to accept
    -- and leaves <CR> unbound. Changing that preset to "enter" puts blink on <CR> too -- fix it
    -- here, by setting map_cr = false, rather than wondering why newlines stopped opening blocks.
    --
    -- fast_wrap's default <M-e> is free: the window-resize mappings hold <M-h>/<M-j>/<M-k>/<M-l>.
  },
}
