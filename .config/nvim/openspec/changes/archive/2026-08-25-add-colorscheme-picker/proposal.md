## Why

Trying a different theme today means editing a plugin file and restarting, which is slow enough that themes get picked once and never revisited. Telescope is already installed and ships a colorscheme picker that previews each theme live on the real buffer, so the switching capability costs one mapping and no new dependency.

A picker is only worth the mapping if there is something to pick from. This configuration installs one theme, so the change also installs three more and puts the four of them somewhere a reader can find them as a set. Having previewed them, the startup theme moves from rose-pine to kanagawa `wave`.

## What Changes

- Add a `<leader>ft` mapping that opens Telescope's built-in colorscheme picker with live preview: moving the selection applies the highlighted theme to the visible buffer immediately, so a theme is judged on real code rather than on its name.
- Install three further colorschemes — kanagawa, tokyonight and catppuccin — alongside the existing rose-pine. Each brings its own variants, taking the picker from four entries plus Neovim's bundled themes to roughly sixteen.
- Only one theme is applied at startup; the other three are installed but never loaded until previewed or selected. Startup cost is unchanged no matter how many are installed.
- The startup theme becomes kanagawa `wave`, chosen by previewing the four. rose-pine stays installed and selectable, as a bare lazy install like the rest.
- Group the four theme files in a new `lua/plugins/themes/` directory and import it explicitly from `lua/config/lazy.lua`. `lua/plugins/rose-pine.lua` moves there.
- The picker's selection is deliberately **not** persisted. After restarting Neovim the startup colorscheme is kanagawa `wave` again. Making a choice stick still means editing a plugin file — which is what fixing kanagawa as the startup theme amounts to.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fuzzy-finder`: gains a requirement for `<leader>ft`, a picker over the installed colorschemes with live preview, alongside the existing `<leader>f`-prefixed pickers.
- `colorscheme`: the existing requirement fixes rose-pine as *the* active colorscheme. It is renamed and narrowed to fix kanagawa `wave` as the colorscheme applied at *startup*, and to say that exactly one installed theme may claim startup and that which one is a movable property. The first-frame requirement is reworded to name the startup colorscheme rather than rose-pine specifically. Two requirements are added: that further colorschemes may be installed without any of them being applied at startup or delaying it, and that a theme chosen during a session applies for that session only.
- `plugin-management`: the existing requirement that adding a plugin touches exactly one file and no registration list. Adding a *directory* under `lua/plugins/` now does require one line in `lua/config/lazy.lua`, because the manager's import does not recurse. The requirement is narrowed to say so, since a silently-ignored plugin file is the failure it exists to prevent.

## Impact

- `lua/plugins/telescope.lua` — one more entry in the existing `keys` table. No change to `opts`, dependencies, or load conditions.
- `lua/plugins/rose-pine.lua` — moves to `lua/plugins/themes/rose-pine.lua` and gives up startup: `lazy = false`, `priority = 1000`, `opts` and the `vim.cmd.colorscheme` call all go, leaving a bare lazy install like the other three.
- `lua/plugins/themes/kanagawa.lua` — takes them on: `lazy = false`, `priority = 1000`, and a `config` applying `kanagawa-wave`.
- `lua/config/options.lua` — two comments that explain `termguicolors` and `background` by naming rose-pine.
- `lua/config/lazy.lua` — `install.colorscheme` leads with `kanagawa-wave`, so the first-run install UI is themed in what will actually start.
- `lua/plugins/themes/{tokyonight,catppuccin}.lua` — new, one plugin per file, a lazy install with no `opts`.
- `lua/config/lazy.lua` — one line added to `spec`, and the comment on the existing line corrected: it currently promises no list to keep in sync, which stops being true for directories.
- `lazy-lock.json` — three new pinned entries.
- `<leader>f` remains a prefix that is never bound in its own right, so `<leader>ft` adds no key-sequence timeout to any existing mapping. `<leader>ft` is currently unbound.
