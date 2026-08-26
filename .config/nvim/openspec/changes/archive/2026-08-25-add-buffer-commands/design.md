## Context

See `proposal.md` — Why. The constraints that shape the approach:

- `lua/config/keymaps.lua` owns every mapping that needs no plugin, and `<leader>bb` — `:buffer #` — already lives there. The new mappings sit beside it and are its siblings, not a new subsystem.
- `plugin-management` keeps one plugin per file and expects a plugin to earn its place. Every operation here is a built-in Ex command; the case for `mini.bufremove` or `bufdelete.nvim` would rest entirely on preserving the window layout across a delete, and the decision below is not to.
- `keymap-hints` reads `desc` off the mapping table while the prefix is pending. Each mapping needs a description and nothing else to be listed; `<leader>b` is already a named group.
- `<leader>b` must stay unbound in its own right, like every other prefix in this configuration, so nothing under it waits out the 1000 ms `'timeoutlen'`.
- Two behaviours were settled with the user before this design: a delete uses `:bdelete`'s own window handling, and a modified buffer raises a prompt rather than an error or a forced discard.

Behaviour of the built-ins was checked rather than assumed:

- `:bnext` and `:bprevious` wrap at both ends of the buffer list on their own — no `-1`/`+1` arithmetic and no wrap logic is needed.
- `:%bdelete` leaves exactly one buffer: an empty unnamed one.
- `:%bd|e#|bd#` leaves exactly one buffer, the one that was current, with its name intact.
- `:bdelete` closes any window displaying the buffer.

## Goals / Non-Goals

**Goals:**

- Eight mappings under `<leader>b` that between them cover what the prefix's name promises: move through the list, make one, remove one, remove the rest.
- Built-in commands, written plainly, so each mapping reads as the Ex command it runs.
- No unsaved work discarded without an explicit answer.

**Non-Goals:**

- Preserving the window layout across a delete. Explicitly declined — see below.
- A bufferline, tabline, or any visual buffer list. The picker at `<leader>,` is the list; these are the movements.
- Ordering buffers by anything but the buffer list's own order. `:bnext` order is the contract; most-recently-used ordering is a different feature.
- `<leader>bb`. It stays exactly as it is.

## Decisions

### Built-in Ex commands, no plugin

Every operation is one command: `:bnext`, `:bprevious`, `:bfirst`, `:blast`, `:enew`, `:bdelete`. The alternative is `mini.bufremove` or `bufdelete.nvim`, both of which exist for one reason — deleting a buffer without closing the windows showing it. That behaviour was considered and declined, which removes the only argument for the dependency.

### `:bdelete`'s window behaviour is kept, not worked around

`:bdelete` closes every window displaying the buffer; a vsplit showing the deleted buffer drops to a single window. The alternative is roughly fifteen lines that walk `nvim_list_wins()`, point each window showing the buffer at its alternate (or a scratch buffer), and only then delete.

Kept as-is deliberately. This configuration already has a place where layout is the subject — `<leader>w` and `<C-w>`, including a maximize toggle that stores and restores `winrestcmd()` — and a buffer mapping that quietly rearranges windows is doing that subject's job badly. `<leader>bd` deletes a buffer; if the layout matters, `<leader>w` is two keys away. The spec states the window behaviour as a requirement rather than leaving it as an accident, so a later change to it is a visible change.

### `:confirm` rather than a bare command or a `!`

`:bdelete` on a modified buffer aborts with `E89`, and `:bdelete!` discards the changes. Neither is acceptable: the first makes the mapping fail in exactly the situation where the user most needs to be told something, and the second can lose work to a two-key sequence.

`:confirm` is the built-in that turns the failure into the save / discard / cancel dialog, per modified buffer, and it applies to `:%bdelete` as well as to a single `:bdelete`. It is one keyword on the front of the command, so the mappings stay one command each. It also matches the shape of `<leader>rc`, which confirms before discarding a session.

### `<leader>bo` is `:%bd|e#|bd#`, `<leader>bO` is `:%bd`

`:%bdelete` deletes the whole list and leaves an empty unnamed buffer — that is `<leader>bO`, the "start over" key.

"Everything but this one" has no built-in. The idiom is `:%bd|e#|bd#`: delete the list, re-edit the buffer that was current (still reachable as `#`), then delete the empty unnamed buffer that step left as the new alternate. Verified to leave exactly one listed buffer with its name intact.

The alternative is a loop over `vim.api.nvim_list_bufs()` deleting all but the current one, which avoids re-editing the file and so preserves the buffer's undo history and local marks. Rejected for now: the idiom is one line, is the form the user asked for, and the re-edit is only observable in the undo history of the surviving buffer. Recorded here because it is the first thing to reach for if that turns out to matter.

The final `bd#` is the step that can fail — there is no alternate to delete if the sequence is run with a single buffer already open. It is silenced so the mapping succeeds in that case rather than reporting an error for a step whose work was already done.

### `o` and `O` for the two clear-outs

`o` mirrors `<C-w>o` and `<leader>wo`, both of which mean "close the others", so the letter already means this in the configuration. `O` is the same operation without the exception, which is the relationship the case difference conventionally carries. Neither is given a further confirmation beyond `:confirm`'s, because nothing is lost that was saved, and nothing unsaved goes without an answer.

## Risks / Trade-offs

- **A delete in a split changes the layout, and the user did not ask for that.** → Stated as a requirement in the spec rather than left implicit, so it is discoverable and its reversal is a visible change. `<leader>w` manages layout.
- **`<leader>bO` is one shifted key from `<leader>bo`.** Pressing the wrong one closes the buffer that was meant to survive. → Nothing unsaved is lost — `:confirm` guarantees that — and reopening a saved file is `<leader><leader>`. Not worth a confirmation prompt on a non-destructive operation.
- **`<leader>bo` re-edits the surviving buffer**, discarding its undo history and buffer-local marks. → Accepted; the loop-based alternative is written down above if it becomes annoying.
- **`<leader>bc` is `c` for "create" while `<C-w>` uses `n` for "new".** → `n` is taken here by "next", which is the more frequent operation and the letter it has in `:bnext`, `<C-w>` and every other buffer-walking convention.
