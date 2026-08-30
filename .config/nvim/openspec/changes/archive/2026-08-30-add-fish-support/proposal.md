## Why

fish is now the interactive shell on this machine, so `config.fish` and the files under `conf.d/` are edited regularly. Neovim opens them today with syntax highlighting and filetype indent from its own runtime, but with no language server and no formatter: nothing reports an undefined function or a bad `set` invocation, and writing the buffer leaves whatever indentation was typed. Every other language this configuration edits gets both.

## What Changes

- Declare `fish_lsp` as a language server, so opening a fish buffer attaches one and reports diagnostics, hover, completion, and symbol navigation.
- Configure `fish_indent` as the external formatter for the `fish` filetype, so fish buffers format on write and on `<leader>cf` like every other supported filetype.
- No change to syntax highlighting, filetype detection, or indent: Neovim 0.12.5 already ships `ftplugin/fish.vim` and `syntax/fish.vim`, and they work as-is.

Explicitly out of scope: a tree-sitter parser for fish. `nvim-treesitter` is deliberately absent from this configuration, as `lua/plugins/flash.lua` records, and adding a parser for one language would reverse that decision for reasons unrelated to fish.

## Capabilities

### New Capabilities

None. Both behaviors already exist as capabilities; fish is being added to the set each covers.

### Modified Capabilities

- `language-servers`: the enumerated list of supported filetypes gains fish. The requirement states that list outright, so extending it is a spec-level change rather than an implementation detail.
- `formatting`: the enumerated list of filetypes that have an external formatter configured gains fish, which also settles that fish formatting comes from `fish_indent` rather than from the language server's own formatting support.

Not modified: `tool-management`. It already requires that a tool be found "whether it was installed by this mechanism or was already present on the system", which is exactly how `fish_indent` is reached — it ships inside the fish installation and has no mason package. `fish-lsp` is an ordinary mason package and needs no new requirement either.

## Impact

- `lua/plugins/mason-lspconfig.lua` — `fish_lsp` joins the `servers` list, which feeds both `ensure_installed` and the `automatic_enable` allowlist.
- `lua/plugins/conform.lua` — a `fish` entry in `formatters_by_ft`.
- New dependency: the `fish-lsp` mason package, an npm package requiring Node on the system. Node is present at `/usr/bin/node`.
- No new plugin, so `lazy-lock.json` is untouched. `fish_indent` adds no dependency: it is part of fish, which is already installed and is now the login shell.
- A machine running this configuration without fish installed gets no fish buffers to format, and `fish_indent` is simply never invoked; `fish-lsp` still installs, since mason fetches it from npm rather than from fish.
