## Why

Window management is spread across three prefixes that do not agree with each other. Neovim's own window commands live under `<C-w>`. This configuration adds four of them again under `<leader>s` — `sv`, `sh`, `sc`, `se` — so splitting has two keys, and `<C-w>` keeps twenty commands the `<leader>` menu never mentions: exchange, rotate, the tab move, the non-directional focus jumps. The maximize toggle sits on a third key again, `<C-w>\`, reachable only from the prefix the menu does not describe.

`<leader>s` is also the wrong letter. It was chosen for "split", but the set is not about splitting — it closes windows and equalizes them too — and `s` is the letter a reader looks for when the subject is a window and the menu says "Split & window".

Separately, `<M-h>` and `<M-l>` resize the wrong way round. `<M-l>` widens the focused window, which reads as "push the divider left" to the hand that just used `<C-l>` to move focus right; the two keys point in opposite directions for the same letter.

And the buffer picker is three keys, `<leader>fb`, while the file picker is two, `<leader><leader>`. Switching buffers is at least as frequent as opening a file.

## What Changes

- Move window management to `<leader>w`, mirroring `<C-w>`'s own letters: `s`/`v` split, `n` new, `c`/`q` close, `o` only, `w`/`W`/`p`/`t`/`b` focus, `x` exchange, `r`/`R` rotate, `=` equalize, `T` move to a new tab.
- Add the maximize toggle to that set as `<leader>we` and `<leader>w\`, and add `<C-w>e` beside the existing `<C-w>\`, so the two prefixes reach the same toggle by the same two letters.
- **BREAKING**: remove the `<leader>s` mappings — `<leader>sv`, `<leader>sh`, `<leader>sc`, `<leader>se`. Every one of them is now under `<leader>w`, on the letter `<C-w>` uses. `<leader>s` is left free.
- Leave the incremental resizes (`<C-w>` `+ - < > _ |`) and the window moves (`<C-w>H`, `J`, `K`, `L`) to `<C-w>` alone. The Alt set already resizes with key repeat, which a `<leader>` sequence cannot do; and directional focus is unprefixed on Ctrl, so a `<leader>w` set with uppercase `HJKL` and no lowercase pair would offer only the destructive half.
- Do not give `<leader>w` lowercase `h`/`j`/`k`/`l`. `<C-h>` and friends exist precisely because directional focus is too frequent to prefix.
- Swap `<M-h>` and `<M-l>`: `<M-h>` widens the focused window, `<M-l>` narrows it.
- Add `<leader>,` for the buffer picker, beside `<leader><leader>` for files. `<leader>fb` stays.
- Rename the which-key group from "Split & window" on `<leader>s` to "Window" on `<leader>w`.

## Capabilities

### Modified Capabilities

- `editor-keymaps`: the `<leader>s` split requirement is replaced by a `<leader>w` window-command requirement covering the whole mirrored set; the maximize requirement grows a second key under each of the two prefixes; the resize requirement swaps which of `<M-h>` and `<M-l>` grows the window.
- `fuzzy-finder`: the buffer picker gains `<leader>,` alongside `<leader>fb`.
- `keymap-hints`: the named group list drops "split and window" on `<leader>s` and gains "window" on `<leader>w`.

## Impact

- `lua/config/keymaps.lua`: the four `<leader>s` mappings are deleted; the `<leader>w` set is added; the `<C-w>\` callback is lifted into a named local so five keys can share it; `<M-h>` and `<M-l>` swap right-hand sides.
- `lua/plugins/telescope.lua`: one `keys` entry added for `<leader>,`.
- `lua/plugins/which-key.lua`: one group entry renamed.
- No plugin is added or removed; `lazy-lock.json` is untouched.
- Muscle memory for `<leader>sv`/`<leader>sh`/`<leader>sc`/`<leader>se` breaks. The replacements are `<leader>wv`, `<leader>ws`, `<leader>wc`, `<leader>w=` — note that horizontal split moves from `h` to `s`, following `<C-w>s`, and equalize from `e` to `=`, following `<C-w>=`, because `e` is the maximize toggle here.
