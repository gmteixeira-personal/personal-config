## Context

See `proposal.md` — Why for motivation, and `specs/editor-options/spec.md` for the behaviour contract.

Three properties of the existing configuration constrain this change, and all three are inherited rather than chosen here:

1. **`lua/config/options.lua` must load with zero plugins installed** (`config-structure`). Nothing here may reference a plugin module, and nothing may be conditional on a plugin being present.
2. **`options.lua` is loaded first, before keymaps and before the plugin manager.** Anything set here is in effect by the time any plugin spec is evaluated.
3. **No plugin file may set a general editor option**, so every option below belongs in this one file and nowhere else.

Two facts about the environment shape the clipboard decision specifically, and both were measured rather than assumed:

- Neovim 0.12.5 **already ships** a `clip`/`powershell` clipboard provider. It is the second-to-last branch of its detection chain, and it does not fire here because it tests for executables named `clip` and `powershell`, while WSL exposes them as `clip.exe` and `powershell.exe`. `vim.fn.executable("clip")` returns 0 and `vim.fn.executable("clip.exe")` returns 1. The gap is a filename suffix, not a missing mechanism.
- `powershell.exe -NoProfile -NoLogo -Command Get-Clipboard` round-trips correctly but returns **CRLF line endings plus a trailing blank line**, and takes **~220 ms** per invocation.

## Goals / Non-Goals

**Goals:**

- Answer the "which options" question once, so it stops being carried forward as an open question in every subsequent change.
- A clipboard that works on this WSL machine today and on a native Linux terminal, without the configuration having to know which one it is running on.
- Keep `options.lua` readable as a list. A contributor should be able to scan it and see the whole editor's general behaviour.

**Non-Goals:**

- Per-filetype indentation. A two-space default is wrong for Go and illegal in a Makefile; fixing that needs `FileType` autocommands or an editorconfig plugin, and is its own change.
- Any keymap. `wrap = true` makes a case for `j`/`k` moving by screen row rather than logical line, and `hlsearch = false` makes a case for a clear-highlight mapping. Both are keymaps, and keymaps live in `lua/config/keymaps.lua` under a different capability.
- Installing anything. The clipboard work is configuration only; no package is installed on the system or under the editor's data directory.
- Re-tuning options the tooling change already set. `vim.diagnostic.config` and the LSP's own settings stay where they are.

## Decisions

### `options.lua` stays a flat list of assignments

Every option is a direct `vim.opt.<name> = <value>` (or `vim.o`), grouped by concern with a comment saying *why* rather than restating what the option name already says. No table-driven loop, no helper function, no wrapper.

The temptation with twenty-odd options is to write `for k, v in pairs(opts) do vim.opt[k] = v end`. It is rejected: it saves nothing at this size, it breaks `gd` and hover on the option name, and it makes the per-option comments — which are the actual content of this file — awkward to attach. The file is a settings list and should read as one.

*Alternative considered:* splitting into `options/ui.lua`, `options/editing.lua`, and so on. Rejected at twenty options; `config-structure` says general options live in **one** module, and the grouping that would justify separate files is achieved by blank lines and a comment header.

### The clipboard bridge is Neovim's own provider, with the names WSL actually uses

`clipboard = "unnamedplus"` is set unconditionally — it is what makes yank and delete reach the `+` register, and it is correct on every platform.

The provider is then supplied **only if Neovim found none**, by asking Neovim rather than guessing, on a deferred tick rather than during startup:

```
vim.schedule(function()
  if vim.fn["provider#clipboard#Executable"]() == "" then  -- nothing found
    … set vim.g.clipboard …
  end
end)
```

The deferral is the one place this file is not a straight-line list, and it is paid for by a
measured cost rather than a preference. Asking the question eagerly takes ~60 ms on WSL: each
`executable()` miss in Neovim's detection chain (`wl-copy`, `waycopy`, `xsel`) stats the `/mnt/c`
directories that WSL puts on `$PATH`, at ~10 ms each, and the chain runs twice — once when the
autoload file is sourced and once from the explicit call. Measured over 15 runs: 39 ms before
this change, 103 ms with the guard eager, 39 ms with it deferred. Nothing needs the answer
during startup — Neovim itself resolves the provider lazily on first clipboard use — so a tick
later is early enough, and on a native Linux terminal (no `/mnt/c` on `$PATH`) the cost never
existed either way.

Guarding on the provider's own answer, rather than on `has("wsl")`, is the load-bearing choice. A guard of "if WSL, use clip.exe" would be wrong under WSLg with `xclip` installed: Neovim's chain checks `$DISPLAY` and `xclip` *before* it reaches its Windows branches, so it would already have picked a faster, native tool, and a WSL-keyed override would stamp on it. `specs/editor-options` states this as a requirement — supplying a mechanism must not override one the editor would otherwise have chosen — and querying the provider is the only guard that actually satisfies it in every environment rather than in the two we happen to have thought about.

The consequence worth stating plainly: on a native Linux terminal this branch does nothing at all. If `wl-copy` or `xclip` is installed, Neovim finds it and the condition is false; if none is installed, the condition is true but the WSL executables do not exist either, so the inner check fails and Neovim's own "no clipboard tool" health warning stands — which is the "no clipboard is reachable at all" scenario in the spec, and is correct behaviour rather than a failure.

*Alternative considered:* setting `vim.g.clipboard` unconditionally to the WSL bridge. Simpler by three lines, and wrong the moment the configuration is used anywhere but this machine.

*Alternative considered:* OSC 52, which reaches the terminal's clipboard with no external tool at all and works over SSH. Genuinely attractive, and Neovim has a built-in branch for it — but that branch is deliberately skipped when `clipboard` is set, paste support depends on the terminal and often prompts, and it would be a larger behavioural bet than this change wants to make. Worth revisiting as its own change.

### Paste output is normalised; copy is not

`Get-Clipboard` returns Windows line endings and appends a trailing newline, so pasting its raw output would leave a `^M` at the end of every line and add a blank line each time. The paste command therefore runs through a shell and strips carriage returns; the copy direction needs no such treatment, since `clip.exe` accepts LF input as-is.

This is a real defect in Neovim's own shipped `clip` provider rather than something novel here, which is worth knowing when comparing the two: this configuration is not merely re-spelling the built-in branch, it is also fixing it.

`cache_enabled` is set, so that text yanked inside the editor is served from Neovim's own cache on the next paste instead of paying ~180 ms to ask Windows for something the editor already knows. The cache is shallower here than it is for `xclip`: Neovim holds it only while the copy process lives, and `clip.exe` exits as soon as it has consumed its input, where `xclip` stays alive owning the selection. Measured, the cache serves a paste in 0.1 ms immediately after a yank and misses once `clip.exe` has gone. It still earns its place — the copy itself drops from 34 ms to 4 ms, because setting it also makes the copy asynchronous — but it is not the durable cache a selection-owning tool gets.

### `signcolumn = "yes"`, which answers the tooling change's open question

`add-editor-tooling`'s design left this open, noting that `signcolumn = "yes"` "becomes more attractive now that gitsigns will otherwise shift text horizontally as signs appear". It is settled here in the affirmative.

The cost is one column of width in every buffer, including buffers that will never show a sign. The benefit is that gitsigns marking a line, or the LSP placing a diagnostic icon, never shoves the entire buffer sideways under the cursor. With both of those plugins now installed and attaching on `BufReadPre`, the jitter is not hypothetical — it happens on essentially every file in a git repository, which is most of them.

*Alternative considered:* `signcolumn = "auto"`, which reserves the column only when a sign exists. That is the option that produces exactly the jitter this decision exists to remove.

### `timeoutlen = 300`, accepted as a trade against the keymap namespace

`add-editor-tooling` built a `<leader>`-prefix namespace on one rule: a key that is a prefix is never also a mapping, so nothing ever waits out `timeoutlen` before acting. That rule addresses the *mapping* side of the timeout. `timeoutlen` itself governs the other side — how long the user has to finish typing a sequence.

Dropping from Neovim's default 1000 ms to 300 ms makes `<Space>` feel immediate and makes an abandoned prefix resolve quickly. The cost is that every two- and three-key `<leader>` mapping in the configuration — `<leader>fg`, `<leader>hs`, `<leader>cf`, `<leader><leader>` — must be typed as a deliberate sequence rather than with a pause in the middle. At 300 ms that is comfortable for a sequence the fingers know and unforgiving for one being recalled.

This is the one option here most likely to be revised after living with it. It is a single number in a single file, which is the cheapest possible thing to revise.

### `wrap = true`, with the follow-on consequence recorded rather than fixed

Long lines soft-wrap at word boundaries with continuation rows indented to match. This makes `linebreak` and `breakindent` live options rather than dormant ones — with `wrap` off, both are inert, which is why the earlier framing of "set them so a future toggle is nice" was rejected in favour of simply turning wrapping on.

The known consequence: `j` and `k` move by *logical* line, so on a wrapped line they jump over several screen rows at once. The conventional remedy is mapping `j`/`k` to `gj`/`gk`. That is a keymap, it belongs to a different capability and a different file, and it is listed as a non-goal above rather than smuggled in here.

### Options already set keep their current values

`termguicolors` and `background` are in `options.lua` today with exactly the values proposed. They are named in the spec so the capability describes the whole of the editor's general behaviour rather than only its new parts, but implementing them is a no-op: the lines stay as they are, comments included.

## Risks / Trade-offs

- **`provider#clipboard#Executable()` initialises the provider as a side effect, and setting `g:clipboard` afterwards is not picked up.** Confirmed by exercising it: without a re-initialisation the provider reports `has('clipboard') = 0` and every yank raises `clipboard: No provider`. The documented remedy did not survive contact — `provider#clipboard#Init()` does not exist in Neovim 0.12.5, which ships only `Error()`, `Executable()` and `Call()`. → Resolved with the provider file's own documented reload recipe, `unlet g:loaded_clipboard_provider` followed by `runtime autoload/provider/clipboard.vim`, which re-runs detection with `g:clipboard` now set.

- **A `g:clipboard` command given as a string is split on spaces and run with no shell.** `s:split_cmd()` turns a string into a list, so a paste command written as a shell pipeline would have its `|` handed to PowerShell as an argument rather than executed. → The paste command is given as an explicit list, `{ "sh", "-c", … }`, which is what actually reaches a shell.

- **The clipboard guard runs on every launch and asking the question is expensive on WSL.** ~60 ms, from `executable()` misses stating `/mnt/c` over drvfs. → Deferred to a `vim.schedule` tick, which returns startup to its pre-change baseline. See the decision above for the measurements.
- **Paste costs ~220 ms in the WSL fallback.** → Bounded to pastes of text copied outside the editor; `cache_enabled` removes the cost for text yanked inside it. Installing `win32yank.exe` removes it entirely *and requires no change to this configuration* — Neovim's own detection prefers win32yank, so the guard turns itself off. That property is the main practical argument for guarding on the provider rather than on `has("wsl")`.
- **A shell pipeline in the paste command adds a shell process per paste.** → Negligible beside the 220 ms PowerShell start it wraps, and it is what removes the `^M` that would otherwise appear on every pasted line.
- **`hlsearch = false` removes the highlight some users navigate by**, and no `n`/`N` highlight remains after the search is accepted. → `incsearch` covers the common case of finding the thing you were looking for. If persistent highlight is wanted, the usual answer is `hlsearch` on plus a mapping to clear it — which is a keymap, and out of scope here.
- **`updatetime = 250` makes Neovim write its swap file roughly four times a second while typing.** → This is the value the ecosystem assumes and the cost is small; it is called out because it is a disk-write change, not only a UI one.
- **Two-space indentation is wrong for some filetypes and illegal in Makefiles.** → Accepted knowingly: this change sets a global default and explicitly defers per-filetype handling. A Makefile edited before that change lands will need its tabs entered deliberately.
- **`undofile` grows a directory of undo history indefinitely.** → Stored under `stdpath("state")`, outside every project, and safe to delete at any time; losing it costs history, never content.
- **`autoread` only reloads on an event that makes Neovim check the file**, so a change on disk is not always picked up the instant it happens. → The spec is written against "when the editor next checks", which is what Neovim actually guarantees. Making it more eager needs a `FocusGained`/`CursorHold` autocommand, which is a behaviour addition rather than an option and is not in scope.

## Migration Plan

One file is edited: `lua/config/options.lua`. No file is created, none is deleted, and nothing under `lua/plugins/` is touched.

Rollback is reverting that file. Two side effects outlive it and are worth knowing: the undo-history directory under `stdpath("state")` remains until deleted by hand, and anything already placed on the system clipboard stays there. Neither affects the configuration's behaviour once the options are reverted.

There is no ordering constraint against the two existing changes. `add-editor-tooling` sets no general editor option, so nothing here can collide with it; `signcolumn` and `timeoutlen` interact with plugins that change installed but are options in their own right, set in the file that owns them.

## Open Questions

- **Should `j`/`k` move by screen row now that `wrap` is on?** Deferrable: it changes no spec here and no task here, and it belongs to whichever change next touches `lua/config/keymaps.lua`. Recorded because `wrap = true` is what makes it a live question.
- **Which filetypes need their own indentation, and by what mechanism?** Deferrable for the same reason — it needs its own capability, and the global default has to exist before the exceptions to it are worth describing.
