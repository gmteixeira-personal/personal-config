## Context

See `proposal.md` — Why. The constraints that shape the approach:

- `lua/plugins/` holds one plugin per file, and that file is the whole description of the plugin (`config-structure`, `plugin-management`).
- `noice.nvim` is installed, `lazy = false`, `priority = 950`, and takes over the command line and messages. Its default route table matches `msg_showmode` with `opts = { skip = true }` — verified against the live merged config, where it is route 17 of 24 and the only route touching the event.
- `cmdheight` is 0 while noice is loaded, so Neovim has no last row on which to draw `recording @a` itself.
- `themery.nvim` is the one caller of `vim.cmd.colorscheme`, at `priority = 1000`, and applies the recorded theme at startup as a side effect of `require("themery")`. Four theme plugins are installed; every one is a bare install that applies nothing itself.
- `mini.icons` is eager at `priority = 900` and calls `MiniIcons.mock_nvim_web_devicons()`. `lua/plugins/mini-icons.lua` states that `nvim-tree/nvim-web-devicons` must never be installed.
- `laststatus` is unset in `lua/config/options.lua`, so it is Neovim's default of 2.

## Goals / Non-Goals

**Goals:**

- One new file, `lua/plugins/lualine.lua`, holding the plugin spec and nothing beyond the one component the capability actually needs.
- `recording @a` visible, closing the `message-ui` requirement that is currently violated.
- Status line colours that follow every theme switch, including between variants of one theme, with no configuration spent on it.

**Non-Goals:**

- Choosing sections, separators, icons, or a fixed theme name. Upstream's defaults are the contract; see the decision below.
- A global status line. `laststatus` stays 2 and each window keeps its own.
- Winbar, tabline, or extensions. All are off by default and stay off.
- Surfacing `msg_showcmd` (the pending-operator display) or `msg_search`, which the same noice route also skips. They are available the same way if they are ever wanted; this change spends nothing on them.
- Adding a noice `routes` entry. The status API already reaches the message; re-displaying it in a view would be a second mechanism for the same thing.

## Decisions

### Take upstream's defaults, and configure only the recording component

lualine's defaults already produce what the `statusline` spec asks for: `lualine_a = { 'mode' }`, `lualine_b = { 'branch', 'diff', 'diagnostics' }`, `lualine_c = { 'filename' }`, `lualine_x = { 'encoding', 'fileformat', 'filetype' }`, `lualine_y = { 'progress' }`, `lualine_z = { 'location' }`. The `filename` component defaults to `file_status = true` with `modified = '[+]'` and `readonly = '[-]'`, and `diagnostics` defaults to `sections = { 'error', 'warn', 'info', 'hint' }` over the `nvim_diagnostic` source — so per-severity counts and the two file-state indicators arrive without being asked for.

Writing those tables out here would pin today's layout and lose upstream's tuning of it — the same reasoning `which-key.lua` records for taking `preset = "modern"` and `noice.lua` for taking `presets` over an expanded `views`/`routes` table. The only entry this file adds is the recording indicator, which is not a default and is the reason the change exists.

Note that `filename` defaults to `path = 0`, a bare name rather than a relative path, so two open files of the same name in different directories read alike on the status line. Accepted: the spec does not require otherwise, and `path = 1` is a one-line change if it ever grates.

Alternatives considered: a hand-written section table matching a list of desired fields (rejected — it owns a layout this change has no reason to own, and every future lualine improvement would have to be merged in by hand); `opts = {}` with no component at all (rejected — leaves `message-ui` violated, which is the whole motivation).

### The recording indicator is `noice.api.status.mode`, not a `reg_recording()` component

A hand-rolled component calling `vim.fn.reg_recording()` would also work and would not depend on noice. It is rejected: noice already owns the message, already formats it (`recording @a`, with the register named), and already clears it — `on_showmode` calls `Manager.remove` when the event fires with empty content, so the component disappears at exactly the right moment with no predicate of ours deciding when.

The mechanism, traced through noice: `on_showmode` calls `Manager.add(message)`, which writes to both `_history` and `_messages`; the router's `skip` branch bypasses only `route.view:push(message)`; `Manager.clear()` at the end of the router pass clears `_messages` and leaves `_history`; and the status API reads `Manager.get(filter, { history = true })` with the filter `{ event = "msg_showmode" }`. So the message the route discards from every view is still exactly where the status API looks for it. This is noice's design, not a loophole — the skip exists *because* the statusline is expected to carry mode messages.

It is added as the documented pair, `get` guarded by `has`, which is the form noice's own README gives for lualine:

```lua
{ require("noice").api.status.mode.get, cond = require("noice").api.status.mode.has }
```

Two things named "mode" now sit on the status line and they are not the same thing: lualine's own `mode` component reports NORMAL/INSERT/VISUAL, while noice's `status.mode` carries the `msg_showmode` message, which is what `recording @a` is. Both are wanted, and the collision is worth a comment in the file rather than a rename.

`lualine_x` is where it goes — beside the filetype, away from `lualine_a`'s mode name, so the two are not read as one field.

Alternatives considered: a `reg_recording()` component (rejected, above); a noice `routes` entry sending `msg_showmode` to the `mini` view (rejected — it re-displays what noice deliberately routed away, and the `mini` backend autohides on a 2 s timer, so it would need an `opts.keep` predicate to survive a recording that outlasts it; the status API needs neither).

### `theme = "auto"`, which is already the default, and needs no entry

The `statusline` spec's theme requirement is met by lualine's default. `theme = 'auto'` resolves `lua/lualine/themes/<vim.g.colors_name>.lua` off the runtimepath, and where no such file exists, `themes/auto.lua` synthesizes a palette from the live highlight groups. `setup_theme()` then registers `autocmd lualine ColorScheme * lua require'lualine'.setup()`, so every `:colorscheme` — which is what Themery issues, both on a switch and on its startup `bootstrap()` — re-runs the whole resolution.

Measured against this configuration's four themes:

| applied | `vim.g.colors_name` | lualine theme |
|---|---|---|
| `kanagawa-wave` | `kanagawa` | ships one |
| `kanagawa-dragon` | `kanagawa` | ships one |
| `catppuccin-mocha` | `catppuccin-mocha` | ships one per variant |
| `rose-pine` | `rose-pine` | ships one |
| `tokyonight-night` | `tokyonight-night` | ships one per variant |

kanagawa is the case worth checking, because both its variants collapse to the same `colors_name` and therefore to the same lualine theme file. It still tracks the variant: `loader.load_theme` uses `dofile`, not `require`, so the file is re-executed rather than served from `package.loaded`, and its first line is `require("kanagawa.colors").setup().theme`, which re-reads the active variant at call time. Measured `normal.a.bg` across the three variants — `#7E9CD8` (wave), `#8ba4b0` (dragon), `#4d699b` (lotus) — confirms it.

So nothing about themes is written into this file. What the file does need is a comment saying that, because "no theme entry" otherwise reads as an oversight in a configuration whose spec makes theme-following contractual.

Alternatives considered: naming a theme explicitly (rejected — pins one colorscheme's palette and breaks on every switch); a `function` theme returning a name per colorscheme (rejected — `auto` already does this, and better, including for themes that ship no palette).

### Eager, ordered behind the colorscheme and the icon mock

`lazy = false` with a priority below themery's 1000 and mini.icons' 900, matching how those two are ordered against each other. The status line is painted in the first frame, so deferring it to `VeryLazy` would show as the stock line being replaced after the editor is already on screen — the same reasoning `gitsigns.lua` and `noice.lua` record for their own load points.

Ordering behind the colorscheme matters for more than tidiness: `themes/auto.lua` reads `vim.g.colors_name` and the live highlight groups at load, so lualine setting up before a colorscheme is applied would resolve against no theme at all. Ordering behind `mini.icons` matters because lualine's `filetype` component asks for `nvim-web-devicons`, which only exists once the mock is registered.

Alternatives considered: `event = "VeryLazy"` (rejected — visible replacement of the stock line, and a first frame themed wrongly); `dependencies = { "echasnovski/mini.icons" }` (rejected — mini.icons is eager and prioritised already, and a dependency entry would start describing a second plugin in this file, which `plugin-management` asks against).

### The wrong comment in `lua/plugins/noice.lua` is corrected, not deleted

Line 59 currently states that `msg_showmode` "is already in noice's default route table and sent to the notify view". The first half is true and the second is false — it is in the table with `skip = true` and reaches no view. The comment is the reason a reader would believe the recording indicator is already handled, so it is corrected in place to say where the message actually goes and which capability now surfaces it.

## Risks / Trade-offs

- **A future lualine release changes its default sections** → the status line changes shape on an update with no edit here. Accepted, and the point of taking defaults; `lazy-lock.json` pins the commit, so it happens on a deliberate update rather than spontaneously.
- **The recording indicator depends on noice** → if noice is ever removed, the component silently shows nothing. It is guarded by `cond = ...has`, so it degrades to an empty section rather than erroring, but `message-ui` would be violated again. Noted here because the two capabilities are now coupled in a way neither file would otherwise show.
- **Two fields called "mode"** → confusing to a reader of the config; addressed with a comment rather than by renaming, since both names are upstream's.
- **`filename` shows a bare name, not a path** → two same-named files in different directories are indistinguishable on the status line. One-line fix (`path = 1`) if it becomes a nuisance; not pre-empted here.
- **Startup cost of an eager plugin** → lualine is small, but it is on the critical path to the first frame alongside noice, themery and mini.icons. Measure against the ~39 ms baseline in `lua/config/options.lua` and reconsider only if it proves material.
- **`kanagawa` variant tracking rests on `dofile` semantics** → if lualine switched `load_theme` to `require`, both kanagawa variants would share whichever palette loaded first. Verified against the installed version; a variant switch that stops changing the status line's colours is the symptom to look for.

## Migration Plan

Additive: one new plugin file, plus one corrected comment in `lua/plugins/noice.lua`. Rollback is deleting `lua/plugins/lualine.lua`, which restores Neovim's stock status line and leaves every other capability untouched — the noice comment correction is true either way and does not need reverting.
