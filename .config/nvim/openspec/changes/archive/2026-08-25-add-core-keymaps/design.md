## Context

See proposal.md — Why. What shapes the approach here is where each mapping is allowed to live and what Neovim 0.12 already provides.

Three constraints govern everything below:

1. **`config-structure` splits mappings by whether they need a plugin.** A mapping that works with every plugin removed goes in `lua/config/keymaps.lua`; a mapping that calls a plugin goes in that plugin's file under `lua/plugins/`. This is not a stylistic preference — the spec has a scenario asserting that deleting a plugin file removes its mappings and leaves nothing behind in `lua/config/`. So this change edits five files rather than one, and the split is decided per mapping, not per feature.

2. **Neovim 0.12.5 ships more than most configurations assume.** `grn`, `gra`, `grr`, `gri`, `grt`, `gO` and `K` are already bound to LSP actions. `[d` and `]d` are already bound to diagnostic jumps. `:restart` exists as a built-in command. Several items in this change are therefore *restatements* or *aliases* rather than new behaviour, and the design has to be explicit about which, so nobody later "fixes" a redundant-looking line by deleting it.

3. **`timeoutlen` is 300ms** once `add-editor-options` lands. Every prefix introduced here competes for that window, and any prefix that is also a mapping in its own right stalls for the full 300ms on every press. `fuzzy-finder` already established the rule — `<leader><leader>` exists precisely so `<leader>f` need not be bound — and this change follows it for `<leader>s` and `<leader>g`.

## Goals / Non-Goals

**Goals:**

- Put each mapping in the file that `config-structure` requires, with no mapping in `lua/config/keymaps.lua` that references a plugin.
- Add LSP aliases without degrading any built-in mapping's response time.
- Make `<C-w>\` a genuine toggle — restoring the exact prior layout, not equalizing.
- Keep every mapping that shadows a Vim default scoped as narrowly as the shadowing allows.

**Non-Goals:**

- A which-key or any other mapping-discovery UI. The `desc` field on each mapping is populated so that such a plugin would work if added later, but adding one is its own change.
- A window-management plugin. `<C-w>\` is roughly thirty lines of Lua; a dependency for it is not warranted.
- Reworking `<leader><leader>` for files or the `<leader>f` prefix. `fuzzy-finder` settled that and this change does not revisit it.
- Buffer *cycling* (`bnext`/`bprevious`) or buffer deletion. `<leader>bb` is alternate-buffer only; a fuller `<leader>b` set is a later change.
- Live-reloading Lua modules. See the `<leader>rc` decision.

## Decisions

### `gr` is not bound; references stays on the built-in `grr`

The request named `gr` for references. Binding it would make `grn`, `gra`, `gri` and `grt` each wait out `timeoutlen` before firing, because Neovim cannot know whether a `gr` press is complete until the window expires. That is a 300ms stall on rename and code action — the two actions this change is trying to make *faster* — in exchange for saving one keystroke on references.

`gi`, `K`, `<leader>rn` and `<leader>ca` have no such problem: none is a strict prefix of a default, and `K` *is* the default, restated for legibility.

Alternatives rejected: binding `gr` and accepting the stall (trades the common case for the rare one); rebinding the whole `gr*` family to a different prefix (a wholesale replacement of the defaults, which `language-servers` forbids and which breaks every piece of Neovim documentation).

The `language-servers` requirement is therefore narrowed rather than deleted. Its old wording — "SHALL NOT be rebound to alternatives" — was doing two jobs: preventing replacement, and preventing addition. Only the first is worth keeping, so the modified requirement states the real rule: never *replace* a default, and never bind a strict *prefix* of one.

### `[d`/`]d` and `K` are bound explicitly even though 0.12 already binds them

These three are already Neovim defaults. Binding them again is redundant at runtime and deliberate at the source level: the `LspAttach` block is where a reader looks to learn what LSP keys exist, and a block listing `gd`, `gD`, `gi`, `<leader>rn`, `<leader>ca` while silently relying on defaults for hover and diagnostics is a worse document than one that lists all seven.

The cost is that if Neovim's defaults change, these lines pin the old behaviour. That is acceptable for `K` and `[d`/`]d`, whose semantics have been stable for years. A comment records that they are restatements, so a future reader can delete them knowingly rather than discovering the redundancy by accident.

`[d`/`]d` are bound with wrapping enabled, which the built-ins also do; the spec states wrapping so the behaviour is contractual rather than inherited.

### `<C-w>\` saves and restores the literal layout

`:wincmd _` and `:wincmd |` maximize, and `<C-w>=` equalizes — but equalizing is not restoring. A user with a 30-column file tree beside a wide editor gets two equal halves back, which is worse than not having toggled.

The toggle therefore captures `winrestcmd()` — the command string that reproduces the current window sizes — before maximizing, stores it, and executes it on the second press. State lives in a module-local variable keyed by tab page, so a maximize in one tab does not restore into another.

Two correctness details the spec pins as scenarios:

- **A single window**: maximizing is a no-op, so the toggle must not store a restore command and then "restore" into a layout the user never had. Guard on window count.
- **A layout that changed while maximized**: `winrestcmd()` output references window numbers that may no longer exist. Executing it is wrapped so a stale command fails silently rather than raising, and the stored state is cleared either way.

Alternative rejected: a tab-based zoom, which opens the buffer in a new tab and closes it on toggle. It survives layout changes for free, but it changes the tab line, loses window-local options, and makes `<C-w>\` interact with tab-switching mappings. Too much behaviour for a resize.

### `<leader>rc` restarts rather than re-sources

The name says "reload config", and the obvious implementation is `:source $MYVIMRC`. It does not work: `init.lua` is three `require` calls, and `require` is memoized, so re-sourcing re-runs nothing. The next-obvious fix — clearing `package.loaded` for every `config.*` and `plugins.*` module and re-sourcing — does re-run the modules, but a *deleted* mapping stays mapped, a *renamed* option keeps its old value, autocommands accumulate duplicates, and plugin `setup()` is not re-entered. It appears to work, which is worse than plainly not working.

`:restart` is a Neovim 0.12 built-in and is present in this environment (`exists(":restart")` returns 2). It gives a genuinely fresh process, which is the only thing that makes every configuration edit take effect.

Confirmation is required because a restart discards the session. The mapping prompts, and unsaved buffers are the user's to resolve — `:restart` refuses while a modified buffer exists rather than discarding it, which is the behaviour the spec's "unsaved work is not lost" scenario relies on. The confirmation prompt exists so that a mistyped `<leader>r`-something cannot restart the editor on one keystroke.

Alternative rejected: `:restart!`, which discards modified buffers. The exclamation mark is exactly the safety this mapping should not remove.

### `<Esc>` clears the highlight, which requires `hlsearch` to be on

`add-editor-options` currently sets `hlsearch = false` and its spec says in as many words that "no command is needed to clear a highlight". With that setting, an `<Esc>` mapping is dead code.

The two are mutually exclusive and this change picks the pair that works together: `hlsearch = true`, `<Esc>` clears. Persistent highlight is what makes a search useful for *seeing* where a term occurs rather than only jumping between occurrences, and the objection to it — that it lingers — is exactly what the mapping answers.

This is the change's one contradiction of already-planned behaviour, so it is a `MODIFIED` delta on `editor-options` rather than an edit to the other change's files. Consequence: **`add-editor-options` must be applied and archived before this change is archived**, since a `MODIFIED` delta needs the requirement to exist in `openspec/specs/editor-options/spec.md`. If that change is abandoned, this requirement moves into `editor-keymaps` and `hlsearch` is set alongside the mapping.

The mapping uses `<cmd>nohlsearch<CR>`, which clears the highlight without touching the last search pattern or the search history, so `n` and `N` continue to work and re-highlight — the spec's "the search itself survives" scenario.

Mapping `<Esc>` in normal mode is the riskiest line in this change, because terminals encode arrow and function keys as escape-prefixed sequences. Neovim distinguishes them by `ttimeoutlen`, which defaults to 50ms — far below hand-typed speed and far above any terminal's inter-byte delay. This is safe in practice and is called out in the proposal's Impact as the first thing to suspect if a key starts misbehaving.

### Window navigation is unprefixed; window *management* is prefixed

`<C-h/j/k/l>` and `<M-h/j/k/l>` are unprefixed because focus and size are adjusted constantly and interactively — a prefix per press is the cost the change exists to remove. The two sets name the same four directions and differ only in modifier, so resizing is the navigation muscle memory with a different thumb. Splitting, closing and equalizing happen occasionally and deliberately, so they sit behind `<leader>s` where they cost nothing in the common case and stay discoverable.

`<C-w>\` is the exception that proves the split: it is prefixed despite being interactive, because it *extends* the window-command prefix rather than competing with it. `\` is unbound under `<C-w>`, so adding it delays no built-in — the spec asserts this as a scenario.

Resize uses Alt and the home row rather than the Control-arrow set this change first proposed. `<C-Up>` and `<C-Down>` are not free: vim-visual-multi claims them for add-cursor-above/below, and because `init.lua` loads `config.keymaps` before `config.lazy`, lazy.nvim's stubs are installed *after* the general mappings and win. A `<C-Up>` resize mapping would therefore have been silently dead while `<C-Left>`/`<C-Right>` worked — the worst kind of half-failure, since the working half suggests the mapping is fine. Alt avoids the collision without touching a plugin file or the `multiple-cursors` capability.

*Alternative considered:* keeping `<C-Left>`/`<C-Right>` for width beside the Alt set, since only the vertical pair collides. Rejected as asymmetric — one axis with two key sets and the other with one is harder to remember than either alone. *Also considered:* moving vim-visual-multi's add-cursor keys to free the arrows. Rejected as a wider blast radius than a resize mapping justifies; it edits a plugin file and reopens a capability this change does not otherwise touch.

Resize increment is 2 columns/rows per press rather than 1. One press of a repeated key should produce a visible change; 1 does not, and a user ends up holding the key.

### `<C-j>`/`<C-k>` mean two things, scoped so they never collide

Globally these are window navigation. Inside a Telescope prompt they move the selection through results. Both are wanted, and they coexist because the picker's are declared in `opts.defaults.mappings.i` — insert mode, prompt buffer only. Normal-mode window navigation is never reachable from a prompt in insert mode, so there is no precedence question to resolve.

This is the one genuinely overloaded key pair in the change, and the fuzzy-finder spec pins both halves — result navigation inside a picker, window navigation outside it — so the overload is contractual rather than incidental.

Telescope's own `<C-n>`/`<C-p>` are left in place. These are added alongside, not instead of.

### Telescope gains an `opts` table for the first time

`lua/plugins/telescope.lua` currently declares only `keys`, so lazy.nvim never calls `require("telescope").setup()`. Both prompt mappings — `<Esc>` to close and `<C-j>`/`<C-k>` to navigate — are picker defaults rather than per-picker settings, so they belong in `opts.defaults.mappings.i`, which means the file acquires an `opts` table and `setup()` starts being called.

That is a real behavioural change beyond the mappings: `setup()` applies Telescope's defaults explicitly rather than lazily. Telescope is designed for this and the defaults it applies are the ones already in effect, so nothing observable should change — but it is the reason to sanity-check the existing four pickers after this change, not only the new ones.

`<Esc>`'s default in insert mode is `close` in recent Telescope versions but has historically been "drop to the picker's normal mode". Binding it explicitly makes the behaviour independent of which of those the installed version does.

### Gitsigns visual mappings pass an explicit line range

`stage_hunk` and `reset_hunk` act on the enclosing hunk when called with no argument, and on exactly a line range when called with one. The visual-mode mappings therefore pass `{ vim.fn.line("."), vim.fn.line("v") }` — the cursor line and the other end of the selection — which gives partial-hunk staging with no separate API.

The order of those two lines is not normalized; gitsigns handles a reversed range, so a selection made upward behaves the same as one made downward.

`<leader>hR` is `reset_buffer`, distinguished from `<leader>hr` only by case. This is deliberate per the modified spec: the wider, more destructive action should not be reachable by a slip of one key, and case is the strongest distinction available inside an established prefix. `reset_buffer` discards only unstaged changes, leaving staged work in the index — which is why the spec has a scenario for it, since "reset the buffer" could plausibly mean either.

All of these go inside the existing `on_attach`, so they remain buffer-local and simply do not exist outside a git repository — the same property the existing hunk mappings rely on.

### `<C-s>` maps in three modes, and the terminal is not this config's problem

Normal mode writes. Insert and visual mode leave the mode first, then write, so the buffer is never written mid-insert with a pending undo entry. `<Esc>` then `<cmd>w<CR>` in the insert-mode mapping; the trailing mode is normal in all three cases, which the spec states.

Under a terminal with legacy XON/XOFF flow control, `<C-s>` never reaches Neovim — the terminal swallows it. This is fixed with `stty -ixon` in the user's shell profile and cannot be fixed from inside Neovim. It is documented in the proposal's Impact rather than worked around.

`<cmd>w<CR>` rather than `:w<CR>`: `<cmd>` does not disturb the current mode or the visual selection on its way to the command, and does not require the mapping to be `<silent>`.

## Risks / Trade-offs

- **`<Esc>` in normal mode interferes with terminal escape sequences** → `ttimeoutlen` defaults to 50ms, which separates a real `<Esc>` press from an arrow key's escape sequence reliably. Left at its default; if a key misbehaves after this change, this mapping is the first suspect.

- **`hlsearch = true` reverses a decision `add-editor-options` already made** → Stated as an explicit `MODIFIED` delta rather than folded in silently, and recorded in the proposal as the change's only breaking item. The ordering dependency is stated in three places (proposal, this document, tasks) because archiving out of order fails at spec-application time, which is a confusing place to discover it.

- **`gi` shadows Vim's jump-to-last-insert-position** → The mapping is buffer-local and created on `LspAttach`, so the built-in survives in every buffer without a server. In an LSP buffer it is genuinely lost; `` `^ `` reaches the same position. Accepted, and pinned as a spec scenario so it is a known trade rather than a surprise.

- **`<C-h>` is backspace-equivalent in some terminals, `<C-l>` redraws in vanilla Vim** → Both are normal-mode only. Insert-mode `<C-h>` is untouched, so backspace behaviour is unaffected. `<C-l>`'s redraw remains reachable as `:redraw!`.

- **The `<C-w>\` restore command can go stale** → Executing a stale `winrestcmd()` is wrapped so failure is silent, and the stored state is cleared on every toggle regardless of outcome. Worst case is that a restore does nothing and the user rearranges manually; it cannot leave the editor in a broken layout or raise an error.

- **Two more `<leader>` prefixes under `timeoutlen = 300`** → `<leader>s` and `<leader>g` are prefixes only, never bound in their own right, so neither stalls. The load-bearing constraint is that this stays true: binding `<leader>s` to something later would slow every split mapping. Both specs state it as a scenario for exactly that reason.

- **Telescope's `setup()` starts being called** → Verify the four existing pickers still behave after this change, not only the new git ones. Telescope's applied defaults should equal its lazy defaults, but this is the change that would expose it if they do not.

- **Seven LSP mappings where two existed** → Three of the seven (`K`, `[d`, `]d`) duplicate Neovim defaults. If Neovim's defaults shift, these pin the old behaviour. Commented in place as restatements so the redundancy is visible to whoever next reads the block.

## Migration Plan

No migration in the deployment sense — this is a Neovim configuration and every change takes effect on next start.

Ordering that does matter:

1. `add-editor-options` must be applied and archived before this change is archived, so that `openspec/specs/editor-options/spec.md` exists for the `MODIFIED` delta to apply against.
2. Within this change, `hlsearch` in `lua/config/options.lua` and the `<Esc>` mapping in `lua/config/keymaps.lua` should land together. Either alone is incoherent: `hlsearch` on with no dismissal is the lingering-highlight complaint the other change was avoiding, and the mapping without `hlsearch` is dead code.

Rollback is per-file and per-mapping: every item here is additive except the `hlsearch` flip, and reverting a file to its previous content restores previous behaviour with no residue.
