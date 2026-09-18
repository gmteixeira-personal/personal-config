## 1. Stand the explorer module up

- [x] 1.1 Create `lua/config/file-explorer.lua` setting `vim.g.loaded_netrw` and `vim.g.loaded_netrwPlugin` to 1, and add `require("config.file-explorer")` to `init.lua` as the third load, before `require("config.lazy")`, with a comment saying the position is forced by netrw being sourced after `init.lua` returns. Verify by restarting with `lua/plugins/oil.lua` still present and running `:echo exists(":Explore")` — it reports 0.
- [x] 1.2 Add the missing-binary guard: a local function that returns false and `vim.notify`s a message naming `yazi` when `vim.fn.executable("yazi") ~= 1`. Verify by temporarily making the check test a name that does not exist, pressing `<leader>e`, and confirming the message appears, the window still shows the same buffer, and `:ls!` lists no new buffer.

## 2. Open yazi in the current window

- [x] 2.1 Write the open function: record `nvim_win_get_buf` and `vim.fn.winsaveview()`, put an unlisted scratch buffer from `nvim_create_buf(false, true)` into the window, start `yazi <path> --chooser-file <tempname>` with `vim.fn.jobstart(cmd, { term = true, on_exit = ... })`, then `vim.cmd.startinsert()`. The path is the current buffer's file, or `vim.fn.getcwd()` when it has no name. Verify by pressing `<leader>e` on an open file: yazi appears in that window with the file hovered, and the first keystroke moves yazi's cursor rather than Neovim's.
- [x] 2.2 Declare the `<leader>e` mapping in this module, with a `desc` that says "Open file explorer" rather than oil's "Toggle Oil" — which-key shows it, and it should not promise a toggle the key no longer performs. Verify with `:verbose nmap <leader>e` — it reports `lua/config/file-explorer.lua`, not `lua/plugins/oil.lua` or `lua/config/keymaps.lua`.
- [x] 2.3 Add a re-entrancy guard so `<leader>e` pressed while a yazi job is running in the focused window does nothing. Verify by opening yazi, pressing `<C-\><C-n>` to reach terminal-normal mode, pressing `<leader>e`, and confirming no second terminal is created and `:ls!` shows one scratch buffer.
- [x] 2.4 Verify the layout requirement directly: open a vertical split, press `<leader>e` in the left window, and confirm the right window keeps its buffer, size and position and stays visible the whole time yazi is up.

## 3. Handle leaving the explorer

- [x] 3.1 Write `on_exit` to do all its work inside `vim.schedule`: read the chooser file, delete it, restore or open, then `nvim_buf_delete` the scratch buffer with `force = true`. Verify that after any exit `:ls!` lists no terminal buffer and `:bnext` never lands on one.
- [x] 3.2 Implement the no-selection path: `nvim_win_set_buf` back to the recorded buffer, then `vim.fn.winrestview` on the recorded view inside `nvim_win_call`. Verify by scrolling a long file well down, pressing `<leader>e`, pressing `q`, and confirming both the cursor line and the first visible line are where they were.
- [x] 3.3 Implement the selection path: first line of the chooser file opened in the window, remaining lines added with `:badd`. Verify by selecting three files with `<Space>` and pressing `<Enter>` — the window shows the first, and `:ls` lists the other two without the layout changing.
- [x] 3.4 Handle the no-buffer-to-return-to case: where the recorded buffer is invalid or unloadable, put an empty buffer in the window. Verify with `nvim /tmp` followed by `q` in yazi — an empty buffer is shown and no error is raised.
- [x] 3.5 Guard the restore on `nvim_win_is_valid` and verify: open yazi in a split, focus another window, close the yazi window with `<leader>wc`, and confirm no error is raised and no orphan buffer remains in `:ls!`.

## 4. Take over directory buffers

- [x] 4.1 Add the `BufEnter` autocmd that opens the explorer on any buffer whose name passes `vim.fn.isdirectory`, wipes that directory buffer, and skips buffers the explorer itself owns. Verify with `nvim ~/.config/nvim`: yazi opens on that directory, and `:ls!` lists no buffer named for it.
- [x] 4.2 Verify the in-editor path too: `:edit ~/.config` from a running session opens yazi rather than a directory listing, and leaves no directory buffer behind.

## 5. Remove oil

- [x] 5.1 Delete `lua/plugins/oil.lua`, restart, and run `:Lazy` — `oil.nvim` is reported as removable. Run `:Lazy clean` and verify `lazy-lock.json` no longer contains an `oil.nvim` entry and the plugin is gone from `stdpath("data")/lazy/`.
- [x] 5.2 Confirm `mini.icons` is still installed and still loaded after oil's removal — `lua/plugins/which-key.lua`, `lua/plugins/render-markdown.lua` and `lua/plugins/lualine.lua` all depend on it. Verify with `:Lazy` showing `mini.icons` loaded and the statusline filetype icon still drawn.

## 6. Update the surrounding comments and docs

- [x] 6.1 Rewrite the `close_unsupported_windows` comment in `lua/plugins/auto-session.lua` to explain the yazi terminal buffer rather than a non-float Oil window, keeping the two separate mechanisms it has to account for: the window cull, and the buffer being unlisted so `:mksession` never records it. Verify by quitting with yazi open and confirming the next launch in that directory restores no empty explorer window.
- [x] 6.2 Update the comment at `lua/config/keymaps.lua:380` that names `oil://` among the unlisted scratch buffers the buffer-delete mappings step over. Verify the named example matches a buffer this configuration can actually produce.
- [x] 6.3 Update `README.md`: the `<leader>e` row of the keymap table (line ~312) to name yazi and say the explorer is left with `q`, and the plugin list entry for oil (line ~483) which is removed — replaced by a note that the explorer is the external `yazi` binary rather than a plugin, since `documentation` requires the plugin list to match what is installed. Verify by cross-checking every `<leader>` row in the table against `:map <leader>`.
- [x] 6.4 Add `yazi` to whatever the README says about prerequisites, alongside the note that it is not installed by Mason. Verify the README's own claim about what a fresh clone needs is true on a machine without yazi: the editor starts, and only `<leader>e` reports a missing program.

## 7. Verify the change end to end

- [x] 7.1 Walk every scenario in `openspec/changes/replace-oil-with-yazi/specs/file-explorer/spec.md` against the running editor and confirm each one holds.
- [x] 7.2 Confirm the user's own yazi configuration applies inside the editor: `<C-n>` opens a ripdrag window (the `keymap.toml` binding), and a file yanked in the editor's yazi can be pasted in a yazi started from a terminal (the shared yank list from `~/.config/yazi/init.lua`).
- [x] 7.3 Run `openspec validate --changes replace-oil-with-yazi --strict` and confirm it passes.
