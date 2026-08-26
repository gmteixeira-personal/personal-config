## Why

`<leader>b` is named "Buffer" in the hint popup and holds exactly one mapping: `<leader>bb`, the alternate-buffer toggle. Every other buffer operation is a colon command typed in full — `:bnext`, `:bdelete`, `:enew` — or is reached indirectly through the buffer picker, which is a fuzzy search over a list when the intent was "the next one". A prefix that opens onto a single entry is a menu that does not describe its subject.

## What Changes

- Add seven mappings under `<leader>b`, beside the existing `<leader>bb`:
  - `<leader>bd` — delete the current buffer.
  - `<leader>bc` — create a new, empty buffer in the current window.
  - `<leader>bn` and `<leader>bp` — the next and previous buffer in the buffer list, wrapping at the ends.
  - `<leader>bf` and `<leader>bl` — the first and last buffer in the list.
  - `<leader>bo` — delete every buffer except the current one, leaving that one open.
  - `<leader>bO` — delete every buffer, including the current one, leaving an empty unnamed buffer.
- Delete a buffer the way `:bdelete` does: any window displaying it closes with it. Layout preservation is explicitly not attempted — that is a plugin's job, and this configuration reaches for `<C-w>` and `<leader>w` when a layout matters.
- Prompt rather than fail or force when a buffer has unsaved changes. `:bdelete` and `:%bdelete` abort with `E89` on a modified buffer; the deleting mappings SHALL instead raise the save / discard / cancel dialog, the same shape of confirmation `<leader>rc` uses before a restart.
- `<leader>bb` is unchanged.

## Capabilities

### Modified Capabilities

- `editor-keymaps`: the single `<leader>bb` requirement is joined by requirements covering buffer navigation (`n`, `p`, `f`, `l`), buffer creation (`c`), and buffer deletion (`d`, `o`, `O`) — including the confirmation behaviour on unsaved changes and the fact that deletion closes windows.

`keymap-hints` is deliberately absent: the new mappings appear in the popup because they carry a description, which its "Descriptions come from the mappings themselves" requirement already guarantees, and `<leader>b` is already a named group. Nothing in that capability changes.

## Impact

- `lua/config/keymaps.lua`: seven mappings added next to `<leader>bb`. No existing mapping changes.
- No plugin is added; `lazy-lock.json` is untouched. `<leader>bd` is deliberately not `mini.bufremove` or `bufdelete.nvim`.
- `<leader>b` grows from one entry to eight in the hint popup, which is what makes the group name accurate.
- `<leader>bo` and `<leader>bO` are destructive in the sense that they unload buffers. Neither can discard unsaved work without an explicit answer to the confirmation dialog, so neither is given a further guard.
- No editor option changes, and no key outside `<leader>b` is touched.
