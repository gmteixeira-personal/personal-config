-- Takes the four things Neovim crowds onto the last screen row -- the command line, its messages,
-- its notifications, and the wildmenu that completes a `:` command -- and gives each its own
-- floating view. A long message becomes a scrollable split rather than a `Press ENTER` prompt, a
-- message that has scrolled past is recalled from a history instead of being lost, and `:` is typed
-- into near the middle of the screen rather than at its far edge.
--
-- Insert-mode completion is NOT touched. That is blink.cmp's, in lua/plugins/blink-cmp.lua, and
-- nothing here changes its candidate list, its keys, or its sources. Only the command-line
-- wildmenu moves.
--
-- lua/plugins/lsp.lua is not modified either: `K`, the LspAttach mappings and vim.diagnostic.config
-- stay exactly as they are, and the `lsp` block below is noice installing its own overrides.
return {
  "folke/noice.nvim",
  -- nui is noice's view backend; nvim-notify is its notification backend, which is what stacks
  -- several outstanding notifications instead of overwriting them and what keeps their history.
  -- Both are bare names on purpose. plugin-management asks that one file describe one plugin, and a
  -- dependency carrying its own opts block starts describing a second. nvim-notify's defaults are
  -- adequate here -- notably background_colour, the setting usually overridden to silence its
  -- transparency warning, which is unnecessary because the colorscheme is applied first (below).
  dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },

  -- Eager, and first on the startup path after the colorscheme.
  --
  -- noice's own README suggests event = "VeryLazy", and that is cheaper: VeryLazy fires after the
  -- first screen is drawn, so noice would cost nothing before the user sees a buffer. It is
  -- rejected because VeryLazy is after every other plugin has loaded -- every message emitted while
  -- lazy.nvim installs, while mason-tool-installer reports what it is fetching, or while a language
  -- server fails to start would go to the classic bottom row and never enter noice's history. Those
  -- are the messages a history is actually reached for. The price is noice and nui on the critical
  -- path to the first frame; measure against the ~39 ms baseline recorded in lua/config/options.lua
  -- and fall back to VeryLazy, accepting an incomplete startup history, if it proves material.
  lazy = false,
  -- 950 sits between themes/themery.lua (1000) and mini-icons.lua (900). The colorscheme has to
  -- stay ahead: nvim-notify resolves its background from the NotifyBackground/Normal highlight the
  -- first time it draws, and with no colorscheme applied yet it falls back to transparent and warns
  -- about it on every launch.
  priority = 950,

  opts = {
    -- Upstream's own composed view and route sets. Writing the equivalent `views` and `routes`
    -- tables out by hand would pin today's layout and lose upstream's tuning of it -- the same
    -- reasoning which-key.lua records for taking preset = "modern" over an expanded win/layout
    -- table. Everything the message-ui spec names is a noice default once these are set.
    --
    -- That still holds with the one `views` entry below: presets remain how the layout is chosen,
    -- and the entry is a single duration no preset carries. A second entry is the point to re-read
    -- this paragraph, not to extend the table by reflex.
    presets = {
      command_palette = true, -- wildmenu popup directly under the cmdline input, as one view
      long_message_to_split = true, -- long output opens a scrollable split, not a Press-ENTER prompt
      lsp_doc_border = true, -- bordered hover / signature floats
      bottom_search = false, -- default, written out because the floating `/` is contractual
      inc_rename = false, -- inc-rename.nvim is not installed
    },

    -- The cmdline, messages, popupmenu and notify option tables are deliberately absent: all four
    -- are enabled by default and the presets above are the only shaping they need. No `routes`
    -- entry either, but NOT because the defaults already display everything: msg_showmode -- the
    -- event carrying `recording @q` -- is in noice's default route table matched with
    -- opts = { skip = true }, which sends it to no view at all. With the last row freed, nothing
    -- would show a recording in progress.
    --
    -- That skip is upstream's design rather than an oversight: noice suppresses mode messages from
    -- views because it expects a status line to carry them, and keeps the message in
    -- Manager._history where noice.api.status reads it. lua/plugins/lualine.lua is what surfaces
    -- it, through noice.api.status.mode, and message-ui's "a recording stays visible" requirement
    -- is met there rather than here. Adding a route to re-display it would be a second mechanism
    -- for one message.

    views = {
      -- How long a transient overlay is held before it clears itself. 1500 ms, against
      -- nvim-notify's 5000 ms default. Well inside message-ui's three-second ceiling, and short
      -- enough that a one-line message is caught in the glance it takes to read it rather than
      -- sitting in the corner afterwards. Deliberately at the brisk end: the messages this
      -- configuration raises are write confirmations and yank counts, which are recognised rather
      -- than read, and anything the user actually needs to study is one of the two recall mappings
      -- below. Raise it if something worth reading is routinely being lost.
      --
      -- This one value governs BOTH vim.notify notifications and short editor messages, and that
      -- is the intended scope rather than a side effect: noice's defaults send messages.view,
      -- view_error, view_warn and every notification to this same `notify` view. Two overlays that
      -- look alike are held for the same time on purpose.
      --
      -- Set on noice's view rather than as an opts table on nvim-notify, which is the other place
      -- it would work. That would turn a bare dependency into a nested spec -- the thing the
      -- dependencies comment above says it is avoiding -- and would put a setting for a view noice
      -- owns into the configuration of a plugin noice merely drives.
      --
      -- It cannot truncate long output: long_message_to_split sends anything too big for this view
      -- to the `split` view, which is not timed and stays until dismissed. A short message missed
      -- inside the shorter window comes back with <leader>nl (the last one, in full) or <leader>nh
      -- (the whole session).
      notify = { timeout = 1500 },
    },

    lsp = {
      hover = { enabled = true }, -- both draw into a noice view that closes on CursorMoved, which
      signature = { enabled = true }, -- is why language-servers' "dismissed by any cursor movement"
      progress = { enabled = true }, -- still holds. progress is what makes $/progress visible at all.
      override = {
        -- The pair that renders server documentation as markdown rather than as the raw text of
        -- the response.
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        -- Off explicitly, not left absent: nvim-cmp is not installed, and a reader comparing this
        -- against noice's README should find the line saying why rather than wonder whether it was
        -- forgotten. blink.cmp draws its own documentation window and noice has no hook into it,
        -- so LSP documentation looks one way under `K` and another in the completion menu.
        -- Accepted -- wiring noice into blink's documentation window is not a supported integration.
        ["cmp.entry.get_documentation"] = false,
      },
    },
  },

  -- keys entries rather than vim.keymap.set calls in config, purely for consistency with the rest
  -- of lua/plugins/. The plugin is lazy = false, so these do no lazy-loading work; the desc on each
  -- is what which-key lists. :Noice pick routes to telescope when telescope is loaded and falls
  -- back to noice's own split otherwise, which is why this file does not require telescope.
  keys = {
    { "<leader>nh", "<cmd>Noice history<cr>", desc = "Message history" },
    { "<leader>nl", "<cmd>Noice last<cr>", desc = "Last message" },
    { "<leader>nn", "<cmd>Noice pick<cr>", desc = "Search messages & notifications" },
    { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss all messages" },
    { "<leader>ne", "<cmd>Noice errors<cr>", desc = "Errors" },
    -- Scroll a hover or signature float without moving focus into it. noice.lsp.scroll returns
    -- false when no scrollable float is open, and the mapping then returns the key string itself --
    -- expr = true is what makes that fallback a real <C-f>/<C-b> page scroll rather than a
    -- recursive call back into this mapping. noice's documented recipe, and the only way to get
    -- scroll-without-focus without shadowing <C-f>/<C-b> outright.
    {
      "<C-f>",
      function()
        if not require("noice.lsp").scroll(4) then
          return "<C-f>"
        end
      end,
      mode = { "n", "i", "s" },
      expr = true,
      silent = true,
      desc = "Scroll documentation float forwards",
    },
    {
      "<C-b>",
      function()
        if not require("noice.lsp").scroll(-4) then
          return "<C-b>"
        end
      end,
      mode = { "n", "i", "s" },
      expr = true,
      silent = true,
      desc = "Scroll documentation float backwards",
    },
  },

  -- Tree-sitter: noice highlights its views with the markdown, markdown_inline, vim and lua parsers
  -- bundled with Neovim 0.12, and probes for them through vim.treesitter.language.add rather than
  -- through nvim-treesitter -- so no parser plugin is needed and none is added. The two noice also
  -- asks for, regex and bash, are not bundled and are deliberately not installed: :checkhealth
  -- noice reports both missing, and the whole effect is unhighlighted search patterns in the search
  -- input and unhighlighted :! shell commands. Dropping the two .so files into
  -- ~/.local/share/nvim/site/parser/, where this machine's extra parsers already live, fixes it
  -- without a plugin.
}
