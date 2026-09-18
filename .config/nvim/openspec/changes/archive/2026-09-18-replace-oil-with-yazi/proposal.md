## Why

The file explorer is oil, which presents a directory as an editable buffer. That is a good fit for renaming several files at once and a poor one for everything else: there is no preview, no filter-as-you-type, no image or archive inspection, and moving a file between two distant directories means navigating away from the source before the destination is on screen. yazi already answers all of that, it is already installed and configured on this machine (`~/.config/yazi/`, with a shared yank list and the ripdrag drag bindings), and every one of those settings is invisible from inside Neovim today. Running two file managers with two sets of habits is the cost being paid for oil's one advantage.

## What Changes

- oil is removed from the configuration: `lua/plugins/oil.lua` is deleted and `oil.nvim` drops out of the lockfile.
- `<leader>e` opens yazi in the current window, replacing the buffer shown there and filling that window, with the cursor on the file the window was displaying.
- Selecting a file in yazi opens it in the window yazi was occupying. Quitting yazi without a selection restores the buffer the window held before, with its cursor and scroll position unchanged.
- **BREAKING** The listing is no longer an editable buffer. File operations are yazi's own keys (`a`, `r`, `d`, `y`/`p`), applied immediately, rather than text edits confirmed by a write. Bulk rename remains available through yazi's own bulk-rename, which opens the selected names in `$EDITOR`.
- **BREAKING** `<leader>e` no longer closes the explorer. yazi has keyboard focus and Neovim never sees the key; the explorer is dismissed with yazi's own `q`.
- **BREAKING** Deleting an entry sends it to the trash. yazi's `d` trashes and `D` deletes permanently, and both are left at their defaults so that yazi behaves identically inside and outside the editor. The existing requirement forbidding a trash is withdrawn.
- `nvim <directory>` opens yazi on that directory rather than netrw, as it does today with oil.
- The explorer becomes dependent on an external `yazi` binary. When it is absent, `<leader>e` reports that plainly instead of failing as a broken terminal job.
- The explorer stops being a plugin and becomes a module of its own, `lua/config/file-explorer.lua`, loaded by `init.lua` before the plugin manager. `lua/plugins/` is reserved for files that each return a spec for one real plugin, and this explorer has none — it drives a binary. The rule that a mapping is declared beside the thing it invokes is kept; what changes is that the thing it invokes is now a config module rather than a plugin file.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `config-structure`: two requirements change. `init.lua`'s load order gains a fourth module — the file explorer, which must run before the plugin manager because disabling netrw has to happen before Neovim sources its built-in plugins. And the rule sending every plugin-independent keymap to `lua/config/keymaps.lua` is generalised to the rule the plugin files already follow: a mapping is declared beside the thing it invokes, whether that is a plugin file or a config module of its own.
- `file-explorer`: nearly every requirement changes. The listing stops being an editable buffer and becomes a terminal user interface, so the editable-buffer requirement and the write-confirmation it rests on are removed; the permanent-delete requirement is withdrawn in favour of yazi's trash; the `<leader>e` requirement keeps its opening behaviour and loses its closing half; and two requirements are added, one for how a selected file is opened and one for the missing-binary case. The icon and netrw requirements survive with their wording adjusted to yazi's terms.

## Impact

- `lua/plugins/oil.lua` — deleted.
- `lua/config/file-explorer.lua` — new. Holds the `<leader>e` mapping, the terminal-job plumbing that runs yazi in the current window, and the netrw hijack for `nvim <directory>`.
- `init.lua` — one added `require`, third of four, before the plugin manager.
- `lazy-lock.json` — loses `oil.nvim`. It gains nothing: the decision recorded in design.md is to drive yazi directly rather than through `yazi.nvim`, because that plugin draws only into a floating window and a float cannot leave the surrounding splits visible.
- `lua/plugins/auto-session.lua` — a comment explains `close_unsupported_windows` in terms of a non-float Oil window. A yazi terminal buffer raises the same question and needs the same answer, so the comment is rewritten rather than deleted.
- `lua/config/keymaps.lua` — one comment names `oil://` among the scratch buffers the buffer-delete mappings step over.
- `README.md` — the keymap table's `<leader>e` row and the plugin list entry for oil.
- `~/.config/yazi/` — unchanged. The existing `init.lua` and `keymap.toml` apply to the yazi instance Neovim starts, which is the point of driving the binary directly.
- Icons: oil's dependency on `mini.icons` goes away. yazi draws its own icons from its own theme, so `mini.icons` stays only for the other plugins that use it.
- New external prerequisite: `yazi` on `PATH`. It is outside `tool-management`'s scope, which covers only what Mason installs into the editor's data directory.
