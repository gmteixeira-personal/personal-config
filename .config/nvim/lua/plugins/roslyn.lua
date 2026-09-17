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
  lazy = false, -- NOT ft-lazy, and the difference is load ORDER rather than cost. lazy.nvim
  -- sources a plugin's plugin/ directory before it applies `opts`, and roslyn.nvim's
  -- plugin/roslyn.lua calls vim.lsp.enable("roslyn"), which on 0.12 also applies to buffers that
  -- already exist. Under `ft` both steps land inside the same FileType event, so the first .cs
  -- buffer of a session is resolved with `opts` not yet set -- choose_target below is nil, the
  -- target is ambiguous, and a SECOND rootless client attaches alongside the real one. Loading
  -- at startup puts setup ahead of any C# buffer and there is only ever one client.
  --
  -- The cost is one small Lua file sourced at startup. It is not the cost the `ft` was avoiding:
  -- vim.lsp.enable only registers the server, and the expensive part -- the roslyn process
  -- itself -- still starts on the first cs or razor buffer and never in a session without one.
  -- .razor and .cshtml both resolve to `razor`, which Neovim detects already, so no ftdetect is
  -- needed either way.
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    -- `./ycrm gen` writes three solutions into the yCRM repository root: Crm.slnx and the
    -- Crm.Client.slnx / Crm.Server.slnx halves. Every csproj named by a half is also named by the
    -- whole, so a .cs file under src/Crm.Server resolves to two targets, the plugin reports
    -- "Multiple potential target files found" and starts NO server. Nothing then attaches, so the
    -- LspAttach block in lsp.lua never runs and gd falls back to its built-in text search --
    -- which is the symptom: a symbol defined in another file is simply not found.
    --
    -- Preferring the widest solution answers that once per session instead of requiring `:Roslyn
    -- target` by hand. Crm.slnx contains every project both halves do, so loading it costs
    -- nothing the halves would have saved, and it is the only target under which a client file
    -- can navigate into a server contract.
    --
    -- Returning nil when no name matches is deliberate: any other repository with several
    -- solutions keeps the plugin's own prompt rather than having one silently chosen for it.
    choose_target = function(targets)
      return vim.iter(targets):find(function(target)
        return vim.fs.basename(target) == "Crm.slnx"
      end)
    end,

    -- broad_search is left at its default false on purpose. It widens the hunt for a .sln into
    -- parent directories, which is the shape of the problem the tailwindcss root_dir override in
    -- lsp.lua exists to prevent: $HOME is a git repository here, and a server that walks up out of
    -- a project and starts indexing from there stalls the editor. .sln and .csproj are real
    -- project markers and satisfy the workspace requirement without help.
  },
}
