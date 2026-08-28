## Context

See proposal.md -- Why. The constraint that shapes everything below is a key collision that is not really a collision.

`lua/config/keymaps.lua:87-90` already owns `<M-h>`, `<M-j>`, `<M-k>` and `<M-l>`, as the window-resize block. Every one of those four is `map("n", ...)`: normal mode, and nothing else. Visual mode has all four free, and the file's own visual mappings -- `<`, `>` at lines 182-183, `<M-;>` at line 256, `<C-s>` at line 266 -- do not touch them. Neither does any plugin: vim-visual-multi declares `<C-n>`, `<C-Down>`, `<C-Up>`, `<S-Right>` and `<S-Left>`; flash takes `s`, `S`, `f`, `F`, `t`, `T` and `R`; nvim-surround shadows visual `S`.

So the four keys are available in exactly the mode this change needs, and the design is mostly about keeping it that way.

## Goals / Non-Goals

**Goals:**

- The four visual-mode moves on the four Alt keys, in the directions the resize block already assigns to those letters.
- The resize mappings observably unchanged -- not merely re-established afterwards, but never overwritten in the first place.
- Loading that costs nothing until one of the keys is pressed, as telescope, conform and vim-visual-multi already do.

**Non-Goals:**

- Normal-mode line movement. mini.move offers it and this change deliberately declines it: `<M-h/j/k/l>` mean "resize" in normal mode here, and a second meaning on the same keys in the same mode is not available. A selection has to exist before it can be moved, so the user is already in visual mode when the need arises.
- Re-siting the resize block onto other keys to make room. It is older, it is documented in its own comment block, and it is not what this change is about.
- Any of the rest of mini.nvim. `mini.move` is installed as a standalone module, the way `mini.icons` already is.

## Decisions

### mini.move rather than hand-written `:m` mappings

The four-line version of this feature is well known:

```lua
map("v", "<M-j>", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "<M-k>", ":m '<-2<CR>gv=gv", "Move selection up")
```

It was the first shape considered, and it covers about half of what the spec asks for. `:m` is linewise, so a charwise or blockwise selection is silently promoted to whole lines; there is no horizontal move at all, because `:m` has no sideways equivalent; a count in front of `<M-j>` does not do what a user expects; and `gv=gv` reindents unconditionally, including on the moves where the reindent is wrong.

mini.move handles all four: it distinguishes the selection modes, it moves left and right, `v:count` is respected, and `reindent_linewise` scopes the reindent to the case that wants it. That is roughly 150 lines of edge-case handling per direction that this config would otherwise own and maintain. A plugin is cheaper.

Alternatives considered: **vim-unimpaired**, whose `[e`/`]e` moves lines but is normal-mode-oriented and drags in a large mapping surface for one feature; **mini.nvim as a whole**, rejected for the same reason `mini.icons` is installed standalone -- the collection's other modules duplicate plugins this config already made a decision about.

### The `line_*` mappings are disabled explicitly, not left to chance

mini.move's defaults put its normal-mode moves on `<M-h/j/k/l>` -- the same four keys as the resize block. The plugin installs its mappings inside `setup()`, which lazy.nvim runs when the plugin loads, which is long after `lua/config/keymaps.lua` has run during startup. Last writer wins, so the defaults would take the resize mappings over, and would do it silently: no error, no warning, just `<M-j>` quietly resizing nothing.

So all four `line_left`, `line_down`, `line_up`, `line_right` are set to `""`, which is how mini.move disables a mapping.

This is the same load-order trap `lua/config/keymaps.lua:82` already documents for the `<C-Up>`/`<C-Down>` arrows and vim-visual-multi, and it is worth stating in the file's comment so the next reader does not "tidy up" the empty strings.

Alternative considered: re-asserting the resize mappings after mini.move loads, via its `config` function. Rejected -- it fixes the symptom by fighting the plugin every time it loads, where the empty strings stop the collision from happening.

### Loaded on `keys`, with the descriptions carried there

`keys` rather than `event = "VeryLazy"`, matching telescope, conform and vim-visual-multi: this is a tool reached for deliberately.

One wrinkle worth writing down: mini.move installs its own mappings in `setup()`, so the `keys` entries are not the mappings. They exist to trigger the load and to give which-key a description. Their `mode = "v"` and their left-hand sides therefore have to agree with the `mappings` table by hand -- there is no mechanism keeping the two in step. vim-visual-multi's spec has the same shape and the same caveat.

### Directions follow the resize block, not upstream

They happen to agree -- upstream also uses h/j/k/l for left/down/up/right -- but the reason to write them out rather than take the defaults is that the resize block is the local precedent, and its comment already explains the h/j/k/l direction mapping at length. Anyone reading `mini-move.lua` should be able to see that the two agree without going to look up what upstream's default was.

## Risks / Trade-offs

- **The empty strings look like a mistake and get "fixed"** → the comment in the file says what breaks if they are removed, and names the resize block by file and line.
- **`keys` and `mappings` drift apart** → the two lists sit adjacent in a short file; a mistyped `keys` entry fails loudly (the key does nothing until the plugin has been loaded some other way) rather than silently.
- **`reindent_linewise` fights a bad `indentexpr`** → the reindent is the plugin's default and the behaviour the spec asks for; in a filetype whose indent rules are wrong, `u` undoes the whole move, reindent included. Not worth a per-filetype exception until one is actually hit.
- **`<M-...>` in a terminal** → the config already depends on Alt reaching Neovim for the resize block and for `<M-;>`, so this adds no new requirement. If Alt is unavailable in some terminal, the resize mappings have already stopped working there.
