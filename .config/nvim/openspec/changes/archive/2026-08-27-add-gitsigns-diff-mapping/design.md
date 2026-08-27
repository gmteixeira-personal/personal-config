## Context

See proposal.md - Why. What matters for the approach is what `gitsigns.diffthis` already does, because most of this requirement is already met by it and the work is in the gap.

Reading `lua/gitsigns/actions/diffthis.lua` in the installed version:

- The revision buffer is created with `nvim_create_buf(false, true)` -- unlisted and scratch, with `bufhidden = 'wipe'`, so it is wiped rather than merely hidden when its window goes away. It does **not** stay unlisted, though: `diffthis_rev` opens it with `vim.cmd.diffsplit({ bufname, ... })`, and an editing command sets `'buflisted'` on the buffer it opens. Verified against the installed version -- `buflisted` reads `true` once the split exists, and `:bnext` reaches the indexed version while the diff is open. **The one thing the spec asks for that upstream does not give.**
- The split is `vim.cmd.diffsplit` with `mods = { vertical = opts.vertical, split = opts.split or config.diffthis.split, keepalt = true }`. `config.diffthis.split` defaults to `'aboveleft'`, and `diff_opts.vertical` is derived from `&diffopt`, defaulting to `true` because `diffopt` carries no `horizontal`. So **the default layout is already the one the spec asks for**: indexed version left, working buffer right.
- A `BufHidden` autocmd on the revision buffer sets `vim.wo[cwin].diff = false` for the originating window, unless another diff window is still open in the tabpage. **The cleanup the spec's two dismissal scenarios need already exists**; nothing has to be written to restore the file's window.
- `M.diffthis` returns early when `vim.wo.diff` is already set. The "press the key again" scenario is upstream behavior, not something to add.
- After splitting, `diffthis_rev` calls `api.nvim_set_current_win(cwin)` -- it deliberately puts the cursor **back in the file's window**. This was at one point overridden here; see the decision below.

The listed revision buffer is the only gap. Everything else the spec describes is already true.

`gitsigns.diffthis` is async: `M.diffthis(base, opts, callback)` hands off to `async_run(callback, ...)`, so the split does not exist when the call returns. Any focus correction has to run from that third argument.

## Goals / Non-Goals

**Goals:**

- One buffer-local mapping, living with gitsigns as this configuration's convention requires.
- Layout pinned by this configuration rather than inherited by accident.
- The indexed version kept out of the buffer list.

**Non-Goals:**

- Moving the cursor. See the decision below -- this was tried and reverted.
- A toggle. `<leader>gd` opens the diff; it does not close it.
- A dedicated close mapping. `<leader>ww` reaches the diff window and `<leader>wq` closes it from there, which is two keystrokes of keys the user already has.
- Diffing against anything but the index. `gitsigns.diffthis('~1')` and friends stay available as commands; a key for each revision is a different change.
- Anything about diffview.nvim. `lua/plugins/neogit.lua` already records why it is deferred, and this change does not revisit that.
- Changing `]c` / `[c`. They are already written to defer to built-in diff navigation when `vim.wo.diff` is set, which is the state this mapping produces.

## Decisions

### The mapping goes in `on_attach`, not in `lua/config/keymaps.lua`

`lua/config/keymaps.lua` opens with "General keymaps only; mappings that invoke a plugin live with it in lua/plugins/", and every existing gitsigns mapping is declared inside `on_attach` so that outside a git repository the key simply does not exist rather than existing and erroring. The spec's last scenario is that property, so this follows the same path rather than restating it.

**Alternative considered:** declaring it in the plugin's `keys` table. Rejected: `keys` is global, and gitsigns is loaded on `BufReadPre` regardless, so `keys` would buy no lazy-loading and would cost the outside-a-repository guarantee.

### `<leader>gd` sits under a prefix two other plugins already use

`<leader>g` currently divides between neogit (`gg`, `gr`, `gv`, `gh`) and Telescope (`gf`, `gs`, `gc`, `gb`). `gd` is free, and "git diff" is the obvious expansion. The prefix itself stays unbound, as every prefix here does.

The division is now three-way, and the comment in `lua/plugins/neogit.lua` that spells out who owns what is the only place a reader would look. It gets a line. There is no shared table to update -- deliberately, because a table would put mappings somewhere other than with the plugin that implements them.

**Alternative considered:** putting it under `<leader>h` with the other gitsigns mappings. Rejected: `<leader>h` is per-hunk actions, and this acts on the whole file. `gd` also stays reachable if the diff ever moves to a different plugin.

### Layout options are passed explicitly, not inherited from `&diffopt`

`gitsigns.diffthis(nil, { vertical = true, split = "aboveleft" })` rather than a bare `gitsigns.diffthis()`, even though the bare call produces exactly this layout today.

The spec pins the arrangement -- indexed version left, working buffer right -- and `vertical` is otherwise derived from `&diffopt`. `lua/config/options.lua` does not set `diffopt` now, but adding `horizontal` to it later would silently turn this mapping's split sideways and break a spec scenario from a file that has nothing to do with git. Stating both outright is the same reasoning that made `kind = "auto"` explicit in `lua/plugins/neogit.lua`: where a setting is load-bearing, this configuration says so rather than relying on a default agreeing with it.

### The cursor is left where gitsigns puts it

`diffthis_rev` ends with `api.nvim_set_current_win(cwin)`, returning the cursor to the window the mapping was pressed in. That stands.

**This reverses an earlier decision in this same change.** The mapping originally moved focus into the diff window, so that `<leader>wq` and `<leader>bd` -- pressed without moving first -- would dismiss the diff rather than close the file. It was built, it worked, and it was wrong in use: the cursor being yanked out of the file on every press costs more than the saved window motion, and `<leader>wq` is not always what is wanted next. Reading the diff and then carrying on editing is the common case, and that case should not have to move back.

Reaching the diff to dismiss it is `<leader>ww` then `<leader>wq`, on keys that already exist and already mean that.

**Alternative considered:** making the focus move a setting. Rejected: a two-value switch for a two-keystroke difference, and it would keep the callback logic alive to serve whichever branch went unused.

Note for anyone reading the callback: it still exists, but only to unlist the revision buffer. The window scan there is not left over from the focus move -- it is how the revision's windows are identified.

### The revision buffer is put back to unlisted, in the same callback

`vim.bo[buf].buflisted = false` for the buffer of every window in the tabpage that is in diff mode and is not the window the mapping was pressed in. A conflicted file opens two revision windows -- `:2` and `:3` -- and both are unlisted, which is why this is a loop rather than a single lookup.

This undoes a side effect of `:diffsplit` rather than a decision gitsigns made -- `create_revision_buf` already asked for an unlisted buffer, and the split overrode it. The scenario it satisfies is that `<leader>bn` and `<leader>bp` do not walk into the indexed version while the diff is open.

**Alternative considered:** leaving it listed, on the grounds that `bufhidden = 'wipe'` means the buffer cannot be cycled to once the diff is closed. Rejected: the spec's scenario is about the diff being open, which is exactly when it is reachable.

**Alternative considered:** `vim.bo[buf].buflisted = false` from a `BufWinEnter` autocmd on the revision buffer. Rejected: the callback is the API's own completion signal, whereas an autocmd would have to distinguish this split from every other window opened while the async call is in flight.

**Alternative considered:** a `WinNew` or `BufWinEnter` autocmd instead of the callback. Rejected: the callback is the API's own completion signal, and an autocmd would have to distinguish this split from every other window opened while the async call is in flight.

### The mapping guards on `vim.wo.diff` itself

`M.diffthis` already returns early when the current window is in diff mode, which is what makes the "press it again" scenario a no-op. The mapping checks the same condition before calling, so the guarantee does not rest on an upstream early-return that could be relaxed. Without it, a second press would run the focus-move against a diff it did not open.

## Risks / Trade-offs

- **Dismissing the diff takes a window motion first.** → `<leader>ww` then `<leader>wq`, both already bound. Accepted deliberately: the alternative was tried and the cost of moving the cursor on every open outweighed it.
- **The index-side buffer is editable, and writing it stages the file.** → Upstream behavior for the index revision (`buftype = 'acwrite'`), unchanged here and not surfaced by the mapping. The cursor no longer starts there, so an accidental edit needs a deliberate move first.
- **The async callback can fire after the user has moved on.** → It only unlists buffers, which does not depend on where the cursor is and is not visible as a jump. The originating window is still captured, because it is what the scan excludes.
- **`<leader>g` now spans three plugins, and no single file lists the whole prefix.** → A comment in `lua/plugins/neogit.lua`, which is where the division is already written down. which-key shows the live set, which is the check that does not go stale.
