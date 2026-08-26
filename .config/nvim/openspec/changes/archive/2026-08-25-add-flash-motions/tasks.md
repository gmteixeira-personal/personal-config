## 1. Plugin file

- [x] 1.1 Create `lua/plugins/flash.lua` returning a single spec for `folke/flash.nvim`, with no `version` (upstream publishes no tags) and no `dependencies`
- [x] 1.2 Write the file's header comment: what the capability is, that normal-mode `s` and `S` are claimed on purpose with `cl` and `cc` as the replacements, that normal-mode `r` (replace character) is untouched and only operator-pending `r` is taken, and that visual-mode `S` is left to `nvim-surround`
- [x] 1.3 Set `opts` naming `modes.char.enabled`, `modes.char.jump_labels`, and `modes.search.enabled` explicitly, with a comment saying why these three are spelled out while everything else rides on upstream defaults

## 2. Keys

- [x] 2.1 Map `s` in normal, visual, and operator-pending mode to `require("flash").jump()`
- [x] 2.2 Map `r` in operator-pending mode to `require("flash").remote()`
- [x] 2.3 Map `S` in normal and operator-pending mode only — not visual — to the tree-sitter select wrapper from task 3.1
- [x] 2.4 Map `R` in operator-pending and visual mode to the tree-sitter search wrapper from task 3.1
- [x] 2.5 Map `<C-s>` in command-line mode to `require("flash").toggle()`
- [x] 2.6 Add `f`, `F`, `t`, `T` (normal, visual, operator-pending) and `/`, `?` (normal, visual) to `keys` so the character-motion and search hooks exist from the first press, with a comment that these entries are load triggers rather than mappings flash needs declared, and that `;` and `,` are left off because their pre-load meaning already matches their post-load one
- [x] 2.7 Give every entry a `desc` in the style the other plugin files use, so which-key lists them

## 3. Tree-sitter guard

- [x] 3.1 Add two local wrappers in the same file that `pcall(vim.treesitter.get_parser, 0)` first, call `require("flash").treesitter()` / `treesitter_search()` on success, and on failure emit one `vim.notify` at warning level naming the buffer's filetype and return without calling flash
- [x] 3.2 Comment the guard with why it exists: Neovim 0.12's runtime ships parsers for a handful of languages, `nvim-treesitter` is deliberately absent from this configuration, and an unguarded call raises in every other buffer

## 4. Spec sync

- [x] 4.1 Confirm `openspec/specs/surround-edits/spec.md` still reads as the delta describes it — the requirement being modified is "The commands do not displace an existing mapping" — and leave the main spec untouched for the archive step to apply
