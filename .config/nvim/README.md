# Neovim configuration

A personal Neovim configuration. Lua throughout, `lazy.nvim` as the plugin
manager, one file per plugin, and a leader key of `<Space>`.

It is written to be self-provisioning: clone it to `~/.config/nvim`, start
Neovim, and wait. The first launch clones the plugin manager, installs about
thirty plugins, and installs the language servers and formatters those plugins
need. There is no install script and no bootstrap command to run.

- [Requirements](#requirements)
- [Layout and load order](#layout-and-load-order)
- [Editor conventions](#editor-conventions)
- [Keymaps](#keymaps)
- [Plugins](#plugins)
- [Where the detail lives](#where-the-detail-lives)

## Requirements

Three things must already be on the machine. Nothing here installs them, and
each one fails differently if it is missing.

| Requirement | Why | Without it |
|---|---|---|
| Neovim 0.11 or newer | `vim.uv`, `vim.lsp.config`, and `:restart` are used directly | startup errors on the first `require` |
| `git` | the plugin manager is cloned on first launch, and plugins are fetched with it | first launch aborts with the clone's error output and exits |
| A Nerd Font in the terminal | filetype and status-line glyphs come from one | icons render as replacement boxes; nothing breaks |

A .NET SDK is needed for C# only. `roslyn.nvim` starts the Roslyn language
server, and mason cannot supply the SDK it runs on. Every other language works
without anything installed by hand.

Everything else arrives on its own:

- **The plugin manager.** `lua/config/lazy.lua` clones `lazy.nvim` into
  `stdpath("data")/lazy/` if it is not there, pinned to its `stable` branch. A
  failed clone prints the error and exits rather than falling through into a
  half-configured session.
- **Plugins.** Installed on first launch from the specs in `lua/plugins/`, at
  the exact revisions recorded in `lazy-lock.json`, so every machine resolves
  the same versions rather than whatever it happens to fetch first.
- **Language servers and formatters.** mason installs them under
  `stdpath("data")/mason/`, in the background, on launch. Nothing lands on the
  system or on the login shell's `PATH`.

## Layout and load order

| Path | What lives there |
|---|---|
| `init.lua` | three `require` calls and nothing else; load order is the only thing it decides |
| `lua/config/options.lua` | editor options that apply with no plugin installed |
| `lua/config/keymaps.lua` | mappings that work with no plugin installed |
| `lua/config/lazy.lua` | the plugin manager: bootstrap, then the imports |
| `lua/plugins/` | one file per plugin, imported wholesale |
| `lua/plugins/themes/` | the colorschemes and the switcher that applies them |
| `lazy-lock.json` | the resolved revision of every plugin, tracked |
| `openspec/` | the specifications; see [Where the detail lives](#where-the-detail-lives) |

`init.lua` loads `config.options`, then `config.keymaps`, then `config.lazy`:

```lua
require("config.options") -- first: leader must exist before any plugin spec is evaluated
require("config.keymaps") -- general mappings, no plugin involved
require("config.lazy")    -- plugin manager, which imports lua/plugins/
```

**The first step is load-bearing.** `mapleader` is resolved when a mapping is
*defined*, not when it is pressed, so it has to exist before any plugin spec is
evaluated — and a spec that declares `keys` is evaluated by `config.lazy`. Set
the leader later and every plugin's `<leader>` mapping silently binds to
backslash instead. The other two steps are ordered for readability rather than
by necessity.

The split between the two general modules and the plugin files is a rule, not a
habit: a setting that would still make sense with every plugin removed belongs
in `lua/config/`, and everything a plugin needs — its options *and* the keymaps
that invoke it — belongs in that plugin's own file. Deleting a plugin file
therefore removes the plugin and its keymaps together, leaving nothing behind in
`lua/config/`.

### Adding a plugin

Add one file to `lua/plugins/` returning a `lazy.nvim` spec, and restart. That
is the whole procedure — no registration list, no edit to `init.lua`, no edit to
any other plugin file.

**A new *subdirectory* is different.** `lazy.nvim` descends into a subdirectory
only if it holds an `init.lua`, so a new directory under `lua/plugins/` needs
its own import line in `lua/config/lazy.lua`:

```lua
spec = {
  { import = "plugins" },
  { import = "plugins.themes" },
},
```

A subdirectory that is not named there contributes no plugins **and reports no
error** — the files are simply never read. That silence is why the rule is
written down.

## Editor conventions

What follows applies to every buffer, regardless of filetype. A plugin's own
settings live with the plugin.

**Line numbers** are relative, with the absolute number on the cursor line, so a
vertical motion count reads straight off the screen. **The sign column is
reserved permanently** rather than sized automatically, so a git or diagnostic
sign appearing cannot shove the buffer sideways under the cursor.

**Indentation** is two columns and never a tab character. A line that opens a
block indents the next one a level deeper.

**Search** is case-insensitive until the query contains an upper-case character,
matches move under the query as it is typed, and matches stay highlighted after
the search is accepted — `<Esc>` is what dismisses them, not the next search.

**Wrapping is display-only; the file on disk is never modified.** Lines break at
word boundaries rather than mid-word, and continuation rows are indented to
match the line they belong to.

**The cursor is held at the vertical middle of the window** and the view scrolls
under it, so the amount of context above and below is the same however the
cursor arrived. It stops being centred only at the very top and bottom of a
file, where there is nothing left to scroll.

**Undo is written to disk** and survives closing the file. **Sessions** record
the layout — window sizes and positions, folds, tabs, per-window options — and
not the global option values, which belong in `lua/config/options.lua` and
nowhere else.

**New splits open right and below**, so the new window takes the new space and
the existing one keeps its position.

**Yank and delete route through the system clipboard** without the register
having to be named. Under WSL that needs a bridge, and the configuration
installs one *only where Neovim found no provider of its own* — it asks the
provider rather than testing for WSL, so a faster tool Neovim already chose is
never replaced. The question is deferred a tick past startup because asking it
costs about 60 ms there, which would otherwise more than double launch time.

Two of these override a Neovim default in a way that can read as a malfunction:

- **`scrolloff` is 999, not 0.** The cursor does not move down the screen as you
  scroll; the text moves instead. This is deliberate.
- **`hlsearch` stays on after a search completes.** Highlights persisting is the
  point — they show a term's spread through the file. `<Esc>` clears them.

## Keymaps

**The leader key is `<Space>`.** The local leader is `\`. A bare `<Space>` is
bound to nothing, so it never moves the cursor while a mapping is pending.

Every prefix below (`<leader>w`, `<leader>b`, `<leader>f`, and the rest) is a
prefix *only* — never a mapping in its own right — so pressing one never waits
out `timeoutlen` before showing what can follow. `which-key` lists the
continuations while a sequence is pending, and `<leader>?` lists the mappings
that belong to the current buffer alone.

### Overrides of built-in keys

These four take over keys Vim already uses. They are unprefixed because they are
wanted constantly.

`H` and `L` reach the ends of the line in two steps outward: `H` to the first
non-blank character and then to column zero, `L` to the last non-blank and then
past any trailing whitespace. They are real motions — an operator consumes them
(`dL` deletes to the end of the line), and a visual selection extends by them.

**What they displace is given up, not rehomed.** The stock screen-top and
screen-bottom motions are gone; `M` still reaches the middle of the screen and
`zt`/`zz`/`zb` still position the view. `H` and `L` also stop being jump
commands, so `''` no longer returns from one.

| Key | Modes | Effect |
|---|---|---|
| `H` | n, x, o | First non-blank, then column zero |
| `L` | n, x, o | Last non-blank, then end of line |
| `<Esc>` | n | Clear search highlight |
| `<C-s>` | n, i, v | Save buffer (from any editing mode) |

### Windows

| Key | Effect |
|---|---|
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Focus the window left / below / above / right |
| `<M-h>` `<M-l>` | Decrease / increase window width |
| `<M-j>` `<M-k>` | Decrease / increase window height |
| `<leader>ws` | Split horizontally |
| `<leader>wv` | Split vertically |
| `<leader>wn` | New window |
| `<leader>wc` | Close window |
| `<leader>wq` | Quit window |
| `<leader>wo` | Close other windows |
| `<leader>ww` / `<leader>wW` | Focus next / previous window |
| `<leader>wp` | Focus last-accessed window |
| `<leader>wt` / `<leader>wb` | Focus top-left / bottom-right window |
| `<leader>wx` | Exchange window with next |
| `<leader>wr` / `<leader>wR` | Rotate windows down-right / up-left |
| `<leader>w=` | Equalize window sizes |
| `<leader>wT` | Move window to a new tab |
| `<leader>we`, `<leader>w\`, `<C-w>e`, `<C-w>\` | Toggle window maximized |

`<leader>w` mirrors the built-in `<C-w>` commands without the chord. The
maximize toggle is the one addition: it **restores the previous sizes** rather
than equalizing them, which is what `<C-w>=` would do.

### Buffers

| Key | Effect |
|---|---|
| `<leader>bn` / `<leader>bp` | Next / previous buffer |
| `<leader>bf` / `<leader>bl` | First / last buffer |
| `<leader>bb` | Alternate buffer |
| `<leader>bc` | New empty buffer |
| `<leader>bd` | Delete this buffer |
| `<leader>bo` | Delete other buffers |
| `<leader>bO` | Delete all buffers |

### Quitting and the session

`<leader>q` is the editing session as a whole — never one window, never one
buffer.

| Key | Effect | From |
|---|---|---|
| `<leader>qq` | Quit all | |
| `<leader>qw` | Write all and quit | |
| `<leader>qc` | Restart Neovim, rebuilding the process (confirms first) | |
| `<leader>qs` | Search saved sessions | auto-session |
| `<leader>qW` | Save session | auto-session |
| `<leader>qr` | Restore session | auto-session |
| `<leader>qd` | Delete session | auto-session |

**Every deletion and every quit goes through `:confirm`**, so a modified buffer
produces a save/discard/cancel dialog rather than an error to work around or a
bang that throws the work away.

### Finding things

| Key | Effect | From |
|---|---|---|
| `<leader><leader>` | Find files | telescope |
| `<leader>fg` | Live grep | telescope |
| `<leader>fb`, `<leader>,` | Find buffers | telescope |
| `<leader>fh` | Find help tags | telescope |
| `<leader>fs` / `<leader>fS` | Document / workspace symbols | telescope |
| `<leader>ft` | Find colorscheme | themery |
| `<leader>e` | Toggle the file explorer | oil |

Inside a telescope prompt, `<C-j>`/`<C-k>` move through the results, `<Esc>`
closes, and `<C-d>` deletes the selected buffers from the buffer picker.

### Git

| Key | Effect | From |
|---|---|---|
| `]c` / `[c` | Next / previous hunk | gitsigns |
| `<leader>hs` | Stage hunk (or the selected range) | gitsigns |
| `<leader>hr` | Reset hunk (or the selected range) | gitsigns |
| `<leader>hR` | Reset buffer | gitsigns |
| `<leader>hp` | Preview hunk | gitsigns |
| `<leader>hb` | Blame line, in full | gitsigns |
| `<leader>gg` | Toggle git status | neogit |
| `<leader>gd` | Toggle the diff of this file | diffview |
| `<leader>gm` | Toggle the diff of the repository | diffview |
| `<leader>gh` | Toggle file history | diffview |
| `<leader>gr` | Refresh the diff view | diffview |
| `<leader>gf` | Git tracked files | telescope |
| `<leader>gs` | Git status (picker) | telescope |
| `<leader>gc` | Git commits | telescope |
| `<leader>gb` | Git branches | telescope |

The `<leader>h` mappings attach per buffer, in a git repository only. Outside
one they do not exist, which is why `<leader>?` lists what the current buffer
actually has.

### Language server

These attach to a buffer when a server does.

| Key | Effect |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>cr` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>cf` | Format buffer (conform) |

### Jumping

| Key | Modes | Effect | From |
|---|---|---|---|
| `s` | n, x, o | Jump to any visible position by typing what is there | flash |
| `S` | n, o | Select a syntax node | flash |
| `r` | o | Operate on a position elsewhere, then come back | flash |
| `R` | o, x | Search to a syntax node | flash |
| `f` `F` `t` `T` | n, x, o | Character motions, labelled | flash |
| `/` `?` | n, x | Search, labelled | flash |
| `<C-s>` | c | Toggle labels during a search | flash |
| `]t` / `[t` | n | Next / previous TODO marker | todo-comments |

### Editing

| Key | Modes | Effect | From |
|---|---|---|---|
| `<` / `>` | v | Outdent / indent and keep the selection | |
| `<M-;>` | i, v | Terminate the line, or the selected lines, with `;` | |
| `<M-h>` `<M-j>` `<M-k>` `<M-l>` | v | Move the selection left / down / up / right | mini.move |
| `ys` `yss` `yS` | n | Add a surrounding pair around a motion / line / on own lines | nvim-surround |
| `ds` / `cs` / `cS` | n | Delete / change a surrounding pair | nvim-surround |
| `S` / `gS` | x | Surround the selection, inline / on own lines | nvim-surround |
| `<C-n>` | n, x | Select the next occurrence as a new cursor | vim-visual-multi |
| `<C-Up>` / `<C-Down>` | n | Add a cursor above / below | vim-visual-multi |
| `<S-Left>` / `<S-Right>` | n | Shrink / extend the selection | vim-visual-multi |
| `<leader>mA` | n | Select every occurrence of the word under the cursor | vim-visual-multi |
| `<leader>m/` | n | Place cursors by regex | vim-visual-multi |
| `<leader>m\` | n | Add a cursor here | vim-visual-multi |

`<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` resize windows in normal mode and move the
selection in visual mode — the same four keys, and no collision, because the
modes differ.

`vim-visual-multi`'s own leader is moved from `\` to `<leader>m`, because `\` is
this configuration's local leader. Every `\`-prefixed command in that plugin's
documentation translates: `\\` becomes `<leader>m\`, `\A` becomes `<leader>mA`,
and so on.

### Completion

Active only while the completion menu is open, except where noted.

| Key | Effect |
|---|---|
| `<Tab>` | Accept the selection, or jump to the next snippet placeholder, or indent |
| `<C-j>` / `<C-k>` | Next / previous item; with the menu closed, `<C-k>` toggles the signature window |
| `<C-y>` | Accept |
| `<C-f>` / `<C-b>` | Scroll the documentation float without focusing it |

Nothing is ever inserted implicitly — accepting a completion always takes a
keypress.

### Messages

| Key | Effect | From |
|---|---|---|
| `<leader>nh` | Message history | noice |
| `<leader>nl` | Last message | noice |
| `<leader>nn` | Search messages and notifications | noice |
| `<leader>nd` | Dismiss all messages | noice |
| `<leader>ne` | Errors | noice |

### TODO markers

| Key | Effect |
|---|---|
| `<leader>tt` | Find markers (telescope) |
| `<leader>tq` | Markers to the quickfix list |
| `<leader>tl` | Markers to this window's location list |

## Plugins

Thirty-one plugin files, grouped by the job each does.

### Language support

- **nvim-lspconfig** — the LSP client: diagnostics display, the buffer-local
  mappings, and the server configurations.
- **mason** — installs servers and tools under `stdpath("data")/mason/`, so
  nothing lands on the system or on the login shell's `PATH`.
- **mason-lspconfig** — declares which servers must be present and enables each
  installed one: `lua_ls`, `vtsls`, `jsonls`, `yamlls`, `cssls`, `html`,
  `tailwindcss`, `basedpyright`, `bashls`, `fish_lsp`.
- **mason-tool-installer** — the same, for the tools that are not servers.
- **roslyn.nvim** — C#. The exception to the path above: it starts its own
  server rather than going through `mason-lspconfig`, which is why
  `roslyn-language-server` is installed but kept out of that allowlist. Two
  instances would attach otherwise.
- **vim-razor** — colours the markup half of a `.razor` buffer, which the
  server does not.

### Completion and formatting

- **blink.cmp** — completion, with **friendly-snippets** as its snippet source.
- **conform.nvim** — the single formatting entry point, on write and on demand
  alike: `stylua` for Lua, `prettierd` (falling back to `prettier`) for the web
  filetypes and markdown, `ruff_format` for Python, `shfmt` for shell.

  Having one entry point is the point. A filetype covered by both an external
  formatter and a formatting-capable server would otherwise produce two
  different results depending on which route the buffer took.

### Git

Three tools at three scales. The boundary between them is which question is
being asked.

- **gitsigns** — *this buffer, line by line*. How the file differs from the
  index, with staging, resetting, previewing and blame for individual hunks.
- **neogit** — *the repository*. Staging, commits, branches, fetch, pull, push,
  rebases, stashes, the log.
- **diffview** — *a whole difference*. Every file that differs against a
  revision, side by side; a file's history; the three-way view a merge conflict
  is resolved in.

Reach for gitsigns while writing code, neogit when committing it, and diffview
when reviewing a change as a whole.

### Navigation

- **telescope** — fuzzy-finds over files, file contents, buffers, help tags,
  symbols, and the repository.
- **flash** — reaches any position visible on screen: type what is there, press
  the label that appears beside it.
- **oil** — presents a directory as an ordinary buffer, so renaming a file is
  editing a line. **A delete here is a real delete, not a move to trash.**

### Editing

- **nvim-autopairs** — closes delimiters as they are typed.
- **nvim-surround** — adds, changes, and deletes the pair around text that
  already exists.
- **mini.move** — shifts a selection around as a unit.
- **vim-visual-multi** — edits at several places at once.

### Interface

- **lualine** — the status line: editing mode, file and modified state, branch
  and working-tree summary, unpushed commits, diagnostic counts, cursor
  position, macro recording.
- **noice** — moves the command line, messages, notifications, and the wildmenu
  off the last screen row into floating views, so a long message is scrolled
  rather than acknowledged with `Press ENTER`.
- **which-key** — lists what a half-typed sequence can still become.
- **render-markdown** — draws markdown as formatted text rather than as its
  markup characters, reverting the cursor's own line to raw source so the
  document stays editable in place.
- **todo-comments** — picks `TODO:`/`FIXME:` and their kin out of the comments
  around them, and lists them across the project.
- **smear-cursor** — animates the cursor between positions, so a large jump is
  traceable instead of the cursor disappearing and reappearing.
- **mini.icons** — the single icon provider every other plugin draws from, so
  the same file shows the same glyph everywhere.

### Sessions and themes

- **auto-session** — writes the open buffers, the window layout, and every
  cursor position on exit, and restores them on the next bare launch in the same
  directory.
- **themery** — the switcher, and the only file in the configuration that
  applies a colorscheme at all. **kanagawa**, **catppuccin**, **rose-pine**, and
  **tokyonight** are installed as bare installs that set nothing themselves,
  with kanagawa wave as the fallback before a theme has been chosen.

## Where the detail lives

This document is orientation and reference: enough to use the configuration and
to change it. It is not the specification.

**`openspec/specs/` is authoritative.** Twenty-nine capability specs cover this
ground exhaustively — the exact mappings and their modes, every option value and
why it holds, which servers are declared, what a session records, what happens
at each edge. When you need to know precisely what something does, or why, read
the spec for it rather than this file.

If this README and a spec disagree, **the spec is right and this file is the
one that gets fixed.** The rule matters because the natural instinct on finding
a contradiction is to trust the document that is easier to edit, which is
exactly backwards.

Changes are proposed and tracked in `openspec/changes/`. A change that adds,
removes, or repurposes anything named here — a plugin, a keymap, an editor-wide
convention, a path — updates this file in the same change. A description that
has outlived what it describes is worse than none, because it is trusted.
