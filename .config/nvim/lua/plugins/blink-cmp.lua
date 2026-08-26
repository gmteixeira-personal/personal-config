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
    keymap = { preset = "default" },
  },
  -- The capabilities handshake is NOT here: it configures the LSP client, so it lives in
  -- lua/plugins/lsp.lua as a single vim.lsp.config("*", ...) call.
}
