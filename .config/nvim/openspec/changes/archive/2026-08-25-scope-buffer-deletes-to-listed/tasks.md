## 1. Scope the two bulk deletions to the buffer list

- [x] 1.1 In `lua/config/keymaps.lua`, add a local helper beside the `<leader>b` group that returns the listed buffer numbers from `vim.fn.getbufinfo({ buflisted = 1 })`, optionally excluding one buffer, and runs `:confirm bdelete` with them. It MUST return without running anything when the list is empty, since a bare `:bdelete` deletes the current buffer.
- [x] 1.2 Repoint `<leader>bO` at the helper with nothing excluded, replacing `<cmd>confirm %bdelete<CR>`. Keep the existing `desc`.
- [x] 1.3 Repoint `<leader>bo` at the helper excluding the current buffer, replacing `<cmd>confirm %bd|e#|silent! bd#<CR>`. Keep the existing `desc`. The `e#` and `silent! bd#` steps go away with it — the surviving buffer is never deleted, so there is nothing to re-edit and no leftover to clean up.
- [x] 1.4 Leave `<leader>bd`, `<leader>bb`, `<leader>bn`, `<leader>bp`, `<leader>bf`, `<leader>bl` and `<leader>bc` exactly as they are.

## 2. Comments

- [x] 2.1 Replace the `%bd|e#|bd#` comment with one covering why the set is named explicitly: that `%` on `:bdelete` is the range `1,$` read as buffer numbers and so covers every buffer regardless of `'buflisted'`, while `:bnext` and the telescope picker both mean the buffer list.
- [x] 2.2 Record that the empty-list early return is a guard rather than an optimisation, because a bare `:bdelete` with no argument deletes the current buffer.
- [x] 2.3 Record that `:confirm` keeps its per-modified-buffer dialog across a list of buffer numbers, and that cancelling one does not abort the rest — so the single command is what preserves the confirmation behaviour, not a loop.
- [x] 2.4 Note that `<leader>bo` no longer re-edits the surviving buffer, so its undo history and buffer-local marks now survive, retiring the trade-off `add-buffer-commands` recorded.
- [x] 2.5 Keep the surrounding comment content that still holds — why no buffer-removal plugin, why `:confirm` over a bare `:bdelete` or a `:bdelete!`, and that `:bdelete` closes the windows displaying the buffer with `<leader>w` owning layout.
