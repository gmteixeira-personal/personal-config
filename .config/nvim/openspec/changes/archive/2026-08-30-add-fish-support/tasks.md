## 1. Language server

- [x] 1.1 Add `"fish_lsp"` to the `servers` list in `lua/plugins/mason-lspconfig.lua`, keeping the list's existing order convention, and verify with `:Mason` that the `fish-lsp` package installs on the next launch without any manual `:MasonInstall`
- [x] 1.2 Add a `vim.lsp.config("fish_lsp", ...)` override in `lua/plugins/lsp.lua` setting `root_markers = { "config.fish" }` and `workspace_required = true`, with a comment recording why `.git` is dropped, and verify by opening `~/.config/fish/config.fish` and checking `:checkhealth vim.lsp` reports the client attached with root `~/.config/fish`
- [x] 1.3 Verify the workspace guarantee holds: open a `.fish` file created in a directory with no `config.fish` above it but inside a git repository, and confirm `:lua =vim.lsp.get_clients({ bufnr = 0 })` returns an empty list and no error is raised
- [x] 1.4 Verify no second server attaches to fish buffers: with `~/.config/fish/config.fish` open, confirm `bashls` is absent from `:lua =vim.lsp.get_clients({ bufnr = 0 })`

## 2. Formatting

- [x] 2.1 Add `fish = { "fish_indent" }` to `formatters_by_ft` in `lua/plugins/conform.lua`, and verify `:ConformInfo` in a fish buffer lists `fish_indent` as available
- [x] 2.2 Verify formatting on write: open a copy of `~/.config/fish/config.fish` with its indentation altered, write it, and confirm the result matches `fish_indent` output for the same input
- [x] 2.3 Verify `<leader>cf` produces the same result as the on-write path in a fish buffer, and that the buffer is not written to disk by it
- [x] 2.4 Verify the server is not the formatter: with `fish-lsp` attached to a fish buffer, confirm `:ConformInfo` reports `fish_indent` as the selected formatter, so the `lsp_format = "fallback"` path is never reached for fish

## 3. Confirm untouched behavior

- [x] 3.1 Verify syntax highlighting and filetype detection still come from Neovim's runtime with no plugin added, by confirming `:set filetype?` reports `fish` and `:lua =vim.fn.globpath(vim.o.rtp, "syntax/fish.vim")` resolves inside `$VIMRUNTIME`
- [x] 3.2 Verify `lazy-lock.json` is unchanged by the whole change, since no plugin was added or updated
- [x] 3.3 Verify no other filetype regressed: open a Lua, a Python, and a `sh` buffer, and confirm each still attaches its usual server and formats on write

## 4. Specs

- [x] 4.1 Run `openspec validate add-fish-support --strict` and confirm it passes
- [x] 4.2 Sync the delta specs into the main specs once the implementation is verified, so `openspec/specs/language-servers/spec.md` and `openspec/specs/formatting/spec.md` list fish
