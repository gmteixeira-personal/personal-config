## Context

See `proposal.md` — Why for motivation, and `specs/multiple-cursors/spec.md` for the behaviour contract.

Four properties of the existing configuration constrain this change, and all four are inherited:

1. **One plugin per file, and a plugin file is the complete description of that plugin** (`config-structure`, `plugin-management`).
2. **A plugin declares its own keymaps in its own file**, never in `lua/config/keymaps.lua`.
3. **A key that is a prefix is never also a mapping.** This is the rule `add-editor-tooling` built its namespace on, and it is why formatting lives at `<leader>cf` rather than `<leader>f`.
4. **`lua/config/options.lua` declares `maplocalleader = "\\"`**, explicitly, with the stated reason that a future leader change must not silently collide.

Two facts about vim-visual-multi shape everything below, and both were read from the plugin's source rather than assumed:

- Its leader defaults to `\` (`autoload/vm/maps.vim`: `get(g:, 'VM_leader', '\\')`), which is exactly the key constraint 4 reserves.
- It reads `g:VM_leader` inside `s:build_permanent_maps()`, which runs from `vm#maps#default()` — described in the source as running "at vim start", when the permanent mappings are generated and applied. The variable is therefore read once, early, and a value set after that point has no effect.

A third fact bounds the risk: `<C-n>` is mapped unconditionally, in normal and visual mode only, regardless of `g:VM_default_mappings`. The source comment is explicit — "map `<c-n>` in any case".

## Goals / Non-Goals

**Goals:**

- Add the capability without letting a plugin take a key namespace the configuration had deliberately reserved.
- Keep `<C-n>` as the entry point, because it is the key every piece of the plugin's documentation and every tutorial assumes, and because a multiple-cursors plugin whose primary key is unfamiliar is worth less than one whose is.
- Lazy loading that is correct rather than aggressive, matching the rest of the configuration: loaded before the first key that needs it and no earlier.

**Non-Goals:**

- Remapping the plugin's in-mode keys — the ones that exist only while cursors are active (`n`, `N`, `q`, `Q`, `[`, `]`, `<Tab>`, `S`). They are a self-contained modal namespace that does not overlap the configuration's, and rebinding them would mean maintaining a table against upstream churn for no benefit. The single exception is Undo/Redo, which ship unmapped rather than mapped to something else — see the decision below.
- Theming its highlight groups to rose-pine. It links to `IncSearch` and `Visual` by default, which the colour scheme already defines, so it inherits sensible colours without a line of configuration.
- Mouse mappings. `g:VM_mouse_mappings` ships disabled; this change leaves it that way.
- Replacing anything. LSP rename and `:substitute` both remain the better tool for their own cases, as the proposal sets out.

## Decisions

### The plugin's leader moves; the configuration's localleader does not

`g:VM_leader` is set to `<leader>m`, leaving `\` unclaimed.

The collision is real but latent: nothing in the configuration currently maps `<localleader>`, so installing at defaults would break nothing today. That is precisely what makes it worth fixing now rather than later — the cost of moving the plugin's leader is one line, and it is paid before any muscle memory exists. Discovering the collision later, after `\A` and `\/` are in the fingers, means either living with a localleader that is not really available or retraining.

Which side moves is the second half of the decision, and it goes the way it does because the configuration's declaration is load-bearing while the plugin's is not. `maplocalleader` is set in `options.lua` with a comment explaining that it exists to prevent silent collisions; deleting it to make room for a plugin would invert the reason it is there. The plugin's leader, by contrast, is a single variable it exposes for exactly this purpose.

`<leader>m` is chosen for "multi", it is free in the existing namespace (`<leader><leader>`, `<leader>e`, and the `f`/`c`/`h` prefixes are the whole of it), and it extends the established pattern rather than inventing one.

The cost is stated plainly rather than hidden: the plugin's own documentation, its help file, and every tutorial about it describe `\\`, `\A`, `\/`. Those become `<leader>m\`, `<leader>mA`, `<leader>m/`. A comment in the plugin file recording the mapping between the two is part of this change, because the alternative is a user reading upstream docs that silently do not apply.

*Alternative considered:* keeping `\` and removing `maplocalleader` from `options.lua`. It produces a single owner for the key, which is tidier than two declarations that agree by luck. Rejected because it edits a bootstrap-era file to accommodate a plugin, which is backwards, and because it would need a `config-structure` spec change for what is ultimately a plugin's default.

*Alternative considered:* `<leader>v` for "visual multi". Rejected only because `m` reads as the capability rather than the plugin, and the capability is what outlives the choice of plugin.

### `g:VM_leader` is set in `init`, not `config`

lazy.nvim runs a spec's `init` during startup, before the plugin is loaded, and its `config` after. Because the plugin reads `g:VM_leader` when it builds its permanent mappings at startup, the assignment must be in `init`. Putting it in `config` would set the variable after the mappings had already been generated from the default, producing a plugin mapped to `\` and a configuration that says otherwise — the worst of both, and a failure that looks like the setting being ignored rather than mis-ordered.

This is the standard shape for a Vimscript plugin configured through `g:` variables, and it is worth a comment in the file saying so, because `config` is the habit-forming default for Lua plugins and the difference here is not visible from the outside.

*Alternative considered:* `vim.g.VM_leader` in `options.lua`, where it would certainly run early enough. Rejected outright by constraint 2 — it is a plugin's setting, and would put a plugin's configuration in a file that must load with no plugins installed.

### Undo and Redo are mapped, and are the only `g:VM_maps` entries

`g:VM_maps` is set to `{ Undo = "u" }`, and to nothing else.

This is not a preference about key placement — it is the only way the capability's undo requirement holds. An edit at several cursors is one undo step *per cursor* in ordinary undo: deleting a word at three cursors takes three presses of `u` to revert, an insert at three cursors takes two or three depending on where the cursors sit. That was measured, not assumed. Without a single-press revert, correcting a mis-aimed multi-cursor edit is as error-prone as the edit was, which defeats the point of being able to see what is about to change before committing to it.

The plugin's own Undo jumps the undo tree back to the tick before the edit and restores the regions with it, so one press reverts everything and leaves the cursors in place to try again. It ships unmapped because upstream considers it experimental, and testing bears that out — the limits are recorded here and in the plugin file rather than discovered later:

- It is exact for the **first** multi-cursor edit of a session, which is the case it is here for, across insert, change, delete, and operator edits alike.
- A later edit in the same session usually reverts to the state in which the cursors were placed rather than one edit back.
- After successive appends it can land on a state that never existed — trailing whitespace where the appended text was. `<Esc>` followed by ordinary undo recovers from it.

`Redo` is deliberately left unmapped. VM's own restores nothing after a VM undo and leaves `E803: ID not found` in `v:errmsg`, so mapping it would put a key on a command that does not work; unmapped, `<C-r>` inside a session is ordinary redo.

The scope is deliberately narrow. `u` is buffer-local and only exists while cursors are active — outside VM it is ordinary undo, and after `<Esc>` it is ordinary undo again, which is what the "keys return to their ordinary meaning" requirement demands. No other in-mode key is touched.

*Alternative considered:* leaving `g:VM_maps` untouched and weakening the spec to "one undo per cursor". Rejected because the undo requirement is what bounds the blast radius of a mis-aimed edit, and it is the one thing a multiple-cursors capability must get right. An experimental command that is exact for the first edit and coarse afterwards is worth more than no single-press revert at all — but only because its limits are written down.

### Lazy-loaded on its entry-point keys

The spec declares the plugin `keys = { "<C-n>", "<C-Down>", "<C-Up>", "<S-Right>", "<S-Left>" }` plus the `<leader>m`-prefixed entry points, in normal and visual mode as each applies.

`keys` rather than `event = "VeryLazy"` follows the rule the rest of the configuration uses: telescope loads on its keys, conform on a write or its keymap, and smear-cursor — genuinely decorative — on `VeryLazy`. Multiple cursors is not decorative and not startup-relevant; it is a tool reached for deliberately, which is exactly the case `keys` describes. The practical difference is small, and the consistency is the point.

The one thing this must not do is swallow the first keypress. lazy.nvim installs a stub mapping, loads the plugin on the first press, and re-feeds the key, so the first `<C-n>` selects a word rather than merely loading the plugin. That behaviour is a requirement in the spec rather than an assumption here, because it is the failure mode a `keys`-based load produces when it goes wrong, and it is invisible until someone presses the key.

The in-mode keys are deliberately absent from `keys`. They only exist once the plugin is active, at which point it is loaded by definition.

### The in-mode namespace is left alone

Once cursors are active the plugin binds a large set of buffer-local keys — `n`/`N` to move between matches, `q`/`Q` to skip and remove, `[`/`]` to navigate, `<Tab>` to switch mode, `S` to surround, and its own leader-prefixed menus. None is touched.

They are buffer-local and modal: they exist only while multiple cursors are active and vanish on `<Esc>`, so they cannot collide with the configuration's namespace in any state a user is normally in. Rebinding them would mean maintaining a table of thirty-odd mappings against a plugin that periodically adds to them, in exchange for nothing.

## Risks / Trade-offs

- **The plugin's documentation will not match the configured keys.** Its help file, README, and every third-party tutorial say `\\`, `\A`, `\/`. → Mitigated by a comment in the plugin file giving the translation explicitly, and by the change of leader being one variable that can be reverted in one line if the divergence proves more annoying than the collision it avoids.
- **`g:VM_leader` set too late fails silently rather than loudly.** The plugin does not warn that the variable arrived after it read it; the mappings simply come out on `\`. → `init` is chosen for exactly this reason, and verifying the mappings actually resolve to `<leader>m` — rather than verifying the variable's value — is a task in its own right.
- **`<S-Right>` and `<S-Left>` shadow their built-in meanings.** Those defaults move by word in insert and select mode. → The plugin claims them in normal mode, where they are unmapped by default, so the shadowing is nominal. Recorded because it is a global mapping and therefore worth knowing about.
- **`<C-n>` is mapped unconditionally and cannot be disabled through `g:VM_default_mappings`.** → Wanted here, not a problem: it is the intended entry point. It matters only if the key is ever needed for something else, in which case `g:VM_maps` is the escape hatch. blink.cmp's `<C-n>` is insert-mode only, so the two already coexist.
- **`<leader>m` becomes both this capability's prefix and, inside multiple-cursor mode, the prefix for the plugin's own menus** — so `<leader>mm` merges regions while cursors are active and means nothing outside. → Consistent rather than confusing: the prefix belongs to the capability in both contexts. It is noted because it is the one place the configured leader appears in a modal context.
- **A multiple-cursor edit that goes wrong can touch many places at once.** → Bounded by the spec's requirement that one undo reverts the whole multi-cursor edit *while cursors are still active*, which needs the `g:VM_maps` Undo entry above and is verified rather than assumed, and by the skip and remove commands that exist to correct the cursor set before editing. After `<Esc>`, undo is ordinary undo and unwinds the edit one cursor at a time — so the correction is made before leaving the mode, not after.
- **A pattern search that matches nothing reports `E486: Pattern not found`.** → The plugin's regex entry point is Vim's own `/`, so a failed search produces Vim's ordinary failed-search message. No cursor is added and the buffer is unchanged; the spec records the message as expected feedback rather than treating it as an error to suppress, since suppressing it would mean wrapping the plugin's search.
- **Vimscript rather than Lua, and last released in 2024.** → It is the mature implementation with no serious Lua equivalent at the same maturity, it has no dependencies and no build step, and rollback is deleting one file. If a Lua replacement becomes compelling, the capability spec is written against behaviour rather than this plugin, so swapping it needs no spec change.

## Migration Plan

Nothing to migrate. One file is created; no existing `lua/` file is edited.

First launch after the change clones one small Vimscript plugin. Nothing is downloaded at runtime and no binary is installed.

Rollback is deleting `lua/plugins/vim-visual-multi.lua`. Because the plugin's leader is set in that same file's `init`, deleting it removes the `g:VM_leader` assignment along with the plugin, leaving no orphaned setting behind — which is the one-plugin-per-file rule doing its job.

## Open Questions

- **Should `<leader>m` gain a which-key style hint once the prefix has more than one plugin behind it?** Deferrable: it changes no spec and no task here, and it only becomes a question if a discoverability plugin is ever added.
