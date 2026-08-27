-- Declares which language servers must be installed, and enables each installed one.
-- mason 2.x lives under the mason-org/ organisation (was williamboman/) and no longer calls
-- lspconfig.setup{}: it calls vim.lsp.enable() instead, which is why lsp.lua has no setup calls.

-- lspconfig config names, not mason package names -- mason-lspconfig translates
-- (lua_ls <-> lua-language-server) from the registry, so neither list is maintained here.
local servers = {
  "lua_ls",
  "vtsls",
  "jsonls",
  "yamlls",
  "cssls",
  "html",
  "tailwindcss",
  "basedpyright",
  "bashls",
}

-- Deliberately absent: roslyn_ls. C# and Razor are served by one Roslyn instance started by
-- roslyn.nvim (see lua/plugins/roslyn.lua), not by vim.lsp.enable(). Naming it here would put it
-- in the allowlist below and start a second instance alongside that one, each with its own
-- workspace. Its binary is declared in mason-tool-installer.lua instead, which is where a tool
-- that must be installed without being auto-enabled belongs.

return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    "mason-org/mason.nvim", -- must have run setup() first: the registry is what maps names below
    "neovim/nvim-lspconfig", -- must be on the runtimepath first: it ships the lsp/<server>.lua
    -- definitions that vim.lsp.enable() resolves against
  },
  opts = {
    ensure_installed = servers,
    -- automatic_enable is on, and passing the same list makes it an allowlist rather than
    -- "everything installed". That distinction is load-bearing: automatic_enable's default
    -- enables every installed mason package that maps to an lspconfig name, and two of the
    -- formatters mason-tool-installer puts on disk -- stylua and ruff -- do map to one. Left at
    -- the default they attach as language servers to every Lua and Python buffer, which is not
    -- what this config installed them for. Deriving the allowlist from `servers` also means a
    -- formatter added later cannot quietly become a server.
    automatic_enable = servers,
  },
}
