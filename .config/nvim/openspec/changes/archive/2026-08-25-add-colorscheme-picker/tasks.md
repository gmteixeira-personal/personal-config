## 1. Themes directory

- [x] 1.1 Create `lua/plugins/themes/` and `git mv lua/plugins/rose-pine.lua lua/plugins/themes/rose-pine.lua`. Move it unchanged — same `opts`, same `lazy = false`, same `priority = 1000`, same `vim.cmd.colorscheme("rose-pine-main")`. This change does not alter what starts.
- [x] 1.2 Add `{ import = "plugins.themes" }` to the `spec` table in `lua/config/lazy.lua`, after the existing `{ import = "plugins" }`. Without it the moved file is ignored **silently** and the editor starts with no theme at all: lazy.nvim's `lsmod` descends into a subdirectory only when it contains `init.lua`, and there is none here. See design.md — "Themes live in `lua/plugins/themes/`".
- [x] 1.3 Correct the comment on the `{ import = "plugins" }` line. It currently reads "imports every file in lua/plugins/; no list to keep in sync", which is now wrong in the way that matters: files are still automatic, directories are not, and a directory left unregistered fails without a message.

## 2. The three themes

- [x] 2.1 Create `lua/plugins/themes/kanagawa.lua` returning a spec for `rebelot/kanagawa.nvim` with `lazy = true` and no `opts`. One plugin, one file.
- [x] 2.2 Create `lua/plugins/themes/tokyonight.lua` returning a spec for `folke/tokyonight.nvim` with `lazy = true` and no `opts`.
- [x] 2.3 Create `lua/plugins/themes/catppuccin.lua` returning a spec for `catppuccin/nvim` with `lazy = true`, no `opts`, and `name = "catppuccin"` — lazy.nvim would otherwise name the plugin `nvim` after the repository's last path segment. Comment the `name`, since it looks redundant next to the two specs above that do not need one.
- [x] 2.4 Comment in each of the three that the theme is installed to be switched to, not to be started in, and that `lazy = true` does not hide it from the picker — Telescope globs `colors/*` under lazy.nvim's unloaded plugins, and lazy.nvim loads the owner on `ColorSchemePre`. One line each; the mechanism is non-obvious enough that a future reader would otherwise "fix" the lazy flag.
- [x] 2.5 Leave `lua/plugins/themes/rose-pine.lua` as the only theme file with `lazy = false`, `priority = 1000` and a `vim.cmd.colorscheme` call. Two files doing that is a load-order race, not an error.

## 3. Picker mapping

- [x] 3.1 Add a `<leader>ft` entry to the `keys` table in `lua/plugins/telescope.lua`, calling `require("telescope.builtin").colorscheme({ enable_preview = true })` from a thunk, with `desc = "Find colorscheme"`. Match the shape of the existing entries exactly, so the plugin stays loaded by its keys alone.
- [x] 3.2 Place it with the `<leader>f` pickers, after `<leader>fS`, not among the `<leader>g` git group. Keep `<leader>f` unbound as a mapping in its own right so nothing under it waits out `timeoutlen`.
- [x] 3.3 Comment `enable_preview = true` in a line: without it the picker only applies a colorscheme on selection, which is a slower way to do what editing the theme file already does. The flag is the entire point of the mapping and reads as noise otherwise.
- [x] 3.4 Comment that the choice is session-only and rose-pine `main` is still what starts: nothing is written to disk, so a restart returns to the configured theme. Say it here so it is not mistaken for a bug.

## 4. Install

- [x] 4.1 Let lazy.nvim install the three new plugins and commit the resulting `lazy-lock.json` entries alongside the change.

## 5. Startup theme moves to kanagawa

- [x] 5.1 Move `lazy = false`, `priority = 1000` and the `vim.cmd.colorscheme` call from `lua/plugins/themes/rose-pine.lua` to `lua/plugins/themes/kanagawa.lua`, applying `kanagawa-wave`. Exactly one theme file carries the three at a time.
- [x] 5.2 Leave `lua/plugins/themes/rose-pine.lua` a bare `lazy = true` install: drop its `opts` and its whole `config`, not just the flags. A leftover `config` calling `vim.cmd.colorscheme("rose-pine-main")` re-applies rose-pine the moment the picker previews it.
- [x] 5.3 Update the comment in each of the four theme files: three name the file that owns startup, and `kanagawa.lua` says why it carries the three properties and what moving them means.
- [x] 5.4 Point `install.colorscheme` in `lua/config/lazy.lua` at `kanagawa-wave`, so the first-run install UI is themed in what actually starts.
- [x] 5.5 Reword the `termguicolors` and `background` comments in `lua/config/options.lua` to name no theme — both hold for every installed theme, and naming one is a comment that goes stale on the next switch.
- [x] 5.6 Repoint the `<leader>ft` comment in `lua/plugins/telescope.lua` at kanagawa `wave` and `themes/kanagawa.lua`.
