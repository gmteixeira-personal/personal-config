## Context

See `proposal.md` — Why. What shapes the approach:

- `<leader>bd`, `<leader>bo` and `<leader>bO` were added by `add-buffer-commands`, already archived, and each is a single `<cmd>` string running one Ex command. Its design records the reasoning this change revisits: the `:%bd|e#|bd#` idiom, and the re-edit it costs.
- `lua/config/keymaps.lua` holds mappings that need no plugin. It already has functions behind mappings — `toggle_maximized`, `terminate_line` — so a mapping that is a function rather than a string is an established shape in the file, not a new one.
- The buffer list is what everything else in the configuration means by "a buffer": `:bnext` walks it, and telescope's `buffers` picker filters entries on `buflisted`. Only `%` disagrees.

Behaviour of the built-ins was checked rather than assumed:

- `%` on `:bdelete` is the range `1,$` read as buffer numbers, so it covers every existing buffer regardless of `'buflisted'`. With 3 listed buffers and 4 unlisted scratch buffers, `:%bdelete` reports `7 buffers deleted`.
- `:bdelete` accepts several buffer numbers as arguments and deletes each of them, reporting the same `N buffers deleted` count.
- `:confirm bdelete n1 n2 n3` raises the save / discard / cancel dialog once per modified buffer in the list and honours each answer independently: cancelling on one buffer leaves that buffer listed and still deletes the others. Verified in a terminal, since the dialog cannot be answered from a headless run.
- `:bdelete` with no argument deletes the *current* buffer. An empty argument list is therefore not a harmless no-op — it is a different command.

## Goals / Non-Goals

**Goals:**

- One definition of "the buffers", shared by the navigation mappings, the picker and the two bulk deletions.
- Keep the confirmation behaviour exactly as specified, including one dialog per modified buffer.
- Keep the built-in's own `N buffers deleted` message, which is now a true statement about what the user could see.

**Non-Goals:**

- Changing `<leader>bd`. It acts on the buffer under the cursor, and "is it listed" is not a question the user is asking when they press it.
- Changing which buffers telescope shows, or adding a filter to the picker. The picker was already right.
- Wiping buffers rather than unloading them. `:bdelete` unlists and unloads; `:bwipeout` destroys. The former is what "delete" has meant here from the start, and `add-buffer-commands` did not promise the latter.
- Reaching unlisted buffers by some other mapping. Nothing so far has wanted to, and `:bdelete` typed in full is the answer if something does.

## Decisions

### The buffer set is named explicitly, not selected by a range

`vim.fn.getbufinfo({ buflisted = 1 })` returns exactly the buffer list, which is the definition `:bnext` and the picker already use, and the mapping passes those numbers to `:bdelete`. The alternative — keeping `%` and finding a range that excludes unlisted buffers — does not exist: `%` has one meaning, and no range modifier filters on `'buflisted'`.

`getbufinfo({ buflisted = 1 })` rather than filtering `nvim_api_list_bufs()` through `vim.fn.buflisted`: it is one call that asks the question directly, where the filter form asks for everything and then discards most of it.

### One `:confirm bdelete` with the whole list, not a loop

`:bdelete` takes a list of buffer numbers, so the mapping stays one command. This matters for three reasons beyond brevity:

- `:confirm` keeps its per-buffer behaviour across the list — verified above, including that a cancel on one buffer does not abort the rest. This is the behaviour the spec requires, and it comes free rather than being reconstructed.
- The built-in emits one `N buffers deleted` message. A loop would emit N messages, or would need the loop to count and compose its own — reimplementing what the command already says correctly.
- A loop would need each iteration wrapped against a failure that stops the rest, which is precisely the failure mode the single command does not have.

### `<leader>bo` excludes the current buffer from the list instead of restoring it afterwards

With the deletion given an explicit set, "everything but this one" is a filter on that set. The buffer that must survive is simply never named, so nothing happens to it.

This retires the `:%bd|e#|bd#` idiom and the trade-off `add-buffer-commands` recorded against it: that sequence deleted the current buffer along with the rest and then re-edited it, which cost the buffer its undo history and its buffer-local marks. That design named the loop-based alternative as "the first thing to reach for if that turns out to matter" — it turns out the same change that fixes the count fixes this too, because both come from `%` being the wrong way to name a set.

The third step, `silent! bd#`, goes with it. It existed to swallow an error from a step that only existed to clean up after the second step.

### An empty list is a guard, not a no-op

`:bdelete` with no arguments deletes the current buffer, so building the command by string concatenation and running it unconditionally turns "there is nothing to clear" into "clear the buffer I am looking at" — the opposite of what `<leader>bo` means. Both mappings return early when their list is empty.

This is reachable in ordinary use: `<leader>bo` with one file open, or either mapping pressed from an `oil://` buffer in a fresh session.

### Nothing is added to protect the unlisted buffers

They are left alone because they are not in the set, not because they are recognised and skipped. There is no allowlist of plugin filetypes to maintain, and a plugin that starts or stops listing its buffers is automatically handled correctly.

## Risks / Trade-offs

- **`<leader>bO` no longer clears help, quickfix and terminal-adjacent buffers.** A user who reached for it to get back to a clean editor now gets a clean *buffer list*, and an unlisted buffer they had forgotten about stays loaded. → That is the stated point of the change, and it is what the picker was already showing them. Memory held by an unloaded-but-listed buffer was never the cost anyway.
- **Two mappings become functions, so they no longer read as the Ex command they run.** → The command is still one line inside the function, and the file already puts functions behind mappings where the behaviour needs it. The alternative is a string that is wrong.
- **`getbufinfo({ buflisted = 1 })` is evaluated when the key is pressed**, so a buffer created between the press and the deletion is not in the set. → Not reachable: the mapping is synchronous and nothing runs between the two.
