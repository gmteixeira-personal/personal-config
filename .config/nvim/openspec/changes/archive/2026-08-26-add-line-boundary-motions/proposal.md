## Why

Getting to the ends of a line costs an awkward key. `^` and `$` are both reached across the keyboard with a modifier, `0` is off the home row entirely, and `g_` is a two-key sequence almost nobody remembers exists — yet moving to the start or end of the line is one of the most frequent motions there is. `H` and `L` sit under the resting index fingers, one Shift away from the `h`/`l` that already mean left and right, and their stock meanings (top and bottom of the *visible screen*) are motions this user does not make: `zt`/`zz`/`zb`, the fuzzy finder, and flash's jumps all cover that ground better, and `M` is left in place for the rare case.

## What Changes

- **BREAKING**: `H` and `L` no longer move to the top and bottom of the visible screen. That motion is not rehomed anywhere — it is given up. `M` (middle of screen) is untouched, as are `zt`/`zz`/`zb`.
- `H` moves to the start of the line, in two steps outward: to the first non-blank character, and — when the cursor is already there — to column zero.
- `L` moves to the end of the line, in the same two steps outward: to the last non-blank character, and — when the cursor is already there — to the true end of line, past any trailing whitespace.
- The step is chosen from **where the cursor is**, not from how many times the key was pressed. No press is counted and no state is stored, so the second step is reached by a repeat press, by a `^` followed by `H`, or by arriving at the first non-blank any other way — all identically.
- Both keys are bound in normal, visual and operator-pending mode, so `dL` deletes to the end of the line and `vH` selects back to the first non-blank. Select mode is deliberately excluded, where a printable key must still replace the selection.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `editor-keymaps`: one new requirement fixing `H` and `L` as the line-boundary motions, the two-step outward rule that selects between the four underlying motions, and the modes the bindings cover. The existing spec covers window focus, resizing, buffer commands, saving and quitting, and says nothing about cursor motion within a line; this adds that, and records that the stock screen-top/screen-bottom motions are surrendered rather than moved.

## Impact

- Modified file: `lua/config/keymaps.lua` — two `map` calls and the small function that picks the step. No new plugin, no lockfile change.
- **The screen-top/screen-bottom motions are gone from the keyboard.** Anything built on `H`/`L` as *screen* motions — `dH` to delete up to the top of the window, a `H`-then-`L` scan of the visible page — stops working, silently and with no error. This is the one thing that will be missed if it is missed at all.
- A count now means something different on both keys. `3H` used to mean "three lines below the top of the screen"; the underlying `^`/`0` ignore a count, so it becomes a plain `H`. `3L` used to mean "three lines above the bottom of the screen"; `$`/`g_` do take a count, so it moves two lines down and then to that line's end. Neither is an error and neither is worth suppressing, but neither is what the key did before.
- Only the buffer line is addressed, never the screen line. On a wrapped line `H` and `L` go to the ends of the whole line, not of the visual row; `g^`/`g$` remain the way to reach the row's ends and are not rebound.
- No plugin mapping is displaced: nothing in `lua/plugins/` binds `H` or `L` in any mode. flash's `s`/`S`, vim-visual-multi's `<C-n>` and the surround and autopair keys are all untouched.
- `L` returning `$` keeps the built-in's "stay at end of line" behaviour for a following `j`/`k`, and keeps visual-block `$`'s ragged-right selection, because the built-in motion itself is what runs.
