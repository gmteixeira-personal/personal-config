-- Shows what a half-typed sequence can still become: pause on a prefix and the keys that continue
-- it are listed, each with the description its mapping already carries. Nothing is registered here
-- -- which-key reads Neovim's keymap tables at the moment the sequence is pending, so a mapping
-- added anywhere under lua/plugins/ is listed with no edit to this file, and the buffer-local sets
-- (gitsigns' <leader>h, the LSP mappings) appear only in the buffers they attached to.
return {
  "folke/which-key.nvim",
  -- VeryLazy, not the `keys` that telescope, conform and vim-visual-multi load on: the keys that
  -- would trigger it are the prefixes themselves, and those are already owned by real mappings, so
  -- a lazy.nvim stub on <leader> would compete with them. VeryLazy runs after the first screen is
  -- drawn and well before the user can plausibly pause on a prefix.
  event = "VeryLazy",
  keys = {
    -- The gitsigns and LSP mappings attach per buffer, and a "Hunk" group name does not tell the
    -- user the whole set is absent outside a git repository. global = false lists what this buffer
    -- has and nothing else. Bare ? -- search backwards -- is untouched.
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer-local keymaps",
    },
  },
  opts = {
    -- The layout, and the only presentation decision this file makes: a bordered, padded panel
    -- across the bottom of the editor. Written as the preset name rather than as an expanded
    -- win/layout table, so upstream's tuning of "modern" carries over instead of being pinned here.
    preset = "modern",

    -- which-key's own popup timer, in milliseconds. Not 'timeoutlen', which stays at 1000 and
    -- governs when a pending sequence resolves. 300 rather than upstream's 200 because
    -- lua/config/options.lua sets that 1000 precisely so <leader> sequences can be typed at a
    -- comfortable pace: at 200 the popup flashes part-way through sequences typed at that pace.
    delay = 300,

    -- Names for the prefixes, so the list under <leader> reads as a menu of subjects rather than as
    -- eight bare letters. A group entry is display only: it binds nothing, so <leader>w and the
    -- rest still execute no command and still complete on the next key, which is what
    -- editor-keymaps guarantees.
    --
    -- <leader>e (file explorer) and <leader><leader> (find files) are absent deliberately -- both
    -- are complete mappings carrying their own desc, not prefixes.
    spec = {
      { "<leader>b", group = "Buffer" },
      { "<leader>c", group = "Code" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      -- mode on these two because both sets have visual-mode members: gitsigns stages and resets a
      -- selected range, and vim-visual-multi's VM_leader set is normal and visual. A group declared
      -- for normal mode alone would leave the prefix unnamed there.
      { "<leader>h", group = "Hunk", mode = { "n", "v" } },
      { "<leader>m", group = "Multi-cursor", mode = { "n", "x" } },
      { "<leader>n", group = "Notices" },
      -- Everything that ends or restores the editing session: <leader>qq and <leader>qw leave it,
      -- <leader>qc rebuilds the process, and the auto-session mappings save, restore, search and
      -- delete the session that persists it across launches. Named for all three rather than
      -- picking one. There is no <leader>r group -- the rename that used to live there is
      -- <leader>cr, under Code with the code action it belongs beside.
      { "<leader>q", group = "Quit, restart & sessions" },
      { "<leader>t", group = "Todo" },
      { "<leader>w", group = "Window" },
    },

    -- Everything else is upstream's default, deliberately not written out here:
    --
    -- plugins.presets is what documents <C-w>, g, z, [ and ], the operators, motions, text objects,
    -- registers and marks. nvim-surround's ys/ds/cs need nothing extra -- their keys entries in
    -- lua/plugins/nvim-surround.lua already carry a desc, and which-key reads it like any other.
    --
    -- Icons come from mini.icons, which which-key detects on its own, so no nvim-web-devicons
    -- dependency is added here. lua/plugins/mini-icons.lua owns the single mock this config has.
    --
    -- notify stays on. The <Space> -> <Nop> guard in lua/config/keymaps.lua is an exact mapping on
    -- the leader key and so overlaps every <leader> mapping here; which-key v3 supports overlapping
    -- keymaps and holds for the longer sequence rather than firing <Nop>. If it reports the overlap
    -- at startup, :checkhealth which-key has the detail -- silencing it with notify = false would
    -- also hide a real conflict introduced later.
  },
}
