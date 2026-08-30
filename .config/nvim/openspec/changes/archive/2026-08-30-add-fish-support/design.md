## Context

See proposal.md — Why.

Three constraints in the existing configuration shape the approach:

- `mason-lspconfig.lua` derives `automatic_enable` from the same `servers` list it passes to `ensure_installed`, deliberately, so that a formatter installed by `mason-tool-installer.lua` cannot quietly become a server. Adding a name to `servers` therefore both installs and enables it, and is the whole of the wiring for an ordinary server.
- The `language-servers` capability already requires that a server take a workspace root only from a configuration file belonging to its own technology, and that a version-control directory never qualify on its own. `$HOME` is a git repository on this machine, which is what motivated that requirement; `lua/plugins/lsp.lua` records the Tailwind incident behind it.
- `conform.lua` runs with `lsp_format = "fallback"`, so a language server is asked to format only where the filetype has no external formatter available.

Facts verified against the installed versions rather than assumed:

- Neovim 0.12.5 ships `ftplugin/fish.vim` and `syntax/fish.vim` in its own runtime.
- The mason registry carries `fish-lsp` (npm, `1.1.4`), declaring `neovim.lspconfig = "fish_lsp"`, so mason-lspconfig translates the name in both directions without either list naming the other form.
- `nvim-lspconfig` ships `lsp/fish_lsp.lua`, with `cmd = { "fish-lsp", "start" }`, `filetypes = { "fish" }`, and `root_markers = { "config.fish", ".git" }`.
- `conform.nvim` ships a `fish_indent` formatter definition; `fish_indent` itself is at `/usr/bin/fish_indent`, part of the fish 4.8.1 install.
- `workspace_required` is a supported `vim.lsp.Config` key in 0.12.5, defaulting to `false`.

## Goals / Non-Goals

**Goals:**

- Add fish through the configuration's ordinary paths, so the diff is two list entries plus one override, and no new mechanism.
- Keep the workspace-root guarantee intact for the new server, rather than treating it as a rule that only applied to Tailwind.

**Non-Goals:**

- Formatting configuration options for `fish_indent`. It has none worth setting; its output is the fish project's canonical style, which is the point of using it.
- Any handling for fish's own `--check` syntax validation as a separate linter. Diagnostics come from the server.

## Decisions

### `fish_lsp` joins the `servers` list, unlike `roslyn_ls`

`mason-lspconfig.lua` is the default path, and fish has none of the properties that made C# an exception: one server, one filetype, no plugin starting it independently, and no system SDK to supply. Declaring it in `mason-tool-installer.lua` instead — the escape hatch for a binary that must exist without being enabled — would mean the server is installed and never started.

### `root_markers` is narrowed to `config.fish`, with `workspace_required`

The shipped definition accepts `.git` as a root marker. Left alone, opening any `.fish` file anywhere under `$HOME` would root the server at the home directory, which is precisely the failure the `language-servers` workspace requirement was written to forbid, and which cost redraw responsiveness the last time it happened.

`vim.lsp.config` shallow-merges, so naming `root_markers = { "config.fish" }` replaces the shipped pair rather than adding to it. `workspace_required = true` is needed alongside it: without it, a fish buffer with no `config.fish` above it attaches rootless rather than not attaching, and the requirement states that declining is not the same as rooting at the buffer.

A `root_markers` list is enough here, where Tailwind needed a `root_dir` function — that case had to expand a base name across four extensions, and this one has a single fixed filename.

Alternative considered: leaving `.git` in place and accepting a home-directory root, on the grounds that fish-lsp indexes far less than Tailwind does. Rejected because the requirement is not phrased as a performance budget; it says a repository is not a project, and a second server quietly exempting itself is how that guarantee erodes.

The accepted cost: a standalone `.fish` script in a directory tree with no `config.fish` gets no server. That is the same trade the requirement already imposes on every other technology, and the fish files actually edited here — `~/.config/fish/config.fish` and `~/.config/fish/conf.d/*.fish` — resolve to `~/.config/fish` by the upward search.

### `fish_indent` is not declared in `mason-tool-installer.lua`

There is no mason package for it. It ships inside fish, so on any machine with fish installed it is already on `PATH`, and on a machine without fish there are no fish buffers to format. The `tool-management` capability already requires that a system-installed copy be usable when no managed copy exists, so this needs no new requirement and no new declaration — which is why the proposal lists `tool-management` as unmodified.

### Formatting stays with `fish_indent` rather than the server

`fish-lsp` implements formatting by shelling out to `fish_indent`, so both paths produce the same bytes. Configuring the external formatter keeps fish on the same rung of the fallback chain as every other filetype except C#, and `lsp_format = "fallback"` then means the server is never asked. This needs no code beyond the `formatters_by_ft` entry; it is recorded because the equivalence is not obvious and someone may later wonder why the server's formatting capability is unused.

## Risks / Trade-offs

- **`fish-lsp` is an npm package, so mason needs Node to install it** → Node is present at `/usr/bin/node` (v26.8.1) as a pacman package, not an nvm shim, so it does not depend on shell state. On a machine without Node the install fails and is reported, which `tool-management` already requires and which leaves the editor usable.
- **A standalone fish script outside a fish config tree gets no server** → Accepted, and stated above. The workaround is the one the Tailwind comment already documents: place the technology's config file in the directory, or name that directory in the override.
- **`fish-lsp` is a young project and may produce noisy diagnostics** → Contained to fish buffers, and reversible by removing one list entry. Nothing else in the configuration depends on it.
- **Narrowing `root_markers` relies on `vim.lsp.config` shallow-merge semantics** → Verified against the shipped `lsp/fish_lsp.lua`; a future upstream change to that file's markers would be picked up as a replacement, not a merge, which is the intended behavior here.
