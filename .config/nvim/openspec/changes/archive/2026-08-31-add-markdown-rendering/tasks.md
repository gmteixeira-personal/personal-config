## 1. Add the plugin file

- [x] 1.1 Create `.config/nvim/lua/plugins/render-markdown.lua` returning a `lazy.nvim` spec for `MeanderingProgrammer/render-markdown.nvim` with `ft = { "markdown" }`, `dependencies = { "echasnovski/mini.icons" }`, and an `opts` table, commented in the same explanatory style as the neighbouring plugin files; verify with `nvim --headless "+lua print(vim.inspect(dofile('.config/nvim/lua/plugins/render-markdown.lua')))" +q` that the file returns a table naming the plugin
- [x] 1.2 In that same file, set `render_modes = true`, with a comment recording why upstream's default `{ "n", "c", "t" }` is not kept — omitting insert mode blanks the rendering across the whole buffer while typing rather than only on the line being edited (see design.md — Decisions); verify with `grep -n render_modes .config/nvim/lua/plugins/render-markdown.lua` that it is present and enabled
- [x] 1.2b Add no autocommand and no `init` function: Neovim's bundled `runtime/ftplugin/markdown.lua` opens with `vim.treesitter.start()`, so starting the highlighter here would be a second call to an idempotent function (see design.md — Decisions); verify with `grep -c "nvim_create_autocmd\|init =" .config/nvim/lua/plugins/render-markdown.lua` that it returns `0`
- [x] 1.3 Leave `anti_conceal` at its enabled default rather than setting it off, and verify by `grep -n anti_conceal .config/nvim/lua/plugins/render-markdown.lua` that the file either omits it or sets it enabled
- [x] 1.4 Format the new file with `~/.local/share/nvim/mason/bin/stylua .config/nvim/lua/plugins/render-markdown.lua` and verify `~/.local/share/nvim/mason/bin/stylua --check .config/nvim/lua/plugins/render-markdown.lua` reports no diff

## 2. Install and pin

- [x] 2.1 Install the plugin with `nvim --headless "+Lazy! sync" +qa` and verify it exits without error
- [x] 2.2 Verify the version is pinned by checking `grep -n render-markdown .config/nvim/lazy-lock.json` prints an entry with a commit hash
- [x] 2.3 Verify no parser manager was pulled in, by checking `grep -c nvim-treesitter .config/nvim/lazy-lock.json` returns `0`

## 3. Verify treesitter highlighting

- [x] 3.1 Write a fixture markdown file containing headings of at least two levels, a pipe table, a checked and an unchecked task item, a block quote, and a fenced `lua` code block, to use for the checks below
- [x] 3.2 Verify a highlighter is attached by running `nvim --headless -n "+e <fixture>" "+lua local b = vim.api.nvim_get_current_buf(); print(vim.treesitter.highlighter.active[b] ~= nil)" +q` and confirming it prints `true`. `active` is keyed by real buffer number, so a probe of `active[0]` reads `nil` whatever the true state is and proves nothing. Neovim attaches this highlighter itself, so the probe prints `true` under `nvim --clean` as well — the check confirms the capability's foundation is present, not that this change created it
- [x] 3.3 Verify the fenced `lua` block is highlighted as Lua rather than as prose by opening the fixture interactively and confirming its keywords and strings are colored differently from the surrounding paragraph text
- [x] 3.4 Add a fenced block declaring a language with no installed parser, open the fixture, and verify it still renders as a code block with no error message

## 4. Verify rendering behavior

- [x] 4.1 Open the fixture and verify headings of different levels are visually distinct from each other and from body text, with no literal leading hash characters shown
- [x] 4.2 Verify the pipe table is drawn with aligned columns and connected borders rather than raw pipe and hyphen characters
- [x] 4.3 Verify the checked and unchecked task items carry different marks and are distinguishable without reading the bracket characters
- [x] 4.4 Move the cursor onto a rendered heading and verify that line reverts to its raw markdown source while the lines around it stay rendered, then move away and verify the rendering returns
- [x] 4.5 Edit markup on the cursor's line — change a heading level and toggle a checkbox character — and verify the characters stay visible throughout the edit and the rendered form reflects the change once the cursor leaves the line
- [x] 4.6 Close the fixture without saving and verify `git status` reports no modification to it, confirming rendering never wrote to the file
- [x] 4.7 Cycle the colorscheme through the themes in `lua/plugins/themes/` and verify heading and code-block backgrounds stay legible in each, adjusting `opts` only if one is unreadable
- [x] 4.8 Enter insert mode on a rendered line and verify only that line goes raw — the table above it keeps its borders and the task item below it keeps its glyph — confirming `render_modes` covers insert mode rather than blanking the buffer

## 5. Verify scope and cost

- [x] 5.1 Open a Lua file and verify no markdown concealment or virtual text appears in it
- [x] 5.2 Verify the plugin does not load without markdown by running `nvim --headless "+lua print(require('lazy.core.config').plugins['render-markdown.nvim']._.loaded ~= nil)" +q` and confirming it prints `false`
- [x] 5.3 Verify `git status` shows exactly two paths changed for this feature — the new `.config/nvim/lua/plugins/render-markdown.lua` and the updated `.config/nvim/lazy-lock.json` — with `init.lua`, `lua/config/`, and every existing plugin file untouched
