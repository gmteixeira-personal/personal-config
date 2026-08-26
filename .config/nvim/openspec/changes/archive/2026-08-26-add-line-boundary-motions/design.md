## Context

See proposal.md — Why. The constraints that shape the approach are in `lua/config/keymaps.lua`: it is plugin-free general mappings, it defines a four-argument `map(mode, lhs, rhs, desc)` helper with no slot for options, and it drops to `vim.keymap.set` directly wherever an option beyond `desc` is needed (the `<Space>` nop already does this for `silent`).

The behaviour asked for is a motion, and motions in Vim are not simply "put the cursor here". A motion is consumed by an operator (`dL`), extends a visual selection (`vH`), takes a count, and can carry state of its own — `$` sets `curswant` to the maximum so a following `j` stays at the end of each line, and in visual block mode it means "to the end of each line" rather than a fixed column. Any implementation that moves the cursor itself throws all of that away.

## Goals / Non-Goals

**Goals:**

- One rule, evaluated once per press, that picks between four built-in motions — `^`, `0`, `g_`, `$`.
- The three bound modes behave identically, with no mode-specific branch.
- The built-in motions do the actual work, so everything they carry is preserved for free.

**Non-Goals:**

- Screen-line variants. `g^`/`g$` stay as they are; the mapping is buffer-line only.
- Rehoming the displaced screen motions. Decided in the proposal: they are surrendered.
- Making `H`/`L` jump commands. The stock `H`/`M`/`L` set the jumplist, so `''` returns from them; `^` and `$` do not, and the replacements will not either.

## Decisions

### Expression mappings that return a built-in motion, not a function that moves the cursor

`vim.keymap.set({ "n", "x", "o" }, "H", fn, { expr = true, desc = ... })`, where `fn` returns one of `"^"`, `"<Home>"`, `"g_"` or `"$"` as a string. The returned keys are then executed by Vim as if typed.

Alternative considered and rejected: a plain (non-`expr`) function that computes the target column and calls `nvim_win_set_cursor`. It fails on every count above: operator-pending mode never even reaches it usefully, `dL` becomes a cursor move with no deletion, visual-block `$` loses its ragged right edge, and `curswant` is left at the literal column so `L` then `j` no longer tracks the end of the line. Returning the built-in is both smaller and strictly more faithful.

### The step is chosen from the cursor column, not from a press counter

The function reads the current line and the cursor's byte column, and compares:

- `H`: if the column equals the byte offset of the first non-blank character, return the outer motion; otherwise return `^`.
- `L`: if the column equals the byte offset of the last non-blank character, return `$`; otherwise return `g_`.

Alternative considered and rejected: remembering the last press (key, buffer, line, timestamp) and toggling on a repeat. It needs invalidation on every buffer switch, window switch and edit; it cannot work in operator-pending mode, where there is no "again"; and it makes `^` then `H` behave differently from `H` then `H` for no reason the user could predict. Reading the column has none of those problems and is one line of Lua.

The comparison is done in **bytes**, because `nvim_win_get_cursor` reports a byte column and Lua patterns index bytes. No conversion to character positions is needed, and multibyte indentation or content cannot desynchronise the two sides of the comparison.

### `<Home>` rather than `0` for the column-zero case

`0` is a digit. A returned `0` risks fusing with a count the user typed before the key — `3H` would offer Vim a `3` and a `0` in sequence, which is a count of thirty and no motion. `<Home>` is the same exclusive motion to column one and cannot be read as part of a count. The other three returns are unaffected, being non-digits.

### Lines with no non-blank character collapse to one step

On an empty or all-whitespace line, "first non-blank" and "last non-blank" do not exist. The pattern match returns nothing, and the function returns the outer motion directly: `H` gives `<Home>`, `L` gives `$`. On an empty line both are already where the cursor is, so nothing moves — which is what the spec requires — and on an all-whitespace line the two keys reach the two real ends of it in one press each.

### Bound in `n`, `x`, `o` — not `v`

`v` in a mode list means visual *and select*. Select mode replaces the selection with any printable character typed, which is how snippet placeholders are overwritten, so binding `H` there would insert nothing and jump instead. `x` is visual alone. `o` is what makes `dL` and `cH` work.

### Placement in the file

Immediately after the `map` helper, ahead of the window-focus block. The file currently runs windows → buffers → session, an ordering from smaller scope outward; motion inside one line is smaller than all of them, so it goes first. `vim.keymap.set` is called directly rather than through `map`, since `expr` has no slot in the helper — the same reason the `<Space>` nop above it does.

## Risks / Trade-offs

- **The screen motions are gone with no error to say so.** → Accepted, and recorded in the proposal and the spec. `M` still works, and `zt`/`zz`/`zb` cover positioning the view. Nothing can warn about a key that now does something else.
- **`H` and `L` no longer set the jumplist.** → Accepted. `''` after an `H` will return to wherever the previous real jump was, not to the pre-`H` position. `^`/`$` have always behaved this way, and the motions are now within one line, where a jumplist entry has little to return to.
- **`.` after a `dL` re-evaluates the rule at the new cursor position.** → Accepted, and arguably right: the repeat means "delete to the end of this line too", and the landing place is recomputed for the line the cursor is now on. It does mean a repeat is not guaranteed to delete the same shape of text.
- **A count now means something different on both keys.** → Documented in the proposal rather than suppressed. `3L` reaching two lines down is the built-in `$`'s own behaviour, not an accident of the mapping.
- **`expr = true` mappings must not have side effects.** Vim evaluates them in a restricted context and may evaluate at unexpected times. → The function only reads the current line and cursor and returns a string; it never sets an option, moves the cursor, or writes to the buffer.
