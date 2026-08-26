## Why

This Neovim configuration is empty: `init.lua` is a zero-byte file and `lua/config/` is an empty directory. Nothing loads, no plugin manager exists, and there is no convention for where settings live. Establishing the directory structure and plugin manager first is a prerequisite for every plugin added later, so the layout decisions should be made once, up front, rather than retrofitted after plugins accumulate.

## What Changes

- Add a standard directory structure with `init.lua` as a thin entrypoint that requires `config.options`, `config.keymaps`, and `config.lazy` in that order.
- Add `lua/config/options.lua` for general Vim options, including the `<Space>` leader assignment (set before any plugin loads so plugin-defined mappings resolve against the correct leader).
- Add `lua/config/keymaps.lua` for general, plugin-independent keymaps.
- Add `lua/config/lazy.lua` to bootstrap [lazy.nvim](https://github.com/folke/lazy.nvim) (clone-if-missing, prepend to `runtimepath`) and configure it to import every plugin spec from `lua/plugins/`.
- Establish the one-plugin-per-file convention: each file in `lua/plugins/` returns a lazy.nvim spec table for exactly one plugin.
- Establish the ownership rule that splits general from plugin-specific configuration, applied symmetrically to both options and keymaps:
  - **General options** (editor behavior that stands alone with no plugin installed) go in `lua/config/options.lua`; **plugin-specific options** (a plugin's own settings, passed to its setup) go in that plugin's file under `lua/plugins/` and nowhere else.
  - **General keymaps** (mappings that work with no plugin installed) go in `lua/config/keymaps.lua`; **plugin-specific keymaps** (mappings that invoke a plugin) go in that plugin's file under `lua/plugins/` and nowhere else.
  - The effect is that a plugin file is the single place a plugin is described — its options, its keymaps, and its dependencies — so deleting that one file removes the plugin completely, and the general files never accumulate plugin-conditional code.
- Install [mini.icons](https://github.com/echasnovski/mini.icons) as the single icon provider, with `MiniIcons.mock_nvim_web_devicons()` enabled so plugins that request `nvim-web-devicons` are transparently served by mini.icons. No `nvim-web-devicons` dependency is installed.
- Install [rose-pine](https://github.com/rose-pine/neovim) with the `main` (dark) variant, loaded at startup with high priority so no unstyled frame is drawn.
- Install [oil.nvim](https://github.com/stevearc/oil.nvim) with a `<leader>e` mapping that toggles a floating oil window, and icons supplied by mini.icons via the devicons mock.

Non-goals for this change: LSP, completion, treesitter, fuzzy finding, statusline, formatting, and git integration. Those are separate changes that build on the structure established here.

## Capabilities

### New Capabilities
- `config-structure`: The directory layout, entrypoint load order, and the contract for where options, keymaps, and plugin specs live.
- `plugin-management`: lazy.nvim bootstrap, the plugins directory import, and the one-plugin-per-file spec convention.
- `icons`: A single icon provider serving both native mini.icons consumers and plugins that expect `nvim-web-devicons`.
- `colorscheme`: The active theme, its variant, and when it is applied during startup.
- `file-explorer`: Directory browsing and editing via oil, and the keymap that toggles it.

### Modified Capabilities

None. This project has no existing specs.

## Impact

- **Files created**: `init.lua` (currently empty, will be populated), `lua/config/options.lua`, `lua/config/keymaps.lua`, `lua/config/lazy.lua`, `lua/plugins/oil.lua`, `lua/plugins/rose-pine.lua`, `lua/plugins/mini-icons.lua`.
- **New runtime state**: lazy.nvim clones plugins into `~/.local/share/nvim/lazy/` and writes a `lazy-lock.json` lockfile at the config root on first sync.
- **External dependencies**: `git` (lazy.nvim bootstrap clone), a Nerd Font in the terminal (icon glyphs render as tofu without one).
- **Environment**: Neovim 0.12.5 is installed; all four plugins support it.
- **Breaking**: None. There is no prior working configuration to break.
