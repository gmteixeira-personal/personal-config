-- The LSP *client*: capabilities, diagnostics display, and the buffer-local mappings.
-- Which servers exist and which are installed is mason-lspconfig's job, not this file's.
--
-- Note the divergence from nearly every tutorial online: there is no
-- require("lspconfig").<server>.setup{} call anywhere here, and there must not be. On Neovim 0.11+
-- nvim-lspconfig is installed only for the lsp/<server>.lua definitions it puts on the
-- runtimepath; vim.lsp.enable() (called for us by mason-lspconfig) starts them, and
-- vim.lsp.config() shallow-merges overrides onto those shipped definitions.
return {
  "neovim/nvim-lspconfig",
  event = "BufReadPre", -- must be configured before a buffer that would attach a server exists;
  -- VeryLazy fires after the first buffer is displayed, which can miss its attach
  dependencies = { "saghen/blink.cmp" }, -- loaded before the capabilities line below runs
  config = function()
    -- One statement, every server, present and future. A per-server capabilities table is how
    -- this rots: the eleventh server silently loses snippet support because someone forgot a line.
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(nil, true),
    })

    -- Per-server overrides. vim.lsp.config shallow-merges onto nvim-lspconfig's shipped
    -- definition, so an override only names the keys it actually changes; nine of the ten
    -- servers need none.
    --
    -- lua_ls is the exception, and only when editing Neovim configuration. The server has no
    -- idea `vim` exists or where Neovim's Lua modules live, so every line of this config reads
    -- as "Undefined global `vim`". Set on on_init rather than in `settings` so it applies to
    -- the workspace the server actually opened.
    vim.lsp.config("lua_ls", {
      on_init = function(client)
        -- A project that describes itself with .luarc.json has already answered these
        -- questions; overriding it there would be wrong.
        local folder = client.workspace_folders and client.workspace_folders[1]
        if folder then
          local path = folder.name
          if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
            return
          end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
          runtime = {
            version = "LuaJIT", -- what Neovim embeds, not stock Lua 5.1
            path = { "lua/?.lua", "lua/?/init.lua" }, -- how Neovim itself resolves `require`
          },
          workspace = {
            checkThirdParty = false, -- else it prompts about every library it half-recognises
            -- $VIMRUNTIME alone: enough to know `vim`, and cheap. Pulling in all of
            -- 'runtimepath' would also index every installed plugin, which is slow and, when
            -- the project IS the config, self-referential.
            library = { vim.env.VIMRUNTIME },
          },
        })
      end,
      settings = { Lua = {} }, -- the table on_init merges into; without it the merge has no base
    })

    -- Diagnostics are an editor-level display concern, so they are configured once, globally --
    -- there is no reason for two servers to render an error differently.
    vim.diagnostic.config({
      virtual_text = { spacing = 2 }, -- the message itself, at the end of the offending line
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      },
      severity_sort = true, -- the worst problem on a line is the one whose sign is shown
    })

    -- Neovim 0.11+ already ships grn, gra, grr, gri, grt, gO and K. Everything below is either a
    -- mapping Neovim has no LSP binding for (gd, gD, gi) or a shorter alias onto a default
    -- (<leader>cr, <leader>ca) -- no default is replaced. Both sit under <leader>c ("code"):
    -- renaming a symbol and applying a code action are the same kind of act on the same subject,
    -- and grouping them there is what lets <leader> hold one prefix per subject rather than one
    -- per plugin.
    --
    -- Deliberately absent: a bare gr for references. gr is a strict prefix of grn, gra, grr, gri
    -- and grt, so binding it would make each of them wait out 'timeoutlen' (300ms) before firing.
    -- That is a stall on rename and code action -- the two actions these aliases exist to speed up
    -- -- in exchange for one keystroke on references. References stays on the built-in grr.
    --
    -- All buffer-local on attach, so a buffer with no server keeps whatever the key does by
    -- default: the built-in text-based gd, and gi's jump to the last insert position.
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP: buffer-local navigation and action mappings",
      callback = function(args)
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("<leader>cr", vim.lsp.buf.rename, "Rename symbol") -- alias for grn
        map("<leader>ca", vim.lsp.buf.code_action, "Code action") -- alias for gra

        -- The three below restate Neovim 0.12 defaults; they are listed for legibility, not
        -- necessity. This block is where a reader looks to learn what LSP keys exist, and one
        -- that names five while silently relying on defaults for hover and diagnostics is a worse
        -- document than one that names all eight. The cost is that they pin the current behaviour
        -- if Neovim's defaults change -- delete them knowingly if that happens.
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("]d", function()
          vim.diagnostic.jump({ count = 1, wrap = true }) -- wrap stated rather than inherited: the spec makes cycling contractual
        end, "Next diagnostic")
        map("[d", function()
          vim.diagnostic.jump({ count = -1, wrap = true })
        end, "Previous diagnostic")
      end,
    })

    -- Deliberately absent: any format keymap, and any BufWritePre formatting autocommand.
    -- Formatting has exactly one entry point and it is conform (see lua/plugins/conform.lua).
  end,
}
