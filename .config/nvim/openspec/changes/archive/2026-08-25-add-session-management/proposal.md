## Why

Closing Neovim throws away the whole working state: which files were open, how the windows were split, where each cursor sat. Reopening a project means rebuilding that layout by hand every time, and the `<leader>rc` restart that reloads the configuration costs the same rebuild. Neovim can already record all of this with `:mksession`, but only if the user remembers to save and to restore by hand — which is exactly the part that never happens.

## What Changes

- Add `rmagatti/auto-session` as a new plugin under `lua/plugins/`, saving the session automatically when Neovim exits and restoring it automatically when Neovim is started in that directory with no file argument.
- Session identity is the current working directory alone. Switching git branches does not switch sessions.
- Directories where a restored layout would be wrong or meaningless — the home directory, the filesystem root, and download directories — are excluded from both saving and restoring.
- Put the session mappings under the existing `<leader>q` prefix — `<leader>qs` search, `<leader>qr` restore, `<leader>qd` delete, `<leader>qW` save — alongside the `<leader>qq` and `<leader>qw` that already live there. The session search is a fuzzy picker over the saved sessions.
- Widen `<leader>q` from "leaving the editor" to the state of the editing session as a whole, and rename its group from "Quit" to "Quit & sessions" in the key hints.
- Set `sessionoptions` in `lua/config/options.lua` so a session records buffers, the working directory, folds, tab pages, window sizes and positions, and per-window local options.
- Reword the `<leader>rc` restart confirmation: a restart no longer discards the layout, so the prompt must stop claiming that it does. The confirmation itself stays — a restart is still disruptive and still must not be one keystroke away.

## Capabilities

### New Capabilities
- `session-management`: saving the editor's open buffers, window layout and cursor positions on exit, restoring them on the next launch in the same directory, and letting the user search, save, restore and delete sessions by hand.

### Modified Capabilities
- `keymap-hints`: the `<leader>q` group is renamed from "quit" to "quit and sessions" in the list of named prefixes.
- `editor-keymaps`: two requirements are restated. The `<leader>q` prefix stops being reserved for leaving the editor and takes the session mappings as well. The `<leader>rc` restart requirement's reason for confirming becomes that a restart is disruptive, not that the session is lost, because it no longer is.

## Impact

- New file `lua/plugins/auto-session.lua` — plugin spec, its options, and the `<leader>q` session mappings.
- `lua/config/options.lua` — adds `sessionoptions`.
- `lua/config/keymaps.lua` — reworded confirmation string on `<leader>rc`.
- `lua/plugins/which-key.lua` — the `<leader>q` group is renamed.
- `lazy-lock.json` — one new pinned plugin.
- New session files under Neovim's data directory. Nothing in the repository, and nothing in any project the user opens.
- Builds on `add-quit-keymaps`, now archived: the `<leader>q` prefix, `<leader>qq` and `<leader>qw` all exist, and this change widens the prefix rather than creating it.
- Startup: the plugin loads eagerly (it must decide about restoring before the first buffer exists), so it is on the startup path.
