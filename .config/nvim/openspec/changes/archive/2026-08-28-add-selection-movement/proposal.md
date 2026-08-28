## Why

Moving a line or a block of lines up and down is one of the most common structural edits there is -- reordering the fields of a table, lifting a guard clause above the work it guards, sinking a helper below its caller. The configuration currently answers it with `dd` followed by `p`, or with `:m` typed out in full. Both work, and both are wrong for the case: `dd`/`p` clobbers the unnamed register and needs the cursor moved to the destination first, and `:m` needs the destination expressed as a line number or an offset, which is exactly the arithmetic the user was hoping to avoid by moving the block one step at a time and looking at it.

The conventional keys for this -- `<M-j>` and `<M-k>` -- are already spoken for here, by the window-resize block in `lua/config/keymaps.lua`. But that block is normal mode only, and this edit is one the user is already in visual mode for: the block has to be selected before it can be moved. The two never meet, so the same four keys can carry both meanings, separated by mode.

## What Changes

- Install [mini.move](https://github.com/echasnovski/mini.move) as the selection-movement implementation, as a new file `lua/plugins/mini-move.lua`.
- Map its four visual-mode moves onto `<M-h>` left, `<M-j>` down, `<M-k>` up, `<M-l>` right. These are the same four keys, in the same four directions, as the window-resize block one mode over: in normal mode Alt moves the window edge, in visual mode it moves the text.
- Disable mini.move's four normal-mode `line_*` mappings outright. They default to the same Alt keys, and the plugin's `setup()` runs long after `lua/config/keymaps.lua`, so left at their defaults they would silently take the resize mappings over. Normal-mode `<M-h/j/k/l>` stay window resize.
- Keep upstream's `reindent_linewise`, so a block moved across a brace lands at the indent of where it arrives rather than carrying its old one.
- Load the plugin on those keys, the way telescope, conform and vim-visual-multi are loaded: this is a tool reached for deliberately, not one that needs to exist before it is asked for.

A plugin rather than a pair of hand-written `:m '>+1<CR>gv=gv` mappings, because the hand-written version only covers the linewise half of the problem. mini.move moves a charwise or blockwise selection as selected instead of promoting it to whole lines, it moves sideways as well as up and down, it takes a count, and it does the reindent itself.

Nothing else claims `<M-h/j/k/l>` in visual mode: vim-visual-multi is on `<C-n>`, `<C-Down>`/`<C-Up>` and `<S-Left>`/`<S-Right>`; flash is on `s`, `S`, `f`, `F`, `t`, `T` and `R`; nvim-surround shadows visual `S`; and the config's own visual mappings are `<`, `>`, `<M-;>` and `<C-s>`.

## Capabilities

### New Capabilities

- `selection-movement`: moving the selected text up, down, left and right as a unit, with the surrounding lines closing behind it and the selection surviving the move so it can be repeated.

### Modified Capabilities

None. `editor-keymaps` describes the window-resize mappings this sits beside, but none of its requirements change: those mappings keep normal mode and keep their current behaviour.

## Impact

- `lua/plugins/mini-move.lua` -- new file, the whole of the change.
- `lazy-lock.json` -- gains a pinned commit for mini.move, as every plugin here has.
- `lua/config/keymaps.lua` -- unchanged. The resize block at lines 87-90 keeps `<M-h/j/k/l>` in normal mode; this change is what has to bend around it, not the other way round.
- `openspec/specs/selection-movement/spec.md` -- created once this change is archived.
- No new dependency beyond the plugin itself: mini.move is a standalone module of the mini.nvim collection, the same way `mini.icons` is already installed here, and needs nothing else.
