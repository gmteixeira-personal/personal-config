## Context

See proposal.md — Why.

`lua/plugins/telescope.lua` already declares seven `<leader>f`-prefixed and four `<leader>g`-prefixed mappings in a `keys` table, each a thunk calling into `telescope.builtin`. The plugin loads on those keys alone. Nothing about that structure has to change to add an eighth entry.

`lua/plugins/rose-pine.lua` is the only theme installed, and it is the only plugin in the configuration with `lazy = false, priority = 1000` — it has to be applied before the first frame is drawn, which is the one thing a colorscheme cannot be lazy about. Once the other three are installed and previewed, that ownership moves to `themes/kanagawa.lua`; see "Which file owns startup" below.

## Goals / Non-Goals

**Goals:**

- One mapping, in the file that already owns Telescope's mappings.
- Preview that shows the theme on the buffer the user was editing, not on a sample.
- Enough themes installed that the picker is worth opening, at no startup cost.

**Non-Goals:**

- Persisting the choice. Covered in Decisions below.
- A single line naming the active theme, so switching never means moving `lazy`/`priority` between files. Discussed and deliberately deferred: it wants all four themes in one spec file, which trades away one-plugin-one-file. The switch to kanagawa has now exercised the move once, and it cost three properties in two files — not enough to pay for the trade yet.
- Curating which colorschemes the picker offers. It lists what is available; filtering is worth wanting only once the list is long enough to be a problem.

## Decisions

### Telescope's built-in picker over a dedicated theme-switcher plugin

`telescope.builtin.colorscheme` is already installed and does the preview part in full. The alternative considered was `zaldih/themery.nvim`, which does the same preview and additionally persists the choice across restarts.

Persistence is the whole of what themery adds, and it buys it at a price this configuration should not pay: themery persists by *rewriting a Lua file in the config directory on selection*. A plugin that edits tracked configuration files as a side effect of a keypress turns `git status` into a record of theme experiments, and makes an idle keystroke a source of working-tree diffs. That is a bad trade for a config that is a git repository.

The third option — a Telescope picker plus a `ColorScheme` autocmd writing the name into `stdpath("data")`, read back at startup — avoids the tracked-file problem and costs about fifteen lines. It is the right shape *if* persistence is wanted. It is deferred rather than rejected: this change establishes whether the picker gets used at all, and persistence is additive on top of it.

So: no persistence now. Making a previewed theme permanent means editing a plugin file, which is a deliberate act that leaves a reviewable diff — as the move to kanagawa `wave` does.

### `enable_preview = true` is passed explicitly

The picker's preview is opt-in; without the flag the picker lists names and applies one only on selection, which makes it a slower way to do what editing the theme file already does. The flag is the feature.

Preview works by applying the colorscheme as the selection moves, and Telescope restores the prior colorscheme and `background` when the picker is dismissed. That restore is the mechanism behind the "backing out" scenario in the spec — it is Telescope's behavior, not something this configuration implements.

### `<leader>ft` for the mapping

`t` for theme. `<leader>ft` is unbound, and `<leader>f` is a prefix that is never a mapping in its own right, so nothing under it waits out `timeoutlen` — the property the fuzzy-finder spec already requires and this addition has to preserve. It sits with the other `<leader>f` pickers in `telescope.lua`, per the ownership rule in `config-structure`.

`<leader>fc` was the other candidate, for colorscheme; `t` wins on being the word actually reached for, and leaves `fc` free.

### The three new themes install lazily, and are still listed

The obvious worry with `lazy = true` on a colorscheme is that an unloaded plugin is not on the runtimepath, so `getcompletion("", "color")` cannot see it and the picker would list only rose-pine's variants plus Neovim's bundled themes — themes installed but unreachable, the worst of both.

Telescope handles exactly this case. `telescope/builtin/__internal.lua:1050-1060` extends the colour list from `lazy.core.util.get_unloaded_rtp`, globbing `colors/*` under every not-yet-loaded plugin directory. lazy.nvim closes the other half: it maps colorscheme names to the plugins providing them and loads the owner on `ColorSchemePre`, so `vim.cmd.colorscheme("kanagawa-dragon")` on an unloaded plugin loads it and then applies it.

So the two spec scenarios — an unloaded theme is listed, and selecting one just works — are satisfied by machinery that already exists in both plugins. Nothing in this configuration implements them, but both are worth stating as requirements because they are what makes `lazy = true` safe here, and a future change that swaps the picker or the manager would silently break them.

Startup therefore stays at one eagerly-loaded theme regardless of how many are installed.

### The new theme specs carry no `opts`

kanagawa, tokyonight and catppuccin each ship `colors/*.lua` files that call their own setup as part of being applied, so none of them needs a `setup()` call before `:colorscheme` works. Passing `opts = {}` would make lazy.nvim call `setup()` at load time to no effect, and would imply the configuration has an opinion about these themes' settings, which it does not yet — the point of installing them is to find out.

rose-pine loses its `opts` when it stops being the startup theme, and kanagawa does not gain any: the variant is now chosen by picking `kanagawa-wave` in `config`, which is the same explicit-variant decision rose-pine's `variant = "main"` used to record. `opts` bought nothing once the theme is applied by name.

`catppuccin/nvim` needs an explicit `name = "catppuccin"`, for the same reason `rose-pine/neovim` carries `name = "rose-pine"`: lazy.nvim derives a plugin's name from the last path segment of the repository, which for that spec is the useless `nvim`.

### Themes live in `lua/plugins/themes/`, imported explicitly

Four theme files in a flat `lua/plugins/` sit among the LSP, completion and git files with nothing marking them as a set to choose among. A directory says it.

The trap is that lazy.nvim's import does not recurse. `lazy/core/util.lua`'s `lsmod` lists `.lua` files in a directory and descends into a subdirectory only when it contains `init.lua`, importing that `init.lua` alone rather than its siblings. A file dropped into `lua/plugins/themes/` under the current `{ import = "plugins" }` is therefore ignored **silently** — no error, no plugin, nothing in `:Lazy`.

Two ways out were considered. The one taken is an explicit second entry in `lua/config/lazy.lua`'s `spec`:

```lua
spec = {
  { import = "plugins" },
  { import = "plugins.themes" },
},
```

The rejected alternative was an `init.lua` inside the folder containing `return { import = "plugins.themes" }`, which works — lazy dedupes imports, so the self-reference terminates and the siblings get picked up — and leaves `lazy.lua` untouched. It was rejected for reading as a no-op to anyone who does not know `lsmod`'s rules. A line in `lazy.lua` naming the directory is legible without knowing anything.

The cost is real and is why `plugin-management` changes: that spec promises adding a plugin needs one file and no registration list, and the comment on the `spec` line in `lazy.lua` says the same. For a plugin in an existing directory that stays true. For the first plugin in a *new* directory it does not — and the failure mode is silence, which is precisely what that requirement exists to prevent. The requirement is narrowed to distinguish the two cases, and the comment in `lazy.lua` is corrected alongside it.

### Which file owns startup is a moving property

Exactly one theme file carries `lazy = false`, `priority = 1000` and a `vim.cmd.colorscheme(...)` call. It started as `themes/rose-pine.lua` and is now `themes/kanagawa.lua`, applying `kanagawa-wave`; `themes/rose-pine.lua` was left a bare install alongside the other two. Switching again is the same move in the other direction.

Two details the first move surfaced, both worth doing whenever startup changes hands: the vacated file's `config` has to go with the rest, or the old theme re-applies itself the moment the picker previews it; and `install.colorscheme` in `lazy.lua`, which themes the first-run install UI, names the startup theme and goes stale silently.

This is stated in the `colorscheme` spec rather than left as folklore, because two theme files both calling `colorscheme` at startup is not an error — it is a race whose winner is load order, and whose symptom is an intermittently wrong theme rather than a message.

## Risks / Trade-offs

- **A stale `{ import = "plugins.themes" }` after the directory is emptied or renamed** → lazy.nvim reports an import that resolves to nothing rather than failing silently, which is the opposite of the failure mode being guarded against, so no mitigation beyond the corrected comment.

- **Preview leaves the wrong theme active if the picker exits abnormally** — an error inside a colorscheme file mid-preview, say → The theme is session-scoped and nothing is written to disk, so `:colorscheme rose-pine-main` or a restart fixes it completely. This is precisely the failure mode that persistence would have made permanent.

- **Three more plugins to keep updated, for a feature that is cosmetic** → They are pinned in `lazy-lock.json` like everything else and are never loaded unless previewed, so an out-of-date theme costs nothing until it is used. Deleting a theme is deleting its file.

- **Some bundled colorschemes will look broken under plugins that assume a modern theme's highlight groups** → Cosmetic and transient, visible only while previewing that entry. Not worth pre-filtering the list over.

- **Theme chosen, then lost on restart, reads as a bug to someone who does not know it is deliberate** → It is specified as intended behavior in the `colorscheme` delta, and the mapping's comment in `telescope.lua` should say the same in a line, naming the theme that does start.

- **Comments elsewhere justify a setting by naming the theme** — `options.lua` explains `termguicolors` and `background` in terms of rose-pine → Reworded to name no theme, since every installed theme wants both. A comment that names the startup theme is a comment that goes stale on the next switch, and only `themes/kanagawa.lua`, `lazy.lua`'s `install.colorscheme` and the `<leader>ft` comment have a reason to.
