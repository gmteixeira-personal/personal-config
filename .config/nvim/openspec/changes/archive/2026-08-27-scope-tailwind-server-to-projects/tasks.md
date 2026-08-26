## 1. Root determination

- [x] 1.1 Add a `vim.lsp.config("tailwindcss", ...)` block in `lua/plugins/lsp.lua` beside the existing `lua_ls` block
- [x] 1.2 Build the marker list from `tailwind.config` and `postcss.config` crossed with the `js`, `cjs`, `mjs` and `ts` extensions
- [x] 1.3 Search upward from the buffer's own path with `vim.fs.find`, and call `on_dir` only when a marker is found

## 2. Verification

- [x] 2.1 Confirm the block is the only change to server configuration and that no other server's root logic is touched
- [x] 2.2 Confirm `stylua --check lua/plugins/lsp.lua` passes

## 3. Cleanup

- [x] 3.1 Delete the log the failure produced, `~/.local/state/nvim/lsp.log`, along with `nvim.log` and the orphaned swap files left by the killed sessions
