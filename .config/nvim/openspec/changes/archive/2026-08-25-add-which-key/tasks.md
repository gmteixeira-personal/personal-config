## 1. The plugin file

- [x] 1.1 Create `lua/plugins/which-key.lua` declaring `folke/which-key.nvim` with `event = "VeryLazy"` and no version pin, leaving `lazy-lock.json` as the pin.
- [x] 1.2 Set `opts.preset = "modern"` and `opts.delay = 300`, leaving `plugins.presets`, `icons`, `notify`, `triggers` and the `win`/`layout` tables at their defaults.
- [x] 1.3 Give `opts.spec` a `group` entry for each of the eight `<leader>` prefixes — `b` Buffer, `c` Code, `f` Find, `g` Git, `h` Hunk, `m` Multi-cursor, `r` Rename & restart, `s` Split & window — with `mode = { "n", "v" }` on `<leader>h` and `mode = { "n", "x" }` on `<leader>m`. No entry for `<leader>e` or `<leader><leader>`: both are complete mappings, not prefixes.
- [x] 1.4 Add a `keys` entry binding `<leader>?` to `require("which-key").show({ global = false })` with a `desc`, so the gitsigns and LSP buffer-local sets are reachable as a list of their own.

## 2. Comments

- [x] 2.1 Comment the file to the density of the neighbouring plugin files, covering: why `VeryLazy` rather than the `keys` loading every other deliberately-invoked plugin here uses (the trigger keys are prefixes already owned by real mappings); that `delay` is which-key's own popup timer and not `'timeoutlen'`, and why 300 rather than upstream's 200 given `'timeoutlen'` is 1000; and that `preset = "modern"` is written as the preset name rather than an expanded `win`/`layout` table so upstream's tuning carries over.
- [x] 2.2 Note in the file that a `group` entry only names a prefix and binds nothing, so `<leader>s` and the rest still run no command — the guarantee `editor-keymaps` makes.
- [x] 2.3 Note why `<leader>r` is named for two subjects (`<leader>rc` restart, `<leader>rn` LSP rename) and that the `mode` on `<leader>h` and `<leader>m` exists because both sets have visual-mode members.
- [x] 2.4 Note that icons come from `mini.icons`, which which-key detects on its own, so no `nvim-web-devicons` dependency is added — the standing rule in `lua/plugins/mini-icons.lua`.
- [x] 2.5 Note that the `<Space>` → `<Nop>` guard in `lua/config/keymaps.lua` overlaps every `<leader>` mapping, that which-key v3 holds for the longer sequence rather than firing it, and that `notify` is left on deliberately so a real conflict introduced later is still reported — `:checkhealth which-key` for the detail.

## 3. Lockfile

- [x] 3.1 Start Neovim once so lazy.nvim installs which-key, and commit the resulting `lazy-lock.json` alongside the new file.
