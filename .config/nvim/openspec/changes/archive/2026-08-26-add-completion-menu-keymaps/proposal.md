## Why

The completion menu is driven entirely by Ctrl chords from blink's default preset: `<C-n>`/`<C-p>` to move, `<C-y>` to accept. Neither matches how the rest of this configuration moves through a list — the telescope prompt takes `<C-j>`/`<C-k>` for exactly that — and `<C-y>` is a reach for the single most frequent action in the menu. Every other editor and terminal the user comes from accepts with `<Tab>`, and the finger goes there first.

## What Changes

- Bind `<Tab>` as a second accept key for the candidate list, alongside the preset's `<C-y>`. The preset's existing `<Tab>` job — jumping to the next snippet placeholder — is kept behind it, and a `<Tab>` pressed with no menu and no snippet still indents.
- Bind `<C-j>` and `<C-k>` to move down and up the candidate list, the same down/up pair the fuzzy finder's prompt uses.
- `<C-k>` keeps the preset's signature-window toggle, which it would otherwise displace: the toggle runs only when no candidate list is open.
- `<C-n>`/`<C-p>`, `<C-y>`, `<C-e>` and `<C-space>` are untouched — this adds keys, it removes none.
- No candidate is inserted without an explicit keypress: `<Tab>` is one more accept key, not an auto-accept.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `completion`: one new requirement fixing the keys that accept a candidate and move through the list. The existing spec describes accepting and dismissing without naming any key; this pins the bindings, and adds the requirement that each of them falls back to the key's ordinary meaning when no list is open.

## Impact

- Modified file: `lua/plugins/blink-cmp.lua` — the `keymap` option grows from `{ preset = "default" }` to the preset plus three explicit bindings. No new plugin, no lockfile change.
- **`<Tab>` is now overloaded three ways** in insert mode: accept, snippet jump, indent. The commands are tried in that order and the first that applies wins, so the ambiguity only bites when a menu is open and the user wanted a literal indent — `<C-e>` dismisses first, or `<C-v><Tab>` inserts one literally.
- **`<C-k>` is stock Neovim's digraph key** (`i_CTRL-K`). It stays reachable, but only with no menu open and no signature window to toggle. A user who types digraphs while completing will find it taken.
- The `<C-j>`/`<C-k>` window-focus mappings in `lua/config/keymaps.lua` are normal-mode only and are not affected.
- Nothing changes about which candidates appear, where they come from, or when the list opens.
