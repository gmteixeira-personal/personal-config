-- Markdown rendering: headings, lists, task checkboxes, tables, block quotes, callouts and fenced
-- code blocks drawn as formatted text rather than shown as their markup characters.
--
-- This is a display layer only. The plugin conceals markup and paints virtual text over it; the
-- bytes on disk are never touched, so a rendered buffer is the same file it always was.
--
-- It runs entirely on what Neovim 0.12 already bundles. The `markdown` and `markdown_inline`
-- parsers ship with the editor, along with their highlight, injection and fold queries, so there is
-- no parser to install, no nvim-treesitter, no external program and no build step -- which is what
-- keeps a fresh checkout of this repository able to render markdown with nothing but `Lazy sync`.
--
-- Nothing here starts treesitter highlighting, because Neovim already does: its bundled
-- `runtime/ftplugin/markdown.lua` opens with `vim.treesitter.start()`, which is also what supplies
-- gO, ]] and [[ in a markdown buffer. That is what reads `injections.scm` and colours a fenced
-- ```lua block as Lua, and a fence naming a language with no parser is a no-op rather than an
-- error, so unknown languages degrade quietly. An autocommand of our own would only call an
-- idempotent function a second time.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" }, -- The plugin declares its own ft; stated here so a session that never opens
  -- a markdown buffer visibly pays nothing for this, rather than paying nothing by inheritance.
  -- Same shape as vim-razor.lua, this config's other filetype-triggered plugin.
  dependencies = { "echasnovski/mini.icons" },

  opts = {
    -- Which modes the rendering is drawn in. Upstream's default is { "n", "c", "t" }, which leaves
    -- insert mode out -- and the effect of that is not "the line being edited goes raw" but the
    -- entire buffer going raw the moment i is pressed, and snapping back on Esc. Every mode is
    -- enabled instead, so entering insert changes only the cursor's own line, through anti_conceal
    -- below. That is what makes editing a rendered document feel like editing rather than toggling
    -- between two views of it.
    render_modes = true,

    -- The line the cursor is on is drawn as its raw markdown source while the lines around it stay
    -- rendered, so markup can be read and edited exactly as written. This is what keeps a rendered
    -- document editable in place instead of an effectively read-only view, and it is the one option
    -- here that is tempting to disable -- concealing everything makes for a better screenshot and a
    -- worse editor. Together with render_modes above, it applies in every mode.
    anti_conceal = { enabled = true },

    -- Colours come from the standard highlight groups all four themes in lua/plugins/themes/
    -- define, rather than from hardcoded values, so heading and code-block backgrounds follow
    -- whichever colorscheme Themery has applied.
  },
}
