## Why

The bootstrap change established the structure — entrypoint load order, lazy.nvim, the one-plugin-per-file rule — and installed exactly three plugins: a theme, an icon provider, and a file explorer. That is a working editor and nothing more. There is no way to find a file without knowing its path, no indication of what has changed in a buffer relative to git, no formatting, and no language intelligence of any kind: no diagnostics, no completion, no go-to-definition.

Everything below was deferred from the bootstrap change on purpose, so the layout decisions could be made once against a small surface. That structure now exists and is stable, so the deferred work can land against it. Doing it as one change rather than seven keeps the cross-cutting decisions — the keymap namespace, where formatter binaries come from, how LSP and formatting divide responsibility for the same filetype — consistent instead of resolved seven times in seven different ways.

## What Changes

### Fuzzy finding

- Install [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) with [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) as its required dependency.
- Map `<leader><leader>` to file search, plus `<leader>fg` live grep, `<leader>fb` open buffers, and `<leader>fh` help tags.

### Git integration

- Install [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) for per-line change indicators in the sign column.
- Map `]c` / `[c` to jump between hunks, and a `<leader>h*` group to stage, reset, preview, and blame a hunk.

### Formatting

- Install [conform.nvim](https://github.com/stevearc/conform.nvim), formatting on save with an LSP fallback, plus `<leader>cf` to format on demand.
- Configure formatters by filetype: `stylua` (Lua), `prettierd` with a `prettier` fallback (JS/TS/JSON/YAML/CSS/HTML/Markdown), `ruff_format` (Python), `shfmt` (shell), and LSP-provided formatting for C#.

### Language servers

- Install [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) as the server-definition registry only, and enable servers through Neovim's native `vim.lsp.enable()` / `vim.lsp.config()` API rather than the legacy `lspconfig.setup{}` call.
- Enable servers for Lua, TypeScript/JavaScript, JSON, YAML, CSS, HTML, Tailwind, Python, Bash, and C# (roslyn).
- Keep Neovim's built-in LSP mappings (`grn`, `gra`, `grr`, `gri`, `K`) and add `gd` and `gD`, which have no built-in LSP binding.
- Render diagnostics as inline virtual text plus sign-column icons.

### Completion

- Install [blink.cmp](https://github.com/Saghen/blink.cmp) as the completion engine, sourcing from LSP, buffer, path, and snippets, and advertise its capabilities to every enabled server.

### Tool management

- Install [mason.nvim](https://github.com/mason-org/mason.nvim) to install and manage external binaries inside Neovim's data directory, so a fresh clone bootstraps its own toolchain without system-wide package installs.
- Install `mason-lspconfig.nvim` to declare which language servers must be present and to enable each installed one, and `mason-tool-installer.nvim` to do the same for the formatter binaries, which `mason-lspconfig` does not cover.

### Cursor animation

- Install [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) to animate cursor movement between positions.

### Conventions this change establishes

- **`<leader>f` is the find prefix and is never itself a mapping.** Formatting therefore lives at `<leader>cf` under a `<leader>c` "code" prefix, not at `<leader>f`, so neither key stalls waiting on `timeoutlen`.
- **Formatting is conform's job, not the LSP's.** A server that also formats is used only as conform's fallback for filetypes with no configured external formatter (C# today). There is one formatting entry point and one keymap.
- **Tool binaries come from mason, plugins come from lazy.nvim.** Neither manages the other's artifacts.

Non-goals for this change: treesitter, statusline, debugging (DAP), linting beyond what a language server reports, session management, and terminal integration.

## Capabilities

### New Capabilities

- `fuzzy-finder`: Searching for files, text, buffers, and help by fuzzy-matching a query in an interactive picker.
- `git-integration`: Showing which lines differ from git HEAD, and staging, resetting, previewing, and blaming those changes from the buffer.
- `formatting`: Normalizing buffer formatting on write and on demand, with per-filetype formatter selection and a fallback chain.
- `language-servers`: Language-aware diagnostics, navigation, and refactoring supplied by a language server per filetype.
- `completion`: Context-aware completion candidates while typing, drawn from the language server and other sources.
- `tool-management`: Acquiring and updating the external binaries — language servers and formatters — that the above capabilities depend on.
- `cursor-animation`: Animated cursor movement between positions.

### Modified Capabilities

None. The five capabilities from the bootstrap change (`config-structure`, `plugin-management`, `icons`, `colorscheme`, `file-explorer`) are unchanged: this change follows their rules rather than altering them. In particular, every plugin file below obeys the one-plugin-per-file and plugin-owns-its-keymaps requirements from `config-structure`, and no new plugin declares `nvim-web-devicons` as a dependency.

## Impact

- **Files created**, one per plugin as `plugin-management` requires: `lua/plugins/telescope.lua`, `lua/plugins/gitsigns.lua`, `lua/plugins/conform.lua`, `lua/plugins/smear-cursor.lua`, `lua/plugins/blink-cmp.lua`, `lua/plugins/mason.lua`, `lua/plugins/mason-lspconfig.lua`, `lua/plugins/mason-tool-installer.lua`, `lua/plugins/lsp.lua`. Nine files, because the tool-management capability is three cooperating plugins rather than one and the one-plugin-per-file rule does not bend for them.
- **Files modified**: `lazy-lock.json` (regenerated by lazy.nvim on install). No existing `lua/` file is edited — the ownership rule from `config-structure` means every addition here is a new plugin file.
- **New runtime state**: mason writes server and formatter binaries under `~/.local/share/nvim/mason/`, tracked by `mason-lock.json`-style registry state that is *separate from* `lazy-lock.json`. blink.cmp downloads a prebuilt fuzzy-matching library on first install.
- **External dependencies added**:
  - `ripgrep` — required by telescope live grep; `fd` optional but recommended for file search.
  - `git` — already required by lazy.nvim; gitsigns needs it at runtime, not just at install.
  - `node` — required by mason to install the JS-based servers (vtsls, jsonls, yamlls, cssls, html, tailwindcss, bashls) and `prettierd`/`prettier`.
  - `.NET SDK` — required by the roslyn server for C#. Mason downloads roslyn but cannot supply the runtime it needs.
  - A C compiler is *not* required: `telescope-fzf-native` is deliberately out of scope, and blink.cmp uses a prebuilt binary on a tagged release.
- **Startup cost**: nine new plugins, all lazy-loaded except mason (which must register its `bin/` directory on `PATH` before any server or formatter is spawned). LSP attaches per-filetype, not at startup.
- **Breaking**: None for existing behavior. `gd` and `gD` are rebound from their built-in Vim meanings (local/global declaration search by text) to LSP definition/declaration, but only in buffers where a server is attached.
