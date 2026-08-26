## Context

See `proposal.md` — Why. Three facts about the current configuration shape the approach:

- `lua/plugins/themes/kanagawa.lua` is the single owner of startup: `lazy = false`, `priority = 1000`, and a `config` calling `vim.cmd.colorscheme("kanagawa-wave")`. The other three theme files are bare `lazy = true` installs.
- lazy.nvim does **not** put `lazy = true` plugins on the runtimepath. It resolves an unloaded colorscheme by stat-ing `<plugin.dir>/colors/<name>.{lua,vim}` from a `ColorSchemePre` handler (`lazy/core/loader.lua:515-529`). Consequently `vim.fn.getcompletion("", "color")` — the discovery call in the request — returns only Neovim's bundled colorschemes plus those of already-loaded plugins.
- Telescope's picker looks complete today because it adds a second source: `lazy.core.util.get_unloaded_rtp("")` plus `globpath(paths, "colors/*")` (`telescope/builtin/__internal.lua:1050-1061`). Dropping Telescope means reimplementing that, not inheriting it.

The configuration directory is a git repository the user pulls on more than one machine.

## Goals / Non-Goals

**Goals:**

- Startup applies the recorded theme, or kanagawa `wave`, before the first frame — the same guarantee `colorscheme` already makes.
- Adding a theme stays a one-file operation. No name list to maintain.
- Startup cost unchanged: exactly one theme plugin loads, the one being applied.
- A missing, stale, or corrupt selection file degrades to the default rather than to an error.

**Non-Goals:**

- Syncing a theme choice between machines. The selection is deliberately machine-local.
- Propagating a switch to other running Neovim instances. The selection is read once at startup.
- A picker over anything but colorschemes. Telescope keeps every other `<leader>f` mapping.
- Reintroducing a `background` toggle or any light/dark automation. Variants are separate entries, as today.

## Decisions

### Discovery: `getcompletion` union unloaded-rtp glob

`vim.fn.getcompletion("", "color")` for what is on the runtimepath, then `globpath` over `lazy.core.util.get_unloaded_rtp("")` for `colors/*` under plugins lazy.nvim has fetched but not loaded, de-duplicated by basename:

```lua
local names, seen = {}, {}
local function add(name)
  if not seen[name] then
    seen[name] = true
    names[#names + 1] = name
  end
end
vim.tbl_map(add, vim.fn.getcompletion("", "color"))
local ok, lazy_util = pcall(require, "lazy.core.util")
if ok and lazy_util.get_unloaded_rtp then
  local paths = table.concat(lazy_util.get_unloaded_rtp(""), ",")
  for _, file in ipairs(vim.fn.globpath(paths, "colors/*", true, true)) do
    add(vim.fn.fnamemodify(file, ":t:r"))
  end
end
```

*Alternatives.* `getcompletion` alone, as in the request — rejected: it misses every `lazy = true` theme, which is three of the four installed. Setting `lazy = false` on all four to force them onto the runtimepath — rejected: it loads four themes at every startup to populate a list the user opens occasionally, and contradicts the `colorscheme` requirement that no other installed theme is loaded at startup. Hand-listing every variant — rejected: it is the sync-by-hand list this configuration avoids everywhere else.

The `pcall` and the `get_unloaded_rtp` existence check keep the second source optional: if lazy.nvim ever renames it, discovery quietly falls back to the runtimepath rather than erroring at startup.

### Bundled-theme filter read from `$VIMRUNTIME`, not hardcoded

The names to exclude are globbed from the running Neovim's own `colors/` directory:

```lua
local builtin = {}
for _, file in ipairs(vim.fn.globpath(vim.env.VIMRUNTIME, "colors/*", true, true)) do
  builtin[vim.fn.fnamemodify(file, ":t:r")] = true
end
```

*Alternative.* Telescope hardcodes the 27 names (`__internal.lua:1065-1071`). Rejected: that list is a snapshot of one Neovim version. Globbing costs one directory read at startup and cannot drift.

### Startup order: Themery owns it, at `priority = 1000`

Themery's spec takes `lazy = false` and `priority = 1000`; `kanagawa.lua` gives both up and becomes a bare install. This preserves the one-owner invariant `colorscheme` requires — it just moves the owner off a theme and onto the switcher, which is what makes a *recorded* choice possible without any theme file knowing about it.

Applying the recorded name inside that `config` still works for an unloaded theme: `vim.cmd.colorscheme` fires `ColorSchemePre`, lazy.nvim's handler stats the plugin directories and loads the owner. lazy.nvim registers its handlers before it loads start plugins, so the handler is live by the time `priority = 1000` runs.

### Selection file: Themery's own state, outside the repository

The recorded selection is Themery's, not this configuration's. `require("themery")` runs `controller.bootstrap()` at module level, which calls `persistence.loadState()`: it reads `vim.fn.stdpath("data") .. "/themery/state.json"` and applies the colorscheme named there. Accepting an entry writes that file back. Neither step needs anything from this configuration.

*Why not a generated Lua file in the config root.* That was this change's first design, and the installed plugin does not support it. `themeConfigFile` is deprecated (`lua/themery/constants.lua:14`), and setting it does nothing but print a deprecation notice at every startup. The marker-block file it once rewrote no longer exists; the state is JSON under `stdpath("data")`. There is nothing for the configuration to seed or to source.

Keeping the state outside the repository is the better answer to the requirement it serves. "Machine-local and untracked" then holds by construction rather than by a `.gitignore` line: switching cannot dirty the working tree because it writes nothing inside it, `git clean -x` cannot delete the choice, and lazy.nvim's `change_detection` never sees the write. The `.gitignore` entry and the generated file both drop out of the change.

*What the configuration still owns: the default.* `loadState` returns silently when no state file exists, so a machine on which no theme has ever been accepted finishes `require("themery")` with no colorscheme applied. The `config` function therefore checks `vim.g.colors_name` after `setup()` and applies `kanagawa-wave` when it is unset.

*And the fallback order.* When the recorded colorscheme fails to apply — its plugin uninstalled since it was chosen — Themery falls back by walking the configured `themes` list and taking the first entry that works (`lua/themery/init.lua:44-55`). Discovery returns names in `getcompletion` order, so that would be whichever name sorts first alphabetically rather than the default. The discovered list is therefore ordered with `kanagawa-wave` in front, which makes Themery's fallback and the default named by `colorscheme` the same theme.

### `<leader>ft` moves file, not key

The Telescope `keys` entry is deleted and an equivalent one is declared in Themery's plugin file. The user's muscle memory is unchanged; `config-structure` is satisfied because the mapping that invokes a plugin lives in that plugin's file; `<leader>f` stays unbound in its own right.

## Risks / Trade-offs

- **A theme installed mid-session is missing from the list until restart.** → Discovery runs once, in `config`. Same as today: Telescope's picker also only sees plugins lazy.nvim knows about, and `:Lazy sync` already implies a restart for a new colorscheme to be usable.
- **A second clone of this configuration on the same machine shares the recorded choice.** → The state is keyed to Neovim's data directory, not to the configuration's path, so two clones driven by the same `nvim` read and write one selection. Accepted: the guarantee is that a choice does not travel between *machines*, which holds.
- **`get_unloaded_rtp` is lazy.nvim internal API.** → Guarded by `pcall` plus an existence check. If it disappears, the three lazy themes drop off the list; the switcher and the recorded theme keep working. Telescope depends on the same function, so this is not a new dependency for the configuration as it stands.
- **Two Neovim instances, one switch.** → The other instance is unaffected until its next start, when it picks up the recorded choice. Previously both were independent forever. Called out because `colorscheme` guaranteed the old behavior explicitly.
- **Themery is a smaller, less-used plugin than Telescope.** → It is confined to one file and one mapping. Backing out is deleting `lua/plugins/themes/themery.lua`, restoring the Telescope `keys` entry, and giving `kanagawa.lua` back its `config` — no other file depends on it.
