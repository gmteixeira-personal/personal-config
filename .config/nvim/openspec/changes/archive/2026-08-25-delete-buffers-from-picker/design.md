## Context

See `proposal.md` — Why. The constraints that shape the approach:

- `lua/plugins/telescope.lua` owns every picker mapping, per `config-structure`. This change adds no file and touches no other one.
- `defaults.mappings` in that file binds `<Esc>`, `<C-j>` and `<C-k>` for every picker. `<C-d>` is not among them: it is Telescope's own default, `preview_scrolling_down`, and the preview is a requirement of this configuration's pickers rather than an incidental default — so `<C-d>` cannot be taken globally.
- `<leader>bd` was settled in `add-buffer-commands` as `:confirm bdelete`, which is Vim's save / discard / cancel dialog. The picker's prompt should ask the same question in the same three ways.
- Three behaviours were settled with the user before this design: `<C-d>` acts on the marked set when there is one, the picker stays open and refreshes, and a modified buffer gets the three-way dialog.

Upstream behaviour was read and checked rather than assumed:

- `actions.delete_buffer` calls `picker:delete_selection(cb)`, which already resolves marked-set-or-selection, removes each entry the callback accepts from the result list, clears the marks, and refreshes the picker. A callback returning `false` leaves its entry in the list.
- Its callback deletes with `nvim_buf_delete{ force = false }` inside a `pcall`, and separately moves the invoking window off the buffer when the buffer being deleted is the one that window displayed — walking the jumplist for a loaded buffer and creating an empty one if the jumplist yields nothing.
- `nvim_buf_delete{ force = false }` on an unmodified buffer displayed in a window does not close that window: the window falls back to the alternate buffer. Telescope's jumplist walk is the harder case, where no alternate is left.
- On a modified buffer the same call fails with `E89`, the `pcall` swallows it, and the entry stays in the list.
- Clearing `'modified'` on a buffer makes the same unforced delete succeed and discards the changes.

## Goals / Non-Goals

**Goals:**

- One binding, scoped to one picker, that reuses Telescope's own deletion rather than reimplementing it.
- Exactly one dialog per modified buffer, and none for an unmodified one.
- A cancel that is local to the buffer it was answered for.

**Non-Goals:**

- Changing what `<C-d>` does in any other picker.
- Preserving the window layout across a delete — declined for `<leader>bd`, and declined here for the same reason.
- A confirmation for unmodified buffers. The buffer list is not the file system; a deleted buffer's file is untouched, and `<leader>,` reopens it.
- Reimplementing the invoking-window rescue beyond what is needed to make the delete happen at all. See the decision on vacating windows below.

## Decisions

### Bound under `pickers.buffers.mappings`, not `defaults.mappings`

The binding goes in a `pickers.buffers` block, which Telescope merges over the defaults for that one picker. The alternative — adding `<C-d>` beside `<Esc>` and `<C-j>` in `defaults.mappings` — would take preview scrolling away from the file, grep, help, symbol and git pickers to give a delete to the one picker that can use it. `pickers.buffers` is the narrowest place the binding fits, and it is where a reader looks for a mapping that only one picker has.

This adds a second top-level key to the returned opts table, alongside `defaults`.

### Resolve the dialogs first, then delegate to `actions.delete_buffer`

The mapping runs a function that walks the set about to be deleted, raises `vim.fn.confirm` for each modified buffer, and only then calls `actions.delete_buffer(prompt_bufnr)`. Save writes the buffer; discard clears `'modified'`; cancel drops that entry from the marked set. Every buffer reaching `actions.delete_buffer` is therefore unmodified, which is the one case it already handles correctly — so the list refresh, the mark clearing and the invoking-window rescue all stay upstream's.

The alternative is to call `picker:delete_selection` with a callback of our own, prompting and deleting per entry, returning `false` to keep a cancelled entry in the list. It has one real advantage — cancel falls out of the return value, with no need to touch the picker's marked set — but it obliges this file to carry a copy of the jumplist walk that moves the invoking window off a deleted buffer, roughly twenty-five lines of upstream logic that would then be frozen at the version it was copied from. Reusing the rescue is worth reaching into the marked set for.

### Discard by clearing `'modified'`, not by force-deleting

Discard could delete the buffer outright with `{ force = true }`. It must not: the entry would then be gone before `actions.delete_buffer` ran, its unforced delete of an invalid buffer would fail, its callback would return false, and the entry would stay in the list describing a buffer that no longer exists.

Clearing `'modified'` instead leaves exactly one deletion path — upstream's — for every answer. The buffer is unmodified for the moment between the answer and the delete; nothing else runs in that window, and if the delete somehow failed the buffer would remain open with its changes present but no longer flagged, which is the one visible cost of this choice.

### Cancel drops the entry from the picker's marked set

With no marks, cancel returns from the function before `actions.delete_buffer` is reached — nothing was going to be deleted but that one buffer. With marks, the cancelled entry is dropped from the picker's marked set so the delete proceeds without it. Should every marked entry be cancelled, the set is left empty, and `delete_selection` falls back to the current selection when the set is empty — so the function must return before delegating rather than let it delete something nobody asked about.

The marked set is picker-internal state rather than a documented API. That is the cost of the previous decision, and it is a narrow surface: reading the set and dropping one entry from it.

### Windows are vacated before the delete is delegated

`nvim_buf_delete` with `force` unset does nothing to a buffer that is displayed in a window other than the current one: it reports success and leaves the buffer listed and loaded. A picker always runs from its own floating prompt, so the buffer in the window the picker was opened from is always in exactly that position.

Delegating without accounting for it deletes every buffer in the set except the ones on screen, while the picker drops all of their rows, because `delete_selection` removes an entry whenever the callback reports success. Upstream's rescue then moves the invoking window onto another buffer in the set, which spares that one from its own delete for the same reason -- so a marked set of four leaves two buffers alive and no rows describing them.

So before delegating, every window displaying a buffer in the set is moved onto a buffer that is staying, or onto a new empty buffer when the whole buffer list is going. That is also the invoking-window rescue this capability requires, so `picker.original_bufnr` is pointed at the replacement as well: it is the field upstream's rescue keys off, and leaving it on a deleted buffer would have that rescue fire afterwards and swap the window's buffer a second time.

This is a second reach into picker-internal state, on the same terms as the marked set. What stays upstream's is the rest of `actions.delete_buffer` -- the deletion itself, dropping the entries, clearing the marks and refreshing the picker.

### `vim.fn.confirm`, matching `:confirm bdelete`

`vim.fn.confirm` is the dialog `:confirm` puts up, it blocks until answered — which keeps the walk over the set a plain loop rather than a chain of callbacks — and its default answer is set to cancel, so a dismissed dialog keeps the buffer. The buffer's name goes in the question, since with a marked set the dialog is the only thing saying which buffer is being asked about.

`vim.ui.select` is the alternative and is rejected: it is asynchronous, which turns the loop into recursion through callbacks, and under a custom UI handler it can be answered in any order or not at all while the picker is still open.

### A buffer that cannot be written is reported and kept

Save on a buffer with no filename fails with `E32`. The write is run under `pcall`; on failure the buffer is reported and treated as cancelled — kept, unmodified flag untouched, dropped from the marked set. Prompting again for a name inside a picker prompt is a second dialog for a case rare enough that leaving the buffer open and letting the user handle it in the buffer itself is the better answer.

## Risks / Trade-offs

- **The picker's marked set is internal.** An upstream rename breaks the cancel path for marked sets. → The two calls sit in one function, next to a comment saying what they are for; a break is a Lua error naming the field, not silent misbehaviour. The single-selection path does not touch it.
- **`picker.original_bufnr` is written, not just read.** An upstream rename leaves the field untouched and upstream's rescue firing a second time, moving the window again. -> Visible churn rather than a lost buffer; the delete itself no longer depends on it.
- **`actions.delete_buffer`'s internals could change.** Delegating means inheriting whatever it does next. → That is the point of delegating: its behaviour is the requirement this spec states, and the alternative is a private copy that cannot follow it.
- **`'modified'` is cleared before the delete.** A failed delete would leave a buffer holding unsaved changes that no longer shows as modified. → Only reachable if the unforced delete of an unmodified buffer fails, which is the path upstream already relies on.
- **`vim.fn.confirm` blocks while a picker is open.** The dialog draws over the picker and the prompt is in insert mode behind it. → It is the same dialog `<leader>bd` raises, answered the same way, and the picker redraws when it closes.
- **`<C-d>` no longer scrolls the preview in the buffer picker.** → It is the only picker where a preview scroll competes with an operation on the thing being previewed, and `<C-u>`, its counterpart, stays bound.
