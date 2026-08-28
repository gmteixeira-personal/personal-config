## 1. The plugin spec

- [x] 1.1 Create `lua/plugins/mini-move.lua` returning a lazy.nvim spec for `"echasnovski/mini.move"` -- the same owner `lua/plugins/mini-icons.lua` uses. No `dependencies`; mini.move is standalone. Verify `:Lazy` lists it after restarting Neovim.
- [x] 1.2 Give it `opts` with `mappings` setting the four visual moves: `left = "<M-h>"`, `down = "<M-j>"`, `up = "<M-k>"`, `right = "<M-l>"`. Verify by selecting two lines and pressing each key.
- [x] 1.3 In the same `mappings` table, set `line_left`, `line_down`, `line_up` and `line_right` to `""`. Verify with `:verbose nmap <M-j>` -- it must still report `lua/config/keymaps.lua`, not mini.move.
- [x] 1.4 Add `options = { reindent_linewise = true }`. Verify by moving a statement down past the opening of a nested `if` and confirming it is reindented to the inner level.
- [x] 1.5 Add a `keys` table with the four left-hand sides at `mode = "v"`, described "Move selection left/down/up/right", so the plugin lazy-loads on them and which-key has descriptions. Verify `:Lazy` shows mini.move unloaded on a fresh start and loaded after the first press.
- [x] 1.6 Comment the file to the standard of the rest of `lua/plugins/`: that the four keys are the resize block's keys one mode over and why that is safe (the block at `lua/config/keymaps.lua:87-90` is normal mode only); why the `line_*` entries are empty strings and what silently breaks if they are removed (mini.move's `setup()` runs after `config.keymaps`, so its defaults would take the resize mappings over -- the same load-order trap `lua/config/keymaps.lua:82` documents for the arrow keys and vim-visual-multi); that `keys` only triggers the load and carries the descriptions, with the real mappings coming from `setup()`, so the two lists have to be kept in step by hand; and why the plugin rather than a pair of `:m` mappings.

## 2. Lockfile

- [x] 2.1 Start Neovim once so lazy.nvim installs the plugin, and confirm `lazy-lock.json` gains a pinned `mini.move` entry. Commit it with the new file.

## 3. Verification

- [x] 3.1 Select two lines with `V`, press `<M-k>` and `<M-j>` several times each, and confirm the block moves one line per press, stays selected, and the file's line count is unchanged.
- [x] 3.2 Confirm the moves repeat without re-selecting -- hold `<M-j>` and confirm the block keeps travelling.
- [x] 3.3 Select a line, type `3<M-j>`, and confirm it lands three lines further down.
- [x] 3.4 Yank a word, then move a selection up and down, then `p` -- confirm the yanked word is what is put.
- [x] 3.5 Move a statement down into a nested `if` and back out again, confirming it is reindented in both directions.
- [x] 3.6 Select a column with `<C-v>`, press `<M-h>` and `<M-l>`, and confirm the block shifts sideways with the surrounding lines untouched and the block still selected.
- [x] 3.7 Select whole lines with `V`, press `<M-h>`, and confirm the lines lose one indentation step -- `shiftwidth`, so two columns with this config's settings, not one -- with the selection intact.
- [x] 3.8 In normal mode with a split open (`<leader>ws`), press all four of `<M-h>`, `<M-j>`, `<M-k>`, `<M-l>` and confirm they resize the window and move no line.
- [x] 3.9 Run `:verbose vmap <M-j>` and confirm it reports mini.move; run `:verbose nmap <M-j>` and confirm it reports `lua/config/keymaps.lua`.
- [x] 3.10 Confirm which-key shows the four descriptions when the prefix is pressed in visual mode, and that vim-visual-multi's `<C-n>`, `<C-Down>`, `<C-Up>` and `<S-Left>`/`<S-Right>` still work from a visual selection.
