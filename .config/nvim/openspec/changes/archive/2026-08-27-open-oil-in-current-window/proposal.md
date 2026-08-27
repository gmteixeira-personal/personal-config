## Why

`<leader>e` opens the file explorer as a centred float that leaves a two-cell margin of the buffer behind it visible on every side. The float buys nothing here: it is already almost the size of the editor, so it reads as a full-window listing wearing a border, and the sliver of dimmed buffer around it is a distraction rather than context. Opening the listing in the current window gives the same view without the frame, and matches what `:Oil` and `nvim <directory>` already do.

## What Changes

- `<leader>e` opens the listing in the current window, replacing the buffer shown there, instead of opening a floating window over it. **BREAKING** for anyone relying on the surrounding buffer staying visible while browsing.
- Pressing `<leader>e` from inside the listing still dismisses it and restores the buffer that window held, with its cursor position and scroll unchanged.
- The `file-explorer` requirement covering `<leader>e` and its three scenarios are restated to describe a full-window listing rather than a float.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `file-explorer`: the requirement covering `<leader>e` changes where the listing appears — the current window rather than a floating window over it — and its closing scenario now describes restoring the window's previous buffer rather than closing a float.

## Impact

- `lua/plugins/oil.lua` — the `<leader>e` mapping's callback and its description.
- `openspec/specs/file-explorer/spec.md` — via the delta spec in this change.
- The explorer's other behaviour is untouched: it is still an editable buffer, still writes confirm destructive operations, still shows icons, and still replaces netrw. Only the window it appears in changes.
- No other keymap and no other plugin is affected.
