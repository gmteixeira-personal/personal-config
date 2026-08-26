## Why

`<leader>,` opens the buffer picker, which is where the user already goes to see what is open. The list it shows is also the list a stale buffer needs removing from — but the picker can only switch to a buffer, so closing one means leaving the list, running a separate mapping, and reopening the list to check. The deletion belongs where the list is.

## What Changes

- Bind `<C-d>` in the buffer picker's prompt to delete the buffer under the selection. Telescope's stock `<C-d>` — scroll the preview down — is left alone in every other picker; only the buffer picker rebinds it.
- Delete every entry marked with `<Tab>` when there are marks, and the selected entry when there are none.
- Keep the picker open across a delete and refresh its list, so the deleted entry disappears and the next `<C-d>` acts on what is now selected.
- Replace silence with a prompt before discarding unsaved work. A modified buffer SHALL raise a save / discard / cancel dialog naming that buffer; save writes it and then deletes, discard deletes without writing, cancel leaves the buffer open and the picker usable. The same three-way dialog `<leader>bd` uses, and one prompt per modified buffer when several are marked.
- Cancelling one buffer's prompt SHALL NOT cancel the rest of a marked set.

## Capabilities

### Modified Capabilities

- `fuzzy-finder`: the buffer-picker requirement gains deletion from within the picker — the `<C-d>` binding, its scope to that one picker, the marked-set behaviour, the picker staying open, and the confirmation on unsaved changes.

`editor-keymaps` is deliberately absent. `<leader>bd` and the rest of `<leader>b` are unchanged; this adds nothing outside a picker prompt. `keymap-hints` is likewise untouched — a picker's own mappings are not `<leader>` sequences and never appear in the hint popup.

## Impact

- `lua/plugins/telescope.lua`: a `pickers.buffers.mappings` entry and the delete function it calls. `defaults.mappings` is untouched, so `<C-d>` keeps scrolling the preview in the file, grep, help, symbol and git pickers.
- No plugin is added. `mini.bufremove` and `bufdelete.nvim` stay out for the same reason they were declined for `<leader>bd`: their one advantage is preserving window layout across a delete, which this configuration does not attempt.
- Deletion is destructive in that it unloads buffers, but no unsaved work can be discarded without an explicit answer to the dialog, so no further guard is added.
- Telescope's own `actions.delete_buffer` is kept and delegated to, not replaced: it already deletes the marked set or the selection, drops the deleted entries from the list, and moves the invoking window off a buffer it just deleted. What it does not do is notice a modified buffer — its delete is wrapped in a `pcall`, so the `E89` a modified buffer raises is swallowed and that buffer simply stays in the list, with no prompt and nothing visible over the picker to say why. That silence is what this change replaces.
