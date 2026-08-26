## 1. Navigation and creation

- [x] 1.1 In `lua/config/keymaps.lua`, beside the existing `<leader>bb`, add `<leader>bn` → `:bnext` and `<leader>bp` → `:bprevious`, each with a `desc`. No wrap logic: both commands wrap on their own.
- [x] 1.2 Add `<leader>bf` → `:bfirst` and `<leader>bl` → `:blast`, each with a `desc`.
- [x] 1.3 Add `<leader>bc` → `:enew`, with a `desc` naming it as creating an empty buffer.

## 2. Deletion

- [x] 2.1 Add `<leader>bd` → `:confirm bdelete`, with a `desc`. `:confirm`, not a bare `:bdelete` (aborts with `E89` on a modified buffer) and not `:bdelete!` (discards the changes).
- [x] 2.2 Add `<leader>bO` → `:confirm %bdelete`, with a `desc` naming it as deleting every buffer.
- [x] 2.3 Add `<leader>bo` running `:%bd|e#|bd#` under `:confirm`, with the final `bd#` silenced so the sequence does not report an error when there is no leftover unnamed buffer to remove. `desc` names it as deleting every buffer but this one.

## 3. Comments

- [x] 3.1 Introduce the group with a comment in the density of the surrounding file, covering: that these are built-in Ex commands and why no buffer-removal plugin is used; that `:bnext`/`:bprevious` already wrap.
- [x] 3.2 Record why `:confirm` prefixes the three deleting mappings — what a bare `:bdelete` and a `:bdelete!` each do to a modified buffer instead.
- [x] 3.3 Record that `:bdelete` closes the windows displaying the buffer, that this is kept rather than worked around, and that `<leader>w` is where layout is managed.
- [x] 3.4 Record what each step of `:%bd|e#|bd#` does and why the last one is silenced.
- [x] 3.5 Record why `<leader>bc` is `c` rather than the `n` that `<C-w>n` uses — `n` is "next" here.
