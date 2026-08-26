## 1. Automatic pairing

- [x] 1.1 Create `lua/plugins/nvim-autopairs.lua` declaring `windwp/nvim-autopairs` with `event = "InsertEnter"`.
- [x] 1.2 Set `opts` to `check_ts = false`, `disable_in_macro = true`, `disable_in_visualblock = true`, `disable_in_replace_mode = true`, leaving `map_cr`, `enable_check_bracket_line`, and `fast_wrap` at their defaults.
- [x] 1.3 Comment the file to the density of the neighbouring plugin files: why `check_ts` is off (no nvim-treesitter here), why the three `disable_in_*` settings are written out rather than inherited, and that `map_cr` is safe only because `lua/plugins/blink-cmp.lua` uses `keymap = { preset = "default" }`, which leaves `<CR>` unbound.
- [x] 1.4 Note in the file that the nvim-cmp integration (`cmp_autopairs`) is deliberately absent — blink.cmp inserts its own brackets by editing the buffer on accept, not by sending keystrokes, so there is nothing to deduplicate.

## 2. Surround edits

- [x] 2.1 Create `lua/plugins/nvim-surround.lua` declaring `kylechui/nvim-surround` with `version = "*"` and `opts = {}`.
- [x] 2.2 Give it a `keys` list covering `ys`, `yss`, `yS`, `ds`, `cs`, `cS` in normal mode and `S`, `gS` in visual mode, each with a `desc`.
- [x] 2.3 Comment the file: that `opts = {}` is deliberate because every requirement in the spec is default behaviour, that visual `S` shadows the built-in linewise change (reachable as `V` then `c`, or `R`), and that a bare `y`/`d`/`c` now waits out `'timeoutlen'` while two-key sequences resolve immediately.

## 3. Lockfile

- [x] 3.1 Start Neovim once so lazy.nvim installs both plugins, and commit the resulting `lazy-lock.json` alongside the two new files.
