## Context

See proposal.md — Why. The constraint that shapes everything below is the one requirement carried over from oil unchanged: the listing fills the focused window and leaves the surrounding splits visible. That rules out the obvious implementation.

`yazi.nvim` — the maintained Neovim integration — draws yazi into a floating window and offers no alternative. Its default config (`yazi-config`, upstream `lua/yazi/config.lua`) exposes `floating_window_scaling_factor`, `yazi_floating_window_winblend`, `yazi_floating_window_border` and `yazi_floating_window_zindex`, and nothing that names a window or a split. A float at `floating_window_scaling_factor = 1.0` with `yazi_floating_window_border = "none"` looks like a full window, but it is drawn over the whole editor: with two splits open it hides both, which is the behaviour the requirement rejects. So the integration is written here against the `yazi` binary directly, and `yazi.nvim` is not installed.

What that binary offers is small and stable, confirmed against yazi 26.9.1's own `--help`:

```
[ENTRIES]...                     Set the current working entry
--cwd-file <CWD_FILE>            Write the cwd on exit to this file
--chooser-file <CHOOSER_FILE>    Write the selected files to this file on open fired
```

Three facts follow from that, and the design is mostly their consequences. yazi is started with a path and hovers it. yazi reports a selection by writing a file, not on stdout — so the integration reads it after the process exits rather than parsing terminal output. And yazi reports nothing at all when quit with `q`, which is exactly the signal needed to tell "the user chose a file" from "the user backed out".

## Goals / Non-Goals

**Goals:**

- One module, `lua/config/file-explorer.lua`, that is the complete description of the explorer and can be deleted in one piece.
- yazi runs with the user's own `~/.config/yazi/`, so the editor's copy is not a second, diverging file manager.
- No terminal-mode mappings. Every key inside the explorer belongs to yazi.
- The window is always returned to an ordinary buffer, on every exit path including a failed launch.

**Non-Goals:**

- Reimplementing `yazi.nvim`'s extras: `<c-v>`/`<c-x>` split-opening, `<c-s>` Telescope grep, `<c-q>` quickfix, LSP rename-on-move. They are the price of the current-window requirement. If one of them turns out to be missed, it is a later change with its own proposal, not a stub added now.
- Changing anything under `~/.config/yazi/`. The existing `init.lua` (shared yank list) and `keymap.toml` (ripdrag bindings) apply to the instance the editor starts, which is the point.
- Making image previews work. See Risks.

## Decisions

### Run yazi in a scratch terminal buffer set into the focused window

The window's current buffer and its view are recorded, an unlisted scratch buffer is put in the window, and yazi is started into it with `vim.fn.jobstart(cmd, { term = true, on_exit = ... })`. `vim.fn.termopen()` is the older spelling of the same call and is deprecated as of Neovim 0.11; this configuration runs 0.12.5, so the `jobstart` form is used.

The terminal attaches to the *current* buffer, so the scratch buffer has to be both the window's buffer and the current one before the job starts. `vim.cmd.startinsert()` follows, which is what hands yazi the keyboard — without it the user lands in terminal-normal mode and the first keystroke goes to Neovim.

The buffer is created unlisted and scratch (`nvim_create_buf(false, true)`) rather than listed. A listed terminal buffer shows up in `<leader>b` buffer-walking and in the session file, and `lua/config/keymaps.lua` already has to step around `oil://` buffers for that reason. Unlisted from birth is cheaper than filtering it out afterwards in two places.

*Alternative considered:* a floating window via `yazi.nvim`. Rejected by the requirement, as above.

*Alternative considered:* suspending Neovim and running yazi in the host terminal (`:suspend` plus a shell wrapper). It gives yazi the real terminal, which fixes image previews, but it only works when Neovim is a child of an interactive shell — not in a GUI front end — and it cannot restore a per-window buffer because there is no window to restore into. Rejected as too fragile for the default key.

### Report the selection through `--chooser-file`, and treat silence as "no selection"

yazi is started with `--chooser-file <tmp>`, where `<tmp>` comes from `vim.fn.tempname()`. On `<Enter>` yazi writes the selected paths there, one per line, and exits. On `q` it exits having written nothing.

So `on_exit` reads the file: non-empty means open, empty or absent means restore. This is the whole toggle-replacement, and it needs no cooperation from yazi beyond a flag yazi already has. The temp file is removed in the same callback, on both paths.

`--cwd-file` is deliberately not passed. Changing Neovim's working directory as a side effect of browsing would reach outside the window the user acted in, and `auto-session` keys session identity on the working directory — so a browse could silently swap which session gets saved on quit.

*Alternative considered:* `--local-events` on stdout. It reports events live rather than on exit, which would allow reacting without the process ending, but it means parsing a stream out of a terminal job and there is nothing here that needs to act before yazi exits.

### `on_exit` work is deferred with `vim.schedule`

`on_exit` for a terminal job can run in a context where buffer and window calls are not safe, and the job's own buffer is still being torn down at that moment. Everything — reading the chooser file, restoring or opening, deleting the scratch buffer — happens inside `vim.schedule`.

Restoring is guarded on `nvim_win_is_valid`: the user can close the window yazi is in, which kills the job and fires `on_exit` against a window that no longer exists. In that case there is nothing to restore and only the scratch buffer needs deleting.

### Restore is `(buffer, view)` recorded at open time

`nvim_win_get_buf` and `vim.fn.winsaveview()` are captured before the scratch buffer goes in; on a no-selection exit the pair is put back with `nvim_win_set_buf` followed by `winrestview` inside `nvim_win_call`. `winrestview` covers the scroll position as well as the cursor, which is what the requirement asks for and what a bare cursor restore would miss.

Where the recorded buffer is gone or was never a real buffer — the editor was started on a directory, or the previous buffer has since been deleted — an empty buffer is put in the window instead. The requirement names this case explicitly because it is the one that otherwise leaves a dead terminal on screen.

### Several chosen files: first into the window, rest onto the buffer list

`--chooser-file` can hold more than one line. The first is opened in the window; the remainder are added with `:badd`, so they are reachable by buffer-walking without any of them stealing the window or disturbing the layout. This mirrors what `yazi.nvim` does by default and is the least surprising reading of "I selected these four files".

### The module lives in `lua/config/`, loaded third from `init.lua`

`lua/plugins/` cannot hold this. `plugin-management` requires every file there to return a specification for exactly one plugin, and lazy.nvim errors on a spec with no source. A file that configures a binary is not a plugin file, and faking one with a `dir` pointing back into the config would scatter the code to make the lie work.

So it is `lua/config/file-explorer.lua`, and `init.lua` gains a third `require` before `config.lazy`. The position is forced, not chosen: netrw is a built-in plugin, Neovim sources built-in plugins after `init.lua` returns, and `vim.g.loaded_netrw` has to be set before that happens. Anything later — including a lazy.nvim spec with `lazy = false`, which is how `lua/plugins/oil.lua` arranged it — is racing the thing it is trying to suppress.

This is the reason `config-structure` gets a delta. Its keymap rule previously routed every plugin-independent mapping to `lua/config/keymaps.lua`; the generalisation is that a mapping lives beside the thing it invokes, which is the rule `lua/plugins/` already follows, now stated so a config module can hold one too.

### netrw is suppressed, and directory buffers are taken over by autocmd

`vim.g.loaded_netrw` and `vim.g.loaded_netrwPlugin` are set to 1 at the top of the module. A `BufEnter` autocmd then catches any buffer whose name is a directory, opens the explorer on it, and wipes the directory buffer so it does not linger in the buffer list — the requirement's third scenario. The same autocmd covers both `nvim <directory>` and editing a directory path from inside the editor, so there is no separate `VimEnter` path.

A re-entrancy guard is needed: the explorer must not fire for a buffer it is itself responsible for, and must not stack a second yazi on top of a running one.

### A missing binary is checked before anything is touched

`vim.fn.executable("yazi") == 1` is checked first, and on failure the mapping notifies and returns having changed nothing. The failure this prevents is not hypothetical: without the check the window is already showing a scratch buffer by the time `jobstart` fails, so the user sees an empty buffer where their file was plus a job error, and the recorded buffer is restored only if `on_exit` runs — which for a failed spawn it may not.

### No terminal-mode mappings at all

The decision recorded in the user-facing choice for this change: `<leader>e` opens, and yazi's own `q` closes. Nothing is mapped in terminal mode, because `<leader>` is `<Space>` and yazi uses `<Space>` to toggle selection — mapping `<Space>e` would make Neovim hold every `<Space>` for `timeoutlen` (1000 ms here) before passing it through, degrading the key yazi uses most.

The same reasoning rules out `<Esc>`, which yazi binds to "exit visual mode, clear selection, or cancel search".

## Risks / Trade-offs

**Image and video previews degrade.** → yazi previews images with the Kitty graphics protocol or Sixel; Neovim's built-in terminal emulator implements neither, so yazi falls back to a placeholder inside the editor while working fully in a real terminal. Not mitigated, and not mitigable from this side. It is the substantive cost of running yazi inside Neovim at all, and it applies equally to `yazi.nvim`, so it is not a cost of the current-window decision specifically.

**Bulk rename opens a nested Neovim.** → yazi's `r` on a multi-selection opens the names in `$EDITOR`, which inside a Neovim terminal is another Neovim. It works — write and quit the inner one and the rename applies — but it is a surprise, and the inner instance loads this whole configuration again. Left as-is for the first cut: overriding `EDITOR` for the job would make the editor behave differently from the terminal, which this change is trying to stop. Worth revisiting if it bites.

**yazi's process can outlive the user's intent.** → Closing the window, deleting the buffer or `:qa` while yazi is open kills the job mid-operation. yazi's own operations are atomic enough that this loses no files, but a pending yank is lost. `on_exit` is written to tolerate an invalid window rather than to prevent this.

**`auto-session` and the terminal buffer.** → `close_unsupported_windows` drops a window whose buffer is not a readable file, which covers the yazi terminal, and the buffer is unlisted so `:mksession` does not record it either. Two mechanisms, and the existing comment in `lua/plugins/auto-session.lua` explains the first one in terms of a non-float Oil window. It is rewritten to name the terminal buffer, because the question a reader arrives with is unchanged and deleting the answer would leave them to rediscover it.

**Losing the editable directory buffer is irreversible in practice.** → Bulk rename survives (see above), but the workflow of editing a directory as text — deleting three lines, undoing, writing — does not. This was the deliberate trade accepted in the proposal, recorded here so it is not rediscovered as a regression.

**No plugin means no upstream maintenance.** → Roughly 80 lines of terminal plumbing become this configuration's to keep working across Neovim releases. The surface is small and the API it uses (`jobstart`, `nvim_win_set_buf`, `winrestview`) is stable, but `yazi.nvim` absorbing a Neovim change is a service being given up.

## Migration Plan

No data, no state, nothing to roll forward. `lua/plugins/oil.lua` is deleted and `lazy-lock.json` loses `oil.nvim` on the next `:Lazy sync`; `oil.nvim` on disk under `stdpath("data")/lazy/` is removed by lazy.nvim's own clean.

Rollback is `git revert` plus `:Lazy sync`. The one thing that does not come back on its own is muscle memory: `<leader>e` twice is a no-op followed by whatever yazi does with `e`, until the `q` habit forms.
