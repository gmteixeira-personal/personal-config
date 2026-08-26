-- Completion engine. Loads on InsertEnter (its own default): nothing before insert mode needs it.
return {
  "saghen/blink.cmp",
  version = "1.*", -- a release tag, not main: tagged builds ship the prebuilt Rust fuzzy-matching
  -- binary, so no Rust toolchain is needed to install this config
  -- Snippet corpus, not a second completion engine. blink's snippets source scans the runtimepath
  -- for friendly-snippets and stdpath("config")/snippets; with neither present the source is wired
  -- but always returns nothing. A dependency edge rather than its own file, since it is not a
  -- plugin anyone configures -- being on the runtimepath is the whole integration.
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    -- Same four as blink's own default, written out because the completion spec names them:
    -- one merged list, not four separate ones.
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    -- Default preset kept: <C-space> open, <C-y> accept, <C-e> dismiss, <C-n>/<C-p> select.
    -- None of those collide with the <leader>/g/]c namespace this change defines, and the preset
    -- inserts nothing without an explicit accept, which is what "no implicit insertion" requires.
    keymap = {
      preset = "default",
      -- The three keys below are a merge, not a replacement: every preset key not spelled out here
      -- is inherited untouched, and every key that IS spelled out has its preset entry replaced
      -- outright -- which is why each list re-states the preset commands that key already carried
      -- rather than dropping them. Within a list the commands run left to right and the first that
      -- applies wins, so the list meaning only takes the key when the menu is actually open.
      --
      -- <Tab> as a second accept key, alongside the preset's <C-y>. select_and_accept is the
      -- addition -- it fires only with the menu open, and selects the first entry when none is
      -- highlighted, which is what a Tab at a fresh menu is asking for. The remaining two are the
      -- preset's own <Tab> entry, kept in its order: snippet_forward jumps between the placeholders
      -- of an expanded snippet, and fallback leaves a bare <Tab> as the indent key it otherwise is.
      -- Still no implicit insertion -- accepting takes a keypress, just one more key than before.
      ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
      -- <C-j>/<C-k> move through the menu, the same pair telescope's prompt uses for its result
      -- list -- one down/up idiom across every list this config puts on screen. The preset leaves
      -- <C-j> unbound, so select_next stands alone there; fallback_to_mappings is the preset's own
      -- choice for its <C-n>/<C-p> selection keys, and hands a menu-less press to whatever mapping
      -- the key otherwise has before reaching the built-in. The <C-w>j/<C-w>k window moves are
      -- normal mode, so nothing collides: insert mode keeps stock <C-j>, and <C-k> its digraphs.
      -- <C-k> DOES have a preset entry -- { show_signature, hide_signature, fallback } -- so its
      -- first two are re-listed after select_prev, else overriding the key would silently delete
      -- the signature window's toggle. Menu open it selects; menu closed it toggles as it did.
      ["<C-j>"] = { "select_next", "fallback_to_mappings" },
      ["<C-k>"] = { "select_prev", "show_signature", "hide_signature", "fallback_to_mappings" },
    },
  },
  -- The capabilities handshake is NOT here: it configures the LSP client, so it lives in
  -- lua/plugins/lsp.lua as a single vim.lsp.config("*", ...) call.
}
