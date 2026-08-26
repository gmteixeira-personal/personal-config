## Why

Picking a theme currently lasts only as long as the session. `<leader>ft` opens Telescope's colorscheme picker, previews live, applies on accept — and the next `nvim` is kanagawa `wave` again. Making a choice stick means editing `lua/plugins/themes/kanagawa.lua`, which is a config edit standing in for what should be a preference.

Themery is a picker built for exactly that: it writes the accepted theme into a small Lua file and applies it on the next start. Adopting it reverses the deliberate no-persistence decision made in `add-colorscheme-picker`, replaces the Telescope mapping, and moves startup theme ownership off the individual theme plugin files.

## What Changes

- Install `zaldih/themery.nvim` as the configuration's theme switcher, in a new `lua/plugins/themes/themery.lua`. It loads eagerly at `priority = 1000`, taking over the startup-apply role.
- **BREAKING** (for the specs, not for the user): a theme accepted in the picker now persists. The `colorscheme` requirement that switching writes nothing to disk is removed and replaced by the opposite guarantee.
- Remove the `<leader>ft` Telescope colorscheme entry from `lua/plugins/telescope.lua`. `<leader>ft` is rebound to `:Themery`, so the key the user already presses does not change.
- Themes are discovered, not listed. `vim.fn.getcompletion("", "color")` finds loaded and bundled colorschemes; because lazy.nvim keeps `lazy = true` plugins off the runtimepath, that call alone misses tokyonight, catppuccin and rose-pine. The discovery therefore also globs `colors/*` over `lazy.core.util.get_unloaded_rtp("")`, which is what Telescope's own picker does. Adding a theme file stays a one-file operation, with no list to keep in sync.
- Neovim's ~27 bundled colorschemes are filtered out of the list, so the picker shows only the installed themes and their variants. The bundled names are identified by globbing `$VIMRUNTIME/colors/*` rather than by a hardcoded list, so the filter does not rot across Neovim versions.
- `lua/plugins/themes/kanagawa.lua` gives up `lazy = false`, `priority = 1000` and its `config`, becoming a bare install like the other three. No theme plugin applies itself at startup any more.
- The persisted selection is Themery's own. `require("themery")` reads `stdpath("data")/themery/state.json` and applies the colorscheme named there; accepting an entry writes it back. Because it lives outside the repository, it is machine-local by construction: switching never leaves the working tree dirty and no `.gitignore` entry is needed. Where nothing has been recorded yet, the configuration applies kanagawa `wave`, so a first launch behaves exactly as it does today.

## Capabilities

### New Capabilities

- `theme-switcher`: the picker itself — how installed colorschemes are discovered, how the list is presented and previewed, how an accepted theme is persisted, and where that persisted state lives. Nothing here is specific to any one theme; `colorscheme` keeps what the theme *is*, this keeps how one is chosen.

### Modified Capabilities

- `colorscheme`: three requirements change. "Kanagawa wave is the startup colorscheme" is narrowed to a *default* rather than a fixed value — kanagawa `wave` is what starts when nothing has been chosen, and startup application moves from a theme plugin to the theme switcher, so the "exactly one installed colorscheme applies itself at startup" clause and its scenario go with it. "A colorscheme chosen during a session is not persisted" is replaced outright by a requirement that it *is*. "Further colorschemes are installed without being applied" keeps its substance but drops its reference to the picker's variant handling, which the new capability now owns.
- `fuzzy-finder`: the `<leader>ft` requirement is removed. Colorscheme selection is no longer a fuzzy-finder feature, and the mapping is redeclared by the theme switcher's own plugin file. Every other `<leader>f` picker is untouched, and `<leader>f` remains unbound in its own right.

## Impact

- `lua/plugins/themes/themery.lua` — new. Plugin spec, the discovery function, the bundled-theme filter, the `<leader>ft` mapping, and the default applied when Themery has recorded no selection.
- `lua/plugins/themes/kanagawa.lua` — loses `lazy = false`, `priority = 1000` and its `config` block, plus the comment paragraph declaring it the owner of startup.
- `lua/plugins/themes/{tokyonight,catppuccin,rose-pine}.lua` — comments only. Each currently says "kanagawa.lua owns startup", which stops being true.
- `lua/plugins/telescope.lua` — the `<leader>ft` `keys` entry and the two comments above it are deleted. `opts`, dependencies and the other five mappings are untouched.
- `lazy-lock.json` — one new pinned entry.
- `lua/config/lazy.lua` — `install.colorscheme` still leads with `kanagawa-wave`, which stays correct as the default. No change expected.
- `init.lua` and `lua/config/` are untouched: the theme switcher is a plugin, so all of it lives in its own plugin file, per `config-structure`.
- lazy.nvim's `change_detection` is unaffected. It watches the configuration directory, and accepting a theme writes under `stdpath("data")` instead, so no switch triggers a reload.
