## 1. The mappings

- [x] 1.1 In `lua/config/keymaps.lua`, add a local helper that performs the move for one direction: half a window is `vim.o.scroll * vim.v.count1`; the screen rows available on that side come from `vim.api.nvim_win_text_height(0, { start_row = …, end_row = … }).all`, measured from the cursor line to the last line going down and from the first line to the cursor line going up; run `normal! G` or `normal! gg` when the half-window does not fit, and `normal! <n>gj` or `normal! <n>gk` otherwise. Verify by calling the helper from `:lua` on a long file with the cursor centred, on line 1, and on the last line, and reading the line it lands on each time.
- [x] 1.2 Map `<C-d>` and `<C-u>` in modes `{ "n", "x" }` to the helper — a function, not `expr = true`, so the count is consumed rather than left pending — and give each a `desc`. Verify with `:verbose nmap <C-d>` and `:verbose xmap <C-u>` that both resolve to the new mappings and to nothing else.
- [x] 1.3 Comment the pair in the file's own register: state that the built-in moves the cursor `'scroll'` lines and `scrolloff = 999` then recentres it, that within the first and last screenful the view cannot absorb its half so the cursor travels a whole window, and that the mapping exists to make the cursor's distance the same everywhere. Record why a real motion is executed rather than the cursor being set (`curswant`, visual), why the mapping is not an expression one (a typed count is prepended to a returned string), why `gj`/`gk` rather than `j`/`k` under `wrap`, and that `{count}<C-d>` no longer sets `'scroll'`.

## 2. Verify the behaviour

- [x] 2.1 On a file of several hundred short lines in a window of known height, verify that `<C-d>` from line 1 moves the cursor half the window height and not a whole one, and that `<C-u>` from the last line does the same upwards.
- [x] 2.2 Verify the middle of the file is unchanged: from a centred cursor, `<C-d>` and `<C-u>` each move half a window and leave the cursor on the middle row, the text having scrolled by the same amount.
- [x] 2.3 Verify the two keys undo each other: from a position with at least half a window on each side, `<C-d>` then `<C-u>` returns the cursor to its starting line, and the reverse order does too.
- [x] 2.4 Verify the clamps: `<C-u>` a few lines below the top lands on line 1, `<C-d>` a few lines above the bottom lands on the last line, and neither reports an error or scrolls past the end of the file.
- [x] 2.5 Verify the column survives: with the cursor at the end of a long line, `<C-d>` and then `<C-u>` returns it to that column rather than to the column of an intervening short line.
- [x] 2.6 Verify screen rows on a wrapped buffer: in a file of long prose lines, `<C-d>` advances the view by about half a screen rather than by half a window's worth of buffer lines.
- [x] 2.7 Verify visual mode: from a visual selection, `<C-d>` extends it by half a window and leaves it active; the same for `<C-u>`.
- [x] 2.8 Verify a count: `2<C-d>` moves twice as far as `<C-d>`, and `2<C-u>` likewise.
- [x] 2.9 Verify a resize: shrink the window with a split, and confirm `<C-d>` moves by half of the smaller window rather than by half the old one.
- [x] 2.10 Verify a buffer shorter than the window: `<C-d>` moves to the last line and `<C-u>` back to the first, with no blank space scrolled in.
- [x] 2.11 Verify nothing else was taken: `<C-d>` in the Telescope buffer picker's prompt still deletes the selected buffers, and `<C-f>`/`<C-b>` still scroll a hover float and page the buffer otherwise.

## 3. Documentation

- [x] 3.1 Extend the `scrolloff` note in `README.md` — Editor conventions to say that `<C-d>` and `<C-u>` move the cursor half a window in every part of the file, the ends included, where the built-ins move a whole one. Verify the paragraph reads correctly beside the existing "held at the vertical middle" one.
- [x] 3.2 Add `<C-d>` and `<C-u>` to the "Overrides of built-in keys" table in `README.md` with modes `n, x`, and correct the section's opening count — it currently says "These four take over keys Vim already uses". Verify the table renders and the count matches its rows.

## 4. The full-page keys

- [x] 4.1 In `lua/config/keymaps.lua`, split the existing `half_page` into a shared mover that takes a row count and a direction — clamping and `normal!` unchanged — and two thin wrappers over it: half a window from `vim.o.scroll`, a whole one from `vim.api.nvim_win_get_height(0)`, each multiplied by `vim.v.count1`. Verify `<C-d>` still moves half a window after the split by re-running the group 2 checks.
- [x] 4.2 Map `<PageDown>` and `<PageUp>` in modes `{ "n", "x" }` to the full-window wrappers, with a `desc` each. Verify with `:verbose nmap <PageDown>` that they resolve to the new mappings.
- [x] 4.3 In `lua/plugins/noice.lua`, change the `<C-f>` and `<C-b>` fallback to return `"<PageDown>"` and `"<PageUp>"` rather than the key itself, and add `remap = true` so the returned key reaches the general mapping. Leave the `require("noice.lsp").scroll` call and `expr = true` as they are. Verify with `:verbose nmap <C-f>` that it still resolves to `lua/plugins/noice.lua`.
- [x] 4.5 Bind `<C-f>` and `<C-b>` in mode `x` in `lua/config/keymaps.lua` to the full-window wrappers: noice declares them in `n`, `i` and `s` only, so visual mode was left on the built-in page scroll. Verify `<C-f>` from a visual selection extends it by a whole window.
- [x] 4.4 Extend the comments in both files: in `keymaps.lua`, that a page is the window's whole height because `scrolloff = 999` makes the cursor the landmark and Vim's two-row overlap only costs two lines a press; in `noice.lua`, that the fallback delegates rather than repeating the motion, that `remap = true` is what makes the returned key reach it, and that a pending count is prepended to the returned key and read there.

## 5. Verify the full-page keys

- [x] 5.1 Verify a page is the whole window: away from both ends of a file of short lines, `<PageDown>` moves the cursor by exactly the window's height, and no line visible before the press is visible after it.
- [x] 5.2 Verify the ends: `<C-f>` from line 1 moves one window and not two, and `<C-b>` from the last line does the same upwards.
- [x] 5.3 Verify the mirror: `<C-f>` then `<C-b>` returns the cursor to its starting line, and `<PageDown>` then `<PageUp>` does too, from a position with a window on each side.
- [x] 5.4 Verify the chord and the named key agree: from one line, `<C-f>` and `<PageDown>` land on the same line, and `<C-b>` and `<PageUp>` do too.
- [x] 5.5 Verify the clamps: `<PageUp>` from within the first screenful lands on line 1 and `<PageDown>` from within the last lands on the last line, with no error and nothing scrolled past the end.
- [x] 5.6 Verify screen rows on a wrapped buffer: `<C-f>` advances the view by about a screen rather than by a window's worth of buffer lines.
- [x] 5.7 Verify visual mode, a count, a resized window and a buffer shorter than the window, as in group 2 but over a whole window.
- [x] 5.8 Verify the float still comes first: with a hover float open, `<C-f>` scrolls the float and the cursor does not move; with none open, it moves a page.
- [x] 5.9 Verify `<C-d>` and `<C-u>` are unaffected by the refactor by re-running the group 2 checks.

## 6. Documentation

- [x] 6.1 Extend the `scrolloff` note in `README.md` — Editor conventions to cover all six keys and to state that a page is the window's whole height, with no overlapped rows. Verify the paragraph still reads correctly beside the "held at the vertical middle" one.
- [x] 6.2 Add `<C-f>`, `<C-b>`, `<PageDown>` and `<PageUp>` to the "Overrides of built-in keys" table in `README.md`, and correct the section's opening count. Verify the table renders and the count matches its rows.
- [x] 6.3 Update the `<C-f>`/`<C-b>` line in `README.md` — Messages, if it states that they page the buffer when no float is open, so it names the corrected page rather than the built-in one. Verify against what that section currently says.
