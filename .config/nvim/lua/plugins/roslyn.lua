-- The Roslyn language server for C# and Razor, started by this plugin rather than by
-- vim.lsp.enable(). It is the one server in this configuration not declared in
-- mason-lspconfig.lua, and the exception is load-bearing rather than stylistic.
--
-- Razor is why. nvim-lspconfig's shipped roslyn_ls definition declares `filetypes = { 'cs' }` and
-- answers the server's razor/provideDynamicFileInfo request with a notification reading "Razor is
-- not supported. Please use https://github.com/seblyng/roslyn.nvim" -- so a .razor buffer opened
-- under that definition gets no server at all. This plugin serves C# and Razor from a single
-- co-hosted instance, which is also why roslyn_ls cannot simply stay alongside it: two instances
-- would attach to every C# buffer, each with its own workspace.
--
-- Highlighting comes from that server's semantic tokens, not from a parser. This is the reason
-- razor needs no tree-sitter parser and the no-tree-sitter decision survives -- but it also means
-- a razor buffer is plain until Roslyn has loaded the project, and stays plain outside one.
--
-- The binary is mason's, declared in mason-tool-installer.lua and found on Neovim's PATH as
-- ~/.local/share/nvim/mason/bin/roslyn-language-server, so no `cmd` override is needed here.
-- The server also needs a .NET SDK on the system, which mason cannot supply.
--
-- Note the config name: this plugin registers the server as `roslyn`, not `roslyn_ls`. The
-- `vim.lsp.config("*", { capabilities = ... })` statement in lsp.lua is a wildcard and still
-- reaches it, so blink.cmp's capabilities apply without a line here.
return {
  "seblyng/roslyn.nvim",
  ft = { "cs", "razor" }, -- .razor and .cshtml both resolve to `razor`; Neovim detects them
  -- already, so no ftdetect is needed. Lazy per filetype rather than on an event, because the
  -- server is expensive to start and most sessions never open a C# file.
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    -- broad_search is left at its default false on purpose. It widens the hunt for a .sln into
    -- parent directories, which is the shape of the problem the tailwindcss root_dir override in
    -- lsp.lua exists to prevent: $HOME is a git repository here, and a server that walks up out of
    -- a project and starts indexing from there stalls the editor. .sln and .csproj are real
    -- project markers and satisfy the workspace requirement without help.
  },
}
