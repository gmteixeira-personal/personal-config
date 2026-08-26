## Why

This configuration has no statusline of its own. The row is drawn — `laststatus` is at Neovim's default of 2 — but what fills it is the stock statusline: a filename, a modified flag, and the ruler. It names no mode, no git branch, and no diagnostics.

More pressingly, one thing that is supposed to be visible is not. `openspec/specs/message-ui/spec.md` requires that "while recording, the user can see that a recording is in progress". It does not happen. Pressing `qa` starts a recording — `reg_recording()` returns `a` — but nothing on screen says so, for two compounding reasons: noice's default route table matches `msg_showmode` with `opts = { skip = true }` and discards it, and `cmdheight=0` means Neovim has no last row to fall back to. The result is a macro that records invisibly, which reads as a key that did nothing.

noice does not treat that skip as a gap. It skips mode messages from *views* because it expects a statusline to carry them: `noice.api.status.mode` exists for exactly this, filtered on exactly the `msg_showmode` event the route drops. The message survives the skip — `Manager.add` writes it to both `_messages` and `_history`, the router's `skip` branch only bypasses `view:push`, and the status API reads `_history` — so the indicator is already available to a statusline and to nothing else. Adding a statusline both fills a row that is currently spent on very little and closes the message-ui gap through the mechanism upstream designed for it.

## What Changes

- Add `nvim-lualine/lualine.nvim` as a new plugin file under `lua/plugins/`, replacing Neovim's stock statusline.
- **Upstream's defaults are taken as they come.** No sections are rearranged, no separators or icons are chosen, and `laststatus` is not touched. The defaults already report the mode, the git branch and working-tree change summary, per-severity diagnostic counts, the filename with its modified and read-only flags, the encoding, the file format, the filetype, and the cursor's position and progress through the file.
- **One deviation from default**, and the reason this change exists: `noice.api.status.mode` is added as a component, which is what makes `recording @a` visible and satisfies the message-ui requirement that is currently unmet. Nothing else is customized.
- **Themes are followed for free.** `theme = "auto"` is already lualine's default: it resolves against the colorscheme in force, and lualine registers a `ColorScheme` autocmd that re-runs its own setup — which is the event Themery's switching fires. This needs no configuration, and it is why the theme requirement costs nothing here.
- **`lua/plugins/noice.lua` gains no route**, but its comment at line 59 is corrected: it currently asserts that `msg_showmode` "is already in noice's default route table and sent to the notify view". It is in the route table, with `skip = true`, and is sent to no view at all.
- No new icon provider. `mini.icons` already mocks `nvim-web-devicons`, which is what lualine asks for, and `lua/plugins/mini-icons.lua` forbids installing the real one.

## Capabilities

### New Capabilities
- `statusline`: a status line reporting the editing mode, the git branch and working-tree change summary, the focused file's name and state, its type, the diagnostics against it, the cursor's position within it, and whether a macro recording is in progress — repainted to follow the active colorscheme whenever it changes.

### Modified Capabilities

None. `message-ui` already requires the recording indicator to be visible and that requirement is unchanged by this proposal — the change makes a violated requirement true rather than restating it. `editor-options` does not enumerate `laststatus`, and this change does not set it: lualine's `globalstatus` default derives from whatever `laststatus` already is, so each window keeps its own status line exactly as now. `icons` is unaffected: lualine consumes the existing mock. `git-integration` is unaffected: it owns per-line hunk indicators in the sign column, not the branch name.

## Impact

- New file `lua/plugins/lualine.lua`. One comment corrected in `lua/plugins/noice.lua`. No `lua/config/` module changes.
- `lazy-lock.json` gains a pinned entry for `lualine.nvim`. No other plugin is added — `mini.icons` and `noice.nvim` are both already installed and are consumed as they are.
- The stock statusline is replaced. `laststatus` stays at 2 and each window keeps a status line of its own. Nothing else reads or writes `vim.o.statusline`.
- Startup cost: the statusline has to be themed before the first frame like the colorscheme is, so this plugin loads eagerly rather than on an event. Measure against the ~39 ms baseline recorded in `lua/config/options.lua`.
- Taking upstream's defaults means upstream's changes to them arrive with an update rather than being pinned here. That is the intent; the alternative is a section table this change has no reason to own.
