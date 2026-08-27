## Why

gitsigns already computes the difference between the buffer and the git index, but the only ways to see that difference as a whole file are `:Gitsigns diffthis` typed out in full, or reading hunk by hunk with `<leader>hp`. There is no key for "show me everything that changed in this file", which is the view wanted before staging or before writing a commit message.

## What Changes

- Add `<leader>gd` in the gitsigns buffer-local mappings: open the current file's full diff against the git index in a vertical split, with the indexed version on the left and the working buffer on the right.
- Leave the cursor where gitsigns puts it -- in the window the file is being edited in. `<leader>ww` and `<leader>wp` move to the diff and back; nothing about window focus is overridden.
- Keep the indexed version out of the buffer list, which `:diffsplit` otherwise puts it into.
- Note gitsigns' new claim on `<leader>gd` in the `<leader>g` ownership comment in `lua/plugins/neogit.lua`, which currently divides that prefix between neogit and Telescope only.

No new plugin and no new dependency: `gitsigns.diffthis` already exists, its defaults already produce the wanted layout, and it already restores the file window's `diff` option when the diff buffer goes away. The change is a mapping plus one correction to the buffer list.

## Capabilities

### New Capabilities

None. This extends what gitsigns already covers.

### Modified Capabilities

- `git-integration`: adds a requirement that the whole file's difference from the index can be opened as a side-by-side diff from a single mapping.

## Impact

- `lua/plugins/gitsigns.lua` -- one mapping added inside `on_attach`, so it exists only in buffers inside a git repository, as every other gitsigns mapping here does.
- `lua/plugins/neogit.lua` -- comment only; the list of who owns which key under `<leader>g` gains gitsigns.
- `openspec/specs/git-integration/spec.md` -- gains a requirement once this change is archived.
- No change to `]c` / `[c`: those are already written to defer to the built-in diff navigation when `vim.wo.diff` is set, which is exactly the state this mapping creates.
