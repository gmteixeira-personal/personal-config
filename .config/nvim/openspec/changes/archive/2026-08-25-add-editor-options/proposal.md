## Why

`lua/config/options.lua` currently sets four things: the two leader keys, and the two colour options rose-pine needs. Everything else is Neovim's default. That was deliberate — the bootstrap change left "which editor options should join `options.lua`?" as an explicit open question, and the tooling change left it open again rather than answer it in passing.

The question is now answerable, because the two changes since have made some of the answers load-bearing rather than cosmetic. Gitsigns puts signs in the sign column, so `signcolumn` decides whether every git-tracked buffer jitters horizontally the moment the first sign appears. The LSP polls `updatetime` for `CursorHold`. The whole `<leader>`-prefix namespace is felt through `timeoutlen`. Answering these together, once, is cheaper than discovering each one as an annoyance.

The rest are the ordinary editing defaults that make the editor pleasant rather than merely functional — indentation, search, scrolling, splits — and they are grouped here because they share one property: every one of them works with zero plugins installed, which is exactly the boundary `config-structure` draws around this file.

## What Changes

### Editor options set in `lua/config/options.lua`

- **Line numbers**: `number` and `relativenumber` both on, for absolute position on the cursor line and relative distances for motion counts.
- **Colours**: `termguicolors` and `background = "dark"` — already set today, restated by the spec so the file is self-describing rather than incidentally correct.
- **Indentation**: `expandtab`, `shiftwidth`/`tabstop`/`softtabstop` all 2, `smartindent`.
- **Search**: `ignorecase` with `smartcase`, `incsearch` on, `hlsearch` off.
- **Scrolling and gutter**: `scrolloff = 8`, `signcolumn = "yes"`.
- **Persistence and timing**: `undofile`, `updatetime = 250`, `timeoutlen = 300`.
- **Splits**: `splitright`, `splitbelow`.
- **Wrapping**: `wrap = true`, with `linebreak` and `breakindent`.
- **External edits**: `autoread`.

### Clipboard

- Set `clipboard = "unnamedplus"`, so yank and delete reach the system clipboard without an explicit `"+` register.
- Supply a clipboard bridge **only where Neovim cannot find one itself**. On a native Linux terminal Neovim's own provider detection (`wl-copy`, `xclip`, `xsel`) is left entirely alone. Under WSL it is also left alone when `win32yank.exe` is present, since Neovim already prefers it. Only the remaining case — WSL where Neovim's detection comes up empty — gets an explicit provider built from `clip.exe` and `powershell.exe`. On this machine that branch is never reached: WSLg sets `$DISPLAY` and `xclip` is installed, so Neovim picks `xclip` and the guard turns itself off, which is exactly the property the guard exists to have. The check is made on a deferred tick, because asking the question during startup costs ~60 ms on WSL.

### Conventions this change establishes

- **`options.lua` is a flat list of assignments, not a program.** The clipboard bridge is the single exception, and it is conditional on the environment rather than on any plugin.
- **An option that is inert is not set.** Options are set because they change behaviour on this configuration, not because they are conventional.

Non-goals: filetype-specific overrides (a 2-space default does not survive contact with Go or Makefiles, and per-filetype indentation is its own change), any keymap, any plugin, and `undodir` relocation — the default under `stdpath("state")` is correct.

## Capabilities

### New Capabilities

- `editor-options`: The general editor behaviour that holds with no plugin installed — how text is displayed and wrapped, how it is indented, how search behaves, what persists across sessions, where splits open, and how the editor exchanges text with the system clipboard.

### Modified Capabilities

None. `config-structure` already requires that general editor options live in `lua/config/options.lua` and that no plugin file sets one; this change populates that file rather than altering the rule. The `colorscheme` capability's requirement that a dark 24-bit palette be in effect is likewise unchanged — `editor-options` states `termguicolors` and `background` as its own concern, and the two agree.

## Impact

- **Files modified**: `lua/config/options.lua` only. It is the sole file this change touches: no file under `lua/plugins/` is edited, no keymap is added, and `init.lua` is unchanged.
- **New runtime state**: `undofile` creates persistent undo history under `stdpath("state")/undo`, which grows with use and is safe to delete.
- **External dependencies**: none added. The WSL clipboard bridge uses `clip.exe` and `powershell.exe`, which exist on any WSL installation by definition. A native Linux terminal needs `wl-clipboard` or `xclip` for the clipboard to function, which is Neovim's own long-standing requirement and not introduced here.
- **Behaviour changes a returning user will notice**:
  - `hlsearch` off means a completed search leaves no highlight — matches are shown while typing via `incsearch` only.
  - `timeoutlen = 300` shortens the window for completing a multi-key sequence. Every `<leader>` mapping in the configuration is two or three keys (`<leader>fg`, `<leader>hs`, `<leader>cf`), so they must be typed as a deliberate sequence rather than idly. This is a real trade against the keymap namespace the tooling change established, taken knowingly for a more responsive `<Space>`.
  - `wrap = true` means long lines soft-wrap instead of scrolling horizontally, so a single logical line may occupy several screen rows and `j`/`k` still move by logical line.
  - `signcolumn = "yes"` reserves the gutter permanently, costing one column in every buffer including those with nothing to show, in exchange for text never shifting sideways when a sign appears. This answers the open question recorded in the tooling change's design.
- **Performance**: `updatetime = 250` raises how often Neovim fires `CursorHold` and writes its swap file. This is the value LSP-adjacent features expect; the cost is more frequent idle work.
- **Breaking**: none for existing behaviour. The two colour options already hold their proposed values, and everything else moves a Neovim default rather than replacing a configured value.
