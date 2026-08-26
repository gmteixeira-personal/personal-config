## Context

See `proposal.md` — Why. The constraints that shape the approach:

- `lua/plugins/` holds one plugin per file, and that file is the complete description of the plugin: its options, its keymaps, its dependencies, and its load condition (`plugin-management`). Nothing about this change may reach `lua/config/keymaps.lua`.
- Every other interactive plugin in this configuration loads on `keys` rather than an event (`nvim-surround`, `telescope`, `vim-visual-multi`, `conform`), and the jump-motions spec repeats that as a requirement.
- The editor is Neovim 0.12, whose runtime already provides tree-sitter and a set of parsers. `nvim-treesitter` is deliberately not installed and must not be introduced by this change.
- `nvim-surround` shadows visual-mode `S` by design, and `<C-s>` writes the buffer in normal, insert, and visual mode. Both must survive.

## Goals / Non-Goals

**Goals:**

- One new file, `lua/plugins/flash.lua`, carrying every mapping and every option.
- Each of the six behaviours in `specs/jump-motions/spec.md` reachable without loading the plugin at startup.
- The tree-sitter modes fail legibly, not loudly, in a buffer with no parser.

**Non-Goals:**

- Configuring which characters are used as labels, the backdrop dimming, or the highlight groups. Upstream defaults are taken until a concrete complaint exists.
- The `flash.jump()` API used from other plugins (telescope pickers, LSP handlers). That is a later change if it is wanted at all.
- Installing or managing tree-sitter parsers. What the runtime ships is what the tree-sitter modes cover.

## Decisions

### Load on `keys`, and list every key the capability needs — including `f`, `t`, `F`, `T`, `/`, and `?`

`flash.nvim` installs its character-motion and search hooks inside `setup()`. A `keys` list of only `s`/`S`/`r`/`R`/`<C-s>` — the arrangement most published configurations use — therefore leaves `f`, `t`, `F`, `T`, `/`, and `?` stock until some *other* flash key has been pressed in the session. The spec requires them enhanced, so `f`, `F`, `t`, `T` (normal, visual, operator-pending) and `/`, `?` (normal, visual) are listed as `keys` too. lazy.nvim installs a stub for each, loads the plugin on the first press, and replays the key into the mapping flash has by then installed.

`;` and `,` are deliberately *not* listed. Before the plugin loads they mean exactly what flash makes them mean afterwards — repeat the last character motion forwards or backwards — so a stub would buy nothing and would load the plugin on a keystroke that did not need it.

Alternatives considered: `event = "VeryLazy"`, which is what makes the hooks unconditional in one line. Rejected because it loads the plugin in every session, including the ones that never jump, and the spec forbids that.

### `S` is mapped in normal and operator-pending mode only

Upstream's default maps `S` in `n`, `x`, and `o`. The `x` entry is dropped: `nvim-surround` owns visual-mode `S`, `surround-edits` states that shadow is deliberate, and the user chose to keep it. Node selection is still reachable from a visual selection through `R` (tree-sitter search), which is mapped in `x`.

The consequence is that `S` cannot be pressed a second time *from within the visual selection it just created* to grow the selection — the second press hits surround. Growing works from the labels flash offers on the first press, which is the path the spec describes.

### Normal-mode `s` and `S` are taken, and that is recorded in the surround spec

`surround-edits` currently promises that bare `s` keeps its stock substitute meaning. That promise is now false, so the delta rewrites the requirement rather than leaving two specs disagreeing. Substitute stays reachable as `cl` and linewise change as `cc`; neither loses a keystroke that matters at the rate `s` is now used.

### Tree-sitter modes are guarded by a parser check in the plugin file

`vim.treesitter.get_parser()` raises when the buffer's language has no parser in the runtime, and Neovim 0.12 ships parsers for a handful of languages only — the rest of the buffers this configuration opens have none. An unguarded `S` would surface a stack trace in the common case.

The two tree-sitter keys therefore call small local wrappers in `lua/plugins/flash.lua`: `pcall(vim.treesitter.get_parser, 0)`, and on failure a single `vim.notify` at warning level naming the buffer's filetype, with no call into flash. On success the wrapper calls `require("flash").treesitter()` or `treesitter_search()` unchanged.

Alternatives considered: letting the error through (rejected — the spec requires a plain report), and installing `nvim-treesitter` to widen parser coverage (rejected — out of scope by the user's decision, and a second tree-sitter runtime alongside the bundled one).

### Options are set explicitly for the modes the spec names

`opts` names `modes.char.enabled`, `modes.search.enabled`, and `modes.char.jump_labels` explicitly rather than relying on upstream defaults, because those particular defaults have changed across flash releases and the spec now depends on them. Everything else — label characters, highlighting, backdrop, jump behaviour — is left unset, matching how `nvim-surround` passes `opts = {}` in this configuration.

`version` is left unpinned, unlike `nvim-surround`'s `version = "*"`: flash publishes no tags, so a version constraint would resolve to nothing. `lazy-lock.json` is what pins it.

## Risks / Trade-offs

- **`s` is muscle memory for substitute** → `cl` is the replacement and it is one keystroke longer. Reverting is deleting one file; the spec's removal scenario says so.
- **Tree-sitter modes are near-useless in most buffers** on a runtime that ships parsers for `c`, `lua`, `markdown`, `query`, `vim`, and `vimdoc` → accepted deliberately: the warning tells the user why, and the other four modes are unaffected. Widening coverage is a separate change.
- **The `/` and `?` stubs put a lazy.nvim mapping on the search keys** → a mapping that loads a plugin and replays the key. If the replay ever misbehaves, search is the most disruptive thing to have broken. Mitigation is that the same mechanism already carries `ys`, `ds`, `cs`, and the telescope keys in this configuration.
- **Labels can collide with the next character the user meant to type** in search mode → `<C-s>` toggles them off mid-search, which the spec requires.
- **`r` in operator-pending shadows nothing**, but `r` in normal mode is replace-character and is untouched → worth stating in the file's comment, since the two are one keystroke apart.

## Migration Plan

Adding the file and restarting installs the plugin and takes effect. Rollback is deleting `lua/plugins/flash.lua` and restarting; `lazy.nvim` reports the plugin as removable and `s`, `S`, `f`, `t`, `F`, `T`, `/`, and `?` return to stock on the same restart.
