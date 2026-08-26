## Context

The configuration is empty: `init.lua` is zero bytes and `lua/config/` has no files. Neovim is **0.12.5**, so `vim.uv`, `vim.keymap.set`, and 24-bit color defaults are all available. See `proposal.md` — Why for motivation, and the five specs under `specs/` for the behavior contract.

Three constraints drive nearly every decision below, and all three are ordering constraints:

1. `vim.g.mapleader` is read when a mapping is *defined*, not when it is pressed. Any mapping declared by a plugin spec is therefore wrong unless the leader is already set when the plugin manager evaluates specs.
2. The colorscheme must be applied before the first frame, or the user sees a visible repaint from default colors into the theme.
3. The `nvim-web-devicons` compatibility shim must be installed before the first plugin asks for icons, or that plugin errors on a missing module.

## Goals / Non-Goals

**Goals:**

- One obvious home for every kind of configuration, enforced by structure rather than by discipline.
- A single-file operation to add or remove a plugin, with no registration list to keep in sync.
- Startup ordering that is correct by construction, not by luck of alphabetical file order.
- A foundation that later changes (LSP, treesitter, completion) extend without revisiting these decisions.

**Non-Goals:**

- Startup-time optimization. Four plugins do not justify aggressive lazy-loading; correctness of ordering beats milliseconds here.
- A personal option set. `options.lua` ships only what the specs require; editor preferences are a follow-up change.
- Abstraction layers over lazy.nvim. Plugin files are plain lazy.nvim specs, readable against upstream documentation.

## Decisions

### Load order lives in `init.lua`, and only load order lives there

`init.lua` requires exactly three modules, in order: `config.options`, `config.keymaps`, `config.lazy`. It contains nothing else.

This makes constraint 1 structural rather than incidental — `mapleader` is assigned at the top of `options.lua`, which is the first thing loaded, so by the time `config.lazy` evaluates any plugin spec the leader is already `<Space>`. Nothing can reorder this by accident.

*Alternative considered:* setting `mapleader` directly in `init.lua` above the requires, as many configurations do. Rejected because it splits "where options live" across two files for one special case, and the ordering guarantee is already provided by loading `options.lua` first.

### `mapleader = "<Space>"`, `maplocalleader = "\\"`

Leader is Space, as requested. Local leader is set explicitly to backslash rather than left at its default — which is *also* backslash, but implicitly. Setting it explicitly means a future change to leader cannot silently collide with localleader.

Space must additionally be mapped to `<Nop>` in normal and visual mode, or pressing it without completing a mapping falls through to its default "move cursor right" behavior. That `<Nop>` is a general keymap with no plugin involved, so it lives in `keymaps.lua` while the leader assignment lives in `options.lua`. The split is deliberate: `vim.g.mapleader` is a variable that must precede everything, the `<Nop>` is an ordinary mapping.

### lazy.nvim, bootstrapped from `--branch=stable`

Bootstrap follows the upstream snippet: check `vim.uv.fs_stat` for the manager under `stdpath("data")`, clone with `--filter=blob:none --branch=stable` if absent, prepend to `runtimepath`. On non-zero `shell_error`, echo the captured `git` output *and the path it was cloning to* as an error, wait for a keypress, and exit non-zero — a failed bootstrap must not proceed into a half-configured session that reports confusing downstream errors.

`--branch=stable` rather than the default branch satisfies the pinning requirement in `specs/plugin-management`.

*Alternatives considered:* `vim.pack`, native to Neovim 0.12, is appealing for having zero bootstrap step at all — but it has no lockfile and a much smaller body of documentation and community specs to draw on, and lazy.nvim was requested by name. `mini.deps` would pair neatly with mini.icons but shares the same maturity gap. Packer is unmaintained.

### Plugin discovery by directory import

`require("lazy").setup()` is given `spec = { { import = "plugins" } }`. lazy.nvim walks `lua/plugins/`, loads each module, and merges the returned specs. Adding a plugin is exactly one new file; there is no list to update, which is what makes the "one plugin per file" rule hold on its own rather than depending on contributors remembering to register things.

Supporting settings: `install.colorscheme = { "rose-pine-main", "habamax" }` so the first-run install UI is themed, `checker.enabled = false` and `change_detection.notify = false` to keep startup free of update noise, `rocks.enabled = false` since no plugin here needs luarocks.

### Plugin files own their options and keymaps; the general modules stay plugin-free

Each file under `lua/plugins/` carries its plugin's `opts`/`config`, its `keys`, and its `dependencies`. Neither `options.lua` nor `keymaps.lua` may reference a plugin.

The payoff is that both directions of the rule are checkable by reading one file. Deleting a plugin file removes its settings and its mappings with it, leaving nothing stale behind; and `options.lua` and `keymaps.lua` load correctly with zero plugins installed, so a broken plugin can never take basic editor behavior down with it. It also means each plugin file reads against upstream documentation directly, with no configuration scattered elsewhere to reconcile.

### mini.icons as the only provider, with a `nvim-web-devicons` mock

`mini.icons` is installed with `lazy = false` and `priority = 900`. Its `config` calls `require("mini.icons").setup(opts)` and then `MiniIcons.mock_nvim_web_devicons()`, which registers mini.icons into `package.loaded` under the `nvim-web-devicons` name and implements that module's interface (`get_icon`, `setup`, and friends).

The consequence, and the reason this satisfies "icons in every plugin": a plugin that hard-requires `nvim-web-devicons` gets mini.icons transparently, so `nvim-web-devicons` is never installed and there is never a second provider whose icons or highlight groups disagree with the first. mini.icons additionally covers categories devicons does not — directories, LSP kinds, and filetypes — which is what later plugins will want.

Eager loading at priority 900 is what makes constraint 3 structural: the mock is registered before any lower-priority or event-loaded plugin can request icons. mini.icons is small enough that eager loading costs little.

*Alternative considered:* keeping mini.icons lazy and installing the mock through a `package.preload["nvim-web-devicons"]` hook in the spec's `init`. This is more elegant — the mock resolves on first actual demand — but it is a subtler mechanism to debug when a plugin loads at an unexpected time, and it buys back only a few milliseconds. Worth revisiting only if startup time becomes a real concern.

**Standing rule for future plugins:** depend on `echasnovski/mini.icons`, never add `nvim-tree/nvim-web-devicons` as a dependency. A single spec listing it would reintroduce the second provider this decision exists to prevent.

### rose-pine at priority 1000, applied by explicit variant name

rose-pine is `lazy = false` with `priority = 1000` — the highest, so it loads before every other plugin and satisfies constraint 2. Its `config` runs `setup()` and then `vim.cmd.colorscheme("rose-pine-main")`.

The variant is applied by the explicit `rose-pine-main` colorscheme name rather than the bare `rose-pine` plus a `variant` option. The bare name resolves its variant from `&background`, so anything that later flips `background` would silently switch the theme; the explicit name cannot drift. `background = "dark"` and `termguicolors` are still set in `options.lua`, since other plugins and rose-pine's own palette read them.

### oil.nvim eager-loaded, toggled as a float

`<leader>e` maps to `require("oil").toggle_float()`, declared in oil's own spec via `keys`.

oil is nonetheless `lazy = false`. This looks contradictory next to a `keys` mapping, but it is required: hijacking netrw so `nvim <directory>` opens oil means oil must be loaded before that first buffer is created, which a `keys`-triggered lazy load is by definition too late for. `keys` still works with eager loading — it is just the mapping declaration. Configuration is `default_file_explorer = true` to take over netrw, `columns = { "icon" }` for the icon column, and oil's default confirmation behavior left untouched so that pending deletions are previewed and confirmed on write.

`toggle_float` gives true toggle semantics — the same key closes the float and restores the previous buffer — which a plain `:Oil` in the current window would not.

## Risks / Trade-offs

- **A Nerd Font is required in the terminal; without one every icon renders as tofu.** → Out of the configuration's control, but recoverable inside it: mini.icons accepts `style = "ascii"`, which swaps every glyph for a plain-text fallback in one line. Document it as the fix rather than pre-emptively degrading the default.
- **Three of four plugins are `lazy = false`.** → Accepted deliberately. Each has an ordering reason (theme first frame, icon mock before consumers, netrw hijack before first buffer) and all three are small. Revisit only when the plugin count is large enough for startup time to be measurable.
- **The `nvim-web-devicons` mock tracks an interface mini.icons does not own.** → If a plugin uses a devicons API the mock has not implemented, it fails at that call site. Low likelihood — the mock covers the common surface and is widely used — and the fallback is installing the real devicons for that one case, at the cost of the single-provider guarantee.
- **`lazy-lock.json` cannot be committed: this directory is not a git repository.** → The lockfile is still written and still pins versions locally, so nothing breaks. The reproducibility requirement in `specs/plugin-management` is only fully realized once the config is under version control; worth doing, but out of scope here.
- **Eager `lazy = false` plugins fail loudly at startup rather than at first use.** → This is the intended trade: a broken theme or icon provider surfacing immediately is better than a confusing failure ten minutes later. `options.lua` and `keymaps.lua` stay plugin-free precisely so that basic editing survives such a failure.

## Migration Plan

There is nothing to migrate — `init.lua` is empty and no plugins are installed. First launch after the change clones lazy.nvim, installs the four plugins, and writes `lazy-lock.json`.

Rollback is deleting the created files and `~/.local/share/nvim/lazy/`, which returns Neovim to its stock defaults.

## Open Questions

- Which editor preferences (line numbers, indentation, search behavior, split direction, clipboard) should join `options.lua`? Deliberately deferred: none of the five specs constrain them, adding them later touches one file, and they are personal enough to be worth deciding separately from the structure.
