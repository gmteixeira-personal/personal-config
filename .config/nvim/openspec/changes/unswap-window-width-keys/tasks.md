## 1. Remap the width keys

- [x] 1.1 In `lua/config/keymaps.lua`, point `<M-l>` at `<cmd>vertical resize +2<CR>` with the description `Increase window width`, and `<M-h>` at `<cmd>vertical resize -2<CR>` with the description `Decrease window width`.
- [x] 1.2 Keep the two lines in the order the block already reads — grow above shrink, matching `<M-k>`/`<M-j>` directly above them — so the four mappings stay visually parallel.
- [x] 1.3 Leave `<M-k>`, `<M-j>`, the `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>` focus mappings, and the maximize toggle untouched.

## 2. Record the rule in the source

- [x] 2.1 Add one sentence to the block comment above the resize mappings stating that each key grows the focused window toward the direction its letter names and shrinks it away from that direction.
- [x] 2.2 Confirm the existing comment text about the Alt modifier, the load-order reason for avoiding `<C-Up>`/`<C-Down>`, and the increment of 2 is left intact.
- [x] 2.3 Check the `<leader>w` comment further down the file, which cites `<M-h>/<M-j>/<M-k>/<M-l>` as owning resizing, and the `nvim-autopairs.lua` comment that names the same four keys — neither states a direction, so confirm both still read correctly rather than editing them.

## 3. Verify in the editor

- [x] 3.1 Restart Neovim, open two windows side by side with `<C-w>v`, focus the left one, and confirm `<M-l>` widens it and `<M-h>` narrows it.
- [x] 3.2 Focus the right-hand window and confirm `<M-l>` widens that window too — the key grows whichever window has focus, which is the scenario the delta spec adds.
- [x] 3.3 Confirm holding either key resizes continuously and stops at the layout's limit without error.
- [x] 3.4 With a single window open, press both keys and confirm the window still fills the tab page and no error is raised.
- [x] 3.5 Confirm `<M-k>`/`<M-j>` still change height in their existing directions.
- [x] 3.6 Open which-key's window listing and confirm the descriptions shown for `<M-h>` and `<M-l>` match their new behaviour.
- [x] 3.7 Run `:checkhealth which-key` and confirm no new overlap or conflict is reported.

## 4. Close out

- [x] 4.1 Run `openspec validate unswap-window-width-keys --strict` and confirm it passes.
