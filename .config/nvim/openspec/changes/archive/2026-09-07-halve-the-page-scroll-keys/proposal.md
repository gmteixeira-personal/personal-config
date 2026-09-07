## Why

`<C-d>` moves the cursor a whole window down instead of half of one whenever the view is against the top of the buffer — which is where every file starts. The built-in first moves the cursor `'scroll'` lines (half a window) and then `scrolloff = 999` recentres it, and inside the first screenful the view has no room to move, so the correction is paid entirely by the cursor: from line 1 in a 23-row window the cursor lands on line 23, not line 12. `<C-u>` looks correct only because pressing it near the top of a file hits line 1 and stops; it has the same defect mirrored into the last screenful, where it moves a full window up.

The full-page keys have the same defect one size up. In a 38-row window, where a page is 36 lines, `<C-f>` from line 1 moves the cursor 54 lines — the page plus half a window — against 36 from the middle of the file. `<PageDown>` is the same command and behaves identically.

The keys are the ordinary way to travel through a file, and each pair silently moves twice as far at the ends as it does in the middle. `scrolloff = 999` is deliberate and stays; the four keys have to be made to move a fixed distance regardless of where the view is clamped.

A page is also being redefined while these are rewritten. Vim moves `height - 2` lines and keeps two rows of the old screen so a reader can find their place after the jump. Under `scrolloff = 999` the cursor is the landmark rather than the top row, so the overlap costs two lines a press and buys nothing: a page becomes the whole window. In a 39-row window `<C-f>` moves 39 lines.

## What Changes

- Bind `<C-d>` and `<C-u>` in normal and visual mode so that each moves the cursor by exactly half the window's height, in screen rows, everywhere in the buffer — including the first and last screenful, where the built-ins currently double.
- Bind `<PageDown>` and `<PageUp>` the same way over a whole window's height, and make `<C-f>` and `<C-b>` reach them, so the four full-page keys are one behaviour under two names.
- **BREAKING** for anyone relying on the overlap: a page is the window's full height, not `height - 2`. No line is shown twice across a press.
- Each pair is a mirror of itself. `<C-u>` moves exactly as far as `<C-d>` in the other direction, and `<C-b>` and `<PageUp>` exactly as far as `<C-f>` and `<PageDown>`, so pressing one and then its opposite returns the cursor to the line it started on.
- Keep both distances measured the way Neovim already measures them — `'scroll'` for half a window, the window's height for a whole one — so a resized window keeps a correct distance, and a count multiplies it.
- Clamp at the ends of the buffer: a move down from within the last screenful lands on the last line rather than failing, and a move up from within the first lands on line 1.
- `<C-f>` and `<C-b>` keep scrolling a hover or signature float first when one is open, as they do today. In visual mode, where no float can be open, they page the buffer directly.
- The view keeps following the cursor from `scrolloff = 999` alone. None of the mappings scrolls the window itself, and the centring requirement is untouched.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `language-servers`: the float-scroll keys' fallback is no longer the editor's built-in page scroll but the page this change defines, so the requirement that says it stays intact has to say what it now falls back to.
- `scrolling`: adds two requirements fixing how far the page-scroll keys move the cursor under the existing centring rule — half a window for `<C-d>`/`<C-u>` and a whole one for `<C-f>`/`<C-b>`/`<PageDown>`/`<PageUp>`, at the ends of the buffer as well as in the middle.

## Impact

- `lua/config/keymaps.lua` gains the shared helper and the four mappings it owns. `lua/config/options.lua` is untouched; `scrolloff` keeps its value.
- `lua/plugins/noice.lua` keeps `<C-f>` and `<C-b>` for its float scroll, and its no-float fallback now reaches the general page mapping instead of the built-in page scroll.
- No plugin is added. Nothing else in the configuration binds these keys outside a Telescope prompt (`lua/plugins/telescope.lua` binds `<C-d>` in the buffer picker's insert-mode prompt, which a normal- and visual-mode mapping cannot reach).
- `README.md` describes the held-centre scrolling behaviour and gains the keys.
