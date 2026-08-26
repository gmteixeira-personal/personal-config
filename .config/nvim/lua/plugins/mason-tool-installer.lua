-- Declares which formatter binaries must be installed. mason-lspconfig handles servers only,
-- so without this file stylua/prettierd/shfmt/ruff would have to be installed by hand
-- with :MasonInstall, which the tool-management spec forbids.
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
    },
    -- run_on_start defaults to true, so missing tools install in the background on launch
    -- and an already-complete set downloads nothing.
  },
}
