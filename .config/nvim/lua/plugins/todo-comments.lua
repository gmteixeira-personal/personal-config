-- The reminders left in the source -- TODO:, FIXME:, HACK: and their kin -- picked out of the
-- comment around them: each keyword group drawn in its own colour with the rest of the line
-- tinted, an icon for the group in the sign column, ]t / [t between the markers in the buffer,
-- and the whole project's markers listed under <leader>t as a picker, a quickfix list, or a
-- window-local location list. Those listings skip openspec/, whose markers are prose about this
-- capability rather than work items; see the search block below.
--
-- ]t and [t are claimed from Neovim 0.12's built-in tag-stack mappings on purpose. This
-- configuration has no tag-file workflow; :tnext and :tprevious remain and are the replacements.
-- The bracket pairs that are used -- ]c / [c for hunks, ]d / [d for diagnostics -- are untouched,
-- and so are bare t and T.
--
-- The picker is reached through Lua rather than through :TodoTelescope. That command expands to
-- :Telescope todo-comments todo, and :Telescope does not exist until telescope.nvim has loaded --
-- lua/plugins/telescope.lua loads it on `keys` and declares no `cmd`, so pressing the mapping
-- first in a session would fail with "Not an editor command". The two list mappings have no such
-- problem, but are written the same way so every mapping in the file reads alike.
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" }, -- already installed as a Telescope dependency; the
  -- searches run through plenary.job. telescope.nvim is deliberately NOT a dependency: it would
  -- drag it in at BufReadPre and undo the lazy loading fuzzy-finder arranged.
  event = "BufReadPre", -- same event and same reasoning as gitsigns: this paints the sign column
  -- and the buffer, so VeryLazy -- which fires after the first frame -- would show as markers
  -- appearing a moment after the file is on screen. Upstream attaches to every visible window at
  -- setup, so the file that triggered the load is covered along with the ones opened later. One
  -- wrinkle, accepted: set up before VimEnter, upstream defers its own setup by an event-loop
  -- tick, so on a file passed on the command line the markers arrive a tick after the first
  -- paint. Nothing shifts when they do -- the sign column is already reserved.
  opts = {
    -- Upstream's default is true, which tests whether the keyword is inside a real comment using
    -- a live tree-sitter highlighter, or failing that Vim's regex syntax stack at the keyword's
    -- column. Neovim 0.12 starts tree-sitter highlighting for lua, markdown, query and help only,
    -- and no parser plugin is installed here, so that test falls back to syntax -- and whether it
    -- answers depends on the filetype's syntax file and on which column it lands in. Measured on
    -- this configuration: a `# TODO:` in Python was highlighted, a `-- TODO:` in Lua and a
    -- `// FIXME:` in JavaScript were not. A marker silently unhighlighted in some languages and
    -- not others is worse than the alternative, so the test is dropped and matching runs on the
    -- highlight pattern alone. The cost: a bare `TODO:` inside a string or on a line of code is
    -- highlighted too. The pattern requires the colon, so prose mentions of the word are not.
    highlight = {
      comments_only = false,
    },

    -- Upstream's default is 8. The sign column here is `signcolumn=yes` -- one column, permanently
    -- reserved -- and gitsigns writes into it at priority 6, where the higher priority wins. At 8
    -- a line that is both marked and changed would show the marker and hide the git indicator,
    -- which git-integration requires to be visible. 5 inverts that: git wins the collision, the
    -- marker icon shows on every other marked line, and the marker's line highlighting is
    -- unaffected either way.
    sign_priority = 5,

    search = {
      -- Upstream's five default arguments, respelled because `search.args` is a list and the
      -- config merge replaces a list wholesale rather than appending to it -- so naming the glob
      -- alone would drop the output format the result parser depends on.
      args = {
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        -- The listings are a list of outstanding work, and openspec/ holds the planning prose
        -- *about* this capability: every `TODO:` and `FIXME:` under it is quoted example text in
        -- a proposal, a spec scenario, or a design note, never a work item. Left in, they are the
        -- clear majority of the hits in this repository and they bury the handful that are real.
        -- Scoped to that directory rather than to markdown as a whole, deliberately: a marker in
        -- a README or in any other note is a real one and stays listed. `**/` rather than an
        -- anchored `openspec/` so the exclusion holds wherever the editor's working directory
        -- sits relative to the planning root.
        "--glob=!**/openspec/**",
      },
      -- command and pattern stay at upstream's defaults: rg, already a prerequisite of <leader>fg,
      -- and the keyword-plus-colon regex. Neither --hidden nor --no-ignore is added, so .gitignore
      -- is honoured exactly as it is for the content search.
    },

    -- This exclusion is the search's alone. Highlighting has no path filter to hang it on --
    -- upstream's highlight.exclude takes filetypes, not globs -- so a marker in an openspec file
    -- is still coloured and signed while that file is open. That is the wanted behaviour anyway:
    -- the noise being removed is in the project-wide listings, not in the file being edited.

    -- keywords, colors, gui_style and highlight.pattern are left at upstream's defaults. The seven
    -- keyword groups and their Diagnostic*-derived colours are taken as they come -- deriving from
    -- the highlight groups is what makes them follow Themery's theme switches.
  },
  keys = {
    {
      "]t",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "Todo: next marker",
    },
    {
      "[t",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "Todo: previous marker",
    },
    -- The listings, under <leader>t. <leader>t itself is left unbound, as every other prefix in
    -- this configuration is.
    {
      "<leader>tt",
      function()
        -- The require is what loads Telescope -- lazy.nvim loads a plugin when a module it owns is
        -- required -- and Telescope's extension manager requires the extension module on first
        -- index, so there is no load_extension call and no Telescope dependency. The extension is
        -- a grep_string picker underneath, so it inherits the layout, borders, preview and
        -- <C-j>/<C-k>/<Esc> mappings from lua/plugins/telescope.lua without configuring any here.
        require("telescope").extensions["todo-comments"].todo()
      end,
      desc = "Todo: find markers",
    },
    {
      "<leader>tq",
      function()
        require("todo-comments.search").setqflist()
      end,
      desc = "Todo: markers to quickfix list",
    },
    {
      "<leader>tl",
      function()
        -- The same project-wide set as <leader>tq, but into this window's own list, so a window
        -- can hold a marker list without disturbing the quickfix list another one is working through.
        require("todo-comments.search").setloclist()
      end,
      desc = "Todo: markers to location list",
    },
  },
}
