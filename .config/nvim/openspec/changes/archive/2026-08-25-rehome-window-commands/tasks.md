## 1. Window commands under `<leader>w`

- [x] 1.1 Lift the `<C-w>\` callback in `lua/config/keymaps.lua` into a named local (`toggle_maximized`) and bind `<C-w>\` to it, so the same function backs every key that toggles.
- [x] 1.2 Add the `<leader>w` set mirroring `<C-w>`'s letters: `s`, `v`, `n`, `c`, `q`, `o`; `w`, `W`, `p`, `t`, `b`; `x`, `r`, `R`; `=`; `T`. Each keeps a `desc`, since `keymap-hints` reads it.
- [x] 1.3 Bind `<leader>we` and `<leader>w\` to `toggle_maximized`, and add `<C-w>e` beside the existing `<C-w>\`.
- [x] 1.4 Delete `<leader>sv`, `<leader>sh`, `<leader>sc` and `<leader>se` and the comment block introducing them.

## 2. Resize direction

- [x] 2.1 Swap the right-hand sides of `<M-h>` and `<M-l>` so `<M-h>` increases the width and `<M-l>` decreases it, leaving `<M-j>`/`<M-k>` alone.

## 3. Buffer picker

- [x] 3.1 Add a `<leader>,` entry to the `keys` table in `lua/plugins/telescope.lua` calling `require("telescope.builtin").buffers()`, with the same `desc` as `<leader>fb`.

## 4. Hints

- [x] 4.1 Replace the `{ "<leader>s", group = "Split & window" }` entry in `lua/plugins/which-key.lua` with `{ "<leader>w", group = "Window" }`.

## 5. Comments

- [x] 5.1 Record why the resizes and the `HJKL` moves are not mirrored under `<leader>w`, and why lowercase `hjkl` is absent.
- [x] 5.2 Record that `\` and `e` are both unbound built-ins under `<C-w>`, so neither shadows nor delays a built-in window command.
- [x] 5.3 Record that `<leader>,` is the unprefixed twin of `<leader>fb`, beside `<leader><leader>` for files.
