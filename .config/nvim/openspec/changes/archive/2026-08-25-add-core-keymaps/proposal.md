## Why

`lua/config/keymaps.lua` contains exactly one mapping today — the `<Space>` no-op that keeps the leader key from moving the cursor. Every general mapping worth having is still a Neovim default, which means window navigation costs a `<C-w>` prefix, resizing costs `<C-w>` plus a count, and there is no way to save, switch back to the previous buffer, or dismiss a search without typing a command.

The plugin side is further along but uneven. Gitsigns can stage and reset a hunk but not a whole buffer, and neither action works on a visual selection, so "discard my edits to this file" and "stage just these three lines" both fall back to the shell. Telescope has file, grep, buffer and help pickers but nothing for git, despite git being the one thing every one of these buffers is in. And its pickers cannot be dismissed with `<Esc>` from insert mode, which is the key every other float in the configuration closes on.

The language-server side is a deliberate gap rather than an oversight: `lua/plugins/lsp.lua` adds only `gd` and `gD`, because `language-servers` requires the built-in `gr`-prefixed mappings to be left alone. That rule was right about not *rebinding* the defaults, but it has been read as forbidding additive aliases too, which leaves rename and code action — the two most-used actions — behind a three-key sequence.

## What Changes

### New general keymaps in `lua/config/keymaps.lua`

- **Window navigation**: `<C-h>` `<C-j>` `<C-k>` `<C-l>` move focus left/down/up/right, replacing the `<C-w>`-prefixed equivalents.
- **Window resizing**: `<M-k>` and `<M-j>` change the focused window's height, `<M-l>` and `<M-h>` its width — the same four directions as the focus mappings, one modifier apart. Arrow keys are deliberately not used: `<C-Up>` and `<C-Down>` already belong to vim-visual-multi.
- **Window maximizing**: `<C-w>\` toggles the focused window between filling the tab page and the layout it came from. It is a toggle, not a one-way maximize — restoring the previous layout is the half that Neovim has no built-in for.
- **Splits**: a `<leader>s` prefix — vertical split, horizontal split, close window, equalize. `<leader>s` itself stays unbound.
- **Search dismissal**: `<Esc>` in normal mode clears the highlight left by the last search.
- **Visual indent retains the selection**: `<` and `>` in visual mode shift the selection and leave it selected, so indentation can be repeated without re-selecting.
- **Save**: `<C-s>` writes the current buffer from normal, insert and visual mode, returning to normal mode.
- **Previous buffer**: `<leader>bb` switches to the alternate buffer.
- **Restart**: `<leader>rc` restarts Neovim via the built-in `:restart`, after confirmation.

### Language-server mappings in `lua/plugins/lsp.lua`

Added to the existing `LspAttach` autocommand, buffer-local, alongside the `gd`/`gD` already there:

- `gi` → implementation, `K` → hover, `<leader>rn` → rename, `<leader>ca` → code action.
- `[d` and `]d` → previous/next diagnostic.
- **No bare `gr` mapping.** References stays on the built-in `grr`. Binding `gr` itself would put `grn`, `gra`, `gri` and `grt` behind a `timeoutlen` wait on every press, which is a worse trade than one extra keystroke for references.

### Gitsigns (`lua/plugins/gitsigns.lua`)

- `<leader>hR` resets the whole buffer to its indexed content, next to the existing `<leader>hr` for a single hunk.
- `<leader>hs` and `<leader>hr` gain visual-mode variants that act on exactly the selected line range rather than the enclosing hunk.

### Telescope (`lua/plugins/telescope.lua`)

- A `<leader>g` prefix for git pickers: tracked files, working-tree status, commit log, branches.
- `<Esc>` in the picker's insert mode closes the picker instead of dropping to its normal mode.
- `<C-j>` and `<C-k>` in the picker's insert mode move the selection down and up through the results, so the result list is driven without leaving the prompt.

### Search highlighting — **BREAKING** relative to the pending `add-editor-options` change

`add-editor-options` currently specifies that a completed search leaves no highlight and that "no command is needed to clear a highlight". This change reverses that: `hlsearch` is on, so matches stay highlighted after the search is accepted, and `<Esc>` is what clears them. Without this reversal the `<Esc>` mapping has nothing to do.

This is the only requirement in this change that contradicts existing planned behaviour, and it is stated as a modification rather than folded silently into the other change.

## Capabilities

### New Capabilities

- `editor-keymaps`: The general key mappings that hold with no plugin installed — how windows are focused, resized, split and maximized, how buffers are switched, how a search highlight is dismissed, how a buffer is saved, how a visual selection survives an indent, and how the editor is restarted. This is to `lua/config/keymaps.lua` what `editor-options` is to `lua/config/options.lua`.

### Modified Capabilities

- `language-servers`: The "built-in language mappings are preserved" requirement is narrowed to forbid *replacing* a default, not *adding* an alias to it, and a new requirement covers the alias set and diagnostic navigation.
- `git-integration`: The hunk-actions requirement gains buffer-wide reset and visual-range staging and resetting.
- `fuzzy-finder`: New requirements for the git pickers under `<leader>g`, for dismissing a picker with `<Esc>` from insert mode, and for moving through results with `<C-j>`/`<C-k>` from insert mode.
- `editor-options`: The search requirement's "no lingering highlight" clause is reversed to "highlight persists until dismissed". **This capability does not yet exist under `openspec/specs/` — it is introduced by the pending `add-editor-options` change, which must be applied and archived before this change is archived.**

## Impact

- **Files modified**: `lua/config/keymaps.lua` (currently one mapping, gains the general set), `lua/plugins/lsp.lua` (`LspAttach` block only), `lua/plugins/gitsigns.lua` (`on_attach` only), `lua/plugins/telescope.lua` (gains an `opts` table and four `keys` entries), and `lua/config/options.lua` (`hlsearch`).
- **New dependencies**: none. Gitsigns and Telescope are both already installed; every mapping added here calls an API that already ships with what is installed.
- **Ordering dependency**: satisfied. This change modifies `editor-options`, a capability the `add-editor-options` change creates; that change has been applied and archived, so the `MODIFIED` delta here has a requirement to apply against.
- **Mappings this shadows**, each an accepted trade rather than an accident:
  - `gi` in vanilla Vim jumps to the last insert position and enters insert mode. The alias is buffer-local to buffers with a server attached, so it is lost only there.
  - `<C-l>` in vanilla Vim redraws the screen, and `<C-h>` is backspace-equivalent in some terminals.
  - `<M-h/j/k/l>` are Alt chords, which many terminals send as an escape prefix followed by the letter. That puts them in the same bracket as the `<Esc>` mapping below, resolved by `ttimeoutlen`: a chord arrives as one packet and is read as Alt, a hand-typed `<Esc>` then `h` does not. Suspect these together if either misbehaves.
  - `<C-j>` and `<C-k>` are window navigation globally but result navigation inside a Telescope prompt. The picker mappings are prompt-buffer-local and insert-mode only, so the two never contend — but it is the one key pair in this change that means two different things.
  - `<Esc>` mapped in normal mode is the one mapping here with a real failure mode: terminals encode function and arrow keys as escape sequences, so a mapped `<Esc>` interacts with `ttimeoutlen`. The default `ttimeoutlen` of 50ms is well below any hand-typed sequence, so this is safe in practice, but it is the mapping to suspect if a key starts misbehaving.
  - `<C-s>` is XOFF under a terminal with legacy flow control enabled. Terminals that still do this need `stty -ixon`; this is a property of the terminal, not something the configuration can fix.
- **`timeoutlen` pressure**: `add-editor-options` sets `timeoutlen = 300`. This change adds two more `<leader>` prefixes (`<leader>s`, `<leader>g`) and two two-key sequences under existing ones. No prefix introduced here is also bound as a mapping in its own right, so none of them stalls waiting for a timeout.
- **Breaking**: only the search-highlight reversal described above. Every other item adds a mapping where none existed, or adds a variant beside an existing one.
