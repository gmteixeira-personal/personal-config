## 1. Plugin file

- [x] 1.1 Create `lua/plugins/lualine.lua` returning a single spec for `nvim-lualine/lualine.nvim`, with no `dependencies` entry
- [x] 1.2 Write the file's header comment: what the capability is, that upstream's defaults are taken as they come and the only presentation choice made here is the recording indicator, and that the indicator is what closes the `message-ui` requirement noice's `msg_showmode` route otherwise leaves unmet
- [x] 1.3 Set `lazy = false` with a priority below themery's 1000 and mini.icons' 900, and comment both halves of the ordering: `themes/auto.lua` reads `vim.g.colors_name` and the live highlight groups at load, so a colorscheme must already be applied; and the `filetype` component asks for `nvim-web-devicons`, which exists only once mini.icons has registered its mock

## 2. Options

- [x] 2.1 Add the recording indicator to `sections.lualine_x`, ahead of the default entries, as `{ require("noice").api.status.mode.get, cond = require("noice").api.status.mode.has }`
- [x] 2.2 Comment the indicator: that noice's default route table matches `msg_showmode` with `skip = true` so it reaches no view, that the message still lands in `Manager._history` where the status API reads it, and that noice clears it itself when recording stops so no predicate here decides when it disappears
- [x] 2.3 Comment the name collision: lualine's own `mode` component in `lualine_a` reports NORMAL/INSERT/VISUAL, while noice's `status.mode` carries the `msg_showmode` message that `recording @a` is — two different things, both upstream's names
- [x] 2.4 Restate the other five default sections only if `lualine_x` cannot be extended without them; otherwise leave every other section absent, with a comment saying the defaults are deliberately not written out and naming what they already provide (mode, branch, diff, per-severity diagnostics, filename with `[+]`/`[-]`, encoding, fileformat, filetype, progress, location)
- [x] 2.5 Leave `options.theme` absent, with a comment recording why the theme requirement needs no entry: `auto` is the default, it resolves `lua/lualine/themes/<colors_name>.lua` and synthesizes from live highlights when there is none, and `setup_theme()` registers a `ColorScheme` autocmd that re-runs setup on every switch Themery makes
- [x] 2.6 Leave `globalstatus`, `laststatus`, separators, icons, winbar, tabline, and extensions untouched, with a comment saying each window keeps its own status line exactly as before

## 3. Correct the noice comment

- [x] 3.1 Rewrite the sentence at `lua/plugins/noice.lua:59` that asserts `msg_showmode` is "sent to the notify view": say instead that it is in the default route table with `skip = true`, reaches no view, and is surfaced by the statusline capability through `noice.api.status.mode`
- [x] 3.2 Confirm no `routes` entry is added to `lua/plugins/noice.lua` — the status API already reaches the message

## 4. Verification

- [x] 4.1 Start the editor and confirm the status line is drawn in the startup colorscheme's colours in the first frame, with no visible repaint from other colours
- [x] 4.2 Press `q` then a register in normal mode and confirm the status line shows the recording and names the register; press `q` again and confirm it disappears
- [x] 4.3 Switch colorscheme with `<leader>ft` and confirm the status line repaints; switch between two variants of kanagawa and confirm the colours differ between them
- [x] 4.4 Confirm each of the four installed themes leaves the status line legible and themed, and that no `nvim-web-devicons` warning is raised
- [x] 4.5 Split the window and confirm each split carries its own status line
- [x] 4.6 Open a file outside a git repository and a buffer with no filetype, and confirm the empty sections are omitted with no error
- [x] 4.7 Confirm `lazy-lock.json` gained a pinned `lualine.nvim` entry and that no icon provider was added

## 5. Spec sync

- [x] 5.1 Confirm `openspec/specs/message-ui/spec.md` still reads as it does today — its recording requirement is satisfied by this change, not modified by it — and leave it untouched
- [x] 5.2 Leave `openspec/specs/statusline/spec.md` to be created by the archive step from this change's delta
