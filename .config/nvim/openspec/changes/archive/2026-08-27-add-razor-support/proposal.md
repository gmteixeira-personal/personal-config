## Why

A `.razor` or `.cshtml` buffer opens as unhighlighted plain text with no language server attached. Three gaps stack up: Neovim ships no `syntax/razor.vim`, there is no tree-sitter razor parser (and this configuration deliberately carries no tree-sitter plugin), and `roslyn_ls` declares `filetypes = { 'cs' }` so it never attaches. nvim-lspconfig is explicit about the last one — its `razor/provideDynamicFileInfo` handler exists only to print `Razor is not supported. Please use https://github.com/seblyng/roslyn.nvim`.

`seblyng/roslyn.nvim` now serves Razor and CSHTML through co-hosting, superseding the older `rzls.nvim` route. It needs no tree-sitter parser, so the no-tree-sitter decision holds. Every prerequisite is already met on this machine: Neovim 0.12.5 against a required 0.12.0, `roslyn-language-server` 5.11.0-1.26380.4 against a required 5.8.0-1.26262.10, and .NET SDK 10.0.302.

The server covers one half of the highlighting. Its semantic tokens describe C# — identifiers, types, keywords, the contents of an `@code` block — and carry nothing for the HTML around them, so tags, attributes, values and the doctype still come through as undifferentiated plain text. `jlcrochet/vim-razor` is a plain Vim syntax file for the razor filetype and covers that half. It is the regex syntax stack Neovim already ships with rather than a parser, so the no-tree-sitter decision holds here too, and unlike semantic tokens its colouring neither waits for the server to load a project nor needs there to be one.

## What Changes

- Add `seblyng/roslyn.nvim` as a plugin. It starts and owns the Roslyn server for both C# and Razor.
- Add `jlcrochet/vim-razor` as a plugin, for the markup half of the highlighting. It is a syntax, indent and ftplugin file and nothing else — no server, no parser — and Roslyn's semantic tokens are extmarks, which draw over the C# regions at a higher priority than syntax, so the two layers compose rather than compete.
- Remove `roslyn_ls` from the `servers` list in `lua/plugins/mason-lspconfig.lua`, which feeds both `ensure_installed` and the `automatic_enable` allowlist. roslyn.nvim starts the server itself, and leaving `roslyn_ls` enabled would attach a second one to every C# buffer.
- Keep `roslyn-language-server` installed through mason so the binary stays version-managed, and point roslyn.nvim at it. The tool-management capability requires declared, automatic installation; dropping the package to let the plugin fetch its own binary would break that.
- **BREAKING** for C#: the server is unchanged but its launcher is not. C# buffers are served by roslyn.nvim from this change on, and the server config name becomes `roslyn` rather than `roslyn_ls`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `language-servers`: Razor joins the list of supported filetypes, so opening a `.razor` or `.cshtml` file attaches a server and gets completion and diagnostics rather than nothing. The file is highlighted in full — markup as well as C# — and the markup half of that does not depend on the server having attached.

## Impact

- `lua/plugins/mason-lspconfig.lua` — `roslyn_ls` leaves the `servers` list.
- `lua/plugins/roslyn.lua` — new file holding the plugin spec.
- `lua/plugins/vim-razor.lua` — new file holding the syntax plugin's spec.
- `lua/plugins/lsp.lua` — the `vim.lsp.config("*", ...)` capabilities statement still covers the server; a `roslyn`-named override goes here only if one proves necessary.
- `openspec/specs/language-servers/spec.md` — via the delta spec in this change.
- The mason package set is unchanged, so nothing is downloaded or removed on next launch.
- `lazy-lock.json` — a pinned revision for each of the two new plugins.
- No tree-sitter plugin is added, and no parser is installed. The `razor` filetype is already detected correctly by Neovim and needs no `ftdetect` of its own.
