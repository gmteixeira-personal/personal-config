## 1. Single-line termination

- [x] 1.1 In `lua/config/keymaps.lua`, add a local helper taking a line number that places the `;` and returns the resulting cursor column, so the two mappings below place it by the same rule.
- [x] 1.2 Implement it with `vim.api.nvim_buf_get_lines` and `vim.api.nvim_buf_set_lines` rather than by feeding `<End>;`: the target column is computed, so the result does not depend on what `<End>` does with trailing whitespace or on the mode the keys are replayed in.
- [x] 1.3 Insert the `;` after the line's last non-blank character, preserving any trailing whitespace after it.
- [x] 1.4 When the last non-blank character is already `;`, insert nothing and return the column just past that existing `;`.
- [x] 1.5 Give the helper a `skip_blank` flag: off, a line holding only whitespace gets the `;` appended after its indentation; on, it is left alone.
- [x] 1.6 Bind `<M-;>` in insert mode to terminate the cursor's line with `skip_blank` off, and move the cursor to just after the `;`.

## 2. The visual-mode form

- [x] 2.1 Bind `<M-;>` in visual mode to read the selected line range with `vim.fn.line("v")` and `vim.fn.line(".")` before leaving visual mode, and terminate every line in it with `skip_blank` on.
- [x] 2.2 Leave visual mode and put the cursor just after the semicolon on the last line that was terminated.
- [x] 2.3 Give both mappings a `desc` in the style of the neighbouring mappings.

## 3. Comments

- [x] 3.1 Comment the mappings to the density of the rest of the file: why the column is computed rather than `<End>;` fed, and why the semicolon goes before trailing whitespace rather than at the raw end of the line.
- [x] 3.2 Record why the key is Alt and not Ctrl — `<C-;>` needs a terminal speaking the Kitty keyboard protocol, Windows Terminal has none, and the press arrives there as a plain `;`.
