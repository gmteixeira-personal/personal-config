## 1. The quit mappings

- [x] 1.1 In `lua/config/keymaps.lua`, after the buffer commands and before the `<leader>rc` restart mapping, add `map("n", "<leader>qq", "<cmd>confirm qall<CR>", "Quit all")`.
- [x] 1.2 In the same block, add `map("n", "<leader>qw", "<cmd>confirm xall<CR>", "Write all and quit")`.
- [x] 1.3 Write the commentary above the pair, in the style of the surrounding blocks: why `:confirm` rather than a bare command or a bang (the same reasoning the `:confirm bdelete` block already carries, referenced rather than repeated in full), why `:xall` rather than `:wqall`, and that `<leader>q` is for leaving the editor while `<leader>wq` and `<C-w>q` remain the way a single window is closed.

## 2. The prefix name

- [x] 2.1 In `lua/plugins/which-key.lua`, add `{ "<leader>q", group = "Quit" }` to `opts.spec`, keeping the list in its existing alphabetical order — between the multi-cursor entry and the rename-and-restart one.
