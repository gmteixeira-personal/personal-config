## 1. Plugin file

- [x] 1.1 Create `lua/plugins/vim-visual-multi.lua` returning a spec for `mg979/vim-visual-multi`. One plugin, one file, per the existing rule; it needs no dependencies, no build step, and no external binary.
- [x] 1.2 Set `vim.g.VM_leader = "<leader>m"` inside the spec's `init`, **not** its `config`. lazy.nvim runs `init` during startup before the plugin loads, and the plugin reads `g:VM_leader` when it builds its permanent mappings at vim start — a value set in `config` arrives after those mappings already exist and is silently ignored. Add a comment saying so, because `config` is the habit-forming default for Lua plugins and the ordering is invisible from outside.
- [x] 1.3 Confirm `lua/config/options.lua` is not edited: `maplocalleader = "\\"` stays exactly as it is. Moving the plugin's leader is what makes that possible, and reversing it would put a plugin's setting in a file that must load with no plugins installed.
- [x] 1.4 Lazy-load on the entry-point keys with a `keys` list — `<C-n>` in normal and visual mode, `<C-Down>`, `<C-Up>`, `<S-Right>`, `<S-Left>`, and the `<leader>m`-prefixed entry points. Do not use `event = "VeryLazy"`: this is a tool reached for deliberately, which is the case `keys` describes, and it matches how telescope and conform load. Do not list the in-mode keys — they only exist once the plugin is active, by which point it is loaded.
- [x] 1.5 Record the leader translation in a comment: the plugin's own docs, help file, and every tutorial say `\\`, `\A`, `\/`, `\gS`, which here are `<leader>m\`, `<leader>mA`, `<leader>m/`, `<leader>mgS`. Without this a reader follows upstream documentation that silently does not apply.
- [x] 1.6 Set `g:VM_maps` to `{ Undo = "u" }` and nothing else — Redo stays unmapped, since VM's own restores nothing and leaves `E803` in `v:errmsg` — the single carve-out from leaving the in-mode namespace alone, and the only reason task 5.3's requirement can hold, since ordinary undo unwinds a multi-cursor edit one cursor at a time. Add no other `g:VM_maps` entries, no highlight-group configuration, and leave `g:VM_mouse_mappings` at its shipped default of off. The plugin's highlights link to `IncSearch` and `Visual`, which rose-pine already defines.

## 2. Leader and namespace

- [x] 2.1 Verify the leader actually moved by checking the **mappings**, not the variable: confirm `<leader>mA`, `<leader>m/`, and `<leader>m\` resolve to plugin commands. Setting `g:VM_leader` too late fails silently — the mappings simply come out on `\` — so reading back the variable proves nothing.
- [x] 2.2 Verify `\` is unclaimed: pressing the localleader key alone runs no multiple-cursor command, and no plugin mapping is defined on any `\`-prefixed sequence.
- [x] 2.3 Verify `<leader>m` is a prefix and not a mapping in its own right: pressed alone it executes nothing and defers nothing pending a timeout, it simply waits for the next key. Note `timeoutlen` may be 300 ms if `add-editor-options` has been applied.
- [x] 2.4 Verify no collision with completion: `<C-n>` in insert mode still selects the next blink.cmp candidate, while `<C-n>` in normal mode starts multiple cursors.
- [x] 2.5 Verify the other claimed keys were previously free: `<C-Down>`, `<C-Up>`, `<S-Right>`, `<S-Left>` are not bound by any other part of the configuration.

## 3. Selecting occurrences

- [x] 3.1 Verify the first press: `<C-n>` on a word selects that word and places a cursor on it.
- [x] 3.2 Verify accumulation: pressing `<C-n>` again selects the next occurrence and adds a cursor there, with the earlier cursors still in place.
- [x] 3.3 Verify wrapping: pressing `<C-n>` past the last occurrence resumes from the first occurrence in the buffer.
- [x] 3.4 Verify saturation and the single-occurrence case: pressing `<C-n>` when every occurrence is already selected adds nothing and raises no error, and `<C-n>` on a word appearing only once selects it without error.
- [x] 3.5 Verify visual-mode entry: selecting text in visual mode and pressing `<C-n>` matches the selected text rather than the word under the cursor, so a partial word or a multi-word span can be matched.

## 4. Placing cursors without matching

- [x] 4.1 Verify vertical extension: `<C-Down>` adds a cursor on the next line at the same column and `<C-Up>` on the previous, with existing cursors kept.
- [x] 4.2 Verify the buffer edges: extending past the first or last line adds no cursor beyond the buffer and raises no error.
- [x] 4.3 Verify `<leader>mA` places a cursor on every occurrence of the word under the cursor in one action.
- [x] 4.4 Verify `<leader>m/` starts a pattern search and, followed by select-all, places a cursor at each match. Verify that a pattern matching nothing adds no cursor and leaves the buffer unchanged; the search is Vim's own `/`, so a failed one reports `E486: Pattern not found` — that message is expected feedback, not a defect.
- [x] 4.5 Verify `<leader>m\` adds a cursor at the current position without matching any text.
- [x] 4.6 Verify `<S-Right>` and `<S-Left>` extend and shrink the selection at every active cursor together, keeping them aligned.

## 5. Editing at every cursor

- [x] 5.1 Verify insert-mode editing: with several cursors active, text typed in insert mode appears at every cursor.
- [x] 5.2 Verify normal-mode editing: with several cursors active, deleting a word deletes one at every cursor.
- [x] 5.3 Verify undo granularity **while cursors are still active**: after the first multi-cursor edit of a session, a single `u` reverts the edit at every cursor, returns the buffer to its exact prior state, and leaves the cursors in place. This needs the `g:VM_maps` Undo entry from task 1.6 — without it a three-cursor edit takes three presses — and it is the requirement that bounds the blast radius of a mis-aimed edit, so exercise it rather than assuming it, across insert, change, and delete edits. Verify the documented limits of the experimental command rather than assuming they are absent: a second edit in the same session reverts coarsely, and successive appends can land on a state that never existed. Verify separately that after `<Esc>` undo is ordinary undo again.
- [x] 5.4 Verify navigation between cursors moves the active cursor without adding or removing any.
- [x] 5.5 Verify skipping an occurrence leaves no cursor there and continues from the following one, and that removing a cursor leaves the rest unaffected.

## 6. Leaving the mode

- [x] 6.1 Verify `<Esc>` after an edit removes the extra cursors and leaves every edit in place.
- [x] 6.2 Verify `<Esc>` without editing removes the extra cursors and leaves the buffer unchanged.
- [x] 6.3 Verify keys return to their ordinary meaning after exit — in particular that `n`, `N`, `q`, `Q`, `S`, and `<Tab>` behave as they do in an ordinary buffer, since the plugin binds all of them while active.

## 7. Loading and rollback

- [x] 7.1 Verify the plugin does not load at startup: with no entry-point key pressed, `:Lazy` shows it unloaded and startup time is unchanged.
- [x] 7.2 Verify the first keypress is not swallowed: the very first `<C-n>` of a session loads the plugin **and** selects the word, rather than being consumed by the load. This is the characteristic failure of a `keys`-based load and is invisible until someone presses the key.
- [x] 7.3 Verify the ownership rule: every mapping is declared in `lua/plugins/vim-visual-multi.lua` and none appears in `lua/config/keymaps.lua`.
- [x] 7.4 Verify rollback: delete the plugin file, restart, and confirm its mappings are gone, `g:VM_leader` is no longer set — it lived in the deleted file's `init`, so no orphaned setting remains — no error is raised about a missing module, and nothing else in the configuration is affected. Restore the file afterwards.
- [x] 7.5 Confirm the icon rule still holds: `nvim-web-devicons` is absent from the resolved dependency tree after adding this plugin.
- [x] 7.6 Run `:checkhealth` and confirm nothing regressed against the previous baseline.
