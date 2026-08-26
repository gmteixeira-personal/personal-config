## Why

Neovim presents the command line, its messages, and its notifications on the last line of the screen — one row, shared by every one of them. A message longer than the row is truncated into `Press ENTER or type command to continue`, which blocks the editor until a key is pressed; a message that arrives while another is still on screen replaces it silently; and the `:` prompt sits at the far bottom edge, away from where the user is looking. There is currently no notification history at all, so anything missed is gone.

noice.nvim replaces all three with floating views that can be sized, positioned, styled, and re-read after the fact. This configuration already has the pieces noice expects — a fully lazy plugin layout, a single icon provider, and a language-server setup that renders documentation into plain floats that noice can render as markdown instead.

## What Changes

- Add `folke/noice.nvim` with `MunifTanjim/nui.nvim` (its view backend) and `rcarriga/nvim-notify` (its notification backend) as dependencies, in one new file `lua/plugins/noice.lua`.
- The command line moves off the last screen row into a centred floating input. Search (`/`, `?`) and the filter/lua/help prompts get their own labelled views.
- Messages are routed to noice's views rather than the message row: short ones appear as a transient overlay, long ones open a scrollable split, and the `Press ENTER` prompt is largely eliminated.
- Notifications (`vim.notify`) are rendered by nvim-notify as stacked toasts, with a searchable history reachable from a keymap.
- The wildmenu — the completion list for `:` commands — is drawn by noice. **This does not touch insert-mode completion**, which stays entirely blink.cmp's.
- Language-server hover documentation and signature help are rendered through noice's markdown views instead of the stock plain-text floats, and language-server progress (`$/progress`) is shown as a message instead of being discarded.
- Add keymaps under a new `<leader>n` prefix for the message history, the last message, the notification history, and dismissing all visible messages, plus which-key group names for that prefix. `<C-f>`/`<C-b>` scroll a hover or signature float when one is open.
- Neovim 0.12's bundled tree-sitter parsers (`markdown`, `markdown_inline`, `vim`, `lua`) are what noice highlights with. **No tree-sitter plugin is added**; the optional `regex` and `bash` parsers are left uninstalled and `:checkhealth noice` will say so.

## Capabilities

### New Capabilities

- `message-ui`: How the command line, editor messages, notifications, and the command-line completion list are presented — where they appear, how they are dismissed, what history is kept, and the guarantee that none of it changes what a keystroke does.

### Modified Capabilities

- `language-servers`: hover and signature-help documentation gains a stated rendering (markdown, scrollable) rather than an unspecified floating window, and server progress becomes visible.
- `keymap-hints`: the named prefix list gains `<leader>n`.

## Impact

- New: `lua/plugins/noice.lua`, `openspec/specs/message-ui/spec.md`.
- Modified: `lua/plugins/which-key.lua` (one `spec` entry), `openspec/specs/language-servers/spec.md`, `openspec/specs/keymap-hints/spec.md`.
- New plugins: `folke/noice.nvim`, `MunifTanjim/nui.nvim`, `rcarriga/nvim-notify`. `lazy-lock.json` gains three entries.
- `lua/plugins/lsp.lua` is deliberately **not** modified: noice installs its language-server overrides itself, and `K` keeps its existing binding.
- Startup cost: noice must load eagerly enough to catch startup messages, so it is the first non-colorscheme plugin on the path. Budget the added time against the ~39 ms baseline recorded in `lua/config/options.lua`.
- `<leader>n` was previously unbound; nothing is displaced.
