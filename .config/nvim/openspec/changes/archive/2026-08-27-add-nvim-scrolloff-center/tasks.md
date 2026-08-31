## 1. Change the option

- [x] 1.1 In `.config/nvim/lua/config/options.lua`, change the `vim.opt.scrolloff` value from `8` to `999` and rewrite its trailing comment to say the cursor is held at the middle of the window, verifying with `grep -n scrolloff .config/nvim/lua/config/options.lua` that exactly one assignment remains and it reads `999`
- [x] 1.2 Confirm the file still loads by running `nvim --headless "+lua print(vim.o.scrolloff)" +q` and verifying it prints `999` with no error

## 2. Verify the behavior

- [x] 2.1 Open a file longer than the window, move down and up with `j`/`k` and jump with a search and a line number, and verify the cursor line stays on the middle row of the window in each case
- [x] 2.2 Move to the first line and then the last line of that buffer and verify the view does not scroll past either end and the cursor moves normally there
- [x] 2.3 Open a file shorter than the window and verify the whole buffer stays visible with the cursor on its own line
- [x] 2.4 Open a split on a long buffer and verify the cursor is centered in the new window as well
