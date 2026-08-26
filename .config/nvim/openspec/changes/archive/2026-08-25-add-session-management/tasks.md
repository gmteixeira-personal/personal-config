## 1. Ordering

- [x] 1.1 Confirm `<leader>qq` and `<leader>qw` are present in `lua/config/keymaps.lua` and that `openspec/specs/editor-keymaps/spec.md` carries the `<leader>q` prefix requirement — `add-quit-keymaps` is archived, so both should already hold. The shifted `<leader>qW` and the widened prefix requirement both assume it.

## 2. Session contents

- [x] 2.1 In `lua/config/options.lua`, add `vim.opt.sessionoptions` set to `blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions`, in the "Persistence and timing" section beside `undofile`.
- [x] 2.2 Comment it in the style of the surrounding lines: what a session records, and why `terminal` and `options` are absent — a restored terminal buffer is a dead window, and `options` would let a saved session override `lua/config/options.lua` itself.

## 3. The plugin

- [x] 3.1 Create `lua/plugins/auto-session.lua` returning the spec for `rmagatti/auto-session` with `lazy = false`, and a header comment stating why it cannot be lazy-loaded: the restore decision happens on `VimEnter`, before any buffer exists.
- [x] 3.2 Set `opts.suppressed_dirs = { "~/", "/", "~/Downloads" }`, commented with why those directories are excluded from saving as well as restoring.
- [x] 3.3 Leave `use_git_branch`, `root_dir`, `auto_save`, `auto_restore`, `auto_create` and `close_unsupported_windows` at their defaults, and record in comments that each default is deliberate — session identity is the directory alone, sessions live under Neovim's data directory so no project acquires a file, and `close_unsupported_windows` is what keeps a non-float Oil window out of a restore.
- [x] 3.4 Note in a comment that no `require("telescope").load_extension(...)` call is made: `:SessionSearch` finds Telescope on its own and falls back to `vim.ui.select` without it, so neither file depends on the other.

## 4. Keymaps

- [x] 4.1 Add the four `keys` entries to `lua/plugins/auto-session.lua`, each with a `desc`: `<leader>qs` → `:SessionSearch` "Search sessions", `<leader>qW` → `:SessionSave` "Save session", `<leader>qr` → `:SessionRestore` "Restore session", `<leader>qd` → `:SessionDelete` "Delete session".
- [x] 4.2 Comment why the session mappings share the quit prefix rather than taking `<leader>s`, and why saving is the shifted `<leader>qW`: `<leader>qw` already writes every modified buffer and quits, so `w` was unavailable. Name the near-miss in the comment so the next reader does not "fix" it.
- [x] 4.3 Comment why the mappings target the plugin's commands rather than its Lua functions: the commands have been stable across the renames its module API went through, and they carry the plugin's own "no session to restore" and "directory is suppressed" reporting, which the specs require.
- [x] 4.4 In `lua/plugins/which-key.lua`, rename the existing `{ "<leader>q", group = "Quit" }` entry to `{ "<leader>q", group = "Quit & sessions" }`, and update its comment the way the `<leader>r` entry's comment already explains a two-subject prefix.

## 5. Restart confirmation

- [x] 5.1 In `lua/config/keymaps.lua`, reword the `<leader>rc` confirmation so it no longer claims the session is discarded — it now describes the restart as a full rebuild of the editor process.
- [x] 5.2 Update the comment above that mapping for the same reason, keeping its `:restart` / `:restart!` note about unsaved buffers intact.

## 6. Lockfile

- [x] 6.1 Let `lazy.nvim` install the plugin and commit the resulting `lazy-lock.json` entry alongside the change, per the pinned-versions requirement in `plugin-management`.
