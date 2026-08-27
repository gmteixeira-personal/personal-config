## Context

See proposal.md - Why. What matters for the approach is what neogit already does with the integration it is refusing, because half this change is turning that on rather than writing anything.

Reading the installed neogit:

- `config.check_integration(name)` returns `M.values.integrations[name]` when it is `true` or `false`, and falls back to `pcall(require, name)` when it is `nil` or `"auto"`. Under lazy.nvim a successful `require` **loads** the plugin, which is exactly why `telescope = true` is stated outright in `lua/plugins/neogit.lua` today. `diffview = false` is currently that same statement with the other answer.
- `config.get_diff_viewer()` is newer than the integrations table and sits above it: an explicit `diff_viewer` is verified through `check_integration` and returned, and a `nil` one auto-detects by trying `diffview` first and then `codediff`.
- The diff popup (`popups/diff/actions.lua`) resolves its viewer through `get_diff_viewer()` on every action, so with no viewer available the popup has nowhere to send a change.
- `buffers/status/actions.lua` branches on the same call when staging an unmerged file. With a viewer it opens `integration.open("conflict", <file>, { on_close = ... })` and the close handler re-checks `git.merge.is_conflicted` and stages the file if it is now clean. Without one it takes the other branch and notifies "Conflicts must be resolved before staging".

So the conflict requirement in the `git-repository-ui` delta is not something to build. It is a branch neogit already has and cannot currently reach.

diffview.nvim is now installed, and the claims below about its registry (`lib.views`, `get_current_view`), its view classes (`DiffView`, `FileHistoryView`) and its default in-view keymaps are read from its source rather than assumed.

## Goals / Non-Goals

**Goals:**

- One mapping, living with the plugin that implements it, as this configuration's convention requires.
- diffview genuinely lazy: nothing loaded until the mapping is pressed, a command is typed, or neogit asks for it.
- The settings that make neogit use it stated outright rather than auto-detected.

**Non-Goals:**

- Diffing against anything but the last commit from a mapping. Revision ranges and single commits are reachable from neogit's diff popup and from `:DiffviewOpen` with an argument; a key for each is a different change.
- Close mappings of their own. The three keys are the toggles; `:DiffviewClose`, `<leader>wq` and the views' own keys still work and are not shadowed.
- Re-mapping diffview's in-view keys. They are the plugin's, they are what its documentation describes, and they are buffer-local.
- Keeping a key for every neogit placement. Three of the four went to diff views; `:Neogit kind=...` is where a choice reconsidered once in a while belongs.
- Registering diffview as git's `mergetool`. That is a git configuration change outside this repository.

## Decisions

### Openness is asked of diffview's registry, never of the windows on screen

Each mapping has two states and no third: pressing it opens its view where none is open and closes it where one is.

**How openness is decided is the load-bearing part.** `require("diffview.lib").views` is the plugin's own list of open views, each carrying the tabpage it occupies, and `lib.get_current_view()` reads it for the current tabpage. Nothing about that list changes when the file panel is hidden.

Every alternative test is wrong for exactly that reason. Looking for the file panel's window fails the moment `<leader>b` hides it -- the view is still open, the check says closed, and the key stands a second view up on top of the first. Counting windows with `vim.wo[w].diff` set has the same failure in reverse, since `<leader>gd` puts an ordinary buffer in diff mode with no diffview involved at all. Matching the `diffview://` buffer-name prefix would be reading a private format, which add-gitsigns-diff-mapping already rejected for the same reason.

The view lives in its own tabpage, and `gf` inside it opens the file back in the *previous* tabpage, so the user can be editing an ordinary buffer with the view still open behind them. Two states means the press closes it rather than opening a second one, which is why the mapping scans the whole registry and not only the current tabpage.

**This reverses a non-goal stated earlier in this change.** The mapping originally opened only, on the reasoning that add-gitsigns-diff-mapping arrived at: leave the plugin's own behaviour alone unless there is a demonstrated reason to override it. The demonstrated reason is that diffview has no default toggle and no close key of its own inside the view -- dismissing it means typing `:DiffviewClose`, which is not a keystroke. That is not the gitsigns case, where the default was already reachable.

**Alternative considered:** where a view is open in another tabpage, switching to it instead of closing it -- `<leader>gm` as "show me the diff" rather than as a toggle. Rejected: it makes the key mean two different things depending on where it is pressed, which is the thing a toggle exists to avoid. It is a two-line change in the loop if the `gf` flow proves to want it.

### The prefix is re-cut around what is pressed often

`<leader>g` has ten two-key sequences and four of them were neogit placements. Placement is chosen rarely; a diff is opened constantly. Three of those keys therefore go to diff views, `<leader>gv` is left unbound, and `<leader>gg` keeps the arrangement that suits a status buffer -- replacing the current window, which is what `<leader>gr` did. A status buffer is a tall list, and reading it beside the file it describes means reading both in half the width.

`<leader>gd` moves too, from gitsigns to diffview. It diffed the buffer against the *index* with `gitsigns.diffthis`; it now opens the same file in diffview against the last commit. What is gained is that every key under the prefix showing a difference shows it in one view, with one set of in-view keys and one way to dismiss it -- rather than a `:diffsplit` whose only dismissal was `<leader>wq`, and a tabpage whose dismissal was its own toggle. What is given up is the index as the other side, which `:Gitsigns diffthis` still provides and which is the rarer question.

**Every one of these reverses a decision made earlier in this change or in add-gitsigns-diff-mapping.** They are the user's calls, taken in sequence, and the files record where each key went so a later reader is not left guessing.

### File history takes `<leader>gh` from neogit

`:DiffviewFileHistory` gets a key after all, and the key is neogit's horizontal-split arrangement. **This reverses the non-goal this change started with**, and it is the one part of this change that removes something.

The overlap the old comment in `lua/plugins/neogit.lua` worried about -- Telescope's `<leader>gc` listing commits and diffview's history listing commits -- is real but is not a collision. `<leader>gc` lists the repository's commits to jump to one; `<leader>gh` lists the commits behind *the file in front of you* and shows what each did to it. Different questions, and neither shadows the other.

What is given up is neogit's fourth placement. It is the least costly of the four to lose: a status buffer is a tall list and a short wide window is the worst shape for one, `<leader>gg`'s automatic arrangement already chooses a horizontal split where the window is too narrow for a vertical one, and `:Neogit kind=split` still asks for one outright. The arrangement survives; only the key naming it does not.

**Alternative considered:** a free letter -- `<leader>gl` for log -- leaving all four neogit mappings intact. Not chosen: it was weighed against this one and this one was picked.

### Each key matches only the views it is responsible for

Three mappings open views into the same registry, and a toggle that closed whichever view happened to be up would let one dismiss what another opened. Each therefore carries a predicate rather than a name.

Two properties separate them. `class.__name` tells a `DiffView` from a `FileHistoryView`. `path_args` tells `<leader>gm` from `<leader>gd`, which both produce a `DiffView`: it is empty for the whole-repository view and holds the path for the single-file one. Both are diffview's own, and both are internal, as `lib.views` is -- but the alternative is inferring from the windows on screen, which the decision above rules out for the same reason.

Pressing `<leader>gm` while one file's diff is up therefore opens the repository view alongside it rather than closing it.

### The single-file view has no file panel

A panel listing one file, whose name is already on screen, is a column spent restating it. It is closed for single-file views and only those.

Done from diffview's `view_opened` hook rather than inside the `<leader>gd` mapping, because it is a property of the view and not of how it was asked for: `:DiffviewOpen -- some/file` typed by hand gets the same treatment. The hook fires once the view is laid out, so the panel exists to close by the time it runs. `<leader>b` reopens it from inside.

**Alternative considered:** hiding the panel from the mapping, after the open. Rejected: it would need to wait for the layout itself, and would leave the typed command inconsistent with the key.

### (superseded) `<leader>gd` toggling on the `gitsigns://` scheme

**This decision no longer applies and is kept only to record why the mapping did not stay with gitsigns.** `<leader>gd` was briefly a toggle over `gitsigns.diffthis`, closing the revision window it had opened. It is diffview's now, so the toggle is the shared one above and none of the below is in the code.

What it tests is the point. That mapping's guard was `vim.wo.diff`, which was the right question for "has a diff already been opened here" and is the wrong one for "which window do I close". `'diff'` is set on the file's own window while the diff is up, on every window of a diffview tabpage, and on anything the user split with `:diffsplit` by hand -- so a toggle resting on it would close windows this mapping never opened.

The revision buffer's name does answer it: gitsigns creates it under a `gitsigns://` scheme, and a window showing one is a window this mapping is responsible for. Scanning the tabpage for that prefix is the toggle's test, and closing those windows is the whole of its close branch -- `bufhidden = "wipe"` and gitsigns' own `BufHidden` autocmd put the file's window back out of diff mode, restore `'wrap'` and the fold column, and leave the buffer untouched.

**This reverses a rejected alternative in the archived design**, which declined to match that prefix on the grounds that it is upstream's private format and `vim.wo.diff` is Neovim's own. That reasoning held for the question it was answering -- which window to move the cursor to, where any diff window would do. It does not hold for a toggle, which has to distinguish this mapping's diff from every other diff, and the name is the only thing that does.

### diffview gets its own file, lazy on `keys` and `cmd`

`lua/plugins/diffview.lua`, following `lua/plugins/neogit.lua` exactly: no `event`, `keys` for the mapping, `cmd` so the commands exist before the plugin does.

`keys` is the right lazy trigger here, unlike in `lua/plugins/gitsigns.lua` where the mapping had to be buffer-local. Nothing about `<leader>gm` needs to be per-buffer -- it acts on the repository containing the working directory, and it is meaningful in a buffer with no file at all.

`cmd` covers the case `keys` cannot: neogit's integration `require`s diffview's modules directly, and a session that opens the status buffer and uses the diff popup without ever pressing `<leader>gm` must still find the plugin. lazy.nvim's module loader handles that require on its own, so `cmd` is for the user typing `:DiffviewOpen`, not for neogit.

**Alternative considered:** adding diffview to neogit's `dependencies`. Rejected: it would load diffview whenever neogit loads, which is most sessions that touch git, to serve a popup action that may never be pressed. The two plugins are peers here, not one and its dependency.

### `<leader>gm` and `<leader>gh` sit under a prefix three other plugins already use

`<leader>g` currently divides between neogit (`gg`, `gr`, `gv`, `gh`), Telescope (`gf`, `gs`, `gc`, `gb`) and gitsigns (`gd`). `gm` is free.

`m` rather than another free letter because the merge-conflict view is the thing this plugin does that nothing else here can, and `d` -- the obvious first choice for a diff -- is gitsigns'. The prefix itself stays unbound, as every prefix here does.

The division is now four-way. The comment in `lua/plugins/neogit.lua` that spells out who owns what gains a line, as it did for gitsigns. There is still no shared table, deliberately, because a table would put mappings somewhere other than with the plugin that implements them.

### The neogit integration is stated, not auto-detected -- and so is `diff_viewer`

`integrations.diffview = true` rather than removing the line and letting it default to `nil`.

This is the same decision the file already made for telescope, and the comment above it already gives the reason: a `nil` integration is resolved with `pcall(require, ...)`, and under lazy.nvim that require loads the plugin as a side effect of detecting it, at whatever moment neogit's setup runs. Declaring it means diffview loads when something actually asks for a diff.

`diff_viewer = "diffview"` is the newer option layered over the same integrations table, and it is stated for the same reason plus one more: left `nil` it auto-detects, and auto-detection tries `codediff` as its second candidate -- another `pcall(require, ...)` for a plugin this configuration does not install, run on a code path the user reaches by pressing `d` in the status buffer. Naming the viewer skips the search entirely.

**Alternative considered:** setting only `integrations.diffview = true` and leaving `diff_viewer` alone, since auto-detect finds diffview first anyway. Rejected on the reasoning `kind = "auto"` was written down for: where a setting is load-bearing, this configuration says so rather than relying on a default agreeing with it. Installing codediff later would otherwise change which viewer neogit picks, from a file that has nothing to do with neogit.

### The deferral comment is rewritten, not deleted

`lua/plugins/neogit.lua` currently argues that neogit's inline diffs are enough and that diffview would bring "a second set of buffer-local keys and a second history UI overlapping `<leader>gc`". That argument was about a plugin nobody had asked for; it is not what happened, and the file should say what is true now rather than losing the reasoning entirely.

The overlap it names is real and unresolved: Telescope's `<leader>gc` lists commits, and diffview's file history does the same thing differently. That is why file history is a non-goal above, and the rewritten comment is where that boundary belongs.

### A view's buffers are dropped when the last view closes

`File:_create_local_buffer` `:edit`s a file in a temporary window when no buffer for it exists yet, and re-lists the buffer when one does — so every file read in a view joins the buffer list and outlives the view. Reading twenty files leaves twenty buffers in `<leader>bn`, and a session written afterwards records them all.

The fix is a snapshot: the listed buffers are remembered before the first view opens, and when the last one closes anything that joined the list since is deleted. Snapshotting rather than matching on the view's file list is what makes it safe — a buffer the user already had open is in the snapshot and is left alone no matter what the view did with it, including the re-listing above.

Two guards on top, for the file opened out of a view with `gf` and then worked on: a buffer with a window, or with unsaved changes, is never dropped.

The snapshot is taken in the mapping, before the command runs, and again from `view_opened` as a fallback for `:DiffviewOpen` typed by hand — less exact there, since the first file may already have loaded, but the mappings are the common path. The cleanup runs from `view_closed`, scheduled, because the view is still in `lib.views` while that hook runs and is disposed of afterwards; it waits for the count to reach zero so closing one of two open views does not drop the other's buffers.

**This was reported from use twice.** The first report was a file reopening on the next launch, answered below; the second was that the buffers tabbed through were still in the list, which is this. The two have the same cause and the session one is now largely a consequence of this fix — with the buffers gone, an editor opened only to read a diff has nothing left to save.

### auto-session closes the views before it writes a session

`pre_save_cmds` in `lua/plugins/auto-session.lua` closes every open diffview view before the session is written.

This was going to be a verification task and no change at all -- `close_unsupported_windows` is on by default and drops windows whose file is not readable, which is what already keeps a non-float Oil window out of a save. It covers the file panel and the `diffview://` revision side. It does not cover the other side of a diff: **that one is the real file on disk, so it survives the cull and lands in the session.** Opening an empty editor, pressing `<leader>gm` and quitting therefore left a session that reopened whichever file the diff happened to be showing -- a file that was never being edited. Reported from use, not caught by the plan.

Closing the views first leaves exactly what the user had. Where that is nothing, no session is written, which is the right answer for an editor opened only to read a diff.

The hook reads `package.loaded["diffview.lib"]` rather than requiring it, because under lazy.nvim a require at quit would load diffview for a session that never opened it. It snapshots `lib.views` before iterating, since closing a view removes it from that list.

**Alternative considered:** `bypass_save_filetypes`, which is auto-session's own mechanism for "do not save while sitting in a scratch UI". It cannot work here: it returns true only when *every* window's filetype is in the list, and the working side of a diff has an ordinary filetype. It would also suppress the save entirely rather than saving the right thing.

**Alternative considered:** dropping `buffers` from `sessionoptions` in `lua/config/options.lua`, so only windowed buffers are recorded. Rejected: that changes what every session contains, to fix one plugin's edge, and the comment there shows the option list was reasoned through on its own terms.

## Risks / Trade-offs

- **diffview's in-view keys may shadow a mapping this configuration relies on.** Its defaults are documented to include `<leader>e` and `<leader>b` inside the view, and `<leader>e` is Oil here. → Buffer-local keys in a dedicated view are the same arrangement neogit's already are, and the view is somewhere the user went deliberately. Confirming which keys it actually binds, and that they are confined to its buffers, is a verification task.
- **Four `<leader>g` keys changed hands, so muscle memory built on the old set now does something else.** `<leader>gr` was neogit replace and is now a diffview refresh; `<leader>gh` was neogit horizontal and is now file history; `<leader>gv` does nothing; `<leader>gd` was gitsigns' index diff and is now diffview's. → Each is recorded in the file it left, `:Neogit kind=...` and `:Gitsigns diffthis` still reach the old behaviour, and which-key shows the live set under the prefix, which is the check that does not go stale.
- **`<leader>gd` no longer diffs against the index.** The last commit is the other side now, so a staged change shows as a difference where it used to show as none. → The distinction matters to hunk staging, which is `<leader>h`'s and unaffected; `:Gitsigns diffthis` is the escape hatch. Stated in `lua/plugins/gitsigns.lua` where the mapping used to be.
- **diffview's in-view `<leader>b` waits a full second before toggling the file panel.** It is a complete mapping, and this configuration has nine longer global mappings under `<leader>b` -- `bn`, `bp`, `bd`, `bo`, `bO`, `bc`, `bb`, `bl`, `bf` -- so Neovim waits out `'timeoutlen'` (1000ms here) to see whether a longer one is coming. Measured, not assumed. → Left alone for now: it is diffview's default, `:DiffviewToggleFiles` has no delay, and re-mapping the view's keys is a non-goal above. Worth revisiting if the panel is toggled often. The same applies to `<leader>co` / `ct` / `cb` / `ca` against the `<leader>c` group.
- **The `<leader>g` prefix now spans four plugins, and no single file lists the whole of it.** → A comment in `lua/plugins/neogit.lua`, which is where the division is already written down. which-key shows the live set, which is the check that does not go stale.
- **The conflict path is hard to exercise on purpose.** Verifying it needs a repository deliberately put into a conflicted merge. → A throwaway repository with two branches editing the same line, built for the check and thrown away. The alternative is shipping the requirement unverified.
- **Pressing `<leader>gm` from an editing buffer closes a view the user may have wanted to go back to.** The `gf` flow leaves the view open behind them, and the next press dismisses it rather than returning to it. → The cost is reopening, which is the same key; the alternative was to make the key mean two things. Recorded above as the alternative to revisit if that flow proves common.
- **A tab page is a bigger footprint than the splits every other view here uses.** → It is what keeps the editing layout intact, which is a spec scenario in its own right, and it is diffview's own arrangement rather than one imposed on it.
