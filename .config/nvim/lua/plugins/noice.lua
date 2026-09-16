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

  -- Everything Neovide needs, and nothing that applies to a terminal.
  --
  -- Neovide attaches its UI with ext_cmdline and ext_messages enabled and turns both off again
  -- about a tick later. Measured with a --cmd probe: they read true at --cmd time, at VimEnter
  -- and at UIEnter, and false from roughly 100ms after that onwards. noice reads them exactly
  -- inside that window, twice, and both reads do damage:
  --
  --   * noice.ui.setup() takes a widget the GUI says it externalises as a widget noice must not
  --     touch, so it attached with { ext_popupmenu = true } alone. cmdline and msg handlers were
  --     false, which is why `:` dropped to the bottom row like a stock Neovim while the same
  --     configuration in foot opened the floating input.
  --   * The health check noice.setup runs before deferring its load reads the same flags and
  --     reports that the GUI has them enabled and noice cannot work. That report was correct.
  --
  -- The two blocks below fix the first and then silence the second, in that order, because the
  -- second is only safe to silence once the first is true. An earlier attempt had the suppression
  -- without the re-attach and hid a real regression for a day.
  config = function(_, opts)
    -- Silence the two "Noice can't work when the GUI has ext_cmdline enabled" reports.
    --
    -- The claim is true when it is made and false by the time it is read: the re-attach below
    -- runs as soon as Neovide clears the flags, so noice is driving the cmdline and the messages
    -- before the notification has finished fading. What is left on screen is a report of a state
    -- that no longer holds, on every single launch.
    --
    -- Seeding is the only lever that reaches it, and the two that look right do not:
    --   * A `routes` filter cannot see it. noice raises its health reports through Util.notify,
    --     which calls require("notify").notify directly, so they never enter noice's router.
    --   * `health = { checker = false }` only stops the once-a-second re-check. This comes from
    --     the ungated check in noice.setup -- verified: with the checker off, both still arrive.
    --
    -- Util.notify_once keys _once by level .. message and skips anything already there, so
    -- seeding the three keys suppresses exactly these messages. The check still runs, on the
    -- timer as well, and every other finding it makes still surfaces unprompted. :checkhealth
    -- noice reports all of them on demand and is the place to look if the GUI's behaviour ever
    -- changes. The cost, stated rather than hidden: _once is private, so a rename upstream brings
    -- the messages back -- visibly, which is the right direction for this kind of dependency.
    if vim.g.neovide then
      local Util = require("noice.util")
      for _, ext in ipairs({ "ext_cmdline", "ext_popupmenu", "ext_messages" }) do
        local msg = ("You're using a GUI that uses %s. Noice can't work when the GUI has %s enabled."):format(ext, ext)
        Util._once[vim.log.levels.ERROR .. msg] = true
      end
    end

    require("noice").setup(opts)

    if vim.g.neovide then
      -- Re-attach noice's UI once Neovide has cleared the flags.
      --
      -- noice.ui.enable() re-runs noice.ui.setup(), which is the function that reads
      -- nvim_list_uis() and decides which widgets to take. Detaching and enabling again is
      -- therefore the whole fix: the second read sees ext_cmdline and ext_messages false and
      -- noice attaches all three handlers. Verified by hand before it was written here --
      -- _handlers goes from { cmdline = false, msg = false, popupmenu = true } to all three true.
      --
      -- Polled rather than hooked to an event, because there is no event: Neovide clears the
      -- flags from its own side and Neovim raises nothing when a UI option changes. The poll is
      -- cheap, stops on the first clear reading, and gives up after five seconds so a Neovide
      -- that never clears them leaves noice as it found it rather than spinning.
      --
      -- What is given up: the startup messages noice would have captured between VimEnter and the
      -- re-attach. They go to the bottom row and are not in the history. That is a tick of
      -- messages against a cmdline that works, and nothing was being captured before this anyway
      -- -- the msg handler was false for the whole session.
      local timer = vim.uv.new_timer()
      local tries = 0
      timer:start(
        50,
        50,
        vim.schedule_wrap(function()
          tries = tries + 1
          local ui = vim.api.nvim_list_uis()[1]
          local clear = ui and not ui.ext_cmdline and not ui.ext_messages
          if clear or tries > 100 then
            timer:stop()
            timer:close()
            if clear then
              local Ui = require("noice.ui")
              Ui.disable()
              Ui.enable()
            end
          end
        end)
      )

      -- Put the command line back at zero rows.
      --
      -- This configuration runs with cmdheight at 0: the floating cmdline replaces the last
      -- screen row and nothing is drawn there. Neovide reads cmdheight at startup and writes it
      -- back twice, both writes landing after the value has settled. That left a 20-pixel row of
      -- empty command line under the status line that foot does not have -- foot reports
      -- cmdheight=0, Neovide 1 -- above the grid's own 16-pixel leftover and the 8 of padding,
      -- which is what made the gap at the bottom more than twice foot's.
      --
      -- Corrected on the option rather than after a fixed delay, because a delay would be a guess
      -- about Neovide's startup: OptionSet fires on each of its writes and this sets the value
      -- back. Setting it to 0 re-enters the callback with option_new "0", which is what the test
      -- is there to stop. The first attempt removed the autocmd after one correction and did not
      -- survive the second write.
      --
      -- The watch is torn down after three seconds. That is an upper bound on startup, not an
      -- estimate of when the writes land, and dropping it is what keeps this from policing
      -- cmdheight for the rest of the session: a deliberate `:set cmdheight=2` later is left
      -- alone.
      local id = vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "cmdheight",
        callback = function()
          if vim.v.option_new ~= "0" then
            vim.schedule(function()
              vim.o.cmdheight = 0
            end)
          end
        end,
      })
      vim.defer_fn(function()
        pcall(vim.api.nvim_del_autocmd, id)
      end, 3000)
    end
  end,

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
    -- false when no scrollable float is open, and the mapping then returns a key string --
    -- expr = true is what makes that fallback a real page scroll rather than a recursive call back
    -- into this mapping. noice's documented recipe, and the only way to get scroll-without-focus
    -- without shadowing <C-f>/<C-b> outright.
    --
    -- The fallback returns <PageDown>/<PageUp> rather than <C-f>/<C-b>, which is where the page
    -- scroll itself is defined: scrolloff = 999 makes the built-in move the cursor two pages inside
    -- the first and last screenful, so lua/config/keymaps.lua rewrites it, and <PageDown>/<PageUp>
    -- are the names a general mapping is allowed to hold. <C-f> and <C-b> cannot be bound there --
    -- lazy.nvim evaluates this spec after config.keymaps has run and would replace them -- so the
    -- two chords stay here and delegate. remap = true is load-bearing: without it the returned key
    -- goes to the built-in and the doubling comes back. A count typed before the chord is not
    -- consumed by an expr mapping; it is prepended to the returned key and read by the mapping that
    -- receives it, so 2<C-f> still moves two pages. In insert and select mode, where the general
    -- mapping is not defined, <PageDown> is the built-in one, as <C-f> was before.
    {
      "<C-f>",
      function()
        if not require("noice.lsp").scroll(4) then
          return "<PageDown>"
        end
      end,
      mode = { "n", "i", "s" },
      expr = true,
      remap = true,
      silent = true,
      desc = "Scroll documentation float forwards",
    },
    {
      "<C-b>",
      function()
        if not require("noice.lsp").scroll(-4) then
          return "<PageUp>"
        end
      end,
      mode = { "n", "i", "s" },
      expr = true,
      remap = true,
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
