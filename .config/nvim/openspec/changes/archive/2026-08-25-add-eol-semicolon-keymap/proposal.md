## Why

Finishing a statement in a semicolon-terminated language means leaving the point of the edit: `<End>` or `<Esc>A`, type `;`, then carry on. The cursor is almost never at end of line when the semicolon is wanted — it is inside the call that was just typed, or back in an argument that was corrected. The round trip is short but constant.

## What Changes

- Bind `<M-;>` in insert mode to terminate the current line with `;` and leave the cursor immediately after it, still in insert mode — the statement is finished and typing continues from the end of it.
- Bind `<M-;>` in visual mode to terminate every line the selection touches, linewise regardless of which columns were highlighted, skipping blank lines and leaving visual mode afterwards.
- The semicolon goes after the last non-blank character, not after trailing whitespace.
- If a line already ends in `;`, no second one is added.
- Declared in `lua/config/keymaps.lua`: it is a general mapping and calls no plugin.

## Capabilities

### Modified Capabilities

- `editor-keymaps`: two new requirements, one for the insert-mode end-of-line semicolon and one for the visual-mode line-range form. No existing mapping is displaced — `<M-;>` is unbound in stock Neovim, and no plugin in this configuration claims it. It does sit in the same Alt family as the window-resize mappings, which use `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` in normal mode only.

## Impact

- Modified file: `lua/config/keymaps.lua`. No new files, no new plugin, no lockfile change.
- The cursor moves. This is a jump, not an in-place insert: whatever position the user was editing at is lost, and the mapping provides no way back. That is the intended trade, since the key is pressed when the statement is done.
- **Alt, not Ctrl.** `<C-;>` is the chord this wants to be, but the legacy terminal key encoding has no representation for Ctrl with `;`: it reaches Neovim only from a terminal speaking the Kitty keyboard protocol (kitty, WezTerm, Ghostty, foot, Alacritty 0.14+) or a GUI such as Neovide. Under Windows Terminal, which this configuration is used from, a key trace shows the press arriving as a plain `;` — no mapping is reachable. Alt sends a leading `<Esc>`, which every terminal encodes.
- `<M-;>` therefore costs an `<Esc>`-prefixed sequence, separated from a hand-typed `<Esc>` by `'ttimeoutlen'` — the same 50ms window the `<Esc>` search-highlight mapping already depends on.
- The edit is a normal buffer change: `u` undoes it, though insert-mode undo blocks mean it may be undone together with surrounding typing rather than on its own.
