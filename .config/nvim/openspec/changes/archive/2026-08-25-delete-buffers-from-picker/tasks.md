## 1. The confirmation walk

- [x] 1.1 In `lua/plugins/telescope.lua`, inside the existing `opts` function, add a local function taking the prompt buffer number that will back `<C-d>`. It resolves the set to act on from the current picker: the marked entries when there are any, otherwise a one-element set holding the current selection. Remember which of the two it was — the cancel path differs.
- [x] 1.2 Walk the set. Skip any buffer whose `'modified'` is unset; nothing is asked about a buffer with no unsaved changes.
- [x] 1.3 For a modified buffer, raise `vim.fn.confirm` naming that buffer, with Save / Discard / Cancel and cancel as the default answer, so a dismissed dialog keeps the buffer.
- [x] 1.4 Save: write the buffer under `pcall`. On success it is now unmodified and falls through to the delete. On failure — an unnamed buffer raises `E32` — report it and take the cancel path for that entry.
- [x] 1.5 Discard: clear the buffer's `'modified'`. Do not delete it here; the delete stays in one place, step 2.1.
- [x] 1.6 Cancel: with no marks, return from the function — there was nothing else to delete. With marks, drop that entry from the picker's marked set and carry on to the next.

## 2. Delegating the delete

- [x] 2.1 After the walk, call `actions.delete_buffer` with the prompt buffer number. Every buffer still in the set is unmodified by now, which is the case it handles: it deletes them, drops their entries from the list, clears the marks, refreshes the picker, and moves the invoking window off a buffer it just deleted.
- [x] 2.2 Guard the delegation: if the walk started from a marked set and every entry was cancelled, the set is now empty and `delete_selection` would fall back to the current selection. Return before delegating instead.

- [x] 2.3 Before delegating, move every window displaying a buffer in the set onto a buffer that is staying, falling back to a new empty buffer when the whole list is going, and point `picker.original_bufnr` at the replacement. Without this the unforced delete silently no-ops on any buffer that is on screen while the picker drops its row anyway.

## 3. Binding it

- [x] 3.1 Add a `pickers` key beside `defaults` in the table `opts` returns, with `buffers.mappings.i` binding `<C-d>` to the function. `defaults.mappings` is not touched, so `<C-d>` keeps scrolling the preview in every other picker.

## 4. Comments

- [x] 4.1 In the density of the surrounding file, record why the binding is under `pickers.buffers` rather than `defaults.mappings` — what `<C-d>` is by default, and that taking it globally would cost the preview scroll in five pickers to serve one.
- [x] 4.2 Record why the walk resolves the dialogs and then hands off to `actions.delete_buffer` rather than passing a callback to `delete_selection`: what upstream's callback does beyond deleting, and that a copy of it here would be frozen at the version it was copied from.
- [x] 4.3 Record why discard clears `'modified'` instead of force-deleting — that a force-deleted buffer would leave its entry stranded in the list, because the delegated unforced delete of an invalid buffer fails and the entry is kept on failure.
- [x] 4.4 Record what the marked-set access is for, that it is picker-internal rather than a documented API, and why the empty-set guard in 2.2 exists.
- [x] 4.5 Record why the dialog is `vim.fn.confirm` — the same dialog `:confirm bdelete` raises behind `<leader>bd`, and blocking is what keeps the walk a loop.
