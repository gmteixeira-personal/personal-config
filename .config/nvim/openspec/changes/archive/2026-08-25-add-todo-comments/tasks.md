## 1. Plugin file

- [x] 1.1 Create `lua/plugins/todo-comments.lua` returning a single spec for `folke/todo-comments.nvim`, with `dependencies = { "nvim-lua/plenary.nvim" }` and `event = "BufReadPre"`
- [x] 1.2 Write the file's header comment: what the capability is, that `]t` and `[t` are claimed from Neovim's built-in tag mappings on purpose with `:tnext` / `:tprevious` as the replacements, and that the picker is reached through Lua rather than `:TodoTelescope` because `:Telescope` does not exist until Telescope loads
- [x] 1.3 Comment the `BufReadPre` choice with the reasoning gitsigns' file uses — the capability paints the sign column and the buffer, so `VeryLazy` would show as markers appearing after the first frame — and note that upstream defers its own setup by a tick when it is set up before `VimEnter`

## 2. Options

- [x] 2.1 Set `highlight.comments_only = false`, with a comment recording why: upstream's comment test needs either a live tree-sitter highlighter or a usable syntax stack, Neovim 0.12 starts tree-sitter for `lua`, `markdown`, `query` and `help` only, no parser plugin is installed, and the measured result is that markers go unhighlighted in some filetypes and not others
- [x] 2.2 Set `sign_priority = 5`, with a comment that it must stay below gitsigns' 6 so a line that is both marked and changed keeps showing its git indicator in the single reserved sign column
- [x] 2.3 Leave `keywords`, `colors`, `gui_style`, and `highlight.pattern` at upstream's defaults, with a comment saying the seven keyword groups and their `Diagnostic*`-derived colours are taken as they come
- [x] 2.4 Set `search.args` to upstream's five defaults plus `--glob=!**/openspec/**`, with a comment recording why the defaults are respelled (the config merge replaces a list rather than appending, and `--with-filename` / `--line-number` / `--column` are the output format `search.process` parses), why the planning directory is excluded (its markers are quoted prose, not work items), why the exclusion is by path rather than by filetype, and why the glob is unanchored
- [x] 2.5 Comment that the exclusion is the search's alone — `highlight.exclude` takes filetypes, not globs — so a marker in an excluded file is still highlighted, signed, and reachable with `]t` while that file is open, and that this is intended. Leave `search.command` and `search.pattern` untouched, so `rg` and the project's ignore rules still apply as they do for `<leader>fg`

## 3. Jump mappings

- [x] 3.1 Map `]t` in normal mode to `require("todo-comments").jump_next()` with a `desc`
- [x] 3.2 Map `[t` in normal mode to `require("todo-comments").jump_prev()` with a `desc`

## 4. Listing mappings under `<leader>t`

- [x] 4.1 Map `<leader>tt` to `require("telescope").extensions["todo-comments"].todo()` with a `desc`, and comment that the `require` is what loads Telescope and that the extension manager resolves the extension on first index, so no `load_extension` call and no Telescope dependency are needed
- [x] 4.2 Map `<leader>tq` to `require("todo-comments.search").setqflist()` with a `desc`
- [x] 4.3 Map `<leader>tl` to `require("todo-comments.search").setloclist()` with a `desc`, and comment that it puts the same project-wide set into the window's own list rather than the shared quickfix list
- [x] 4.4 Leave `<leader>t` itself unbound, as the other prefixes in this configuration are

## 5. Keymap hints

- [x] 5.1 Add `{ "<leader>t", group = "Todo" }` to the `spec` table in `lua/plugins/which-key.lua`, in the existing alphabetical position between `<leader>q` and `<leader>w`

## 6. Spec sync

- [x] 6.1 Confirm `openspec/specs/keymap-hints/spec.md` still reads as the delta describes it — the requirement being modified is "Prefixes are listed as named groups" — and leave the main spec untouched for the archive step to apply
