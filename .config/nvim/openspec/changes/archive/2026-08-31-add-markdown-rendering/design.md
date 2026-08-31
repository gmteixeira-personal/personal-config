## Context

See proposal.md — Why. The constraints that actually shape the approach are properties of the machine this configuration targets, and were verified rather than assumed:

- Neovim is 0.12.5. Its bundled parsers are `c`, `lua`, `markdown`, `markdown_inline`, `query`, `vim`, and `vimdoc`, with `highlights.scm`, `injections.scm`, and `folds.scm` shipped for each. The two markdown parsers are therefore already present.
- There is no `nvim-treesitter` plugin in this configuration, and on its current `main` branch that plugin is a parser installer rather than the parsing engine. Nothing about markdown rendering needs it.
- Neovim 0.12 **does** attach a treesitter highlighter to a markdown buffer by default, via its bundled `runtime/ftplugin/markdown.lua`, whose first line is `vim.treesitter.start()` and which also supplies `gO`, `]]` and `[[` there. Measured with `nvim --clean --headless` on a markdown file: `vim.treesitter.highlighter.active[bufnr]` is non-nil, and forcing a parse yields `lua`, `markdown` and `markdown_inline` trees on a fixture with a fenced `lua` block. Nothing in this configuration has to start it.

  An earlier draft of this document claimed the opposite. That claim came from probing `vim.treesitter.highlighter.active[0]`, and `active` is keyed by real buffer number — index `0` is never populated, so the probe reads `nil` whether or not a highlighter is attached. The conclusion drawn from it was wrong, and the autocommand it justified was dead code.
- `mini.icons` is already a plugin here, so no second icon provider is needed.
- Every `nvim_create_autocmd` call in this configuration lives inside the plugin file that needs it — `telescope.lua`, `lualine.lua`, `lsp.lua`. There is no `lua/config/autocmds.lua` and no `ftplugin/` directory.
- `lazy-lock.json` is tracked, so plugin versions are pinned by the repository.

## Goals / Non-Goals

**Goals:**

- Keep the entire capability in one file, so the whole feature can be read and reverted as a unit.
- Add no component beyond the plugin itself — no parser, no parser manager, no external binary.
- Match the surrounding configuration's conventions rather than introducing a new organizing pattern for one feature.

**Non-Goals:**

- Markdown *editing* affordances — list continuation, table formatting, text objects, link following. A separate concern and a separate plugin; the spec covers display only.
- Rendering markdown in filetypes other than markdown. The plugin supports Quarto, R Markdown, and various chat buffers; none exist in this configuration, and adding them speculatively would widen the load trigger for no benefit.
- LaTeX and inline HTML rendering. Both need parsers Neovim does not bundle, which would violate the "runs on what Neovim bundles" requirement.

## Decisions

### Use `render-markdown.nvim` rather than `markview.nvim` or `headlines.nvim`

`render-markdown.nvim` covers every requirement in the spec using only the bundled parsers, and its configuration surface is a single small `opts` table, which matches the shape of the other files in `lua/plugins/`.

Alternatives considered:

- **`markview.nvim`** — richer visually, with native LaTeX and fuller HTML support. Those advantages sit behind the `latex`, `html`, `yaml`, and `typst` parsers, none of which Neovim bundles, so adopting it would drag in a parser manager to reach its differentiating features. It also has a substantially larger configuration surface and a history of breaking configuration changes across major versions. Rejected: the features that justify the cost are ones this spec explicitly does not want.
- **`headlines.nvim`** — heading and code-block backgrounds only. No tables, no checkboxes, no callouts, no icons. Rejected: it cannot satisfy the rendering requirement.
- **An external preview** (`markdown-preview.nvim`, `peek.nvim`, `glow.nvim`) — highest fidelity, but a second window that is read-only and out of band, and each needs a runtime this machine lacks. Rejected by the user during exploration; also incompatible with the "no external program" requirement.

### Start no treesitter highlighting at all

Neovim's own `ftplugin/markdown.lua` already calls `vim.treesitter.start()` on every markdown buffer, so this configuration adds nothing. The plugin file holds the `lazy.nvim` spec and its `opts` and nothing else.

Alternatives considered — all three of them answers to a problem that does not exist, kept here so the next person to reach for one knows it was measured rather than assumed:

- **A `FileType markdown` autocommand in `render-markdown.lua`** — what this change originally implemented. `vim.treesitter.start()` is idempotent, so it was harmless, but it re-started a highlighter Neovim had already started, and it coupled a general markdown concern to one plugin's file to do it. Rejected: dead code, with a comment asserting something untrue about the editor.
- **A new `lua/config/autocmds.lua`** — the same dead call, in a new file, behind a new `init.lua` require line.
- **A new `ftplugin/markdown.lua`** — this would *shadow* the runtime one rather than sit alongside it. A user `ftplugin/markdown.lua` earlier on the runtimepath does not suppress the bundled file (both run, `:filetype plugin on` sources every match), but writing one whose contents duplicate the runtime's is a standing invitation to drift from it.

### Render in every mode rather than upstream's `{ "n", "c", "t" }`

`render_modes = true`. The plugin's default omits insert mode, and the effect is not that the line being edited goes raw — `anti_conceal` already does that — but that the *entire buffer* drops to raw markup the moment `i` is pressed and snaps back on `<Esc>`. Tables lose their borders, headings regain their hashes, and a document being written flickers between two presentations on every insert.

Enabling every mode leaves `anti_conceal` as the only thing that reveals markup, so exactly one line is ever raw, in every mode. Measured: with the cursor in insert on a task line, that line reads `- [x] A checked task item` while the table above keeps its box borders and the task item below keeps its glyph.

Alternative considered: leaving the default and treating the flicker as normal. Rejected — it contradicts the spec's "a rendered document is never read-only in practice", which is about editing feeling like editing.

### Load on `ft = { "markdown" }`

The plugin already declares its own `ft`, but stating it explicitly satisfies the spec's "a session without markdown pays nothing" requirement visibly rather than by inheritance, and reads the same way as `vim-razor.lua`, which is this configuration's existing precedent for filetype-triggered loading.

### Declare `mini.icons` as an explicit dependency

`render-markdown.nvim` detects an icon provider at run time and would find `mini.icons` anyway. Declaring it makes `lazy.nvim` guarantee the load order instead of leaving it to chance, matching how `oil.lua` already declares the same dependency.

### Keep `anti_conceal` enabled

This is the plugin's default and the mechanism behind the spec's "cursor's own line shows raw markup" requirement. It is called out here because disabling it is a tempting way to make screenshots look better, and doing so would turn a rendered buffer into an effectively read-only one.

## Risks / Trade-offs

- **Concealment decouples visual columns from byte columns** → Horizontal motion across a rendered heading or link traverses characters that are not drawn, which can feel like the cursor jumping. Mitigated by `anti_conceal`: the line being edited is never the concealed one.
- **Rendering is redrawn on cursor movement, which costs time in very large files** → Not expected to matter at the size of notes and READMEs. If it ever does, the plugin exposes a file-size threshold above which it disables itself.
- **Heading and code-block backgrounds are colorscheme-dependent** → This configuration ships four themes and a switcher, so a background that reads well in `kanagawa-wave` may be low-contrast in another. Mitigated by taking the plugin's defaults, which derive from standard highlight groups that all four themes define, rather than hardcoding colors.
- **Rendering in insert mode means the renderer runs while typing** → More redraw work in the mode where latency is most noticeable. Not measurable at the size of notes and READMEs; the same file-size threshold that guards cursor-movement redraws guards this one.

## Migration Plan

Not applicable in the deployment sense — this is an additive local configuration change. Rollback is deleting `lua/plugins/render-markdown.lua` and the `lazy-lock.json` entry; nothing else is touched, and no other file depends on it.

One forward note: the colours here come from `RenderMarkdownH1Bg` and friends, which the plugin derives from standard highlight groups. If a theme is ever added that leaves those groups undefined or too close to `Normal`, the fix is an `opts` override in this same file rather than a change to the theme.
