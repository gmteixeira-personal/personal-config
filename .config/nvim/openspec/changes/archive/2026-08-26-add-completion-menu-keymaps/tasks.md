## 1. The keymap table

- [x] 1.1 In `lua/plugins/blink-cmp.lua`, expand `keymap = { preset = "default" }` into a table that keeps `preset = "default"` and adds the three key entries below beside it, so the preset's other keys are inherited rather than restated.
- [x] 1.2 Bind `<Tab>` to `{ "select_and_accept", "snippet_forward", "fallback" }` — accept first, then the preset's own snippet jump, then the built-in indent.
- [x] 1.3 Bind `<C-j>` to `{ "select_next", "fallback_to_mappings" }`, matching the fallback form the preset uses for `<C-n>`/`<C-p>`.
- [x] 1.4 Bind `<C-k>` to `{ "select_prev", "show_signature", "hide_signature", "fallback_to_mappings" }`, re-listing the preset's two signature commands so overriding the key does not delete the signature-window toggle.
- [x] 1.5 Leave `sources`, the selection defaults, and every other preset key untouched — no `<CR>` accept, no `<S-Tab>` counterpart, and `<C-n>`/`<C-p>`/`<C-y>`/`<C-e>`/`<C-space>` unchanged.

## 2. Comments

- [x] 2.1 Comment the entries to the density of the rest of the file: that a spelled-out key replaces the preset's entry for that key outright, and that the command lists run in order until one applies.
- [x] 2.2 Record which commands in each list came from the preset, so a later reader can see where this configuration diverges from upstream.
- [x] 2.3 Note that `<C-j>`/`<C-k>` deliberately mirror the fuzzy finder prompt's down/up pair, and that the `<C-w>j`/`<C-w>k` window mappings are normal-mode only and unaffected.
- [x] 2.4 Keep the existing note that nothing is inserted without an explicit accept, updated for `<Tab>` now being a second accept key.

## 3. Verification

- [x] 3.1 Restart Neovim and confirm `<Tab>` accepts a candidate, `<C-j>`/`<C-k>` move the selection, and `<C-n>`/`<C-p>`/`<C-y>`/`<C-e>` still behave as before.
- [x] 3.2 Confirm the fallbacks: `<Tab>` indents with no list open, `<Tab>` jumps placeholders inside an expanded snippet, `<C-k>` toggles the signature window with no list open, and `<C-j>`/`<C-k>` still move window focus in normal mode.
