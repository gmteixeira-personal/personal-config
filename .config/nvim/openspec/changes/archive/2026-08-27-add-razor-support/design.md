## Context

See proposal.md — Why. Two constraints shape everything below.

The first is that this configuration carries no tree-sitter plugin, by an explicit decision recorded in `2026-08-25-add-noice-message-ui`. The usual answer to "razor has no highlighting" is a tree-sitter parser, and taking it would reverse that decision for one filetype.

The second is the shape of the current LSP wiring, which is unusual on purpose and documented at the top of `lua/plugins/lsp.lua`: there is no `require("lspconfig").<server>.setup{}` call anywhere. nvim-lspconfig is installed only for the `lsp/<server>.lua` definitions it puts on the runtimepath, `vim.lsp.enable()` starts them, and mason-lspconfig calls that from its `automatic_enable` allowlist. A plugin that starts a server itself sits outside that pipeline and has to be kept from colliding with it.

## Goals / Non-Goals

**Goals:**

- Razor and CSHTML buffers get highlighting, completion, and diagnostics, with the highlighting covering the markup as well as the C#.
- One Roslyn server instance, whichever of C# or Razor opened first.
- The Roslyn binary stays managed by mason, as the tool-management capability requires.

**Non-Goals:**

- Adding a tree-sitter plugin or any parser.
- Changing how the other nine servers are declared, installed, or enabled.
- Blazor-specific tooling beyond what the server itself provides.
- A razor entry in `conform.lua`. Formatting is a separate capability and this change does not touch it.

## Decisions

**roslyn.nvim and a syntax plugin, not one instead of the other.** The two cover different halves of the same file and neither covers both. roslyn.nvim brings the server — completion, diagnostics, navigation — and with it semantic tokens, which colour C# and only C#: the markup a razor file is mostly made of carries no token and stays plain text. `jlcrochet/vim-razor` brings the other half — tags, attributes, values, the doctype, razor comments and `@` expressions — and brings no server at all. Taking both costs one small vimscript plugin; taking either alone leaves a visibly unfinished buffer, which is what the first pass of this change shipped. The two layers do not collide, because semantic tokens are extmarks and extmarks draw over syntax: inside a C# region the server's colouring wins and the syntax file is what sits under it.

**A syntax file rather than a tree-sitter parser, for the markup.** `tris203/tree-sitter-razor` exists and would give a real parse tree, and it is not taken: there is no tree-sitter plugin here to install it with, so the parser would drag in the plugin the `2026-08-25-add-noice-message-ui` decision left out, for one filetype. The regex syntax stack is already loaded for every other filetype in this configuration and needs nothing added to run a razor file through it. Every group `vim-razor` defines links to a standard group — `Special`, `Keyword`, `String`, `Delimiter`, `PreProc`, `Comment`, `Type` — so it takes its colours from whichever theme Themery has applied, with no per-theme configuration.

**roslyn.nvim over rzls.nvim.** rzls.nvim is the older route and roslyn.nvim's own documentation now says to uninstall it and its `rzls` binary. It is also unavailable here on its own terms: mason's registry carries no `rzls` package — checked across all 593 — so the binary would have to be fetched outside mason, which the tool-management capability does not allow.

**`roslyn_ls` leaves the `servers` list rather than staying and being overridden.** That list feeds `ensure_installed` and `automatic_enable` from one table, and the comment in `mason-lspconfig.lua` explains that the allowlist is load-bearing precisely so that nothing attaches as a server unintentionally. Leaving `roslyn_ls` in it would have `vim.lsp.enable()` start one Roslyn instance while roslyn.nvim starts another — two servers on every C# buffer, each with its own workspace. Removing the entry also removes the mason package, so the package is re-declared in `mason-tool-installer.lua`, which exists for exactly this case: a binary that must be installed but must not be auto-enabled as a server. Note the name changes across that move — `roslyn_ls` is an lspconfig config name, `roslyn-language-server` is the mason package name — and the two files take different vocabularies, which their own comments already state.

**The server config name becomes `roslyn`.** roslyn.nvim registers its server under `roslyn`, not `roslyn_ls`. The `vim.lsp.config("*", { capabilities = ... })` statement in `lsp.lua` is a wildcard and keeps applying, so blink.cmp's capabilities still reach it and no per-server capabilities line is needed. Anything that named `roslyn_ls` explicitly would have to be renamed; nothing currently does.

**Root detection is left to the plugin.** The `tailwindcss` override in `lsp.lua` exists because that server's root marker set ended in `.git`, which is pathological in `$HOME`. Roslyn roots on `.sln` and `.csproj`, which are real project markers and satisfy the workspace requirement in `language-servers` without an override. `broad_search` is left at its default `false`; it walks parent directories looking for solutions, which is the behaviour the tailwind incident is a warning about.

## Risks / Trade-offs

- **Two Roslyn servers attach if the `servers` list edit is missed.** → This is the one way the change breaks badly, and it breaks C#, not razor. The task list verifies the running client count explicitly rather than trusting that the buffer looks fine.
- **C# gains a new launcher for no C# benefit.** → Accepted, and unavoidable: co-hosting means one server serves both filetypes, so razor support cannot be added beside the existing C# setup without replacing it. `roslyn-language-server` is the same binary at the same mason-managed version, so the server's own behaviour is unchanged.
- **roslyn.nvim's razor support is recent.** → The version floor is real and checked (5.8.0-1.26262.10; installed 5.11.0-1.26380.4). If razor co-hosting misbehaves, C# is what is at stake, and the rollback is one commit.
- **The two highlighting layers can disagree at their seam.** → The syntax file reads an `@` expression with a regex and the server reads it from a compiled model, so on constructs the regex gets wrong the colour shifts as the server attaches. It is cosmetic and self-correcting, and the alternative — suppressing one layer to keep them consistent — is exactly what left half the file plain.
- **`vim-razor` is quiet upstream.** → Its last commit is 2024-05-27. It is a self-contained syntax, indent and ftplugin set with no runtime dependency and nothing to break against, so going stale costs coverage of razor syntax added after that date rather than correctness, and dropping it is one file. Its `ftdetect` is already redundant: Neovim 0.12 resolves `.razor` and `.cshtml` to the razor filetype on its own.
