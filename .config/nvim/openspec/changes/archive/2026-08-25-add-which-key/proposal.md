## Why

This configuration now defines mappings under eight `<leader>` prefixes — `b`, `c`, `f`, `g`, `h`, `m`, `r`, `s` — spread across `lua/config/keymaps.lua` and seven plugin files, two of them buffer-local and therefore invisible outside a git repository or an attached language server. Every mapping already carries a `desc`, and nothing reads it: recalling what lives under `<leader>g` means opening `lua/plugins/telescope.lua`, and remembering that `<leader>h` exists at all means knowing gitsigns is installed. `'timeoutlen'` is 1000, so a half-remembered prefix is a full second of staring at an editor that gives no hint about what it is waiting for.

which-key turns that second into the answer: press a prefix, and the mappings under it are listed with the descriptions this configuration has been writing all along.

## What Changes

- Add `folke/which-key.nvim` in a new `lua/plugins/which-key.lua`, loading on `VeryLazy`. Holding a mapped prefix pops up the keys that continue it, each with its description.
- Use the **modern** preset: a bordered floating window at the bottom of the screen, with padding and per-mapping icons. This is the layout decision the change is built around; `classic` and `helix` are not used.
- Name the eight `<leader>` groups so the popup reads as a menu rather than as eight bare letters — Buffer, Code, Find, Git, Hunk, Multi-cursor, Rename & restart, Split & window.
- Add `<leader>?`, which lists the mappings local to the current buffer. This is the only way the gitsigns `<leader>h` set and the LSP mappings become discoverable as buffer-local, rather than being mixed into the global list.
- **BREAKING** (for the specs, not for the user): `<leader>s` and every other prefix stop being strictly unbound. which-key attaches a hint trigger to each prefix it knows. No command runs on a prefix press and completing the sequence is not slowed, but the `editor-keymaps` requirement that the prefix is bound to nothing at all no longer holds literally.
- Nothing else is touched: no existing mapping is redefined, moved, or renamed, and no `desc` is rewritten.

## Capabilities

### New Capabilities

- `keymap-hints`: what the user sees while a key sequence is pending — which mappings are listed, where the descriptions come from, how prefixes are grouped and named, how buffer-local mappings are reached, and the guarantee that the hints never change what a completed sequence does.

### Modified Capabilities

- `editor-keymaps`: one requirement changes. "Windows are split and closed under a `<leader>s` prefix" currently states that `<leader>s` SHALL NOT itself be bound as a mapping, with a scenario asserting that pressing it defers no action pending a timeout. which-key binds each prefix to a hint trigger, so the requirement is rewritten to guarantee what the original was protecting — no command runs on the prefix, and the next key of the sequence resolves without waiting — rather than the mechanism it happened to use.

## Impact

- New file: `lua/plugins/which-key.lua` — the plugin spec, `preset = "modern"`, the group spec for the eight prefixes, and the `<leader>?` mapping.
- `lazy-lock.json` gains one entry.
- Every prefix in the configuration gains a popup, including the non-`<leader>` ones: `<C-w>`, `g`, `z`, `[`, `]`, and the operator/motion/text-object lists which-key documents from its built-in presets. `ys`, `ds`, and `cs` from nvim-surround appear under their operators.
- Icons come from `mini.icons`, already installed eagerly as this configuration's single icon provider, so which-key needs no icon dependency of its own. The modern preset's icons assume a Nerd Font, which `mini.icons` already assumes.
- `'timeoutlen'` stays at 1000 and no editor option changes. which-key's popup delay is its own setting, unrelated to the mapping timeout.
- The `<Space>` → `<Nop>` guard in `lua/config/keymaps.lua` is an exact mapping on the leader key, so it overlaps every `<leader>` mapping in the configuration. which-key v3 supports overlapping keymaps and holds the popup rather than firing the shorter one; the guard is kept, because deleting it would restore `<Space>`'s default cursor movement if which-key were ever removed.
- No change to `lua/config/`, to any existing plugin file, or to any mapping's key or behaviour.
