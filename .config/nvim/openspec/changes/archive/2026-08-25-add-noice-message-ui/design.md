## Context

See proposal.md — Why. What matters for the approach:

- **Neovim 0.12.5.** `cmdheight = 0` is supported, and the runtime already ships the tree-sitter parsers noice highlights its views with: `markdown`, `markdown_inline`, `vim`, `lua`, `query`, `vimdoc`, `c`. `regex` and `bash` — the two noice also asks for — are not bundled and are not installed.
- **No tree-sitter plugin, and none is being added.** noice's health check probes parsers through `vim.treesitter.language.add`, not through `nvim-treesitter`, so the bundled parsers satisfy it without one.
- **Load order is already spoken for.** `themes/themery.lua` is `lazy = false, priority = 1000` and is the only caller of `vim.cmd.colorscheme`; `mini-icons.lua` is `lazy = false, priority = 900` and mocks `nvim-web-devicons`. Anything eager that this change adds has to slot between them or after.
- **Completion is blink.cmp, not nvim-cmp.** noice ships an override for `cmp.entry.get_documentation`; there is no nvim-cmp here for it to hook.
- **`lua/plugins/lsp.lua` owns `K`, `vim.diagnostic.config`, and the `LspAttach` mappings.** noice's language-server work is installed by noice itself, not by editing that file.
- The `<leader>` namespace currently uses `b c f g h m r w`, plus `<leader><leader>`, `<leader>,` and `<leader>?`. `n` is free.

## Goals / Non-Goals

**Goals:**

- One file, `lua/plugins/noice.lua`, holding the plugin, both dependencies, the view configuration, and the mappings — deletable to get the stock UI back.
- Startup messages routed through noice, so the message history is complete from the first frame.
- Language-server hover and signature help rendered as markdown without touching `lua/plugins/lsp.lua`.

**Non-Goals:**

- A status line. noice frees the last screen row; nothing is put back on it here.
- Replacing `vim.ui.select` / `vim.ui.input`. Both stay stock; noice does not own them and neither does this change.
- Insert-mode completion. blink.cmp keeps it entirely — only the command-line wildmenu moves.
- Installing the `regex` and `bash` parsers. Accepted as a known health-check warning; see Risks.

## Decisions

### Eager at `priority = 950`, not `event = "VeryLazy"`

noice is loaded `lazy = false` with `priority = 950`, which places it after the colorscheme (1000) and before mini.icons (900) — the first plugin on the startup path that is not the colorscheme.

`event = "VeryLazy"` is what noice's own README suggests and what most configurations use, and it is cheaper: VeryLazy fires after the first screen is drawn, so noice costs nothing before the user sees a buffer. It is rejected because VeryLazy is *after* every other plugin's own load, so every message emitted while lazy.nvim installs, while mason-tool-installer reports what it is fetching, or while a language server fails to start, is written to the classic bottom row and never enters noice's log. `message-ui` requires those to be in the history, and a history that starts empty at VeryLazy is the one case a user actually reaches for it.

The colorscheme has to stay ahead of it: nvim-notify resolves its background from the `NotifyBackground`/`Normal` highlight when it first draws, and with no colorscheme applied yet it falls back to a transparent background and warns about it on every launch.

The cost is real — noice and nui are on the critical path to the first frame. Measure against the ~39 ms baseline recorded in `lua/config/options.lua`; if it is unacceptable, VeryLazy is the fallback and the trade is stated above.

### nvim-notify as a bare dependency, with no options table

`dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }` — two plugin names, no nested spec tables. `plugin-management` requires one file to describe one plugin, and a dependency carrying its own `opts` block starts describing a second one. nvim-notify's defaults are acceptable here, and the one setting usually overridden — `background_colour`, to silence the transparency warning — is unnecessary because the colorscheme is applied first (above).

Alternatives: noice's built-in `mini` view as the notification backend, which needs no second plugin but stacks nothing and keeps no history of its own; or no notifications at all. Rejected — the history is half of what this capability is for.

### `presets`, not a hand-written view table

```lua
presets = {
  command_palette = true,       -- cmdline and its completion popup as one centred view
  long_message_to_split = true, -- long output opens a scrollable split, not a Press-ENTER prompt
  lsp_doc_border = true,        -- bordered hover / signature floats
  bottom_search = false,        -- `/` gets the same floating input as `:`
  inc_rename = false,           -- inc-rename.nvim is not installed
}
```

Presets are upstream's own composed view/route sets. Writing the equivalent `views` and `routes` tables by hand would pin today's layout and lose upstream's tuning of it — the same reasoning `which-key.lua` records for using `preset = "modern"` over an expanded `win`/`layout` table.

`command_palette` is what satisfies the spec's "floating list near the command-line input": it puts the wildmenu popup directly under the cmdline input rather than in a separate corner. `bottom_search = false` is the default, written out because the spec makes the floating search contractual.

### Language-server overrides, minus the nvim-cmp one

```lua
lsp = {
  hover = { enabled = true },
  signature = { enabled = true },
  progress = { enabled = true },
  override = {
    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
    ["vim.lsp.util.stylize_markdown"] = true,
    ["cmp.entry.get_documentation"] = false,
  },
}
```

The two `vim.lsp.util.*` overrides are what render server documentation as markdown; `hover`/`signature` are what draw it in a noice view that closes on `CursorMoved` — which is why the existing `language-servers` scenario "the window is dismissed by any cursor movement" continues to hold and is not being modified.

`cmp.entry.get_documentation` is set to `false` explicitly rather than left at its default: nvim-cmp is not installed, and a reader comparing this against noice's README should find the line that says why it is off rather than wonder whether it was forgotten. blink.cmp renders its own documentation window and noice has no hook into it — LSP documentation therefore looks different in the completion menu than under `K`, and that is accepted.

`progress = { enabled = true }` is what makes `$/progress` visible. Nothing in `lua/plugins/lsp.lua` changes.

### `<leader>n`, five mappings, declared in `keys`

| Key | Action |
| --- | --- |
| `<leader>nh` | `:Noice history` — every message this session |
| `<leader>nl` | `:Noice last` — the most recent message in full |
| `<leader>nn` | `:Noice pick` — the log in a picker, searchable; notifications included |
| `<leader>nd` | `:Noice dismiss` — clear everything currently displayed |
| `<leader>ne` | `:Noice errors` — errors only |

Declared as `keys` entries in the plugin spec, each with a `desc`, which is what `keymap-hints` reads. They are `keys` rather than `vim.keymap.set` calls in `config` purely for consistency with the rest of `lua/plugins/`; because the plugin is `lazy = false`, they carry no lazy-loading weight.

`n` is free under `<leader>` and nothing is displaced. `which-key.lua` gains exactly one line — `{ "<leader>n", group = "Notices" }` — which is the only edit outside the new file.

`:Noice pick` routes to telescope when telescope is loaded and falls back to noice's own split otherwise, so it does not couple this file to `lua/plugins/telescope.lua`.

### `<C-f>` / `<C-b>` scroll a documentation float, and page the buffer otherwise

```lua
{ "<C-f>", function() if not require("noice.lsp").scroll(4) then return "<C-f>" end end, mode = { "n", "i", "s" }, expr = true, silent = true },
```

`noice.lsp.scroll` returns `false` when no scrollable float is open, and the mapping then returns the key itself for the built-in page scroll to handle. `expr = true` is what makes that fallback a real key press rather than a recursive call. This is noice's documented recipe and is the only way to get scroll-without-focus without shadowing `<C-f>`/`<C-b>` outright.

### The recording indicator is routed explicitly

`message-ui` requires that an in-progress macro recording stays visible. With `cmdheight = 0` there is no row for `msg_showmode` to land on, so a route sends it to the `notify` view:

```lua
routes = {
  { view = "notify", filter = { event = "msg_showmode" } },
}
```

Verify this during implementation by recording a macro — if noice's defaults already surface it, drop the route rather than keep a redundant one.

## Risks / Trade-offs

- **Startup cost on the critical path.** noice + nui + nvim-notify load before the first frame → measure against the ~39 ms baseline; if the regression is material, fall back to `event = "VeryLazy"` and accept an incomplete startup history.
- **`:checkhealth noice` will report `regex` and `bash` parsers missing.** → Accepted. The effect is unhighlighted search patterns in the search input and unhighlighted `:!` shell commands; everything else uses bundled parsers. Installing the two `.so` files into `~/.local/share/nvim/site/parser/`, where this machine's extra parsers already live, fixes it without adding a plugin.
- **`cmdheight = 0` is a Neovim mode some plugins still handle badly** — a plugin that writes to the message row can leave artefacts, and resize handling around a zero-height command line has historically been buggy. → The symptom is a stale line at the bottom of the screen, cleared by `<C-l>`. If it becomes routine, `cmdheight = 1` with noice's cmdline still floating is a supported configuration.
- **noice describes itself as experimental and rewrites `vim.notify`, the cmdline UI, and several `vim.lsp.util` functions.** A breaking change upstream can take the command line with it. → `lazy-lock.json` pins the commit; rollback is deleting one file.
- **Errors raised before noice loads still go to the classic UI.** → Unavoidable and required: the `message-ui` spec says a failure in this capability must not leave the editor unable to report errors, which is exactly this behaviour.
- **smear-cursor animates the cursor into and out of the floating cmdline.** → Cosmetic; both are decorative. If it reads badly, `smear-cursor`'s float handling is where to look, not noice's.
- **LSP documentation is rendered two ways** — noice markdown under `K`, blink.cmp's own renderer in the completion menu. → Accepted; wiring noice into blink's documentation window is not a supported integration.

## Migration Plan

1. Add `lua/plugins/noice.lua`; restart. lazy.nvim installs noice, nui, and nvim-notify and writes them into `lazy-lock.json`.
2. Add the `<leader>n` group line to `lua/plugins/which-key.lua`.
3. Check `:checkhealth noice` — expect exactly the `regex`/`bash` parser warnings named above and nothing else.
4. Walk the spec's scenarios by hand: `:`, `/`, a long `:map` listing, `K` on a documented symbol, `q:`, a recorded macro, `<leader>n` and each mapping under it.

Rollback: delete `lua/plugins/noice.lua`, revert the which-key line, run `:Lazy clean`. The stock command line, messages, and wildmenu return with no other change.
