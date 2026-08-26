## Why

Typing a `"`, `(`, or `{` today produces one character; the closing one has to be typed by hand, and putting a pair around text that already exists means moving to each end and inserting separately. Both are frequent enough — quotes especially — that the manual version is a steady tax, and both are the kind of mechanical edit the configuration already delegates to a plugin elsewhere (vim-visual-multi for repeated small edits, conform for formatting).

## What Changes

- Add `windwp/nvim-autopairs`: typing an opening delimiter inserts the closing one after the cursor, backspacing over an empty pair removes both, and typing the closing delimiter where one already sits moves over it instead of doubling it.
- Add `kylechui/nvim-surround`: `ys<motion><char>` puts a pair around the text a motion covers, `S<char>` puts one around a visual selection, `ds<char>` deletes the nearest surrounding pair, and `cs<old><new>` replaces one.
- Two new plugin files under `lua/plugins/`, matching how every other capability in this configuration is declared. No change to `lua/config/keymaps.lua`.

## Capabilities

### New Capabilities

- `auto-pairs`: closing delimiters are inserted, skipped over, and deleted automatically as the user types, without the user ever typing a closing delimiter that is already there.
- `surround-edits`: delimiter pairs are added around, deleted from, and replaced on text that already exists in the buffer.

### Modified Capabilities

None. Neither plugin changes an existing capability's requirements: no mapping in `editor-keymaps` is displaced, `completion` keeps blink.cmp's default preset (which does not bind `<CR>`, the only key nvim-autopairs claims outside of the delimiter characters themselves), and `multiple-cursors` keeps its `<C-n>`/arrow/`<leader>m` set.

## Impact

- New files: `lua/plugins/nvim-autopairs.lua`, `lua/plugins/nvim-surround.lua`.
- `lazy-lock.json` gains two entries.
- Insert mode gains behaviour on every delimiter character. This is the change with real blast radius: a pairing rule that misfires is felt on every keystroke, not on a key the user chose to press.
- Normal mode: `ys`, `ds`, `cs`, `yS`, `cS` become mappings. None shadows a valid built-in — `s` is not a motion, so `ys`/`ds`/`cs` are errors in stock Neovim — but pressing `y`, `d`, or `c` alone now waits out `'timeoutlen'` before falling through to the operator.
- Visual mode: `S` is shadowed. In stock Neovim visual `S` is a synonym for linewise change, reachable as `V` then `c`, or as `R`.
- No dependency on nvim-treesitter, which this configuration does not have.
