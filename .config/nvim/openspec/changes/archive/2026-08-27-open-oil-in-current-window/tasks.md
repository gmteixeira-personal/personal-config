## 1. Implementation

- [x] 1.1 In `lua/plugins/oil.lua`, replace the `<leader>e` callback's `require("oil").toggle_float()` with a toggle that calls `require("oil").close()` when `vim.bo.filetype == "oil"` and `require("oil").open()` otherwise
- [x] 1.2 Update the mapping's `desc` so it no longer says "float", and rewrite the inline comment to record why the toggle is assembled here rather than taken from oil — oil ships `toggle_float` but no in-window equivalent
- [x] 1.3 Run `stylua --check lua/plugins/oil.lua` against the repo's `.stylua.toml`

## 2. Verification

- [x] 2.1 Open a file, press `<leader>e`: the listing fills the window with no border and none of the previous buffer showing
- [x] 2.2 Press `<leader>e` again: the file returns with its cursor line and scroll position unchanged
- [x] 2.3 Start with `nvim` on an empty screen, press `<leader>e`: the working directory is listed with no error; press it again and the listing is dismissed without error
- [x] 2.4 Start with `nvim .`, press `<leader>e`: the listing is dismissed with no error
- [x] 2.5 Split the window, press `<leader>e` in one side: only that window changes, the other keeps its size and buffer
- [x] 2.6 From the listing, enter a subdirectory with `<CR>` and go back up with `-`: both stay full-window, and `<leader>e` still restores the original buffer afterwards

## 3. Spec sync

- [x] 3.1 Run `openspec validate open-oil-in-current-window`
- [x] 3.2 Archive the change so the modified requirement lands in `openspec/specs/file-explorer/spec.md`
