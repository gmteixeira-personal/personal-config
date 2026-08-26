## 1. Install Themery and read its file contract

- [x] 1.1 Create `lua/plugins/themes/themery.lua` with a minimal spec for `zaldih/themery.nvim` (`lazy = false`, `priority = 1000`, no options yet), so lazy.nvim fetches it and pins it in `lazy-lock.json`.
- [x] 1.2 Read the installed plugin's source for how it persists an accepted theme, which options it accepts, and the command it exposes. Record what that implies for this configuration as a comment in `themery.lua`.

## 2. Theme discovery

- [x] 2.1 In `themery.lua`, build the candidate list from `vim.fn.getcompletion("", "color")`, de-duplicated by name.
- [x] 2.2 Extend it with `colors/*` globbed over `lazy.core.util.get_unloaded_rtp("")`, taking each entry's basename. Guard the `require` with `pcall` and check `get_unloaded_rtp` exists before calling it, so a lazy.nvim change degrades to runtimepath-only discovery rather than a startup error.
- [x] 2.3 Build the bundled-theme set by globbing `colors/*` under `vim.env.VIMRUNTIME` and filter those names out of the candidate list.
- [x] 2.4 Order the candidate list so `kanagawa-wave` comes first, and comment why: Themery's fallback for an unappliable recorded theme takes the first entry of `themes` that works (`lua/themery/init.lua:44-55`), so the ordering is what makes that fallback land on the default named by `colorscheme` rather than on whichever name sorts first.
- [x] 2.5 Pass the resulting list as `themes` to `require("themery").setup()`, with `livePreview = true`. Do not set `themeConfigFile`: it is deprecated in the installed version (`lua/themery/constants.lua:14`) and setting it only prints a deprecation notice at every startup.

## 3. Persisted selection

- [x] 3.1 In `themery.lua`, after `setup()`, apply `kanagawa-wave` when `vim.g.colors_name` is unset. Comment why: `persistence.loadState()` returns silently when its state file is absent, so this is the machine on which no theme has been accepted yet.
- [x] 3.2 Comment the ordering of the `config` function: `require("themery")` applies the recorded colorscheme as a side effect of loading the module, so discovery, `setup()` and the default all have to run inside `priority = 1000` for the first frame to be themed.

## 4. Mapping

- [x] 4.1 Add the `<leader>ft` entry to `themery.lua`'s `keys`, invoking Themery's command, with a `desc`. Note in a comment that `<leader>f` stays a bare prefix.
- [x] 4.2 Delete the `<leader>ft` entry and its two preceding comment lines from `lua/plugins/telescope.lua` (currently lines 85-95).
- [x] 4.3 Update the stale comment in `lua/plugins/telescope.lua` above `opts` that counts "the four pickers below", and the session-only note at line 85-86 that says a switch is never written to disk.

## 5. Hand startup over from kanagawa

- [x] 5.1 Strip `lazy = false`, `priority = 1000` and the `config` block from `lua/plugins/themes/kanagawa.lua`, leaving `lazy = true` and a bare install.
- [x] 5.2 Rewrite kanagawa.lua's header comment: it currently declares itself the owner of startup and explains how to move that ownership. Replace with a note that the theme switcher applies the startup colorscheme and that kanagawa `wave` is the default it falls back to.
- [x] 5.3 Update the header comment in `tokyonight.lua`, `catppuccin.lua` and `rose-pine.lua` — each says "kanagawa.lua owns startup" and describes Telescope's globbing of `colors/*`, both of which stop being true.
- [x] 5.4 Confirm `install.colorscheme` in `lua/config/lazy.lua` still leads with `kanagawa-wave` and leave it; the first-run install UI runs before any selection exists, so the default is the right value there.

## 6. Documentation of the invariant

- [x] 6.1 State in `themery.lua`'s header comment that this is now the only file in the configuration that applies a colorscheme, and that theme files under `lua/plugins/themes/` must stay bare installs — the invariant `colorscheme` requires, which previously lived in kanagawa.lua's comment.
