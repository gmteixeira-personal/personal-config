## Why

`<leader>bO` reports "18 buffers deleted" in a session where the buffer picker lists two. The two mappings that clear buffers in bulk run `:%bd`, and `%` on `:bdelete` is the line range `1,$` reinterpreted as buffer *numbers* — every buffer that exists, not the buffer list. Everything else under `<leader>b` disagrees with that: `:bnext` walks listed buffers, and the picker at `<leader>,` filters on `buflisted`. The unlisted buffers the plugins keep alive are swept up as collateral, and the count is the only sign of it.

## What Changes

- `<leader>bo` and `<leader>bO` SHALL act on the listed buffers only — the same set the navigation mappings walk and the buffer picker shows. Unlisted buffers SHALL be left loaded and untouched.
- The reported count SHALL therefore match what the picker showed, which is what makes the mappings legible.
- `<leader>bo` drops the `:%bd|e#|bd#` idiom. With the deletion scoped to a named set of buffers, the buffer that must survive can simply be left out of it, so it is never deleted and never re-edited. This retires a trade-off `add-buffer-commands` recorded and accepted: the surviving buffer keeps its undo history, its buffer-local marks and its cursor position, because nothing happens to it at all.
- Confirmation on unsaved changes is unchanged. `:confirm bdelete` with several buffer numbers raises the save / discard / cancel dialog once per modified buffer and honours each answer — verified, not assumed.
- `<leader>bd` is unchanged. It deletes the current buffer, whatever its listed state, and needs no scoping.

## Capabilities

### Modified Capabilities

- `editor-keymaps`: the requirement covering `<leader>bd`, `<leader>bo` and `<leader>bO` gains the set the two bulk mappings act on. Deleting a buffer with unsaved changes is unaffected, and neither the navigation nor the creation requirement changes.

`fuzzy-finder` is deliberately absent. The picker's filter is not changing; the mappings are moving to agree with the filter it already has.

## Impact

- `lua/config/keymaps.lua`: `<leader>bo` and `<leader>bO` change from a `<cmd>` string to a function that names the buffers to delete. No other mapping is touched.
- No plugin is added and none becomes necessary; `lazy-lock.json` is untouched.
- The plugins whose scratch buffers were being deleted — smear-cursor's pooled float buffers, `oil://` directory buffers, blink.cmp's menu and documentation buffers, telescope's previewer buffers, which-key's popup buffer, gitsigns' diff buffers — stop being disturbed. Each recreates its buffers on demand, so nothing was visibly broken before; nothing depends on the old behaviour either.
- Help and quickfix buffers, both unlisted, likewise survive a bulk clear. A user who wants them gone still has `:bdelete` and `:helpclose`.
- `<leader>bo` and `<leader>bO` remain destructive in that they unload buffers, and `:confirm` remains the only guard, exactly as before.
