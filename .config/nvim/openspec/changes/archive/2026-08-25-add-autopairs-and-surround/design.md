## Context

See proposal.md — Why.

Three facts about this configuration shape the approach:

- **No nvim-treesitter.** Nothing in `lazy-lock.json` provides it, so any option that asks a pairing rule to consult a syntax tree has nothing to consult and must stay off.
- **blink.cmp runs the default preset.** `lua/plugins/blink-cmp.lua` sets `keymap = { preset = "default" }`, which binds `<C-space>`, `<C-y>`, `<C-e>`, `<C-n>`, `<C-p>` — and *not* `<CR>`. `<CR>` is therefore free for pair expansion. This is the one coupling between the two plugin files and the reason the preset must not quietly become `"enter"` later.
- **Mappings live with their plugin.** `lua/config/keymaps.lua` opens by saying so, and vim-visual-multi follows it. Both new capabilities do the same, in one file each.

## Goals / Non-Goals

**Goals:**

- Defaults wherever the defaults are right, so the two files stay short and the upstream documentation stays accurate for this configuration.
- Every deviation from a default carries a comment explaining what it is protecting, matching the density of the existing plugin files.
- Each capability removable by deleting one file.

**Non-Goals:**

- Treesitter-aware pairing. Deferred until nvim-treesitter exists here; see Open Questions.
- Per-filetype pairing rules. Nothing in the current filetype set needs one; the default rule table already handles apostrophes and escaped quotes.
- Renaming nvim-surround's mappings onto a leader prefix. Its `ys`/`ds`/`cs` set is the vim-surround vocabulary that every tutorial and muscle memory assumes, and it collides with nothing valid.

## Decisions

### nvim-autopairs over mini.pairs

mini.pairs is smaller and shares an author with the already-installed mini.icons, which is a real argument. It loses on the rule engine: nvim-autopairs ships a default rule table that covers the cases the spec names — apostrophe after a word character, quote before a word character, quote after a backslash, opening bracket where the line already has an unmatched close — and exposes `Rule()` for adding more. mini.pairs expresses conditions as neighbour regex patterns per key, which covers the apostrophe case but not "an unmatched close already stands later on the line". `map_cr` and `fast_wrap` are nvim-autopairs-only and both are required by the spec.

### nvim-surround over vim-surround and mini.surround

- **vim-surround**: needs vim-repeat for dot-repeat, which is a third plugin for a behaviour the spec requires.
- **mini.surround**: uses an `s`-prefixed set (`sa`/`sd`/`sr`) that shadows the built-in `s`. Remapping it away is possible but then the keys match neither mini's documentation nor vim-surround's.
- **nvim-surround**: dot-repeat with no helper plugin, the vim-surround key vocabulary unchanged, and configurable `keymaps` if a collision ever appears.

### Two plugin files, not one

`lua/plugins/nvim-autopairs.lua` and `lua/plugins/nvim-surround.lua`. They are two capabilities with two specs and no shared configuration; one file would make the "delete the file, lose the capability" property untrue for both.

### Loading

- **nvim-autopairs: `event = "InsertEnter"`.** Its entire surface is insert mode. lazy.nvim's `InsertEnter` fires before the first character is typed, so the first keystroke of the first insert is already paired.
- **nvim-surround: `keys = { ... }`,** listing `ys`, `yss`, `yS`, `ds`, `cs`, `cS` in normal mode and `S`, `gS` in visual — the same shape as vim-visual-multi's `keys` list, and the same reasoning: a tool reached for deliberately.

  The subtlety is that `y`, `d`, and `c` are operators, so lazy.nvim's stub for `ys` makes Neovim wait after a bare `y` to see whether `s` follows. It does *not* delay `yw` or `yy` — the second key disambiguates immediately — and the wait exists identically once the plugin is loaded, because nvim-surround maps `ys` itself. So `keys` costs nothing that `event = "VeryLazy"` would avoid.

### Options

nvim-autopairs, deviating from defaults only where the spec forces it:

- `check_ts` **off** (the default). There is no treesitter to check.
- `disable_in_macro`, `disable_in_visualblock`, `disable_in_replace_mode` set **explicitly true** rather than left to their defaults. The spec requires all three, and these are exactly the settings whose upstream default has moved before; writing them down makes the file say what it means.
- `map_cr` **on** (the default), which is safe only because of the blink preset noted in Context. The comment in the file must say so, so that changing the preset to `"enter"` surfaces the conflict.
- `fast_wrap` **on** at its default `<M-e>`. `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` are the window-resize mappings; `<M-e>` is free.

nvim-surround: `opts = {}`. Every spec requirement is default behaviour — the aliases (`q` for any quote, `b` for any bracket), tag support, padded-versus-unpadded via which half of the bracket is named, dot-repeat, and single-step undo.

### Ordering against blink.cmp

Two separate mechanisms insert brackets and they do not meet. blink adds brackets when a completion item is *accepted*, by editing the buffer directly — no keystroke passes through nvim-autopairs, so nothing is doubled. nvim-autopairs acts only on a delimiter the user physically types. No integration shim is needed; the nvim-cmp one (`cmp_autopairs`) is for nvim-cmp and must not be wired up here.

## Risks / Trade-offs

- **Insert mode gains behaviour on every delimiter keystroke.** → The largest risk in the change, and unavoidable — it is the feature. Bounded by taking the upstream default rule table rather than inventing rules, and by the three `disable_in_*` settings that keep macros and block inserts literal, so a bad rule cannot silently corrupt a bulk edit.
- **A bare `y`, `d`, or `c` now waits out `'timeoutlen'`.** → Accepted. It affects only pressing an operator and stopping; every real two-key sequence resolves on the second key.
- **Visual-mode `S` is shadowed.** → Accepted, and noted in the spec. `V` then `c`, or `R`, reach the built-in.
- **`map_cr` depends on blink not binding `<CR>`.** → A comment in `nvim-autopairs.lua` naming `keymap = { preset = "default" }` in `blink-cmp.lua`, so the coupling is discoverable from the side that would break.
- **Two plugins whose behaviour overlaps conceptually.** → They do not overlap mechanically: autopairs acts on text being typed, surround on text already in the buffer. Neither maps a key the other maps.

## Migration Plan

Add the two files; lazy.nvim installs both on next start and writes `lazy-lock.json`. Nothing existing is edited, so rollback is deleting the file for whichever capability is unwanted — the other is unaffected.

## Open Questions

- If nvim-treesitter is added to this configuration later, `check_ts` becomes available and would let pairing skip strings and comments. Deferrable: turning it on changes no requirement in either spec, only how reliably the bracket rules avoid false positives.
