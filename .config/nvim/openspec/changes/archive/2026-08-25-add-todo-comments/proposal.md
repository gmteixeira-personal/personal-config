## Why

A `TODO:` or `FIXME:` left in a buffer reads exactly like the comment around it — same colour, same weight — so the reminders this configuration's user writes for themselves disappear into the file the moment the cursor leaves them. There is also no way to ask what is still outstanding across a project: `<leader>fg` can grep for the word, but the answer comes back as undifferentiated text hits, with no distinction between a note, a bug marker, and a line that merely mentions the word.

## What Changes

- Add `folke/todo-comments.nvim` as a plugin file under `lua/plugins/`, loaded on `BufReadPre` like `gitsigns` so the markers are painted with the first frame rather than appearing a moment later.
- **Keyword highlighting**: `TODO`, `FIX`/`FIXME`/`BUG`/`ISSUE`, `HACK`, `WARN`/`WARNING`/`XXX`, `PERF`/`OPTIM`/`PERFORMANCE`/`OPTIMIZE`, `NOTE`/`INFO`, and `TEST`/`TESTING`/`PASSED`/`FAILED` are highlighted where they appear as a comment marker, each keyword group in its own colour, with the rest of the line tinted so the note is legible as one unit.
- **Sign-column icon** per keyword group, at a priority *below* gitsigns', so a line that is both changed and marked keeps showing its git indicator in the single reserved sign column.
- **Highlighting is not restricted to tree-sitter comments**: `highlight.comments_only` is set to `false`. This configuration deliberately ships no parser plugin, so the default would silently leave the markers unhighlighted in nearly every filetype. The cost is that a bare `TODO:` inside a string or a code line is highlighted too.
- **Jumps on `]t` and `[t`** to the next and previous marker in the buffer. **BREAKING** for Neovim 0.12's default `]t` / `[t` (`:tnext` / `:tprevious`), which the user chose to shadow; the tag commands remain reachable as `:tnext` and `:tprevious`.
- **A `<leader>t` prefix** carrying the project-wide listings: a Telescope picker over every marker, the same set as a quickfix list, and the current buffer's markers as a location list.
- **The listings skip `openspec/`**: the markers under it are quoted inside proposals, spec scenarios, and design notes — prose *about* markers rather than outstanding work — and at present they are thirteen of the seventeen hits in this repository. The exclusion is by path, not by filetype: a `TODO:` in a README or any other document stays listed. Highlighting is unaffected; a marker in an openspec file is still coloured, signed, and reachable with `]t` while that file is open.
- `<leader>t` is added to which-key's named groups, so the prefix reads as a subject rather than a bare letter.

## Capabilities

### New Capabilities
- `todo-comments`: keyword markers in comments highlighted and signed per keyword group, in-buffer navigation between them, and project-wide listings of every marker through the picker, the quickfix list, and the location list.

### Modified Capabilities
- `keymap-hints`: the "Prefixes are listed as named groups" requirement enumerates every `<leader>` prefix this configuration defines mappings under. A `<leader>t` prefix now exists, so the enumeration gains it.

## Impact

- New file `lua/plugins/todo-comments.lua`. No other plugin file and no `lua/config/` module changes, apart from `lua/plugins/which-key.lua` gaining one group entry.
- `lazy-lock.json` gains a pinned entry for `todo-comments.nvim`. `plenary.nvim` is already installed as a Telescope dependency and is reused rather than added.
- The listings shell out to `ripgrep`, which this configuration already relies on for `<leader>fg`. No new external prerequisite. `search.args` is respelled in full rather than left at upstream's default, because the config merge replaces a list wholesale — naming the exclusion glob alone would drop the output format the result parser depends on.
- Normal-mode `]t` and `[t` change meaning. `]c` / `[c` (hunks), `]d` / `[d` (diagnostics), and every other bracket pair are untouched.
- The Telescope picker this capability opens inherits the layout, border, preview, and navigation mappings already configured globally in `lua/plugins/telescope.lua`.
