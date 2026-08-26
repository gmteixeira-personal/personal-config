## Context

See `proposal.md` — Why. The constraints that shape the approach:

- Mappings live in nine places: `lua/config/keymaps.lua` and eight plugin files. Two sets are buffer-local — gitsigns attaches `<leader>h*` in `on_attach`, the LSP config attaches its own in an `LspAttach` autocommand — so any design that reads mappings once at startup would miss them.
- Every mapping already passes a `desc`, both the `map()` helpers in `keymaps.lua` and `gitsigns.lua` and the `keys` entries in the lazy.nvim specs. That is the text to display; nothing needs writing.
- `'timeoutlen'` is 1000 (`lua/config/options.lua`), deliberately, so multi-key `<leader>` sequences can be typed at a comfortable pace.
- `mini.icons` is installed eagerly with `mock_nvim_web_devicons()`, and is the configuration's single icon provider.
- `plugin-management` requires one plugin per file under `lua/plugins/`, self-contained.
- The user has chosen the **modern** layout. That decision is an input to this design, not an outcome of it.

## Goals / Non-Goals

**Goals:**

- Hints for every prefix in the configuration, `<leader>` and otherwise, with no per-mapping registration.
- Buffer-local mappings listed where and only where they exist.
- One new file, no edit to any existing mapping.

**Non-Goals:**

- Rewriting or re-homing any `desc`. If a description reads badly in the popup, that is a separate change to the file that owns the mapping.
- Changing `'timeoutlen'` or any other editor option.
- Adding mappings beyond the single buffer-local listing key. which-key can drive keymap creation through its `spec` table; this configuration keeps mappings where they are and uses which-key to read them.
- Naming the non-`<leader>` prefixes. The built-in presets already describe `<C-w>`, `g`, `z`, and the bracket pairs.

## Decisions

### which-key v3, not mini.clue or a menu plugin

`folke/which-key.nvim` at v3 discovers mappings by reading Neovim's keymap tables at the moment a sequence is pending, and uses each mapping's `desc`. Nothing has to be declared twice, and a mapping added to any plugin file is listed on the next restart with no edit here — which is what `keymap-hints`' "descriptions come from the mappings themselves" requirement asks for.

Alternatives considered:

- **mini.clue** — the natural fit given `mini.icons` is already installed, and lighter. Rejected because triggers are enumerated by hand: every prefix, in every mode, listed in its config. That is a second inventory to keep in sync with nine files, and the buffer-local sets would need per-attach registration.
- **legendary.nvim / hydra.nvim** — a command palette and a modal-submode tool respectively. Neither answers "what continues this prefix"; both would mean re-declaring mappings.

Pinning: no `version = "*"`. which-key is a folke plugin tracking `main` with `lazy-lock.json` as the pin, matching how `lazy.nvim` itself and the other plugins here are handled.

### `preset = "modern"`

The user's choice, and the reason the change exists in this shape. `modern` gives a bordered, padded floating window anchored to the bottom of the editor, spanning its width, with an icon column. Concretely it differs from the alternatives in `win` and `layout` defaults only — `classic` is a borderless bottom strip without padding, `helix` is a bottom panel with a different column layout. All three read the same mappings; the preset is presentation. Written as `preset = "modern"` rather than as an expanded `win`/`layout` table, so upstream's tuning of the preset carries over and this file does not silently pin an old look.

### `event = "VeryLazy"`, not `keys`

Every other deliberately-invoked plugin here loads on `keys`. which-key cannot: the keys that would trigger it are the prefixes, and those are already owned by real mappings, so a lazy.nvim `keys` stub on `<leader>` would compete with them. `VeryLazy` is which-key's documented load event — after the first screen is drawn, before the user can plausibly pause on a prefix, which is what the "costs nothing at startup" requirement asks for.

### `delay = 300`

which-key v3's popup delay is its own option, in milliseconds, and is not `'timeoutlen'`. Upstream's default is 200. 300 is set explicitly here because `'timeoutlen'` is 1000 precisely so sequences can be typed unhurriedly: at 200 the popup flashes during ordinary two-key sequences typed at that comfortable pace, which is noise, not help. 300 stays inside the "responds without a perceptible wait" bar that `editor-options` sets for idle-triggered behaviour.

### Group names in `opts.spec`, all eight

```
{ "<leader>b", group = "Buffer" }
{ "<leader>c", group = "Code" }
{ "<leader>f", group = "Find" }
{ "<leader>g", group = "Git" }
{ "<leader>h", group = "Hunk", mode = { "n", "v" } }
{ "<leader>m", group = "Multi-cursor", mode = { "n", "x" } }
{ "<leader>r", group = "Rename & restart" }
{ "<leader>s", group = "Split & window" }
```

A `group` entry is display metadata: it does not bind the key, so `editor-keymaps`' "no command runs on the prefix" holds. `<leader>h` and `<leader>m` carry a `mode` because both have visual-mode members — gitsigns stages and resets a selected range, vim-visual-multi's `VM_leader` set is normal and visual — and a group declared for normal mode only would leave those unnamed in visual mode.

`<leader>r` is genuinely two subjects: `<leader>rc` restarts the editor, `<leader>rn` is the LSP rename. "Rename & restart" names both rather than picking one and lying about the other. Splitting them into separate prefixes is a mapping change and belongs to whichever change wants it.

`<leader>e` (file explorer) and `<leader><leader>` (find files) get no entry: they are complete mappings with their own `desc`, not prefixes.

### `<leader>?` lists the current buffer's mappings

`require("which-key").show({ global = false })`. The gitsigns and LSP sets are attached per buffer, and a `<leader>h` group name does not tell the user that the whole set is absent outside a git repository. `<leader>?` is upstream's suggested key, is unbound here, and `?` alone (search backwards) is untouched. Declared in the plugin file's own `keys`, per `config-structure`.

### `<Space>` → `<Nop>` stays

`lua/config/keymaps.lua` maps `<Space>` to `<Nop>` in normal and visual mode, so a bare leader press does not move the cursor right. It is an exact mapping on a key that prefixes every `<leader>` mapping in the configuration — the overlapping-keymap case which-key v3 handles explicitly: it holds for the longer sequence and shows the popup rather than firing the shorter mapping. The guard is kept because it is the fallback if which-key is ever removed, and because deleting it is an `editor-keymaps` change, not this one.

`notify` is left at its default. If which-key does report the overlap at startup, `:checkhealth which-key` is where the detail is, and the fix is a one-line `notify = false` — but the setting is not pre-emptively disabled, because a real mapping conflict introduced later is worth being told about.

### Built-in presets left on

which-key's `plugins.presets` — operators, motions, text objects, windows, nav, `z`, `g` — are all on by default and stay on. They are what covers `<C-w>`, `g`, `z`, `[`/`]`, registers and marks, which the "built-in and non-leader sequences" requirement asks for, and they cost nothing to leave alone. nvim-surround's `ys`/`ds`/`cs` appear through the ordinary keymap read, and their `keys` entries here already carry a `desc`.

### Icons from mini.icons

which-key v3 detects `mini.icons` and uses it; there is no `nvim-web-devicons` dependency to add, and adding one would violate the standing rule in `lua/plugins/mini-icons.lua`. Icons are left at their defaults.

## Risks / Trade-offs

- **The popup does not appear until `'timeoutlen'` elapses** → which-key v3 takes over key reading once a trigger fires, so the popup is governed by `delay`, not by the 1000ms mapping timeout. If it behaves otherwise in practice, the fix is local: lower `'timeoutlen'`, which `editor-options` already describes as "within a third of a second" — a pre-existing discrepancy with the configured 1000, and out of scope here.
- **A trigger swallows or delays a real mapping** → v3 attaches to prefixes and passes completed sequences through, which is the "hints do not change what any mapping does" requirement. The escape hatch, if one specific key misbehaves, is `triggers` with a `false` entry for that key, or `defer` for operator-pending cases. Not configured pre-emptively.
- **No Nerd Font in the terminal** → the icon column renders as boxes. `mini.icons` already assumes a Nerd Font in this configuration, so this fails no worse than the file explorer does today; `icons.mappings = false` turns them off if it ever matters.
- **`<Space>` overlap notice at startup** → covered above; one line to silence, and the noisy case is a fresh install, not steady state.
- **A description that reads well in source reads badly in a popup** — several `desc` strings here are prefixed ("Multi-cursor: select occurrence") because nothing grouped them before. Under a named group the prefix is redundant. Left alone deliberately: rewriting them is a change to the files that own those mappings, and this change touches none.

## Migration Plan

Add one file, restart, commit `lazy-lock.json`. Rollback is deleting the file: no mapping, option, or other plugin file is modified, so nothing else has to be undone.
