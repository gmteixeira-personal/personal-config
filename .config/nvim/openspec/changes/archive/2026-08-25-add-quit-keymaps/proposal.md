## Why

Leaving the editor is the one everyday operation with no `<leader>` mapping: it is typed as `:qa<CR>`, and when a buffer is modified that command fails with `E37` rather than asking what to do about it. LazyVim answers this with a `<leader>q` menu, and `<leader>q` is unbound here, so the prefix is free to carry the same idea.

The session half of that LazyVim menu — restore, restore-last, don't-save — is deliberately out of scope. This configuration has no session manager, and choosing one is a separate decision; `<leader>q` is claimed for quitting now, and can be extended later without moving anything added here.

## What Changes

- Add a `<leader>q` prefix for leaving the editor, bound to no command of its own.
- `<leader>qq` quits every window and tab page, prompting per modified buffer rather than refusing.
- `<leader>qw` writes every modified buffer and then quits, so the common "save and go" needs one sequence rather than `<C-s>` followed by a quit.
- Name `<leader>q` as a group in the key-sequence hints, alongside the eight prefixes already named there.
- No force variant is added. Nothing here discards a modified buffer without asking, matching the buffer deletions, which use `:confirm` and never a bang.
- No session mappings (`qs`, `ql`, `qd`) are added, and no session-manager plugin is introduced.

## Capabilities

### New Capabilities

None. Quitting is an unprefixed-and-`<leader>` key mapping that holds with no plugin installed, which is what `editor-keymaps` already covers.

### Modified Capabilities

- `editor-keymaps`: adds a requirement for the `<leader>q` prefix and the two mappings under it, including the unsaved-changes prompt and the guarantee that the prefix itself runs nothing.
- `keymap-hints`: the requirement listing which `<leader>` prefixes are named gains quit, so the new prefix is displayed as a subject rather than as a bare `q`.

## Impact

- `lua/config/keymaps.lua`: two new mappings and their commentary, next to the buffer commands.
- `lua/plugins/which-key.lua`: one entry added to `opts.spec`.
- No new plugin, no new file, no dependency change. `<leader>q` is currently unbound, and `<leader>wq` — quit window — is a different sequence and is untouched.
