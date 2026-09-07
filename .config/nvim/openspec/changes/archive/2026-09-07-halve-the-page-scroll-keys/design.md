## Context

See proposal.md — Why for the defect. The measurement behind it, taken with this configuration in a 23-row window where `'scroll'` is 11:

| start line | `<C-d>` lands on | cursor moved | `<C-u>` lands on | cursor moved |
| --- | --- | --- | --- | --- |
| 1 | 23 | +22 | 1 | 0 |
| 12 | 23 | +11 | 1 | −11 |
| 100 | 111 | +11 | 89 | −11 |
| 500 (last) | 500 | 0 | 478 | −22 |

`<C-f>` shows the same shape in a 38-row window, where a page is 36: from line 1 the cursor moves +54, from the middle +36. `<PageDown>` is the same command.

The doubling is confined to the screenful at each end, and it is the arithmetic of the built-in meeting `scrolloff = 999`: `<C-d>` advances the topline by `'scroll'` and the cursor by `'scroll'`, and then the centring correction moves the cursor to the middle row. Away from the ends the correction is a no-op, because the cursor was already centred and both moved by the same amount. Within the first screenful the topline cannot advance the full `'scroll'` — it is clamped at 1 — so the cursor absorbs the remainder and travels a whole window. `<C-u>` is the same statement at the other end.

Nothing in the configuration binds `<C-d>` or `<C-u>` in normal or visual mode today. `lua/plugins/telescope.lua` binds `<C-d>` in the buffer picker's prompt and `lua/plugins/noice.lua` binds `<C-f>`/`<C-b>`; neither is in the way.

## Goals / Non-Goals

**Goals:**

- The cursor moves a fixed distance per press — half a window on `<C-d>`/`<C-u>`, a whole one on `<C-f>`/`<C-b>`/`<PageDown>`/`<PageUp>` — at both ends of the buffer as well as in the middle.
- Each key is the exact mirror of its opposite, so a press and its reverse cancel.
- The keys stay usable as they are today: from visual mode, with a count, and with the view following as centring already makes it.

**Non-Goals:**

- Changing `scrolloff`, the centring requirement, or anything about where the cursor sits.
- Animating or smoothing the scroll. `smear-cursor` already animates the cursor and is untouched.
- Taking `<C-f>`/`<C-b>` away from noice's float scroll, or touching `<C-d>` in a Telescope prompt.

## Decisions

### A function that executes a real motion, not an expression mapping and not a cursor API call

The mapping runs `:normal! <n>gj` from a Lua function. What matters is that a genuine motion is executed: `curswant` is set by it, so half a page down and back up lands in the column it started in rather than in the column of some short line in between, and in visual mode the selection extends. `nvim_win_set_cursor` gives up both.

Alternative considered and rejected: an expression mapping returning the motion as a string, the way `H` and `L` are written. It cannot take a count. A count typed before an expression mapping is not consumed by it — the digits stay pending and are prepended to whatever the mapping returns, which is the same fusing the `H`/`L` comment already records. Returning `22gj` for `2<C-d>` executes `222gj`: measured, that moved the cursor from line 100 to line 322. Nothing can be returned that both carries a count and swallows the pending one.

The cost of a function is that the keys cannot be operator-pending motions. They are not motions in stock Neovim either, so nothing is lost.

Alternative also considered: run the built-in `<C-d>` and then correct the cursor afterwards. It is two moves where one will do, and it makes the intermediate over-travel visible to anything watching the cursor, `smear-cursor` included.

### Screen rows (`gj`/`gk`), not buffer lines (`j`/`k`)

`wrap` is on for every buffer in this configuration, so the two differ constantly. Half a *page* is a screen measurement, and the built-in `<C-d>` this replaces is already screen-based when `wrap` is set — measured here, from line 1 of a file of mixed long and short lines it advanced 16 buffer lines, not 22. Using `j` would keep the fix but change a second thing at the same time: in a buffer of long prose lines a press would scroll several screens.

The cost is that `<C-d>` can land part-way down a wrapped line, on a screen row rather than at the start of a buffer line — which is what `gj` means, and what the built-in already did.

### Half a window comes from `'scroll'`

Neovim maintains `'scroll'` at half the window height and re-derives it whenever the window is resized, so reading it costs nothing and keeps the mapping correct across splits and resizes without an autocommand. It also honours a `'scroll'` the user has set deliberately. `v:count1` multiplies it, so `3<C-d>` moves three half-windows. A function mapping reads the count instead of leaving it pending, which is the second reason the mapping is not an expression one.

This drops one built-in behaviour: `{count}<C-d>` sets `'scroll'` to the count for later presses. It is obscure, it is a hidden mode change, and `:set scroll=` remains for anyone who wants it.

### Clamping is explicit, because a counted motion fails rather than stops

`11gj` on the last line does nothing at all — a counted motion past the end of the buffer aborts, where `<C-d>` clamps. The mapping therefore measures the screen rows that remain on the wanted side with `nvim_win_text_height`, which reports the rendered height of a line range including wrapping, and runs `G` or `gg` instead when a whole half-window will not fit. Landing on the last or first line is what the built-in does at the ends, so the clamp is not a new behaviour.

`nvim_win_text_height` is a Neovim 0.10 API and this configuration runs 0.12.

### Normal and visual mode only

`<C-d>` and `<C-u>` are not operator-pending motions in stock Neovim — `d<C-d>` is not a thing — and making them into ones is a separate change nobody asked for.

### A page is the window's height, not `height - 2`

Vim moves `height - 2` lines and leaves two rows of the previous screen on the new one, so a reader can find the place the text jumped from. Under `scrolloff = 999` the cursor is the landmark — it is on the middle row before the press and on the middle row after it — and the two rows are then a pure tax of two lines a press. A page becomes the whole window: 39 rows move 39 lines.

This is the one place the change is not merely a repair, and it is the user's explicit call.

### One helper, two distances

`<C-d>` and `<C-f>` differ only in how many rows they ask for, so the clamping, the direction, and the `normal!` invocation are written once and the distance is passed in: `vim.o.scroll` for half a window, `nvim_win_get_height` for a whole one. `nvim_win_get_height` rather than `vim.o.lines`, which counts the statusline and the command line and belongs to the screen rather than to the window.

### `<PageDown>`/`<PageUp>` own the behaviour and `<C-f>`/`<C-b>` delegate to them

`config-structure` puts a mapping that would still make sense with every plugin removed in `lua/config/keymaps.lua`, and a page scroll is exactly that, so the helper and the two named keys live there. `<C-f>` and `<C-b>` cannot: `lua/plugins/noice.lua` binds them so a hover or signature float scrolls first, lazy.nvim evaluates that spec after `config.keymaps` has run, and a mapping written in `keymaps.lua` would be silently replaced — the same load-order trap the `<M-k>`/`<M-j>` comment already records for the arrow keys.

So noice keeps the two chords and its fallback branch, which today returns the key itself for the built-in page scroll, returns `<PageDown>`/`<PageUp>` instead with `remap = true`, re-entering the general mapping. One implementation, and noice's spec is left owning only the float scroll.

The count survives the hop. An expression mapping leaves a typed count pending, and here that is exactly what is wanted: it is prepended to the returned key and read by the general mapping, which is a function. Measured with the real mapping: `2<C-f>` moved +46 in a 23-row window.

Visual mode is the exception: noice declares `<C-f>`/`<C-b>` in `n`, `i` and `s` only, so `x` was left on the built-in page scroll. It is bound in `keymaps.lua` alongside the named keys rather than by widening noice's mode list — a float cannot be open with a selection active, so noice has nothing to do there, and lazy.nvim replaces only the modes noice declares.

Alternative considered: export the helper from `config.keymaps` and call it from `noice.lua`. It makes a plugin spec depend on a config module, which nothing in this configuration does, to avoid a one-key indirection that is already how the fallback branch is written.

## Risks / Trade-offs

- **`normal!` ignores anything later mapped to `gj`/`gk`.** → Nothing in the configuration maps them today, and the bang is what keeps the pair from depending on a mapping a plugin might install. A mapped `gj` that mattered would have to be reflected here by hand.
- **A page no longer overlaps, so nothing on screen before a press is on screen after it.** → Deliberate, and the reason it is safe here is that the cursor does not move on screen: it is on the middle row before and after. On a buffer read rather than edited this is the whole point of the change.
- **`<C-f>` is declared in two files — `n`/`i`/`s` in `noice.lua`, `x` in `keymaps.lua`.** → Both carry a comment naming the other. The alternative puts a plugin-free mapping in a plugin spec, which `config-structure` forbids.
- **`<C-f>` depends on noice being installed to reach the general mapping.** → With noice removed the chord falls back to Neovim's built-in page scroll, overlap and doubling included, while `<PageDown>` keeps the corrected behaviour. Acceptable: `config-structure` already accepts that a plugin owns the keys it maps, and the named keys are the ones the general module is allowed to hold.
- **The keys stop being scroll commands and become motions.** → Visible in one place: `<C-d>` no longer moves the view without moving the cursor. Under `scrolloff = 999` it never did — the cursor was dragged along regardless.
- **`gj` can leave the cursor mid-line on a wrapped line.** → Accepted, and unchanged from the built-in. `H` still reaches the start of the buffer line.

## Migration Plan

Not applicable — two mappings added to a tracked file, removed by deleting them.
