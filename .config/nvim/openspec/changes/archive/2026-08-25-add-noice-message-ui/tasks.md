## 1. The plugin file and its load position

- [x] 1.1 Create `lua/plugins/noice.lua` returning a single spec for `folke/noice.nvim`, with `dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }` as bare names — no nested spec table, no `opts` on either dependency.
- [x] 1.2 Set `lazy = false` and `priority = 950`, which puts it after `themes/themery.lua` (1000) and ahead of `mini-icons.lua` (900). This is what routes startup messages into noice's log, and what guarantees a colorscheme is applied before nvim-notify resolves its background.

## 2. Views: the command line, messages, and the completion popup

- [x] 2.1 Add a `presets` table with `command_palette = true`, `long_message_to_split = true`, `lsp_doc_border = true`, `bottom_search = false`, `inc_rename = false`. `command_palette` is what puts the wildmenu popup under the cmdline input; `bottom_search = false` is the default, written out because the floating search is contractual.
- [x] 2.2 Leave `cmdline`, `messages`, `popupmenu` and `notify` at their defaults — enabled, no `views` or `routes` overrides beyond 2.3. Every behaviour `message-ui` names is a noice default once the presets above are set; a hand-written view table would pin today's layout and lose upstream's tuning of it.
- [x] 2.3 Record a macro and check whether the recording indicator is visible with `cmdheight = 0`. If it is not, add a single route sending `event = "msg_showmode"` to the `notify` view. If it already is, add no route — do not carry a redundant one.

## 3. Language-server rendering

- [x] 3.1 Add an `lsp` table with `hover = { enabled = true }`, `signature = { enabled = true }` and `progress = { enabled = true }`.
- [x] 3.2 Under `lsp.override`, set `["vim.lsp.util.convert_input_to_markdown_lines"] = true` and `["vim.lsp.util.stylize_markdown"] = true`, and `["cmp.entry.get_documentation"] = false` explicitly.
- [x] 3.3 Do not touch `lua/plugins/lsp.lua`. `K`, the `LspAttach` mappings and `vim.diagnostic.config` stay exactly as they are; noice installs its overrides itself.

## 4. Mappings

- [x] 4.1 Add a `keys` table with five entries, each carrying a `desc`: `<leader>nh` → `:Noice history` ("Message history"), `<leader>nl` → `:Noice last` ("Last message"), `<leader>nn` → `:Noice pick` ("Search messages & notifications"), `<leader>nd` → `:Noice dismiss` ("Dismiss all messages"), `<leader>ne` → `:Noice errors` ("Errors").
- [x] 4.2 Add `<C-f>` and `<C-b>` to the same `keys` table, mode `{ "n", "i", "s" }`, `expr = true`, `silent = true`, each calling `require("noice.lsp").scroll(4)` / `scroll(-4)` and returning the key itself — `"<C-f>"` / `"<C-b>"` — when it returns false, so the built-in page scroll runs whenever no float is open.
- [x] 4.3 In `lua/plugins/which-key.lua`, add `{ "<leader>n", group = "Notices" }` to the `spec` table, in the existing alphabetical position between `<leader>m` and `<leader>r`. This is the only edit outside the new file.

## 5. Comments

- [x] 5.1 At the density of the surrounding files, open `noice.lua` with what the plugin replaces — command line, messages, notifications, wildmenu — and state plainly that insert-mode completion is blink.cmp's and is untouched.
- [x] 5.2 Record why the load is eager at 950 rather than `event = "VeryLazy"`, which is what noice's own README suggests: VeryLazy fires after every other plugin has loaded, so the install, tool-installer and server-startup messages a history is actually reached for would never enter it. Name the startup cost as the price, and VeryLazy as the fallback if it proves material.
- [x] 5.3 Record why the colorscheme must stay ahead of it — nvim-notify resolves its background from the highlight groups on first draw and warns on every launch if none is set.
- [x] 5.4 Record why nvim-notify is a bare dependency with no options table: `plugin-management` requires one file to describe one plugin, and its defaults are adequate here.
- [x] 5.5 Record why `presets` is used instead of expanded `views`/`routes` tables, pointing at the same reasoning `which-key.lua` records for `preset = "modern"`.
- [x] 5.6 Record why `cmp.entry.get_documentation` is `false` rather than absent — nvim-cmp is not installed — and note the consequence that LSP documentation renders one way under `K` and another in blink.cmp's own documentation window.
- [x] 5.7 Record what `expr = true` is doing in the `<C-f>`/`<C-b>` mappings: `noice.lsp.scroll` returns false with no float open, and returning the key string is what makes the fallback a real page scroll rather than a recursive call.
- [x] 5.8 Record that `regex` and `bash` tree-sitter parsers are deliberately not installed and that `:checkhealth noice` reports them, that the bundled `markdown`, `markdown_inline`, `vim` and `lua` parsers cover everything else, and that no tree-sitter plugin is needed because noice probes parsers through `vim.treesitter.language.add`.
- [x] 5.9 Note beside the `keys` table that these are `keys` entries purely for consistency with the rest of `lua/plugins/` — the plugin is `lazy = false`, so they do no lazy-loading work — and that `:Noice pick` uses telescope when it is loaded and its own split otherwise, which is why this file does not require telescope.
