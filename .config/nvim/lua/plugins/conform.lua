-- The single formatting entry point: on write, and on demand via <leader>cf. Both take this path,
-- so a filetype covered by both an external formatter and a formatting-capable server cannot
-- produce two different results depending on which key was pressed.
return {
  "stevearc/conform.nvim",
  event = "BufWritePre", -- nothing before a write needs it; the keys entry below covers the rest
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      desc = "Format buffer",
    },
    -- Under <leader>c ("code"), not <leader>f: <leader>f is the find prefix, and binding a
    -- prefix as a mapping in its own right makes every use of it wait out 'timeoutlen' first.
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      -- prettierd first for latency (it keeps a daemon; prettier pays Node startup per save),
      -- prettier second so a machine with only one of them still formats.
      javascript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      jsonc = { "prettierd", "prettier" },
      yaml = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
      scss = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
      -- a single static binary, with no coupling to an activated virtualenv the way black has
      python = { "ruff_format" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      cs = {}, -- empty on purpose: no external C# formatter, so the LSP fallback below engages
    },
    format_on_save = function()
      return {
        timeout_ms = 500, -- bounded; on timeout the write still completes, unformatted
        -- "fallback", not "prefer" or "first": the server formats ONLY where the filetype has no
        -- available external formatter. Today that is C# alone.
        lsp_format = "fallback",
      }
    end,
  },
}
