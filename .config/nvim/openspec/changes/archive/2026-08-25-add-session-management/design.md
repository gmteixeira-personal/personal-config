## Context

See proposal.md — Why. The constraints this design has to work inside are the ones this configuration already imposes:

- **`config-structure`** — a plugin's own settings and the keymaps that invoke it live in one file under `lua/plugins/`; a general editor option that works with no plugin installed lives in `lua/config/options.lua`, and no plugin file may set one.
- **Startup budget** — `lua/config/options.lua` documents a ~39 ms baseline and defers the WSL clipboard probe specifically to protect it. Session management cannot be lazy-loaded by keypress: it has to decide about restoring before the first buffer exists.
- **Existing occupants of the keyspace** — `<leader>q` already carries `<leader>qq` (quit all) and `<leader>qw` (write all and quit), both live in `lua/config/keymaps.lua` and spec'd by the now-archived `add-quit-keymaps`, whose text reserves the prefix "for leaving the editor only". `<leader>fs`/`<leader>fS` are LSP symbol pickers and stay where they are.
- **Telescope** — `lua/plugins/telescope.lua` is `keys`-lazy, and its `flex` layout is configured once and inherited by every picker.
- **Oil** — `lua/plugins/oil.lua` is `lazy = false` and takes over netrw; `<leader>e` opens it as a float.

## Goals / Non-Goals

**Goals:**

- One plugin file that fully describes the capability, deletable without residue — deleting it must leave `<leader>qq` and `<leader>qw` untouched.
- A restore that reproduces the layout, not just the file list.
- No session file inside any project directory, and no `.gitignore` entry anywhere.
- Version-tolerant configuration: prefer the plugin's user-facing commands over reaching into its modules.

**Non-Goals:**

- Named or per-branch sessions. Identity is the working directory, decided in the proposal.
- Restoring terminal buffers.
- Persisting anything the session file does not already carry — no LSP state, no marks store, no undo (`undofile` already covers undo independently).
- A session picker with its own layout. It inherits Telescope's.

## Decisions

### Plugin: `rmagatti/auto-session`

Chosen over hand-rolling `:mksession` autocommands and over `folke/persistence.nvim`.

- Against hand-rolling: the hard parts are not `:mksession` — they are deciding *whether* to restore (argument count, standard input, suppressed directories), hashing a directory to a stable filename, and cleaning up windows that must not be saved. That is the plugin's whole surface area, and reimplementing it in this repo means owning those edge cases.
- Against `persistence.nvim`: it is smaller and lazier, but restoring is explicitly manual — it deliberately has no auto-restore. The proposal's first requirement is that a bare launch restores by itself, so choosing it means writing the auto-restore layer by hand and losing the reason to take a dependency at all.

### `lazy = false`, no `priority`

The plugin must run its restore decision on `VimEnter`, before anything opens a buffer, so it cannot be `keys`- or `event`-lazy. It is not given a `priority` bump: `lazy.nvim` starts eager plugins in alphabetical order, `auto-session` sorts before `oil`, and both are only registering autocommands at that point — the ordering that matters is autocommand ordering on `VimEnter`, which `lazy.nvim` does not affect. Adding a priority would be cargo-culting.

The cost is roughly a millisecond of `require` on every launch, plus the restore itself when there is a session to restore. This is the one place the startup budget is deliberately spent, and it is spent on the thing the user asked for.

### Session identity and storage

- `use_git_branch` is left off (the default), per the proposal.
- `root_dir` is left at its default under Neovim's own data directory (`stdpath("data") .. "/sessions/"`), which is already outside every project. Nothing in the repository changes, and no ignore rule is needed.
- `auto_create` stays on, so the first exit in a new project produces a session without the user doing anything.

### `sessionoptions` lives in `lua/config/options.lua`

`sessionoptions` governs the built-in `:mksession` and takes effect with no plugin installed, so `config-structure` puts it in the general options module — not in the plugin file, even though the plugin is the only reason to change it.

Value: `blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions`.

Deviations from the plugin's suggested string, both deliberate:

- **`terminal` omitted.** Restoring a terminal buffer re-runs nothing and reliably produces a dead window or an error on restore. This configuration has no terminal plugin, so there is nothing to lose.
- **`options` omitted** in favour of `localoptions` alone. `options` persists *global* option values into the session file, which means a session saved today silently overrides `lua/config/options.lua` tomorrow — the configuration stops being the source of truth for its own settings. `localoptions` keeps per-window settings such as a manually set `wrap` or `foldmethod` without that.

### Suppressed directories

`suppressed_dirs = { "~/", "/", "~/Downloads" }`. These are places a restored layout would be wrong rather than helpful, and where `auto_create` would otherwise scatter sessions for one-off edits. Suppression applies to saving and restoring alike, so a bare `nvim` from home behaves exactly as it does today.

### Keymaps under `<leader>q`, declared in the plugin file

| Key | Command | Description |
| --- | --- | --- |
| `<leader>qs` | `:SessionSearch` | Search sessions |
| `<leader>qW` | `:SessionSave` | Save session |
| `<leader>qr` | `:SessionRestore` | Restore session |
| `<leader>qd` | `:SessionDelete` | Delete session |

The prefix is shared with the quit mappings rather than given to sessions alone. What `<leader>q` covers is the editing session as a whole — ending it, and persisting it across launches — so quitting and session management are two faces of one subject, and the repository already has the precedent for a prefix named after two: `<leader>r` is "Rename & restart". `<leader>s` stays free.

`s`, `r` and `d` are unclaimed under the prefix and go to search, restore and delete. Save is the awkward one: `w` is taken by "write all and quit", so saving a session is `<leader>qW` on the shifted key.

That is a real cost and worth stating plainly. `<leader>qw` and `<leader>qW` are one Shift apart and mean very different things — one ends the editing session, the other writes a file and carries on. A mistyped `<leader>qW` is harmless. A mistyped `<leader>qw` quits, though `confirm xall` still stops it from losing unsaved work silently. The specs pin the two apart so neither can drift into doing part of the other's job, and both descriptions are explicit ("Save session" against "Write all and quit") so the key hints distinguish them at the moment of pressing.

All four are declared as `keys` entries on the plugin spec — which is where `config-structure` requires them, and which also means the plugin's commands exist by the time a key is pressed.

They are bound to the **commands**, not to `require("auto-session")` functions. The plugin has renamed its Lua entry points across releases while the commands stayed stable, and the commands also carry the plugin's own error reporting — which is what satisfies the spec's "reports that there is no session to restore" and "reports that this directory is excluded" scenarios, instead of this configuration having to write those messages itself.

`<leader>q` is still never bound in its own right, so nothing under it waits out `timeoutlen` — the rule `add-quit-keymaps` already states and `<leader>f` and `<leader>g` already follow.

### The session picker

`:SessionSearch` uses Telescope when Telescope is installed and falls back to `vim.ui.select` when it is not. Nothing is wired up explicitly: no `require("telescope").load_extension(...)` call, no dependency edge from the session plugin to Telescope. That keeps `lua/plugins/telescope.lua` untouched, keeps its `keys`-lazy loading intact, and means deleting either file leaves the other working — Telescope loses one picker, or the session search degrades to `vim.ui.select`.

The picker inherits Telescope's configured `flex` layout like every other picker, so `fuzzy-finder`'s layout requirements are satisfied without restating them.

### Oil windows are not restored as stale windows

Two mechanisms, and only one of them is ours:

1. Neovim's `:mksession` does not record floating windows at all. `<leader>e` opens Oil as a float, so the common case needs no handling.
2. A non-float Oil window — from `nvim <directory>` — is closed by `close_unsupported_windows`, which the plugin leaves on by default and this configuration does not change.

No `pre_save_cmds` hook is added. If a stale Oil window does turn up in a restore, that is a hook to add then, against a reproduction, rather than speculative code now.

### `<leader>rc` confirmation text

`lua/config/keymaps.lua` currently asks *"Restart Neovim? The session is discarded."* That stops being true: the session is saved on the way out and restored on the way back in. The prompt is reworded to state what a restart actually costs — a full rebuild of the editor process — and the confirmation itself stays, because a restart is still not something that should happen on one mistyped keystroke. The comment above the mapping is updated for the same reason.

This touches `lua/config/keymaps.lua`, but not in a way that breaks `editor-keymaps`' independence rule: it is a string, and the mapping still calls no plugin function.

### which-key

The existing `{ "<leader>q", group = "Quit" }` entry is renamed to `{ "<leader>q", group = "Quit & sessions" }`. No entry is added and none is removed; group entries bind nothing.

### Relationship to the changes around it

- **`add-quit-keymaps` — archived, and this change depends on it.** It created the `<leader>q` prefix, `<leader>qq` and `<leader>qw`, and stated that the prefix is "for leaving the editor only". That clause is the one thing standing in the way of this change, so the `editor-keymaps` delta MODIFIES that requirement to widen the prefix to the editing session as a whole. The requirement is in `openspec/specs/editor-keymaps/spec.md` now, so the delta has a real target.
- **`add-noice-message-ui` — still in flight.** It rewrites the same named-prefix sentence in `keymap-hints`, adding "notices", where this change renames "quit" to "quit and sessions". Whichever archives last overwrites the sentence, so the archiver folds in the other's name rather than taking its delta verbatim.

## Risks / Trade-offs

- **A plugin is now on the startup path.** → It is one `require` and a `VimEnter` autocommand; the restore itself is work the user asked for. `nvim --startuptime` before and after is the check if launch ever feels slower.
- **A restore can fail on a file that has been deleted or moved since the session was saved.** → The plugin reports it and restores the rest; the session is rewritten on the next exit, so the stale entry disappears on its own.
- **Auto-save on exit can capture a layout the user did not want to keep** — a stray split, a file opened by mistake. → `<leader>qd` deletes the session, and the next launch starts clean. The alternative, prompting on every exit, is exactly the friction this change exists to remove.
- **The plugin has renamed its options across major versions** (`auto_save_enabled` → `auto_save`, `auto_session_suppress_dirs` → `suppressed_dirs`). → Binding keys to commands rather than modules limits the blast radius, and `lazy-lock.json` pins the version, so a rename arrives on a deliberate update rather than silently.
- **Two Neovim instances open on the same directory both save on exit; the last one out wins.** → Inherent to directory-keyed sessions and true of any tool in this class. `<leader>qW` in the instance whose layout matters is the workaround.
- **`<leader>qw` and `<leader>qW` are one Shift apart and do unrelated things.** → Covered above under the keymaps decision. If the near-miss turns out to bite in practice, moving the session save to a free letter under the prefix is a one-line change to the plugin file and a one-line change to the spec; nothing else depends on the key.

## Migration Plan

No migration. Nothing exists to migrate from — this configuration has never saved sessions. The first exit after the change creates the first session.

Rollback is deleting `lua/plugins/auto-session.lua`, dropping the `sessionoptions` line, restoring the `<leader>rc` string, and renaming the which-key group back to "Quit"; the leftover session files under Neovim's data directory are inert and can be deleted at leisure.
