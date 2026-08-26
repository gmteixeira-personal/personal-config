## Context

See `proposal.md` — Why. The constraints that shape the approach:

- `lua/plugins/` holds one plugin per file, and that file is the whole description of the plugin: options, mappings, dependencies, load condition (`config-structure`, `plugin-management`). The only edit outside the new file is the group entry in `lua/plugins/which-key.lua`, which that capability's spec requires.
- The sign column is `signcolumn=yes` — one column, permanently reserved (`editor-options`). `gitsigns` already writes into it at sign priority 6, and `git-integration` requires its per-line indicators to be visible.
- `nvim-treesitter` is deliberately absent. Neovim 0.12's runtime starts tree-sitter highlighting for `lua`, `markdown`, `query`, and `help` only; every other filetype falls back to Vim's regex syntax, or to nothing.
- `telescope.nvim` loads on `keys` and declares no `cmd`, so its `:Telescope` command does not exist until one of those keys is pressed.
- `plenary.nvim` is already installed as a Telescope dependency, and `ripgrep` is already a prerequisite of `<leader>fg`.
- Neovim 0.12 defines `]t` and `[t` by default (`:tnext` / `:tprevious`). The user chose to shadow them.

## Goals / Non-Goals

**Goals:**

- One new file, `lua/plugins/todo-comments.lua`, carrying the options, the two jump mappings, and the three listing mappings.
- Markers visible in every filetype this configuration opens, without adding a parser plugin.
- The marker signs coexist with the git indicators in the single reserved sign column, with git winning the collision.

**Non-Goals:**

- Custom keyword groups, icons, or colours. Upstream's seven groups and their `Diagnostic*`-derived colours are taken as they come; they already follow the colorscheme.
- `TodoTrouble` and `TodoFzfLua`, the two listing commands whose plugins this configuration does not have.
- Highlighting markers only inside real comments. See the decision below — that mode is not dependable here.
- Filtering a listing to a subset of keywords. `keywords=` is available on every command if it is ever wanted; no mapping spends a key on it now.

## Decisions

### `highlight.comments_only = false`

Upstream's default is `true`, and its comment test takes one of two paths: a live tree-sitter highlighter for the buffer, or, failing that, Vim's regex syntax stack at the keyword's column.

Measured against this configuration's Neovim (0.12.5, no parser plugin, upstream's default settings): a `# TODO:` in a Python buffer was highlighted, a `-- TODO:` in a Lua buffer and a `// FIXME:` in a JavaScript buffer were not. The uneven part is not that the fallback is missing — it is that whether it answers depends on the filetype's syntax file, on whether the runtime started tree-sitter for that language, and on which column the test lands in. A marker silently failing to highlight in some languages and not others is worse than the alternative.

So `comments_only` is set to `false`, which drops the comment test and matches on the highlight pattern alone. Because that pattern is `.*<(KEYWORDS)\s*:` — a keyword immediately followed by a colon — the false positives it admits are narrow: a string literal or a piece of code containing the literal text `TODO:`. The spec records this as accepted behaviour rather than as a defect.

Alternatives considered: installing `nvim-treesitter` to make the comment test dependable (rejected — a second tree-sitter runtime alongside the bundled one, and out of scope); leaving `comments_only = true` and accepting the gaps (rejected — the capability's whole point is that a marker cannot be missed).

### `sign_priority = 5`, below gitsigns' 6

Upstream's default is 8. With one column reserved, the higher-priority sign wins, so at the default a marked line that is also changed would show the marker and hide the git indicator — which `git-integration` requires to be visible.

Setting the marker priority to 5 inverts the collision: the git indicator wins on a line that is both, and the marker icon shows everywhere else. Both capabilities keep what they need in the column that exists.

Alternatives considered: `signs = false`, which removes the collision by removing the icons (rejected — the icon is what makes a marker findable when scrolling past folded or narrow code); widening the sign column to `yes:2` (rejected — it is a global display change owned by `editor-options`, made to accommodate one plugin, and it costs a column of text width in every buffer).

### Load on `BufReadPre`

The same event and the same reasoning as `gitsigns`: the capability paints into the sign column and into the buffer, so it has to be attached by the time the file is on screen, and `VeryLazy` fires after the first frame.

Upstream registers its own `BufWinEnter` / `WinNew` / `WinScrolled` / `ColorScheme` autocmds when it sets up, and its setup attaches to the buffers in all visible windows rather than waiting for the next event — so loading at `BufReadPre` covers the file that triggered the load as well as the ones opened later. `ColorScheme` is what keeps the marker colours following Themery's theme switches.

One wrinkle, accepted: upstream defers its own setup by one event-loop tick when it is set up before `VimEnter`, which is exactly the startup case. The markers therefore appear a tick after the first paint of a file passed on the command line. The sign column is already reserved, so nothing shifts when they arrive; the spec asks for the markers to appear without user action, not within a particular frame.

Alternatives considered: `event = { "BufReadPost", "BufNewFile" }` (upstream's suggestion — equivalent in effect, but `BufReadPre` is the event this configuration already uses for the other buffer-painting plugin, and consistency is worth more here than the difference); `keys`-only loading (rejected — highlighting is passive, there is no key to hang it on).

### The picker is called through Lua, not through `:TodoTelescope`

`:TodoTelescope` expands to `:Telescope todo-comments todo`, and `:Telescope` does not exist until `telescope.nvim` has loaded — this configuration loads it on `keys` and declares no `cmd`, so pressing the marker-picker mapping first in a session would fail with "Not an editor command".

The mapping therefore calls `require("telescope").extensions["todo-comments"].todo()`. The `require` is what loads Telescope (lazy.nvim loads a plugin when a module it owns is required), and Telescope's extension manager requires the extension module on first index, so no explicit `load_extension` call is needed either. The extension is a `grep_string` picker underneath, which is why it inherits the flex layout, the joined borders, the preview, and the `<C-j>`/`<C-k>`/`<Esc>` mappings from `lua/plugins/telescope.lua` without this file configuring any of them.

Adding `telescope.nvim` to this plugin's `dependencies` would also work and is rejected: it would drag Telescope in at `BufReadPre`, undoing the lazy loading `fuzzy-finder` deliberately arranged.

`:TodoQuickFix` and `:TodoLocList` have no such problem — they are commands this plugin defines itself and they run through `plenary.job` — but they are called as `require("todo-comments.search").setqflist()` / `setloclist()` for symmetry with the picker mapping and so every mapping in the file reads the same way.

### The `<leader>t` prefix, and `]t` / `[t`

`<leader>t` is free: no mapping in this configuration begins with it, and `<leader>ft` (the colorscheme picker) is a different sequence. It takes three mappings — the picker, the quickfix list, and the location list — and is named in which-key's group list, which is what the `keymap-hints` delta records.

`]t` / `[t` shadow Neovim 0.12's default tag-stack mappings. That is the user's decision, made knowingly: `:tnext` and `:tprevious` remain, this configuration has no tag file workflow, and the bracket pairs it does use — `]c` / `[c` for hunks, `]d` / `[d` for diagnostics — are untouched. The plugin file's header comment says so, in the manner `lua/plugins/flash.lua` documents its own claimed keys.

When there is no further marker, upstream emits one warning notification ("No more todo comments to jump to") and leaves the cursor alone — which is the plain report the spec asks for, routed through noice like every other notification here.

### Search scope is the working directory, with the project's ignore rules, less `openspec/`

Both the picker and the list commands shell out to `ripgrep` with no `--hidden` or `--no-ignore`, so `.gitignore` is honoured exactly as it is for `<leader>fg`. `ripgrep` is already required by that mapping; if it is ever missing, upstream reports `rg was not found on your path` rather than failing silently.

One argument is added to upstream's set: `--glob=!**/openspec/**`. The listings are meant to read as the outstanding work in the project, and `openspec/` is where this configuration keeps the planning prose — every `TODO:` and `FIXME:` under it is quoted example text inside a proposal, a spec scenario, or a design note, including the ones in this very file. Measured on this repository: seventeen marker hits in total, thirteen of them under `openspec/`, and none of those thirteen a work item. Left in, the real markers are the minority of their own list.

The exclusion is scoped to that directory by path rather than to markdown as a filetype, deliberately: a marker in a README, a doc, or any other note is a real one and stays listed. `**/openspec/**` rather than an anchored `openspec/**` so it holds wherever the editor's working directory sits relative to the planning root — both forms behave identically from the repository root, and only the unanchored one survives being opened deeper in the tree.

Setting `search.args` at all means respelling upstream's five defaults alongside the glob. `Config.setup` merges with `vim.tbl_deep_extend("force", ...)`, which replaces a list rather than appending to it, so an `args` table holding the glob alone would drop `--color=never`, `--no-heading`, `--with-filename`, `--line-number` and `--column` — the last three being the output format `search.process` parses each result line with. `search.command` and `search.pattern` are untouched. Both listing paths read the same table: `search.setlist` passes it straight to `plenary.job`, and the Telescope extension builds its `vimgrep_arguments` from it, so one setting covers all three mappings.

Alternatives considered: excluding all markdown (rejected — it is the filetype the planning happens to use, not the thing being excluded, and it would silently drop real markers from every doc in the project); filtering the results in Lua after the search (rejected — `rg` already does exactly this, and the Telescope extension has no result-filter hook to hang it on without reimplementing the picker); `.rgignore` or `.ignore` (rejected — it would also hide `openspec/` from `<leader>fg`, where searching the planning documents is wanted).

### Highlighting is not excluded, only the listings

`highlight.exclude` takes a list of *filetypes*, not globs, so there is no path filter to hang the same exclusion on — a marker in an openspec file is still coloured, signed, and reachable with `]t` and `[t` while that file is open.

That is the wanted behaviour rather than a shortfall. The noise being removed is in the project-wide listings, which are supposed to answer "what is left to do"; a buffer showing its own markers as the user reads it is answering a different question, and a spec scenario that quotes `TODO:` is more legible highlighted than not. Excluding `markdown` as a filetype would have bought nothing here and cost every real marker in every other document.

## Risks / Trade-offs

- **A `TODO:` inside a string or a code line is highlighted as a marker** → accepted, and written into the spec. The pattern requires the colon, which keeps prose mentions of the word out of it.
- **A project of this configuration's own that legitimately keeps work markers under an `openspec/` directory would have them hidden from the listings** → accepted. The directory name is an OpenSpec convention and its contents are planning artifacts by definition; `<leader>fg` still searches it, and the markers are still highlighted on opening the file.
- **Upstream changing its default `search.args`** → the respelled copy here would not follow it, and would have to be reconciled by hand. The five arguments are the output format the result parser depends on, so they are unlikely to move.
- **`]t` / `[t` no longer walk the tag stack** → `:tnext` / `:tprevious` remain, and reverting is deleting one file.
- **A marker icon is hidden on a line that is also changed** → deliberate: the git indicator is the one that must be visible, and the marker's line highlighting is unaffected, so the marker is still obvious.
- **Marker highlighting on a startup file appears one tick after the first paint** → nothing shifts when it arrives, because the sign column is already reserved.
- **Upstream's colours derive from `Diagnostic*` highlight groups** → a colorscheme without them falls back to the hex defaults, which may sit oddly against that theme. Visible immediately if it happens, and fixable with a `colors` entry.

## Migration Plan

Additive: a new plugin file plus one group entry in `lua/plugins/which-key.lua`. Rollback is deleting the file and removing the group entry; `]t` / `[t` revert to the built-in tag mappings on the next start. Dropping just the exclusion is deleting one line of `search.args` — or the whole `search` block, which returns the listings to upstream's defaults.
