## Why

Markdown files open in Neovim as raw source: a heading is a line of hashes, a table is pipes that do not line up, a task list is bracket characters, and a fenced code block is indistinguishable from the prose around it. Reading a README or a set of notes means parsing the markup by eye instead of reading the document. Neovim 0.12 already ships everything needed to fix this — the treesitter engine, the `markdown` and `markdown_inline` parsers, and their highlight, injection, and fold queries — so the gap is a renderer, not infrastructure.

## What Changes

- Add `render-markdown.nvim` to the Neovim configuration as a new plugin file, so markdown buffers display headings, lists, task checkboxes, tables, block quotes, callouts, and fenced code blocks as formatted text rather than as markup.
- Load the plugin only for markdown buffers, so start-up cost for every other filetype stays at zero.
- Declare `mini.icons` as an explicit dependency, so the icon provider the renderer picks up is fixed by the spec rather than decided by plugin load order.
- Keep the raw markup visible on the line the cursor is on, so a rendered document stays editable in place instead of becoming a read-only view.
- Draw the rendering in every mode, insert included. The plugin's default omits insert mode, which blanks the rendering across the whole buffer for as long as a key is being typed rather than only on the line being edited.
- Nothing needs to turn treesitter highlighting on. Neovim's bundled `runtime/ftplugin/markdown.lua` opens with `vim.treesitter.start()`, so the injection queries are already in use and a fenced block is already coloured by its declared language before this change adds anything.
- No new treesitter parsers, no `nvim-treesitter` plugin, no external CLI, and no build step. The bundled parsers and queries cover the whole feature.

## Capabilities

### New Capabilities
- `nvim-markdown-rendering`: how Neovim displays markdown buffers — what is rendered rather than shown as markup, what stays editable, and where the syntax highlighting inside fenced code blocks comes from.

### Modified Capabilities

<!-- none -->

## Impact

- `.config/nvim/lua/plugins/render-markdown.lua` — new file, the whole change. Holds the plugin specification and its `opts` table, and nothing else: no autocommand, no keymap, no highlight override.
- `.config/nvim/lazy-lock.json` — a new pinned entry, written by `lazy.nvim` on first install and tracked by this repository.
- Behavioral side effects to accept: concealing markup shifts the visual column of text away from its byte column, so horizontal cursor motion across a rendered heading or link covers characters that are not drawn. Rendering is suppressed on the cursor's own line, so editing behaves normally where it matters.
- No change to `init.lua`, to any file under `lua/config/`, or to any existing plugin file.
- Nothing outside the Neovim configuration is affected. No LSP, formatter, or session behavior changes.
