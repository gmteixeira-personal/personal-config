## Context

See proposal.md — Why. The constraints that shape the approach, all of them present before this change:

- **The material is large.** `lua/config/keymaps.lua` makes roughly fifty mappings; another seventeen keymap declarations sit in plugin files; `lua/plugins/` holds about thirty plugin specs across two directory levels. A README that treats all of it at equal depth is unreadable, and one that treats none of it is useless.
- **`openspec/specs/` already specifies the behaviour.** Twenty-nine capability specs cover the same ground exhaustively and are the authoritative source. The README's value is orientation and lookup, not a second copy — so the design problem is where to cut, not what to write.
- **A description of the repository-root README already exists and is out of reach.** `~/README.md` carries a Neovim section today, and the home workspace's `dotfiles-repo` spec requires it. Both sit outside this workspace's edit root. The user will rewrite that requirement afterwards so the root section draws from this README; until then, two documents overlap.
- **Two things drift for different reasons.** The README can fall behind the configuration, and it can fall behind the specs. These need different answers.

## Goals / Non-Goals

**Goals:**

- A single document that answers, in one place, what this configuration is, how it is put together, what it binds, and what it loads.
- Look-up-ability in both directions: key to effect, and task to key.
- A cut between README and specs that is stated in the document, so a future contributor knows which side a new sentence belongs on.
- A document complete enough within `.config/nvim/` to be the source another README draws from.

**Non-Goals:**

- Not a tutorial on Neovim, Lua, or any plugin's own usage — those have upstream documentation and this document links to nothing it would have to maintain.
- Not a changelog or a rationale archive. Reasoning that belongs to a decision lives in the spec or the commit that made it.
- Not generated. No script derives the README from the source tree in this change.
- Not the repository-root README, and not the `dotfiles-repo` spec that governs it.

## Decisions

### One document, not a `docs/` tree

A single `README.md` at the configuration root, rather than a README plus a set of topic files.

The material fits: an orientation-depth document over thirty plugins and fifty keymaps is long but not book-length, and every section is something a reader wants adjacent to the others — the keymap table is read next to the plugin that provides the key. Splitting it would also create a second place for the README-versus-spec cut to be litigated. `openspec/specs/` is already the split, and adding a third tier between README and spec means every new sentence has three homes to choose from instead of two.

*Alternative considered:* `README.md` plus `docs/keymaps.md` and `docs/plugins.md`. Rejected: it moves the two sections a reader most often wants out of the document they land on, for a length problem that a table of contents solves.

### Sections follow the reader's questions, not the source tree

Order: what this is and how to run it → layout and load order → editor conventions → keymaps → plugins → where the detail lives.

This is arrival order. A reader who has just cloned needs the first section; a reader who has used it for a month needs the fourth. Ordering by the file tree instead would open on `init.lua`, which is three `require` calls and says nothing a newcomer wants first.

The final section is load-bearing rather than a footer: it names `openspec/specs/` as authoritative and states the cut, which is what keeps the document from growing into a duplicate of the specs one well-meant paragraph at a time.

### Keymaps as tables, grouped by family; prose reserved for the ones that surprise

Tables give scanning and reverse lookup — key, effect, mode — which prose does not. But three or four mappings are choices a table cannot justify: the ones that displace a built-in. `H` and `L` take over the screen-top and screen-bottom motions, and a reader who finds `H` no longer does what every other Vim does needs to know it was deliberate and what became of the old behaviour.

So: tables carry the enumeration, and a short paragraph precedes the table of any family that displaces something. Grouping is by prefix family — the unprefixed overrides, `<leader>w`, `<leader>b`, `<leader>q`, the window-focus and resize chords, and the plugin-provided keys — because that is how a reader half-remembers a binding.

*Alternative considered:* one flat table of every mapping sorted by key. Rejected: it answers "what does this key do" and abandons "which key does this thing", and the user asked for both.

### Plugin mappings are documented with the general ones, attributed by name

A reader pressing a key does not know which file declared it. The keymap section therefore covers plugin-provided keys too, with the providing plugin named in the row. The plugin section stays about what each plugin is *for*.

The cost is that a plugin's keys and its description are in two sections. That is the right split: the keymap section is a lookup table, the plugin section is a map of the territory, and merging them makes both worse.

### Plugins grouped by job, with the boundary stated where several overlap

Grouping by purpose — language support, completion and formatting, git, navigation, editing, interface, sessions and themes — rather than alphabetically. Three git plugins are loaded, and the only interesting fact about them is which one answers which question: hunks in the current buffer, the repository as a whole, or a full difference against a revision. A bare list omits exactly that.

### The README delegates to the specs and never restates a scenario

The rule written into the spec: the README summarizes behaviour, the specs carry the scenarios, and on disagreement the spec wins and the README is what changes.

Stating the direction of resolution matters more than it looks. Without it, a contributor who finds the two disagreeing has to guess which to trust, and the natural guess is the one that is easier to edit — the README — which is precisely backwards.

### No generation, no CI check

The README is written and maintained by hand, and the sync obligation is a spec requirement rather than a script.

Generating a keymap table from the source is possible and tempting, but the values worth documenting — what a mapping is *for*, what it displaces, why a convention overrides a default — are not in the source in a machine-readable form, and a half-generated document is one nobody is sure whether they may edit. There is no test runner in this repository to hang a check on either, so a CI check would mean introducing one for a documentation change.

The exposure is real and accepted: nothing mechanically prevents the README going stale. The mitigation is that the obligation is specified, so a change that skips it is reviewable against a written requirement rather than against someone's memory.

### The root README is left alone in this change

`~/README.md` keeps its Neovim section untouched here. That section and the `dotfiles-repo` requirement behind it live in the home OpenSpec workspace, outside this change's edit root, and the user will rewrite that requirement so the root section draws from this README.

The overlap between the two documents is therefore temporary and known, not an oversight. This README is written to be the source in that later arrangement: complete on its own, confined to Neovim, and free of the enclosing repository's bootstrap and staging procedure.

## Risks / Trade-offs

- **The README goes stale.** → The obligation is a spec requirement, so a change that touches a documented plugin, key, convention, or path is reviewable against a written rule. Accepted as the residual risk of not generating the document.
- **Two documents describe Neovim until the home spec is rewritten.** → Bounded and deliberate; this README is written to be the source the other draws from, so the resolution is an edit to the root document rather than a rewrite of this one.
- **Orientation depth is a judgement call, and the document creeps toward the specs.** → The final section states the cut explicitly, and the spec forbids reproducing requirement and scenario blocks. A reviewer has something to point at.
- **The keymap tables are the part most likely to rot**, being the largest enumeration and the thing changed most often. → Grouping by family localizes the edit: a change to one prefix touches one table.
- **Attributing plugin keys splits a plugin's documentation across two sections.** → Accepted; the plugin is named in the keymap row, so the two are one search apart.

## Migration Plan

Not applicable — this change adds a file and a spec. Nothing is replaced, no behaviour changes, and reverting is deleting the README.

The one sequenced item is external to this change: the home workspace's `dotfiles-repo` requirement is rewritten to draw the root README's Neovim section from this document. That is the user's change, proposed from `~`, and it depends on this one landing first.
