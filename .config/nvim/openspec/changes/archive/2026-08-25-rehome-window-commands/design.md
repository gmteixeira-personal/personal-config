## Context

See `proposal.md` — Why. The constraints that shape the approach:

- Neovim already has a complete window-command set under `<C-w>`, documented in `:h CTRL-W` and listed by which-key's built-in presets. Anything added here competes with a set the user may already know.
- `lua/config/keymaps.lua` owns every mapping that needs no plugin, and the four `<leader>s` mappings, the four `<C-h>`-family focus mappings, the four Alt resize mappings and the `<C-w>\` toggle all live there.
- `keymap-hints` reads `desc` off the mapping tables at the moment a sequence is pending. A mapping is listed if and only if it exists and carries a description; nothing is registered twice.
- `'timeoutlen'` is 1000. A prefix that is bound to a command of its own puts every mapping under it behind a full second, which is why no prefix in this configuration is bound.
- `editor-keymaps` already guarantees that `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>` move focus unprefixed, precisely because directional focus is the most frequent window operation there is.

## Goals / Non-Goals

**Goals:**

- One prefix for window management, carrying the operations `<C-w>` carries, on the letters `<C-w>` uses.
- The maximize toggle reachable by the same letters from either prefix.
- No second way to do anything the configuration already does well.

**Non-Goals:**

- Replacing `<C-w>`. It keeps working, including every key not mirrored here.
- A window-management plugin. This is four dozen lines of `wincmd` and one `winrestcmd()` toggle.
- Re-homing the Alt resizes or the Ctrl focus mappings. Both are unprefixed on purpose.

## Decisions

### `<leader>w`, mirroring `<C-w>`'s letters

The alternative was to keep `<leader>s` and add the missing commands under it. Rejected: `s` names "split", and the set does not split — it also closes, equalizes, rotates and exchanges. `w` is the letter the built-in prefix already uses for the subject, so `<leader>w` and `<C-w>` are the same menu reached two ways, and a user who knows one knows the other.

Mirroring the letters rather than choosing mnemonics is what makes that true. It costs one surprise — horizontal split is `s`, not `h`, and equalize is `=`, not `e` — and buys the property that `<leader>w` never has to be learned separately from `:h CTRL-W`.

### The two excluded families

The incremental resizes (`+ - < > _ |`) are excluded because they are the one window operation that is *repeated*: a resize is a held key, and `<leader>w-` cannot be held. `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` already own that, and this change fixes their direction rather than adding a second way to do it.

The moves (`H J K L`) are excluded for a different reason. Mirroring them would put uppercase `HJKL` in a menu whose lowercase `hjkl` is deliberately empty, because directional focus is unprefixed on Ctrl. A user reaching for `<leader>wl` finds nothing, and finds `<leader>wL` — which drags the window rather than moving to it. Offering the destructive half of a pair alone is worse than offering neither; `<C-w>H` is unchanged for when a move is meant.

### `e` and `\` for the maximize toggle, under both prefixes

The toggle is not a built-in, so it has no letter to mirror. `\` was the existing key and stays, because it is already in muscle memory and is unambiguously unbound under `<C-w>`. `e` is added as the reachable one — a home-row letter, and the key the hand goes to.

Both are added under `<C-w>` as well as `<leader>w`, so the mirror holds in the direction that matters: everything in the `<leader>w` menu works under `<C-w>` too. Neither letter is a built-in `<C-w>` command, so no built-in is shadowed and none is delayed waiting to see whether `e` or `\` follows.

The five keys share one `toggle_maximized` local rather than five copies of the callback, so the saved-layout table is one table. Keying it by tab page handle is unchanged.

### `=` for equalize, not `e`

`<C-w>=` equalizes, so `<leader>w=` equalizes. That leaves `e` free for the toggle, and it means the one letter where this set could have contradicted `<C-w>` does not.

### Swapping `<M-h>` and `<M-l>`

`:vertical resize +2` grows the focused window regardless of which side of the layout it sits on, so neither key is "correct" in the sense of matching a divider direction — the choice is which letter reads as "grow". Paired with `<C-h>`/`<C-l>`, which move focus in the direction of the letter, the intuition the user reports is that `h` pulls the edge toward the left window, growing it. That is the swap.

### `<leader>,` for the buffer picker

`<leader><leader>` is files; `,` is the free key next to it, and buffers are the other half of that pair. `<leader>fb` stays rather than moving, so the picker is still listed under Find with its siblings — the same relationship `<leader><leader>` has with `<leader>fg` and the rest.

## Risks / Trade-offs

- **Muscle memory breaks for `<leader>s`.** Accepted and deliberate: leaving it as an alias would keep two prefixes for one subject, which is what the change exists to remove. The mapping from old to new is in `proposal.md`.
- **`<leader>ws` splits horizontally where `<leader>sh` did.** This is the one letter that moves rather than disappearing, and the one place where following `<C-w>` costs rather than helps. Following it anyway keeps the rule ("`<leader>w` is `<C-w>`") true without exception, which is worth more than one letter.
- **`<leader>w` is now a prefix with fifteen mappings under it.** The hint popup lists them; without `keymap-hints` installed, this set would be harder to justify than the four it replaces.
