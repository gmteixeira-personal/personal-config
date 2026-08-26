## Why

Git in this configuration stops at the buffer. gitsigns marks and stages hunks in the file being edited, and the Telescope pickers under `<leader>g` list tracked files, status, commits and branches — but every operation that acts on the *repository* rather than on one buffer (writing a commit message, amending, switching or creating a branch, pulling, pushing, rebasing, stashing) still means leaving the editor for a shell. That is the one remaining reason to drop out of Neovim during ordinary work.

## What Changes

- Add `NeogitOrg/neogit` — a magit-style status buffer for the repository containing the working directory. Staging across files, commit and amend, branch, remote, rebase, stash and log all happen inside it, driven by its own buffer-local mappings.
- Four mappings under the existing `<leader>g` (Git) prefix open it in a chosen window arrangement:
  - `<leader>gg` — `kind = "auto"`, arrangement chosen from the window's width
  - `<leader>gr` — `kind = "replace"`, the status buffer takes over the current window
  - `<leader>gv` — `kind = "vsplit"`
  - `<leader>gh` — `kind = "split"`
- `<leader>g` itself stays unbound, as every other prefix in this configuration does.
- Loaded lazily on those keys and on the `Neogit` command; nothing is loaded at startup.
- gitsigns is untouched. Hunk-level work under `<leader>h` and `]c`/`[c` keeps working exactly as it does now, and the two operate on the same index.

## Capabilities

### New Capabilities
- `git-repository-ui`: a repository-level git interface — a status buffer listing the whole working tree and index, from which changes are staged and committed and the repository's branches, remotes, rebases and stashes are driven, opened in a window arrangement the user picks at the moment of opening.

### Modified Capabilities

None. `git-integration` continues to describe buffer-local hunk work and its requirements do not change; `fuzzy-finder`'s `<leader>g` pickers keep their keys and their behaviour; `keymap-hints` already requires the git prefix to be named, and the new mappings appear under that existing name with no change to the requirement.

## Impact

- **New file**: `lua/plugins/neogit.lua` — the whole change. No existing plugin file is edited.
- **New dependency**: `NeogitOrg/neogit`, plus `nvim-lua/plenary.nvim` which is already installed for Telescope and todo-comments. `sindrets/diffview.nvim` is deliberately *not* added; see design.
- **Keys claimed**: `<leader>gg`, `<leader>gr`, `<leader>gv`, `<leader>gh`. All four are currently unbound — Telescope holds `<leader>gf`, `<leader>gs`, `<leader>gc`, `<leader>gb` and is unaffected.
- **Lockfile**: `lazy-lock.json` gains entries on first sync.
- **Runtime requirement**: a `git` executable on `PATH`, already assumed by gitsigns and the Telescope git pickers.
