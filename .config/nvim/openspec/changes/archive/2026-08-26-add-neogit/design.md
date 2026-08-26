## Context

See `proposal.md` — Why. The constraints this configuration already imposes on a new plugin file:

- **Every plugin is lazy.** Nothing loads at startup unless it paints part of the first frame (gitsigns and todo-comments load on `BufReadPre` for exactly that reason). A plugin reached only by a keypress is loaded by `keys`, as telescope and vim-visual-multi are.
- **`<leader>` prefixes are never bound.** `<leader>g` is a prefix for Telescope's four git pickers today; a fifth family joining it must not bind the prefix itself.
- **which-key registers nothing.** It reads Neovim's keymap tables live, so a mapping declared with a `desc` in a plugin file is listed with no edit to `lua/plugins/which-key.lua`. The `{ "<leader>g", group = "Git" }` entry already exists.
- **plenary is already installed** as a dependency of both Telescope and todo-comments.
- **Telescope loads on `keys` only** — it declares no `cmd` and no event. Anything that wants to use it must reach it through a `require`, which is what triggers lazy.nvim to load it.
- **gitsigns owns the buffer.** Its `on_attach` mappings under `<leader>h` and its sign column are the buffer-level half of git here, and they must keep working unchanged alongside a repository-level view.

## Goals / Non-Goals

**Goals:**

- One new file, `lua/plugins/neogit.lua`, holding the plugin spec and all four mappings. No existing plugin file is edited.
- The four arrangements are a property of the *mapping*, not of a configured default the user has to change to get a different placement.
- Zero startup cost: nothing of neogit is loaded until one of the four keys is pressed or `:Neogit` is run.
- The state neogit changes and the state gitsigns displays stay in agreement without a bridge written here.

**Non-Goals:**

- Re-mapping anything inside the status buffer. Neogit's own buffer-local keys are taken as they come; the spec requires only that they be discoverable from inside the view, which upstream's `?` already satisfies.
- Replacing the Telescope git pickers. `<leader>gf`, `<leader>gs`, `<leader>gc` and `<leader>gb` stay exactly as they are.
- A side-by-side diff viewer. See the diffview decision below.
- Any change to gitsigns, which-key, or `lua/config/keymaps.lua`.

## Decisions

### The arrangement is an argument to the mapping, not a setting

`require("neogit").open({ kind = "…" })` takes the placement per call, and `opts.kind` sets what a bare `:Neogit` uses. So each of the four mappings passes its own `kind` — `"auto"`, `"replace"`, `"vsplit"`, `"split"` — and `opts.kind = "auto"` makes the command form agree with `<leader>gg`.

The doubled letter carries `"auto"` rather than a specific arrangement. `<leader>gg` is the sequence typed without deciding anything, so it gets the placement that requires no decision; `<leader>gr`, `<leader>gv` and `<leader>gh` are there for when a particular one is wanted.

*Alternative considered*: a single mapping plus a configured `kind`. Rejected because the placement wanted depends on what the user is doing at that moment — a full window to work through a large status, a vertical split to keep the file in view while staging it — and a setting makes that a config edit rather than a keystroke. Four two-key mappings under a prefix that is already named cost nothing to remember.

`"auto"` is neogit's own width-based choice — a vertical split when `columns / 2 >= 80`, a horizontal split otherwise — and is left to upstream rather than reimplemented against a column count here.

### Loaded by `keys` plus `cmd`, not by an event

`keys` for the four mappings, and `cmd = "Neogit"` so the command exists before the plugin is loaded. No `event`: neogit paints nothing until it is asked to, so there is no first-frame flicker argument of the kind that puts gitsigns and todo-comments on `BufReadPre`.

The mappings are written as `function() require("neogit").open({ kind = "…" }) end` rather than as `"<cmd>Neogit kind=…<CR>"`. Both work — `cmd` covers the command form — but the Lua form is what the rest of this configuration uses for plugin mappings, it is the API the `kind` argument actually belongs to, and it does not depend on the command's argument parsing.

### Integrations are declared explicitly, not auto-detected

Neogit resolves `integrations.telescope` and `integrations.diffview` by `pcall(require, …)` when they are left `nil`. Under lazy.nvim a successful `require` *loads* the plugin, so auto-detection would drag Telescope in as a side effect of detection, at whatever moment neogit's setup happens to run. Both are therefore stated outright:

- `telescope = true` — Telescope is installed, and the `require` that loads it then happens when neogit actually opens a picker, which is a keypress the user made.
- `diffview = false` — see below.

### `sindrets/diffview.nvim` is not added

Neogit's own expandable diffs inside the status buffer cover reviewing a change before staging it, which is what the spec requires. diffview would add a second full plugin, a second set of buffer-local keys, and a second git-history UI overlapping the Telescope commit picker — for a better side-by-side view than neogit's inline one.

*Alternative considered*: adding it now, since neogit integrates with it directly. Deferred rather than rejected: `integrations.diffview = true` and a `dependencies` entry are the whole change if the inline diffs turn out to be insufficient in use. Nothing in this design has to be revisited to add it.

### No bridge between neogit and gitsigns

Staging a file in neogit changes `.git/index`. gitsigns watches the git directory itself (`watch_gitdir`, on by default) and refreshes the buffers it is attached to when the index changes, so the sign column follows a stage performed in neogit with nothing written here.

*Alternative considered*: an autocmd on neogit's `NeogitStatusRefreshed` / `NeogitCommitComplete` user events calling `gitsigns.refresh()`. Rejected as a duplicate of a mechanism that already exists, and one that would silently keep working — masking the real problem — if the index watcher were ever disabled. If the sign column is observed to lag in practice, that autocmd is the fix, and it is three lines.

### Placement in `lua/plugins/`, flat, one file

Consistent with every other plugin here. The mappings live in this file rather than in `lua/config/keymaps.lua`, which holds general mappings only and says so in its first line.

## Risks / Trade-offs

- **`kind = "replace"` puts the status buffer where the user's file was** → Neogit restores the previous buffer when the view is closed, which is upstream behaviour the spec pins with a scenario. Worth verifying against the `<leader>gr` mapping specifically during implementation, since it is the arrangement that has something to restore.
- **`<leader>gh` sits one letter from the `<leader>h` hunk prefix** → Different prefixes, so no key-sequence conflict; the risk is the user's memory, not the editor's. Mitigated by which-key listing `<leader>gh` under the Git group with its own description, which is where the user will be looking when they pause on `<leader>g`.
- **The commit-message buffer meets this configuration's global mappings** → `<C-s>` writes the buffer and `<leader>qq` confirms a quit-all; neither is destructive against a commit buffer, but the commit flow should be exercised once by hand rather than assumed.
- **Neogit is a large plugin with a fast-moving API** → `kind` values and `integrations` keys should be checked against the version lazy.nvim actually installs, not against memory; `lazy-lock.json` pins it afterwards. This is the same care the gitsigns file records taking over its v1.0 staging API rename.
- **Outside a repository, neogit asks before it reports** → `neogit.open()` offers `Initialize repository in <dir>?` (`vim.fn.confirm`, defaulting to No) before telling the user the directory is not a repository. Upstream exposes no option to suppress it, and guarding the four mappings with a `git rev-parse` of our own was considered and declined: it would cost a subprocess per open and hide an offer that is occasionally what the user wanted. The spec describes the prompt rather than pretending it is absent.
- **Four more keys under `<leader>g`** → The prefix now carries eight mappings from two plugins. Still well inside what one which-key panel lists, and the split is coherent: `f/s/c/b` fuzzy-find over the repository, `g/r/v/h` open the view that acts on it.
