## Context

The bootstrap change is implemented and stable: `init.lua` loads options, then keymaps, then lazy.nvim, which imports every file in `lua/plugins/`. Three plugins are installed. Neovim is **0.12.5**. See `proposal.md` — Why for motivation, and the seven specs under `specs/` for the behavior contract.

Four properties of the existing configuration constrain everything below, and all four are inherited rather than chosen here:

1. **One plugin per file, and a plugin file is the complete description of that plugin** (`config-structure`, `plugin-management`). Nine plugins therefore means nine files, and no plugin's settings or keymaps may appear in `lua/config/`.
2. **`lua/config/options.lua` and `lua/config/keymaps.lua` must load with zero plugins installed.** Nothing here may add a general-module dependency on a plugin.
3. **mini.icons is the only icon provider** and `nvim-web-devicons` must never be listed as a dependency. Telescope, mason, and blink.cmp all display icons; all three must be checked for a devicons dependency that would reintroduce a second provider.
4. **`lazy-lock.json` pins plugin versions.** It cannot pin the *tool* versions this change introduces — that is a new and separate axis of reproducibility, discussed below.

Two further constraints come from the environment rather than the configuration: this is WSL2, so binaries installed by mason run under Linux and must be Linux builds; and the directory is still not a git repository, so no lockfile of any kind is committed.

## Goals / Non-Goals

**Goals:**

- One keymap namespace with no prefix ambiguity, decided once here rather than accreting per plugin.
- One formatting path, so a filetype covered by both an external formatter and a formatting-capable server cannot format two different ways.
- Server and formatter binaries provisioned by the configuration itself, so a fresh clone is self-sufficient given a language runtime.
- Lazy loading that is *correct* rather than aggressive: a plugin loads before the first event that needs it and no earlier.

**Non-Goals:**

- A per-server tuning pass. Servers get their upstream defaults plus the minimum override needed to work; tuning belongs to whoever hits a specific annoyance.
- Any abstraction over the LSP API. Neovim 0.12's `vim.lsp.config` is the interface; no wrapper is introduced.
- Reproducibility of tool versions to the standard `lazy-lock.json` provides for plugins. Explicitly accepted as a gap; see Risks.
- Startup-time optimization beyond the lazy-load triggers listed. Nine plugins still does not justify measuring milliseconds.

## Decisions

### Native `vim.lsp.enable()`, with nvim-lspconfig demoted to a data source

Servers are enabled with `vim.lsp.enable(name)` and configured with `vim.lsp.config(name, opts)`. `require("lspconfig").<server>.setup{}` is not called anywhere.

nvim-lspconfig is still installed, but only for the `lsp/<server>.lua` files it ships — the per-server command lines, root-directory detection, and filetype lists that nobody wants to maintain by hand. Neovim 0.11+ resolves those from the `runtimepath` automatically, so installing the plugin is the entire integration; `vim.lsp.config(name, ...)` then *merges* an override on top of the shipped definition rather than replacing it.

The payoff is that server setup stops being a plugin API and becomes an editor API. Overrides are shallow-merged onto upstream defaults, `vim.lsp.config("*", ...)` provides defaults to every server at once (used below for capabilities), and the configuration survives nvim-lspconfig's own churn because it no longer calls into it.

*Alternative considered:* the classic `lspconfig.setup{}` path. Rejected because it is the deprecated route on 0.12, it has no equivalent of the `"*"` wildcard so capabilities must be threaded into every server individually, and it is the thing mason-lspconfig v2 stopped doing. Its one real advantage — that nearly every tutorial online uses it — is a reason to leave a comment in the file explaining the divergence, not a reason to adopt it.

### mason installs binaries; three plugins, three jobs

- **mason.nvim** installs and updates binaries under `stdpath("data")/mason/`, and prepends `mason/bin` to the *editor's* `PATH`. That last part is the whole reason it exists in this design: it makes every managed binary resolvable by bare name to anything Neovim spawns, which is what `specs/tool-management` requires for both formatters and servers.
- **mason-lspconfig.nvim** declares the required *servers* via `ensure_installed` and, through `automatic_enable`, calls `vim.lsp.enable()` for each installed one. It is the bridge between mason's package names and lspconfig's config names — the two do not agree (`lua-language-server` vs `lua_ls`), and hand-maintaining that mapping is exactly the kind of table that rots.
- **mason-tool-installer.nvim** does the same `ensure_installed` job for the *formatters*. mason-lspconfig deliberately handles servers only, so without this third plugin `stylua`, `prettierd`, `shfmt`, and `ruff` would have to be installed by hand with `:MasonInstall` — which fails `specs/tool-management`'s "no user command required" scenario.

Load order is a hard dependency chain: `mason.setup()` → `mason-lspconfig.setup()` → everything that spawns a binary. It is expressed as lazy.nvim `dependencies` edges rather than as priorities, so it holds regardless of file order.

mason itself is the one plugin here that loads eagerly. `PATH` must be modified before the first formatter or server is spawned, and both of those can happen on the first buffer read.

*Alternative considered:* system-installed servers only, configured against whatever is on `PATH`. Rejected for this tool list specifically. `lua-language-server`, `basedpyright`, `vtsls`, `stylua`, and `shfmt` are all absent or badly stale in Debian/Ubuntu repositories, so "system install" would in practice mean a hand-written mix of `npm -g`, `pip`, and `cargo install` — which is what mason is, minus the manifest, minus the isolation, and plus global `PATH` pollution. Worth revisiting only if the tools ever come under a real system package manager such as nix or mise.

### Two lockfiles, and the honest reason there are two

`lazy-lock.json` pins plugins. mason pins tools in its own registry state. They are separate files, updated by separate commands, and neither knows about the other.

This is a real regression against `plugin-management`'s reproducibility intent, and it is accepted rather than solved: `mason-lock.nvim` exists to close it, but it is a fourth plugin in a chain that is already three deep, for a benefit that is currently zero because nothing here is under version control. `specs/tool-management` therefore *requires* the separation rather than pretending it away — a plugin update must not silently move a tool version, and vice versa. Revisit when the config is in git.

### The keymap namespace is decided here, once

| Key | Meaning |
|---|---|
| `<leader><leader>` | find files |
| `<leader>f` | **prefix only** — find (`fg` grep, `fb` buffers, `fh` help) |
| `<leader>c` | **prefix only** — code (`cf` format) |
| `<leader>h` | **prefix only** — hunk (`hs` stage, `hr` reset, `hp` preview, `hb` blame) |
| `<leader>e` | toggle file explorer (existing) |
| `gd`, `gD` | LSP definition, declaration |
| `]c`, `[c` | next/previous hunk |

The one rule behind the table: **a key that is a prefix is never also a mapping.** Binding `<leader>f` to format while `<leader>fg` exists means every format waits out `timeoutlen` first — a delay the user feels on every single format and cannot explain. Hence `<leader>cf`, not `<leader>f`. The `<leader>c` prefix is chosen over cramming format into `<leader>ff` because "code" is where the next few additions naturally go (code action, code lens, diagnostics list) if the built-in `gr*` mappings ever prove too obscure.

Neovim 0.11+ already ships `grn` (rename), `gra` (code action), `grr` (references), `gri` (implementation), `grt` (type definition), `gO` (document symbols), and `K` (hover). These are kept as-is. Only `gd` and `gD` are added, because Neovim provides no built-in *LSP* binding for them — the built-in `gd` is a text-based local-declaration search, which is strictly worse when a server is attached and is what gets shadowed.

### conform owns formatting outright; servers format only as its fallback

conform is configured with `formatters_by_ft` per filetype and `format_on_save` returning `{ timeout_ms = 500, lsp_format = "fallback" }`. `<leader>cf` calls the same `conform.format()`. No `LspAttach` handler defines a format keymap, and no `BufWritePre` autocommand calls `vim.lsp.buf.format()`.

`lsp_format = "fallback"` is the load-bearing word: the server formats **only** when the filetype has no available external formatter. C# is the case that exists today — roslyn formats it, because configuring `cs = {}` leaves the list empty and the fallback engages. Every other supported filetype resolves to an external binary and never reaches the server.

The alternative — `lsp_format = "prefer"`, or letting each server keep its own format-on-save — produces the failure this decision exists to prevent: a TypeScript buffer formatted by prettier on `<leader>cf` and by vtsls on write, differing on quote style, with nothing in the config that says which one is supposed to win.

`timeout_ms = 500` with conform's default `async = false` on save: the write blocks briefly, and on timeout the file is written unformatted rather than the write being lost. That trade — a possible unformatted save over a possible lost save — is the one `specs/formatting` requires.

Formatter assignments:

| Filetype | Formatter |
|---|---|
| lua | `stylua` |
| js, jsx, ts, tsx, json, jsonc, yaml, css, scss, html, markdown | `prettierd`, falling back to `prettier` |
| python | `ruff_format` |
| sh, bash | `shfmt` |
| cs | *(empty — LSP fallback)* |

`prettierd` before `prettier` is a real latency decision, not a preference: `prettier` pays Node startup on every save, `prettierd` keeps a daemon. Listing both means a machine with only one still formats, satisfying the "falling back within a filetype's formatter list" scenario.

`ruff_format` rather than `black`: ruff is a single static binary with no Python-environment coupling, which matters when the formatter is spawned by the editor rather than from an activated virtualenv.

### blink.cmp, with capabilities wired in exactly one place

blink.cmp is installed on a version tag (`version = "1.*"`) so lazy.nvim fetches the release with the prebuilt Rust fuzzy-matching binary. Building from source would add a Rust toolchain to this change's external dependencies for no user-visible benefit.

Capabilities reach servers through a single call:

```lua
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })
```

One statement, every server, present and future. This is the concrete payoff of the wildcard mentioned earlier, and it is why `specs/language-servers` states the requirement as "without being configured per server" — a per-server capabilities table is the classic way this configuration rots, with the eleventh server silently missing snippet support because someone forgot a line.

The call lives in `lsp.lua`, not `blink-cmp.lua`, and blink is listed as a dependency of nvim-lspconfig so it is loaded when that line runs. The ownership rule says a plugin file holds *that plugin's* settings; this line configures the LSP client, not blink.

*Alternative considered:* nvim-cmp. It is the incumbent and has more third-party sources, but it needs four to five companion plugins and a large mapping table to reach what blink does with `opts`. Against a nine-plugin change that is already at its complexity ceiling, that is the wrong trade. Built-in `vim.lsp.completion` was also considered and rejected: it is genuinely zero-plugin, but it has no fuzzy matching and no non-LSP sources, so `specs/completion`'s buffer, path, and snippet requirements would go unmet.

### C# is the one server that is not routine

roslyn is unlike the other nine. Its mason package name, its lspconfig config name, and whether mason-lspconfig's mapping table connects the two are all things to verify against the installed versions rather than assume — and unlike every other server here, it needs a **.NET SDK already on the system**, which mason cannot provide.

The implementation therefore treats C# as a task that can fail independently: if `automatic_enable` does not pick it up, fall back to an explicit `vim.lsp.config("roslyn_ls", ...)` plus `vim.lsp.enable("roslyn_ls")`, and if that too proves unworkable on the installed versions, `seblyng/roslyn.nvim` is the escape hatch — at the cost of a tenth plugin. The other nine servers must not be blocked on it, and `specs/language-servers` is written so that a missing server degrades to "buffer opens and is editable" rather than to an error.

### Lazy-load triggers, chosen per plugin from what must be true first

| Plugin | Trigger | Why |
|---|---|---|
| mason | eager | `PATH` must be set before the first spawn |
| mason-lspconfig, mason-tool-installer | after mason | dependency edge, not a priority |
| nvim-lspconfig (+ diagnostics, keymaps) | `BufReadPre` | must be configured before a buffer that would attach a server exists |
| conform | `BufWritePre` + `<leader>cf` | nothing before a write or an explicit format needs it |
| gitsigns | `BufReadPre` | signs must be present on the first painted frame, not after |
| telescope | its keymaps | nothing loads it but a keypress |
| blink.cmp | `InsertEnter` (its default) | no completion before insert mode |
| smear-cursor | `VeryLazy` | purely decorative; must not be on the startup path |

`BufReadPre` rather than `VeryLazy` for the LSP and gitsigns is deliberate: `VeryLazy` fires after the first buffer is already displayed, which for gitsigns means a visible pop-in of the sign column and for the LSP means the first buffer of a session can miss its `FileType` attach.

### `]c` / `[c` must not shadow diff mode

gitsigns' hunk navigation is defined inside its `on_attach`, buffer-locally, and guarded: when `vim.wo.diff` is true the mapping returns the literal `]c` / `[c` so Neovim's built-in diff navigation runs. Without the guard, opening a diff — including the one gitsigns itself opens — leaves the user unable to navigate it with the keys that exist for exactly that purpose.

The `<leader>h*` mappings are likewise buffer-local via `on_attach`, so they simply do not exist in a buffer outside a git repository, rather than existing and erroring.

### Deliberate omissions

- **telescope-fzf-native is not installed.** It needs `make` and a C compiler, which would add a build toolchain to this change's dependency list. Telescope's Lua sorter is adequate at this repository's size. Revisit when a picker feels slow, not before.
- **No linter beyond what servers report.** `ruff` is installed as a formatter only; its diagnostics would arrive through a separate `ruff` language server or `nvim-lint`, which is its own change.
- **`vim.diagnostic.config` is global, not per-server**, and is set once in `lsp.lua`: `virtual_text` on, `signs` with per-severity icons. Diagnostics are an editor-level display concern; there is no reason for two servers to render errors differently.

## Risks / Trade-offs

- **roslyn may not wire up through `automatic_enable`, and needs a .NET SDK mason cannot install.** → Isolated into its own tasks with two documented fallbacks (explicit `vim.lsp.config` + `vim.lsp.enable`, then `roslyn.nvim`). The other nine servers do not depend on it. If none of the three paths work, C# LSP is dropped from this change and `cs` formatting falls through to "no formatter, no error", which `specs/formatting` already permits.
- **mason 2.x and mason-lspconfig 2.x changed their APIs, and most material online targets 1.x.** → `automatic_enable`, `ensure_installed` semantics, and the mason organisation's repository rename (`williamboman/*` → `mason-org/*`) are all things to read from the installed version's own docs during implementation, not from memory or a blog post. Verification tasks cover each.
- **Node is a hard prerequisite for seven of the ten tools** (vtsls, jsonls, yamlls, cssls, html, tailwindcss, bashls, prettierd/prettier). Without it, mason reports install failures on first launch. → `specs/tool-management` requires those failures to be reported per tool and to not block the others or the editor. Lua, Python, and shell support work regardless.
- **Two lockfiles means tool versions are not reproducible.** → Accepted and specified rather than hidden; see the decision above. Zero practical cost until the config is in git.
- **`gd` and `gD` change meaning in LSP buffers.** → Only where a server is attached, and the LSP behavior is strictly better there. Muscle memory for text-based `gd` survives in every buffer without a server.
- **Format-on-save can block the UI for up to 500 ms.** → Bounded by construction, and only on filetypes with a configured formatter. If it ever bites, conform's async-on-save mode is a one-line change, at the cost of the formatted text not being what lands on disk for that write.
- **Nine plugins is roughly triple the current count, and three of them exist only to serve the other six.** → The mason chain is the price of self-provisioning, and `specs/tool-management` is written against the behavior rather than the plugin count, so collapsing three plugins into one later requires no spec change.
- **smear-cursor animates on every cursor move, inside WSL2 over a terminal.** → Purely decorative and `VeryLazy`-loaded; if it feels laggy over the terminal connection, deleting one file removes it completely with nothing else to unwind. That is the one-plugin-per-file rule paying for itself.
- **Telescope, mason, and blink.cmp may each pull `nvim-web-devicons` transitively**, which would violate `icons`' single-provider requirement. → An explicit verification task checks the resolved dependency tree, not just the specs as written.
- **`ripgrep` missing makes `<leader>fg` silently return nothing** rather than erroring, which reads as "no matches". → Called out as a verification step; `:checkhealth telescope` reports it.

## Migration Plan

Nothing to migrate. No existing file under `lua/` is edited — every change is a new file, which is what the ownership rule buys.

First launch after the change clones nine plugins, then mason downloads the servers and formatters in the background. That first launch is slow and will surface install errors for anything whose runtime is missing; subsequent launches do neither.

Rollback is per-plugin and independent: delete the file. Full rollback is deleting the nine files, `~/.local/share/nvim/lazy/`, and `~/.local/share/nvim/mason/`, which returns the configuration to its bootstrap state.

## Open Questions

- **Should the config move under git before the tool-version gap is worth closing?** The two-lockfile problem, the uncommitted `lazy-lock.json` from the bootstrap change, and any `mason-lock.nvim` decision all collapse into this one question, and none of them matters until it is answered. Deferrable: it changes no spec and no task here.
- **Which editor options should join `options.lua`?** Still open from the bootstrap change, and still unrelated to any spec here. Nothing in this change depends on the answer, though `signcolumn = "yes"` becomes more attractive now that gitsigns will otherwise shift text horizontally as signs appear.
- **`basedpyright` or `pyright` for Python?** Implemented as `basedpyright` — same language server lineage, actively maintained fork, more diagnostics available without a paid tier. Recorded here because it is a one-word change in `ensure_installed` if its stricter defaults prove noisy, and no spec distinguishes the two.
