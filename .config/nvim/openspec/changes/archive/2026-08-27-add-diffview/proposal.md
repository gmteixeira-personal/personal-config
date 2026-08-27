## Why

Reviewing a change spanning several files has no good answer here. `<leader>gd` diffs one file against the index, and neogit's status buffer expands an entry into an inline diff -- both are per-file, and neither shows the working tree and a revision side by side with a list of every file that differs. Reading a branch before merging it, or a commit after the fact, means leaving the editor.

The second gap is merge conflicts. Neogit declines to stage a conflicted file, reporting "Conflicts must be resolved before staging", because resolving one needs a three-way view it does not have. Today that resolution happens outside the editor entirely.

`lua/plugins/neogit.lua` already records diffview.nvim as deferred rather than declined, and names exactly this as the trigger: "flipping this to true and adding the dependency is the whole change if the inline diffs prove too cramped."

## What Changes

- Install diffview.nvim, and give it four of the `<leader>g` keys, three of them toggles:
  - `<leader>gd` — this file against the last commit, with no file panel (it would list one entry).
  - `<leader>gm` — every file that differs, with the panel.
  - `<leader>gh` — this file's history.
  - `<leader>gr` — refresh an open view. Not a toggle; it acts on a view already up.
- Drop the buffers a view loaded when the last view closes, so reading several files in one does not leave a buffer per file in `<leader>bn` — and so an editor opened only to read a diff has nothing to save on exit. Buffers the user already had open, and any with unsaved changes or a window, are left alone.
- Turn neogit's diffview integration on, which it has been explicitly refusing, and pin `diff_viewer` rather than leaving it to auto-detect. This gives the status buffer's diff popup somewhere to open, and gives staging a conflicted file a three-way resolution view instead of a refusal.
- **BREAKING**: collapse neogit's four placement mappings to one. `<leader>gg` becomes a toggle and opens the status view in place of the current window, which is what `<leader>gr` did. `<leader>gr`, `<leader>gv` and `<leader>gh` stop reaching neogit; every arrangement stays reachable as `:Neogit kind=...`.
- **BREAKING**: `<leader>gd` stops being gitsigns'. It opened the buffer against the *index* with `gitsigns.diffthis`; it now opens the same file in diffview, against the last commit. `:Gitsigns diffthis` still does the old thing. gitsigns keeps the sign column and its `<leader>h` hunk actions.

The result is that every key under the prefix that shows a difference shows it in the same view, with one set of in-view keys and one way to dismiss it, and every view under the prefix is a toggle.

No other plugin in this configuration has a diffview setting — `gitsigns`, `telescope`, `lualine`, `noice`, `todo-comments` and `which-key` were checked, and only neogit's `integrations` table mentions it. which-key needs nothing: `<leader>g` is already grouped as "Git" and each mapping's own description is what it lists.

## Capabilities

### New Capabilities

- `repository-diff-view`: the whole repository's difference against a revision as a dedicated view -- a panel listing every file that differs, a side-by-side diff of the selected one, and a three-way view for resolving a merge conflict.

### Modified Capabilities

- `git-integration`: its `<leader>gd` requirement is **removed**. Showing one file's whole difference moves to `repository-diff-view`; gitsigns keeps the sign column and the hunk actions.
- `git-repository-ui`: gains a requirement that the status view can hand a change to the dedicated diff view, and that a conflicted file is staged by resolving it there rather than being refused. Its opening requirement is **modified** to one toggling mapping, and its window-arrangement requirement is **removed**.

## Impact

- `lua/plugins/diffview.lua` -- new file, lazy on the mapping and on its commands.
- `lua/plugins/gitsigns.lua` -- the `<leader>gd` mapping is removed; the sign column, `]c` / `[c` and the `<leader>h` actions are untouched.
- `lua/plugins/neogit.lua` -- `integrations.diffview` flipped to `true`, `diff_viewer` stated, the `<leader>gh` mapping removed, and the comments rewritten: the one arguing the deferral, the one introducing the placement mappings, and the one dividing the `<leader>g` prefix.
- `lazy-lock.json` -- a new pinned commit.
- `openspec/specs/repository-diff-view/spec.md` -- created once this change is archived.
- `openspec/specs/git-repository-ui/spec.md` -- extended with the diff-view and conflict requirements, and its window-arrangement requirement rewritten for three mappings.
- `lua/plugins/auto-session.lua` -- `pre_save_cmds` closes any open diffview view before a session is written. Without it a session records the file a diff was showing and reopens it on the next launch.
- `lua/plugins/neogit.lua` keeps one mapping where it had four.
