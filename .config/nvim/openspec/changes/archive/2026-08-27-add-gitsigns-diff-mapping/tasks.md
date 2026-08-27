## 1. The mapping

- [x] 1.1 In `lua/plugins/gitsigns.lua`, inside `on_attach`, add a normal-mode `<leader>gd` mapping described as "Diff file against index", placed after the `<leader>h` hunk actions so the file reads hunk-level first, then file-level.
- [x] 1.2 Have it return early when `vim.wo.diff` is already set, so a second press opens nothing.
- [x] 1.3 Capture the current window before calling, then call `gitsigns.diffthis(nil, { vertical = true, split = "aboveleft" }, callback)` -- both layout options stated explicitly rather than inherited from `&diffopt`.
- [x] 1.4 In the callback, return on error.
- [x] 1.5 In the callback, unlist the buffer of every window of the current tabpage whose `vim.wo[w].diff` is set and which is not the captured window -- `:diffsplit` lists the revision buffer that gitsigns created unlisted. Leave the cursor where gitsigns put it; do not move focus.
- [x] 1.6 Comment the block to the standard of the rest of the file: why the layout options are stated rather than inherited, why the callback rather than a straight-line call (`diffthis` is async), why the revision windows are found by `vim.wo.diff` rather than `wincmd h`, why the buffer is unlisted, and that the conflict case's two windows are both covered.

## 2. Prefix ownership

- [x] 2.1 In `lua/plugins/neogit.lua`, extend the comment that divides `<leader>g` between neogit and Telescope to record that gitsigns owns `<leader>gd`, keeping the existing note that `<leader>g` itself stays unbound.

## 3. Verification

- [x] 3.1 Open a modified tracked file, press `<leader>gd`, and confirm a vertical split with the indexed version on the left and the working buffer on the right.
- [x] 3.2 Confirm the cursor is left in the window the file is being edited in, with its content and cursor position unchanged.
- [x] 3.3 From there press `<leader>ww` to reach the diff and `<leader>wq` to close it, and confirm the cursor lands back in the file being edited, that window is out of diff mode (`:echo &diff` prints `0`, and `'wrap'` and the fold column are back to normal), and content and cursor position are unchanged.
- [x] 3.4 With the diff open, press `<leader>bn` and `<leader>bp` and confirm the indexed version is never reached.
- [x] 3.5 With the diff open, press `]c` and `[c` and confirm they move between differences with both windows staying aligned, rather than jumping by hunk.
- [x] 3.6 Press `<leader>gd` a second time with the diff open and confirm nothing opens and no error is raised.
- [x] 3.7 Press `<leader>gd` on a tracked file with no changes and confirm the diff opens with two identical sides and no error.
- [x] 3.8 Open a file outside any git repository and confirm `<leader>gd` is unmapped there and raises no error.
- [x] 3.9 Confirm which-key lists the new mapping under the `<leader>g` prefix with its description.
