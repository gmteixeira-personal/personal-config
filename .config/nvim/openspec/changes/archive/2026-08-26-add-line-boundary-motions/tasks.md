## 1. The step-picking function

- [x] 1.1 In `lua/config/keymaps.lua`, immediately after the `map` helper and ahead of the window-focus block, add a local function that takes the current line and cursor byte column and returns the motion to run.
- [x] 1.2 Read the line with `vim.api.nvim_get_current_line()` and the byte column with `vim.api.nvim_win_get_cursor(0)[2]`, so both sides of the comparison are byte offsets and no charwise conversion is needed.
- [x] 1.3 Find the first non-blank byte offset with a `%S` pattern match and the last non-blank byte offset with a trailing-`%s*$` match, both converted from Lua's 1-based index to the 0-based column the cursor API reports.
- [x] 1.4 For `H`: return the outer motion when the cursor column equals the first non-blank offset, and `^` otherwise.
- [x] 1.5 For `L`: return `$` when the cursor column equals the last non-blank offset, and `g_` otherwise.
- [x] 1.6 Return the outer motion directly when the line holds no non-blank character at all, so an empty or all-whitespace line collapses to one step instead of comparing against a nil offset.

## 2. The mappings

- [x] 2.1 Bind `H` and `L` with `vim.keymap.set({ "n", "x", "o" }, ...)` and `{ expr = true, desc = ... }`, called directly rather than through the `map` helper, which has no slot for options beyond `desc`.
- [x] 2.2 Return `"<Home>"`, not `"0"`, for the column-zero case, so a returned digit can never fuse with a count the user typed before the key.
- [x] 2.3 Use `x`, not `v`, in the mode list, so select mode keeps replacing the selection with a typed `H` or `L`.
- [x] 2.4 Give each mapping a `desc` in the voice of the rest of the file, naming both steps rather than only the first.
- [x] 2.5 Leave every other mapping in the file untouched, and bind nothing new for the screen-top/screen-bottom motions the change surrenders.

## 3. Comments

- [x] 3.1 Comment the block to the density of the rest of the file: why the mappings return a built-in motion rather than moving the cursor, and what that buys — operator-pending, visual block `$`, and the `curswant` that keeps a following `j` at the end of the line.
- [x] 3.2 Record that the step is chosen from the cursor column rather than a press counter, and that this is what makes the rule work identically in all three modes and after arriving by `^`.
- [x] 3.3 Note the `<Home>`-instead-of-`0` reason, the `x`-instead-of-`v` reason, and that the comparison is in bytes because that is what `nvim_win_get_cursor` reports.
- [x] 3.4 State plainly that the stock screen-top/screen-bottom motions are given up and not rehomed, so a later reader does not restore them by accident.

## 4. Verification

- [x] 4.1 Restart Neovim and confirm `H` on an indented line goes to the first non-blank, and again to column zero; `L` goes to the last non-blank, and again past trailing whitespace onto the end of the line.
- [x] 4.2 Confirm the collapsed cases: `H` on an unindented line goes straight to column zero and stays, `L` on a line with no trailing whitespace stays on the last character, and neither key moves on an empty line.
- [x] 4.3 Confirm `^` followed by `H` reaches column zero, the same as `H` followed by `H`.
- [x] 4.4 Confirm the motions: `dL` deletes charwise to the end of the line, `dH` at the first non-blank deletes the indentation, and `vH` extends the selection back to the first non-blank.
- [x] 4.5 Confirm `L` then `j` lands at the end of the shorter line, and that `<C-v>L` selects to each line's own end.
- [x] 4.6 Confirm `3H` moves to the start of the current line rather than being read as a count of thirty, and that `M`, `zt`, `zz` and `zb` still work.
