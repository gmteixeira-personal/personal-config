## 1. Search highlighting

- [x] 1.1 Set `hlsearch = true` in `lua/config/options.lua`, replacing the `hlsearch = false` that `add-editor-options` set, with a comment pointing at the `<Esc>` mapping as its dismissal.

## 2. General keymaps — windows

- [x] 2.1 Add `<C-h>` `<C-j>` `<C-k>` `<C-l>` in normal mode to focus the window left/down/up/right, each with a `desc`.
- [x] 2.2 Add `<M-k>` `<M-j>` for height and `<M-l>` `<M-h>` for width, resizing by 2 per press, each with a `desc`. Do not map the arrow keys: `<C-Up>` and `<C-Down>` are vim-visual-multi's, and lazy.nvim installs its stubs after `lua/config/keymaps.lua` runs, so a resize mapping there would be silently overwritten.
- [x] 2.3 Add the `<leader>s` split mappings — vertical split, horizontal split, close window, equalize. Leave `<leader>s` itself unbound, so no sequence under it waits out `timeoutlen`.
- [x] 2.4 Implement the `<C-w>\` maximize toggle: capture `winrestcmd()` before maximizing, store it in a module-local variable keyed by tab page, and execute it on the second press. Guard the single-window case so no restore command is stored for a no-op maximize.
- [x] 2.5 Wrap the restore execution so a `winrestcmd()` string referencing windows that no longer exist fails silently, and clear the stored state on every toggle regardless of outcome.

## 3. General keymaps — editing and session

- [x] 3.1 Map `<Esc>` in normal mode to `<cmd>nohlsearch<CR>`, so the highlight clears without moving the cursor.
- [x] 3.2 Map `<` and `>` in visual mode to shift and re-select (`<gv`, `>gv`).
- [x] 3.3 Map `<C-s>` in normal, insert and visual mode to write the buffer, leaving the editor in normal mode in all three cases. Use `<cmd>w<CR>` rather than `:w<CR>`, so no mode is left partially exited.
- [x] 3.4 Map `<leader>bb` to the alternate buffer.
- [x] 3.5 Map `<leader>rc` to a confirmation prompt followed by `:restart`. Use `:restart`, never `:restart!`, so it refuses while a modified buffer exists rather than discarding unsaved work.
- [x] 3.6 Keep `lua/config/keymaps.lua` free of any plugin reference, per `config-structure`.

## 4. Language-server mappings

- [x] 4.1 In the existing `LspAttach` autocommand in `lua/plugins/lsp.lua`, add `gi` → implementation, `<leader>rn` → rename, and `<leader>ca` → code action, buffer-local alongside the existing `gd`/`gD`.
- [x] 4.2 Add `K` → hover and `[d`/`]d` → previous/next diagnostic with wrapping, with a comment recording that these three restate Neovim 0.12 defaults and are listed for legibility rather than necessity.

## 5. Gitsigns

- [x] 5.1 Add `<leader>hR` → `reset_buffer` inside the existing `on_attach` in `lua/plugins/gitsigns.lua`, next to `<leader>hr`.
- [x] 5.2 Add visual-mode variants of `<leader>hs` and `<leader>hr` that pass `{ vim.fn.line("."), vim.fn.line("v") }` so they act on exactly the selected range.

## 6. Telescope

- [x] 6.1 Add an `opts` table to `lua/plugins/telescope.lua` with `defaults.mappings.i` — this file has no `opts` today, so `setup()` starts being called.
- [x] 6.2 Map `<Esc>` in the picker's insert mode to `actions.close`, and `<C-j>`/`<C-k>` to move the selection to the next and previous result, leaving Telescope's own `<C-n>`/`<C-p>` in place. Scope these to the prompt buffer in insert mode only, so they never contend with the window navigation in section 2.
- [x] 6.3 Add the `<leader>g` git pickers — tracked files, working-tree status, commit log, branches — as `keys` entries. Leave `<leader>g` itself unbound.

## 7. Static checks

- [x] 7.1 Grep the result: no bare `gr` mapping anywhere, `<leader>s` and `<leader>g` appear only as prefixes and never as mappings in their own right, and `lua/config/keymaps.lua` references no plugin module.
- [x] 7.2 Start Neovim once and confirm it loads with no error.
- [x] 7.3 Run `openspec validate --strict` for this change and resolve anything it reports.

## 8. Hand-off

- [x] 8.1 Give the user a manual test checklist covering the behaviour these specs describe — grouped by area, each item naming the keys to press and what should happen, including the cases this change deliberately guards: no window in the given direction, a single window open, a maximize toggled after the layout changed, `<C-w>` built-ins firing without delay, `<Esc>` in insert/visual/command-line mode, `<C-s>` on an unnamed buffer, `gi` with no server attached, `<leader>ca` with nothing offered, `]d` with no diagnostics, a partial-hunk stage, `<leader>hR` against the index, each git picker outside a repository, and the four pre-existing Telescope pickers now that `setup()` is called. Do not run these; the user does.
