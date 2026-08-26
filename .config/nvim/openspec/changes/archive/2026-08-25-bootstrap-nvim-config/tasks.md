## 1. Core structure and load order

- [x] 1.1 Create `lua/config/options.lua`. Assign `vim.g.mapleader = " "` and `vim.g.maplocalleader = "\\"` at the very top of the file, before anything else, then set `termguicolors` and `background = "dark"`. Add no plugin-specific settings and no `require` of any plugin module.
- [x] 1.2 Create `lua/config/keymaps.lua`. Map `<Space>` to `<Nop>` in normal and visual mode with `silent = true`, so a bare leader press does not move the cursor. Add no mapping that invokes a plugin.
- [x] 1.3 Populate `init.lua` with exactly three requires in order — `config.options`, `config.keymaps`, `config.lazy` — and nothing else: no options, no keymaps, no plugin specs.
- [x] 1.4 Verify the split holds: `lua/config/options.lua` and `lua/config/keymaps.lua` both load with zero plugins installed and neither references a plugin module.

## 2. Plugin manager bootstrap

- [x] 2.1 Create `lua/config/lazy.lua` with the bootstrap block: resolve `lazypath` under `vim.fn.stdpath("data") .. "/lazy/lazy.nvim"`, and skip the clone when `vim.uv.fs_stat(lazypath)` reports the directory already exists.
- [x] 2.2 In the bootstrap block, clone with `git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git <lazypath>`, capturing output via `vim.fn.system`. `--branch=stable` is required, not the default branch.
- [x] 2.3 Handle clone failure: when `vim.v.shell_error ~= 0`, echo the captured `git` output *and* `lazypath` as an error, wait for a keypress, then `os.exit(1)`. Do not fall through into a half-configured session.
- [x] 2.4 Prepend `lazypath` to `runtimepath` after the bootstrap block.
- [x] 2.5 Call `require("lazy").setup()` with `spec = { { import = "plugins" } }`, `install.colorscheme = { "rose-pine-main", "habamax" }`, `checker.enabled = false`, `change_detection.notify = false`, and `rocks.enabled = false`.
- [x] 2.6 Create the `lua/plugins/` directory.

## 3. Icons provider

- [x] 3.1 Create `lua/plugins/mini-icons.lua` returning a spec for `echasnovski/mini.icons` with `lazy = false` and `priority = 900`.
- [x] 3.2 In its `config`, call `require("mini.icons").setup(opts)` and then `MiniIcons.mock_nvim_web_devicons()`, in that order, so the compatibility shim is registered at startup before any lower-priority plugin can request icons.
- [x] 3.3 Confirm no spec anywhere lists `nvim-tree/nvim-web-devicons` as a plugin or dependency — one provider only.

## 4. Colorscheme

- [x] 4.1 Create `lua/plugins/rose-pine.lua` returning a spec for `rose-pine/neovim` with `name = "rose-pine"`, `lazy = false`, and `priority = 1000` so it loads ahead of every other plugin.
- [x] 4.2 In its `config`, call `require("rose-pine").setup(opts)` and then apply the theme with `vim.cmd.colorscheme("rose-pine-main")` — the explicit variant name, not the bare `rose-pine`, so the variant cannot drift with `&background`.

## 5. File explorer

- [x] 5.1 Create `lua/plugins/oil.lua` returning a spec for `stevearc/oil.nvim` with `lazy = false` (required to hijack netrw before the first buffer is created) and `dependencies = { "echasnovski/mini.icons" }`.
- [x] 5.2 Set its `opts`: `default_file_explorer = true` and `columns = { "icon" }`. Leave oil's write-confirmation defaults untouched so pending deletions are previewed and confirmed.
- [x] 5.3 Declare the mapping in this file's `keys`: `<leader>e` → `require("oil").toggle_float()`, with a `desc`. It must not appear in `lua/config/keymaps.lua`.

## 6. Verification

- [x] 6.1 Start Neovim on a machine state with no plugins installed. Confirm lazy.nvim bootstraps itself, all four plugins install without a manual command, and `lazy-lock.json` is written at the config root.
- [x] 6.2 Restart. Confirm no clone is attempted, no errors appear, and `:checkhealth lazy` is clean.
- [x] 6.3 Confirm the theme: the active colorscheme is rose-pine and the applied palette is the `main` variant — `Normal` background is `#191724`, not moon's `#232136` or dawn's `#faf4ed`. (`vim.g.colors_name` reports `rose-pine` without the variant suffix; the variant file applies its palette and hands off, so the palette is what confirms it.) Also confirm that running `nvim <file>` from the shell paints themed colors on the first frame with no visible repaint from default colors.
- [x] 6.4 Confirm the leader: `<Space>e` opens the oil float, and pressing `<Space>` alone in normal mode neither moves the cursor nor errors.
- [x] 6.5 Confirm the toggle: `<leader>e` from a file opens a float listing that file's directory; pressing `<leader>e` again closes it and restores the previous buffer with its cursor position unchanged. Repeat from an empty start screen and confirm it opens the working directory without error.
- [x] 6.6 Confirm icons render in the oil listing — a filetype-appropriate icon per file, a directory icon per subdirectory — and that they are colored by theme highlight groups.
- [x] 6.7 Confirm the devicons shim: `:lua print(vim.inspect(require("nvim-web-devicons").get_icon("init.lua")))` returns an icon and highlight group rather than a missing-module error.
- [x] 6.8 Confirm the netrw hijack: `nvim <directory>` opens the oil listing, not netrw.
- [x] 6.9 Confirm oil's buffer semantics on a scratch directory: adding a line creates a file on write, editing an entry renames it on write, closing without writing leaves the filesystem unchanged, and a pending deletion shows a confirmation prompt listing the exact operations.
