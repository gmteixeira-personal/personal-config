## Why

Moving to a spot that is visible on screen but not near the cursor currently costs a search, a count, or a sequence of `f`/`t` presses followed by `;` repeats — the position is already in the user's eye, but not in reach of one deliberate keystroke. The same problem shows up a second time inside operators: yanking or deleting a word elsewhere on screen means jumping there, operating, and jumping back, which loses the original cursor position and pollutes the jumplist.

## What Changes

- Add `folke/flash.nvim` as a plugin file under `lua/plugins/`, loaded lazily on its keys.
- **Label-based jump on `s`** in normal, visual, and operator-pending mode: type a few characters, then press the label shown beside the match to land on it. **BREAKING** for stock normal-mode `s` (substitute character), which remains reachable as `cl`.
- **Remote operator action on `r`** in operator-pending mode: `yr`, `dr`, `cr` and friends run the label jump, apply the operator at the chosen location, and return the cursor to where the operator started.
- **Tree-sitter node selection on `S`** in normal and operator-pending mode, growing and shrinking the selection through the syntax tree. Visual-mode `S` is deliberately **not** claimed — it stays with `nvim-surround`, which already shadows it by design.
- **Tree-sitter search on `R`** in operator-pending and visual mode: search-then-label, with the match expanded to the enclosing tree-sitter node.
- **Enhanced `f`, `t`, `F`, `T`**: the repeat of a character motion continues in the same direction without `;`/`,`, and `;`/`,` keep working across all of them.
- **Labelled `/` and `?`**: an in-progress search shows a label beside each visible match, and pressing one jumps straight there. `<C-s>` toggles the labels off inside the command line for a search where they get in the way.
- Tree-sitter modes use the tree-sitter runtime bundled with Neovim 0.12. `nvim-treesitter` is **not** added as a dependency, so the tree-sitter modes work for the languages whose parsers the runtime provides and degrade with a clear message elsewhere.

## Capabilities

### New Capabilities
- `jump-motions`: label-based jumping to any position on screen, the remote operator action, tree-sitter node selection and search, the enhanced character motions, and the labelled incremental search.

### Modified Capabilities
- `surround-edits`: the "commands do not displace an existing mapping" requirement currently states that bare `s` in normal mode keeps its stock substitute meaning. Jump motions claim that key, so the requirement's scope narrows to what the surround capability itself must not take, and the surviving-substitute scenario is replaced.

## Impact

- New file `lua/plugins/flash.lua`. No other plugin file or `lua/config/` module changes.
- `lazy-lock.json` gains a pinned entry for `flash.nvim`.
- Normal-mode `s` and `S`, and operator-pending `r` and `R`, change meaning. `<leader>wr` / `<leader>wR` (window rotation, normal mode) and visual-mode `S` (surround) are untouched, as are `<C-s>` in normal, insert and visual mode.
- No dependency on `nvim-treesitter`; the tree-sitter modes read the parsers Neovim 0.12 ships.
