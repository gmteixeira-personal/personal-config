## Context

See proposal.md — Why. The constraint shaping everything below is that blink.cmp's `keymap` option is a merge, not a replacement: `preset = "default"` supplies a table of key → command-list entries, and any key spelled out alongside it overrides that key's entry outright while leaving every other preset key intact. So the question for each of the three keys is not "what should this key do" but "what does the preset already have it doing, and what happens to that".

The preset's relevant entries:

- `<Tab>` → `{ "snippet_forward", "fallback" }`
- `<C-k>` → `{ "show_signature", "hide_signature", "fallback" }`
- `<C-j>` → unbound

A command list is tried left to right and stops at the first command that reports it did something. `fallback` at the end means "run whatever this key did before blink mapped it" — the built-in behaviour. `fallback_to_mappings`, which the preset uses for `<C-n>`/`<C-p>`, is the same except it first looks for a user or plugin mapping on that key and only reaches the built-in if there is none.

`lua/config/keymaps.lua` maps `<C-j>`/`<C-k>` to `<C-w>j`/`<C-w>k`, but in normal mode. blink's keymaps are insert mode (and cmdline), so the two never meet.

## Goals / Non-Goals

**Goals:**

- Three entries in the existing `keymap` table, next to the `preset` line that stays.
- Every preset behaviour these keys already carried survives the override.

**Non-Goals:**

- Changing which candidates appear, when the list opens, or whether an entry is preselected. The `sources` table and blink's selection defaults are untouched.
- Displacing `<C-n>`/`<C-p>`. Two ways to move a list is not a problem worth solving; taking one away from a user who has it in muscle memory is.
- A `<S-Tab>` counterpart for accepting. `<S-Tab>` keeps the preset's `snippet_backward` alone — there is nothing for a reverse-accept to mean.
- Auto-accepting on `<CR>`. `<CR>` stays a newline; see the risk below.

## Decisions

**`<Tab>` = `{ "select_and_accept", "snippet_forward", "fallback" }`.**

The preset's own two commands are kept, in order, behind the new one. `select_and_accept` reports failure when no list is open or nothing is selected, so it falls through to `snippet_forward` and then to the built-in indent — the key gains a meaning rather than trading one away. Ordering accept first is what makes the change worth making: when a list is open over an active snippet placeholder, the list is the thing on screen and the thing the user is looking at.

`accept` was rejected in favour of `select_and_accept`: `accept` acts only on an already-selected item, while `select_and_accept` selects the first entry if none is, which is what a user pressing Tab at a fresh list expects.

**`<C-j>`/`<C-k>` = `select_next`/`select_prev`, not a re-preset.**

blink ships a `super-tab` preset and others that would supply some of this wholesale, but each also rearranges keys this configuration has not been asked to change — `super-tab` puts accept on `<Tab>` at the cost of moving `<C-n>`/`<C-p>` semantics and adding `<CR>` accept. Spelling out three entries over `default` changes exactly three keys, and the diff says which.

**`fallback_to_mappings` for `<C-j>`/`<C-k>`, plain `fallback` for `<Tab>`.**

`fallback_to_mappings` is what the preset uses for its own selection keys, and it is the right choice for a key another plugin might claim in insert mode later: a future insert-mode `<C-j>` mapping keeps working when no list is open. `<Tab>` keeps plain `fallback` because the preset already chose it there and the built-in indent is precisely what should run — there is no user mapping in this configuration for it to defer to.

**`<C-k>` re-lists the preset's two signature commands after `select_prev`.**

The override replaces the entry, so omitting them would silently delete the signature-window toggle — a capability from a different spec, lost as a side effect of a keymap change. Listing them after `select_prev` gives the key the same shape as `<Tab>`: list first, then the preset's prior job, then the built-in. The alternative, moving the signature toggle to a free key, was rejected as scope this change was not asked for.

**Nothing is written to `lua/config/keymaps.lua`.**

These are plugin mappings, active only while blink's menu is up and defined by blink's own dispatch. They belong in the plugin's spec next to the preset they modify, the way telescope's `<C-j>`/`<C-k>` live in `lua/plugins/telescope.lua`.

## Risks / Trade-offs

- **`<Tab>` is overloaded three ways in insert mode, and the list wins** → A user wanting a literal indent while a list is open gets an accept instead. `<C-e>` dismisses first, and `<C-v><Tab>` inserts one literally; both are one extra key in a case that arises rarely, and the ordering is the point of the change.
- **`<C-k>` shadows stock `i_CTRL-K` (digraph entry) whenever a list or a signature is available** → The digraph key is reachable only in the quiet case now. Accepted: this configuration has no digraph workflow, and the fallback chain means nothing is lost outside completion.
- **The three overrides are pinned against a preset that upstream may change** → If blink's default `<Tab>` or `<C-k>` gains a command, this table will not pick it up, and the drift is silent. The comments in `lua/plugins/blink-cmp.lua` name which commands came from the preset so the divergence is visible when the file is next read.
- **`select_and_accept` inserts when the user meant to keep typing** → It only fires on an explicit `<Tab>`; the "no implicit insertion" requirement in the completion spec is about the list appearing, not about a keypress, and that stays true.
