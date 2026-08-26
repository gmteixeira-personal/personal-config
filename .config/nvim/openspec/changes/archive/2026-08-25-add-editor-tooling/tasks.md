## 1. Tool management (mason chain)

- [x] 1.1 Create `lua/plugins/mason.lua` returning a spec for `mason-org/mason.nvim` with `lazy = false`, so `mason/bin` is prepended to the editor's `PATH` before the first buffer read can spawn a formatter or server. Call `require("mason").setup(opts)` with defaults.
- [x] 1.2 Read the installed mason version's own documentation before writing 1.3–1.5. mason 2.x renamed the repositories (`williamboman/*` → `mason-org/*`) and changed `mason-lspconfig`'s API; do not carry over a 1.x snippet from memory or a blog post.
- [x] 1.3 Create `lua/plugins/mason-lspconfig.lua` returning a spec for `mason-org/mason-lspconfig.nvim` with `dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" }`, so mason's `setup()` runs first and lspconfig's `lsp/` definitions are on the `runtimepath` before any server is enabled.
- [x] 1.4 Set its `ensure_installed` to the ten servers: `lua_ls`, `vtsls`, `jsonls`, `yamlls`, `cssls`, `html`, `tailwindcss`, `basedpyright`, `bashls`, and the C# server (see 2.7 — leave C# out of this list if 2.7 determines it must be wired explicitly). Confirm `automatic_enable` is on, so each installed server is enabled via `vim.lsp.enable()` and no `lspconfig.setup{}` call is needed.
- [x] 1.5 Create `lua/plugins/mason-tool-installer.lua` returning a spec for `WhoIsSethDaniel/mason-tool-installer.nvim` with `dependencies = { "mason-org/mason.nvim" }`, and `ensure_installed = { "stylua", "prettierd", "prettier", "shfmt", "ruff" }`. mason-lspconfig handles servers only; without this the formatter binaries never install.
- [x] 1.6 Verify isolation: after first launch, every installed tool lives under `~/.local/share/nvim/mason/`, and nothing was installed system-wide or added to the login shell's `PATH`.
- [x] 1.7 Verify resolution: `:lua print(vim.fn.exepath("stylua"))` from inside Neovim returns the mason path, and a formatter is found by bare name without any absolute path in the configuration.
- [x] 1.8 Verify the failure path: with a tool whose runtime is absent (for example a Node-based server on a machine without `node`), that one tool reports an install failure with its reason, the other tools still install, and the editor starts normally.
- [x] 1.9 Verify the lockfile boundary: `lazy-lock.json` lists plugins only, and no installed server or formatter appears in it.

## 2. Language servers

- [x] 2.1 Create `lua/plugins/lsp.lua` returning a spec for `neovim/nvim-lspconfig` with `event = "BufReadPre"` and `dependencies = { "saghen/blink.cmp" }`. This file configures the LSP *client*; it must not call `require("lspconfig").<server>.setup{}` anywhere.
- [x] 2.2 In its `config`, set client-wide defaults with `vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })` — one statement covering every server, present and future. Do not build a per-server capabilities table.
- [x] 2.3 Add per-server overrides with `vim.lsp.config(<name>, <opts>)` only where a server needs one; `vim.lsp.config` shallow-merges onto nvim-lspconfig's shipped definition, so anything left out keeps the upstream default. Add no override that is not needed to make a server work.
- [x] 2.4 Configure diagnostics once, globally, with `vim.diagnostic.config({ virtual_text = ..., signs = ... })`: message text at end of line, per-severity icons in the sign column. Not per-server.
- [x] 2.5 Add an `LspAttach` autocommand that maps `gd` → `vim.lsp.buf.definition` and `gD` → `vim.lsp.buf.declaration`, buffer-locally with a `desc`. Add nothing else — the built-in `grn`, `gra`, `grr`, `gri`, `grt`, `gO`, and `K` stay as Neovim ships them.
- [x] 2.6 Confirm no format keymap and no `BufWritePre` formatting autocommand is defined in this file. Formatting belongs to conform alone (see group 4).
- [x] 2.7 Wire the C# server, treating it as independently failable. First try adding it to `mason-lspconfig`'s `ensure_installed` and letting `automatic_enable` pick it up. If mason's package name and lspconfig's config name are not bridged by the installed versions, fall back to an explicit `vim.lsp.config("roslyn_ls", ...)` plus `vim.lsp.enable("roslyn_ls")`. If neither works, record the finding and stop — do not add `seblyng/roslyn.nvim` without raising it first. Note that a .NET SDK must be present on the system regardless; mason cannot supply it.
- [x] 2.8 Verify lazy attach: open a Python file and confirm a server attaches to that buffer, and that `:lua =vim.lsp.get_clients()` shows no server running for a filetype that has not been opened this session.
- [x] 2.9 Verify graceful degradation: open a file of an unsupported filetype, and separately a supported filetype whose server binary is missing. In both cases the buffer opens and is fully editable, and the missing server is reported rather than erroring or blocking the open.
- [x] 2.10 Verify diagnostics: introduce an error and confirm the message renders at end of line with an error icon in the sign column; fix it and confirm both disappear; produce an error and a warning together and confirm their icons differ.
- [x] 2.11 Verify navigation: `gd` on a symbol defined in another file opens that file at the definition and pushes the previous position onto the jumplist (`<C-o>` returns). `gd` on an unresolvable symbol leaves the cursor put and reports that no definition was found. `gd` in a buffer with no attached server falls through to Neovim's built-in behavior.
- [x] 2.12 Verify the built-in mappings still work in an attached buffer: `grn` renames across references, `grr` lists references, `K` shows hover documentation.

## 3. Completion

- [x] 3.1 Create `lua/plugins/blink-cmp.lua` returning a spec for `saghen/blink.cmp` with `version = "1.*"` — a version tag, so lazy.nvim fetches the release carrying the prebuilt fuzzy-matching binary and no Rust toolchain is required.
- [x] 3.2 Configure its `opts` with sources for LSP, buffer, path, and snippets, and leave its default keymap preset unless a key conflicts with something in the namespace table in `design.md`.
- [x] 3.3 Confirm the capabilities wiring lives in `lua/plugins/lsp.lua` (task 2.2), not here — this file holds blink's own settings only.
- [x] 3.4 Verify autocompletion: typing an identifier prefix in insert mode raises a candidate list with no explicit trigger key, and it narrows as more characters are typed.
- [x] 3.5 Verify acceptance and dismissal: accepting a candidate replaces the typed prefix and leaves the cursor at the end of the inserted text; dismissing the list leaves the typed text exactly as entered and stays in insert mode.
- [x] 3.6 Verify non-interference: with the list open and an entry highlighted, typing ordinary characters inserts exactly those characters and does not insert the highlighted candidate; leaving insert mode closes the list without inserting anything.
- [x] 3.7 Verify sources: LSP candidates carry their kind and detail in an attached buffer; path candidates appear when typing a path fragment; and in a buffer with no attached server, buffer-word, path, and snippet candidates still appear with no error.

## 4. Formatting

- [x] 4.1 Create `lua/plugins/conform.lua` returning a spec for `stevearc/conform.nvim` with `event = "BufWritePre"` and a `keys` entry for `<leader>cf` → `require("conform").format()` with a `desc`.
- [x] 4.2 Set `formatters_by_ft`: `lua = { "stylua" }`; `js`/`jsx`/`ts`/`tsx`/`json`/`jsonc`/`yaml`/`css`/`scss`/`html`/`markdown` = `{ "prettierd", "prettier" }` (both listed, so a machine with only one still formats); `python = { "ruff_format" }`; `sh`/`bash` = `{ "shfmt" }`; `cs = {}` — empty on purpose, so the LSP fallback engages.
- [x] 4.3 Set `format_on_save` to return `{ timeout_ms = 500, lsp_format = "fallback" }`. `"fallback"`, not `"prefer"` or `"first"`: the server formats only when the filetype has no available external formatter.
- [x] 4.4 Confirm `<leader>f` is not bound anywhere as a mapping in its own right, so it remains a pure prefix for the telescope mappings in group 6 and never waits out `timeoutlen`.
- [x] 4.5 Verify on-write formatting: writing a misformatted Lua buffer replaces its contents with stylua's output and writes the formatted text to disk; writing an already-formatted buffer changes nothing and preserves the cursor position.
- [x] 4.6 Verify on-demand formatting: `<leader>cf` formats in place without writing to disk, and the result is a single undoable edit (one `u` restores the pre-format text).
- [x] 4.7 Verify the fallback chain: a C# buffer is formatted by the attached server (requires 2.7 to have succeeded); a filetype with neither an external formatter nor a formatting-capable server writes unchanged with no error; and removing `prettierd` from `PATH` makes a TypeScript buffer format via `prettier` with no error about the missing daemon.
- [x] 4.8 Verify failure handling: formatting a syntactically invalid file leaves the buffer unmodified, completes the write, and surfaces the formatter's error rather than swallowing it.
- [x] 4.9 Verify the single entry point: for a TypeScript buffer, which has both prettier and a formatting-capable server, `<leader>cf` and format-on-save produce identical output, and no other keymap in the configuration formats via the LSP.

## 5. Git integration

- [x] 5.1 Create `lua/plugins/gitsigns.lua` returning a spec for `lewis6991/gitsigns.nvim` with `event = "BufReadPre"` — not `VeryLazy`, which would let the sign column pop in after the first frame is painted.
- [x] 5.2 In its `on_attach`, map `]c` and `[c` to next/previous hunk, buffer-locally, guarded on `vim.wo.diff`: when the buffer is in diff mode the mapping must return the literal `]c` / `[c` so Neovim's built-in diff navigation runs instead.
- [x] 5.3 In the same `on_attach`, map the hunk actions buffer-locally: `<leader>hs` stage, `<leader>hr` reset, `<leader>hp` preview, `<leader>hb` blame line. Check the installed gitsigns version for the current names of these functions before writing them — v1.0 changed the staging API. Leave `<leader>h` itself unbound.
- [x] 5.4 Confirm these mappings are buffer-local via `on_attach`, so they do not exist at all in a buffer outside a git repository rather than existing and erroring.
- [x] 5.5 Verify signs: editing a tracked line marks it as changed without saving; adding lines marks them as added; deleting lines marks the position of the deletion; undoing back to the indexed content clears the indicator.
- [x] 5.6 Verify a file outside any git repository opens with no indicators and no error.
- [x] 5.7 Verify hunk navigation: with two separate changed blocks, `]c` from above the first moves to it and again moves to the second, and `[c` moves back. Then open a diff and confirm `]c` performs built-in diff navigation.
- [x] 5.8 Verify hunk actions on a scratch repository: staging one of two hunks adds only that hunk's lines to the index and leaves the other unstaged (`git diff --cached` confirms); resetting a hunk restores the indexed content and clears its indicator; previewing shows old and new content while modifying neither the buffer nor the index; blame reports commit, author, and date for the current line.
- [x] 5.9 Verify that invoking stage or reset with the cursor on an unchanged line does nothing and raises no error.

## 6. Fuzzy finder

- [x] 6.1 Create `lua/plugins/telescope.lua` returning a spec for `nvim-telescope/telescope.nvim` with `dependencies = { "nvim-lua/plenary.nvim" }`, lazy-loaded by its `keys` alone. Do not add `telescope-fzf-native` — it needs a C toolchain and is deliberately out of scope.
- [x] 6.2 Declare all four mappings in this file's `keys`, each with a `desc`: `<leader><leader>` → file search, `<leader>fg` → live grep, `<leader>fb` → buffers, `<leader>fh` → help tags. None may appear in `lua/config/keymaps.lua`.
- [x] 6.3 Verify file search: `<leader><leader>` narrows on a filename fragment and updates per keystroke; selecting an entry opens it in the invoking window and closes the picker; cancelling leaves the buffer and cursor position exactly as they were.
- [x] 6.4 Verify the prefix: pressing `<leader>f` executes nothing and defers nothing pending a timeout — it simply waits for the next key.
- [x] 6.5 Verify live grep: a query lists matching lines with file and line number, selecting one opens that file with the cursor on the matched line, and a query matching nothing shows an empty list with no error. Confirm `ripgrep` is installed first — without it results are silently empty, which reads as "no matches"; `:checkhealth telescope` reports its absence.
- [x] 6.6 Verify buffers and help: with two or more buffers open, `<leader>fb` switches to a selected one; `<leader>fh` opens the help window positioned at a selected tag.

## 7. Cursor animation

- [x] 7.1 Create `lua/plugins/smear-cursor.lua` returning a spec for `sphamba/smear-cursor.nvim` with `event = "VeryLazy"` — purely decorative, so it must not sit on the startup path — and default `opts`.
- [x] 7.2 Verify the animation: a large jump such as `G` draws a visible trail between the two positions, and moving between windows animates across them.
- [x] 7.3 Verify it changes no state: after an animation the buffer is byte-identical and unmodified, keystrokes typed mid-animation are all applied in order with none dropped, and the cursor ends at exactly the targeted position.
- [x] 7.4 If the animation is visibly laggy over the WSL2 terminal connection, record it — deleting this one file removes the plugin completely with nothing else to unwind.

## 8. Cross-cutting verification

- [x] 8.1 Confirm the single icon provider survived: `:Lazy` shows no `nvim-tree/nvim-web-devicons` anywhere in the resolved dependency tree. Telescope, mason, and blink.cmp are each capable of pulling it transitively, so check the resolved tree, not just the specs as written.
- [x] 8.2 Confirm the ownership rule held: `lua/config/options.lua` and `lua/config/keymaps.lua` are unchanged by this work, and no plugin added here contributed a line to either.
- [x] 8.3 Confirm the one-plugin-per-file rule held: nine new files under `lua/plugins/`, each returning a spec for exactly one plugin, with cooperating plugins expressed as `dependencies` edges rather than as extra specs in one file.
- [x] 8.4 Confirm the keymap namespace has no prefix that is also a mapping: `<leader>f`, `<leader>c`, and `<leader>h` are each pressed alone and none executes anything or stalls.
- [x] 8.5 Confirm startup ordering end to end on a clean machine state: launch with no plugins and no mason tools installed, and check that lazy.nvim installs the nine plugins, mason installs the servers and formatters in the background with the editor usable throughout, and the second launch downloads nothing and adds no startup delay.
- [x] 8.6 Run `:checkhealth` and confirm mason, telescope, gitsigns, and the LSP sections report no errors, and that any warnings are limited to the known external prerequisites (`node`, .NET SDK, `ripgrep`).
- [x] 8.7 Confirm rollback works per plugin: delete one of the nine files, restart, and confirm its keymaps are gone, no error is raised about a missing module, and nothing else in the configuration is affected.
