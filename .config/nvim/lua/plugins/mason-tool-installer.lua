-- Declares which tool binaries must be installed outside mason-lspconfig's server list. Without
-- this file stylua/prettierd/shfmt/ruff would have to be installed by hand with :MasonInstall,
-- which the tool-management spec forbids.
--
-- Mostly formatters, and one server: a binary belongs here rather than in mason-lspconfig when it
-- must be installed but must not be enabled by vim.lsp.enable().
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "mason-org/mason.nvim" }, -- installs through mason's registry
  opts = {
    -- mason package names here, unlike mason-lspconfig above, which takes lspconfig names.
    ensure_installed = {
      "stylua", -- lua
      "prettierd", -- js/ts/json/yaml/css/html/markdown, daemon-backed
      "prettier", -- same, without the daemon: the fallback when prettierd is unavailable
      "shfmt", -- sh, bash
      "ruff", -- python (ruff_format)
      -- The one server in this list, and the reason the file's header names servers at all.
      -- roslyn.nvim starts it for both C# and Razor, so it must be on disk but must NOT reach
      -- mason-lspconfig's allowlist -- two instances would attach otherwise. Also needs a .NET SDK
      -- on the system, which mason cannot supply.
      "roslyn-language-server",
    },
    -- run_on_start defaults to true, so missing tools install in the background on launch
    -- and an already-complete set downloads nothing.
  },
}
