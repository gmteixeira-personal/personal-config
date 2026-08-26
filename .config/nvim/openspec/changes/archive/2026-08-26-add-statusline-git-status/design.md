## Context

See `proposal.md` — Why, and `specs/statusline/spec.md` for what must hold. The constraints that shape the approach:

- `lua/plugins/lualine.lua` is the whole of the `statusline` capability, and its own requirement says so: *"Everything this capability needs SHALL be declared in a single file under `lua/plugins/`"*, and deleting that file must return the editor to its stock line. There is no `lua/util/` in this configuration and this change does not create one.
- lualine is `lazy = false, priority = 800`, and its `opts` is a **function** rather than a table, because `lualine_x`'s recording component calls `require("noice")` and a bare table would run that require during lazy.nvim's spec collection. Anything this change needs at load time — autocmds, timers, a first refresh — has the same constraint and the same solution.
- lualine's defaults are `lualine_b = { "branch", "diff", "diagnostics" }` and `component_separators = { left = "", right = "" }`, verified against the installed copy (`lua/lualine/config.lua:13`). Naming a section replaces it wholesale, so placing anything in `lualine_b` costs restating all three — exactly as `lualine_x` already restates `encoding`, `fileformat`, `filetype`.
- A lualine component function is called on **every status line redraw**. It has no budget for a subprocess, a filesystem walk, or a `require`.
- Neovim is 0.12.5, so `vim.system()`, `vim.fs.root()` and `vim.uv` are all available. Verified.
- gitsigns is installed and emits `User GitSignsChanged` when it alters the index (`gitsigns/git.lua:143`, from `stage_file`/`unstage_file` and their hunk equivalents) and `User GitSignsUpdate` on every buffer diff recomputation (`gitsigns/status.lua:16`).
- neogit is installed and emits `User` autocmds named `NeogitStatusRefreshed`, `NeogitCommitComplete`, `NeogitPushComplete`, `NeogitPullComplete`, `NeogitFetchComplete`, `NeogitBranchCheckout`, `NeogitRevertComplete` and others, all through `nvim_exec_autocmds("User", { pattern = ... })`. Verified against the installed copy.
- `git status --porcelain=v2 --branch` reports the branch, its upstream, the ahead/behind pair and every changed path in one invocation. Verified in this repository.

## Goals / Non-Goals

**Goals:**

- One `git` invocation per refresh, off the main loop, producing all four counts.
- A component function that does nothing but return a string that was already built.
- Refresh driven by the events that can change the answer, with no polling timer.
- Correct where two repositories are open at once, and silent where there is no repository and where there is no `git`.

**Non-Goals:**

- Colouring the segments. See the decision below.
- Behind-count (`↓`), stash count, or a divergence indicator. The user asked for commits to push; the parse already yields the behind count, so adding `↓` later is a formatting change, not a design change.
- Reporting anything about a repository other than the focused buffer's. A single active repository is tracked; there is no aggregate across open buffers.
- Replacing, wrapping or reconfiguring lualine's `diff` component. It stays exactly as upstream ships it.
- A `<leader>` mapping to force a refresh. The event list is the contract; a manual refresh key would be an admission it is incomplete.
- Making the summary available anywhere but the status line — no command, no API, no `vim.g`.

## Decisions

### One `git status --porcelain=v2 --branch -uall`, not four commands

Every count comes out of a single invocation:

```
# branch.oid <sha>
# branch.head main
# branch.upstream origin/main
# branch.ab +1 -0
1 .M N... 100644 100644 100644 <h> <h> lua/plugins/lualine.lua
1 M. N... 100644 100644 100644 <h> <h> lua/config/options.lua
2 R. N... ... <h> <h> R100 new<NUL>old
u UU N... ... conflicted.lua
? untracked.lua
```

- `↑` is the `+N` of the `# branch.ab` line. That line is present only when `branch.upstream` is, which is what makes "no upstream ⇒ no `↑`" fall out of the parse rather than needing a separate `git rev-parse @{u}` that would have to be error-suppressed.
- Ordinary and renamed entries are the `1 ` and `2 ` lines. Their second field is the two-character `XY` code: `X` is the index-vs-HEAD state, `Y` the worktree-vs-index state, and `.` means unchanged. So `◆` is the count of entries with `X ~= "."` and `●` the count with `Y ~= "."`, which gives the both-staged-and-further-edited case (`MM`) counting in both, as the spec requires, with no extra logic.
- `u ` lines are unmerged paths. They are counted in `●`: a conflicted file is work the user must do before committing, which is what `●` means to a reader, and porcelain v2 gives conflicts their own record type precisely so they are not silently folded into the modified count by accident.
- `? ` lines are untracked.

Alternatives considered: `git status --porcelain` (v1) — rejected, it does not carry the ahead/behind pair, so a second `git rev-list --count @{u}..HEAD` would be needed and would have to swallow the error when no upstream exists. Separate `git diff --name-only` / `--cached --name-only` / `ls-files --others` calls — rejected, three to four spawns per refresh for information one already contains, and they can observe the tree at different instants and disagree.

### `-uall`, not git's default `-unormal`

`--untracked-files=normal` collapses an untracked directory to a single entry — in this very repository it reports `? openspec/changes/add-statusline-git-status/` where `-uall` reports the four files inside it. The spec says `+N` counts *files*, so `-uall` is the literal reading and `-unormal` would make `+1` mean "one directory containing an unknown number of files", which is not a count of anything the user asked for.

The cost is that git descends into untracked directories. It does **not** descend into ignored ones, so the usual worry — a large `node_modules` — costs nothing as long as it is in `.gitignore`, which is the only state in which it would not itself be flooding `+N` anyway. Combined with the refresh being asynchronous and debounced, the cost is bounded and never visible.

Alternative considered: `-unormal` for speed, documenting that `+N` counts entries rather than files — rejected, it makes the commonest case of new work (a new directory of files) report `+1`, which is actively misleading.

### The component returns a cached string; nothing is computed on redraw

A lualine component runs on every redraw. The refresh writes a fully rendered string — `"+2 ●5 ◆3 ↑1"` — into a per-repository cache entry, and the component function returns that entry's string for the active repository. Zero-suppression, spacing and symbol choice all happen once when the counts arrive, not once per redraw. `cond` returns whether that string is non-empty, so an all-zero repository costs the section no width, as the spec requires.

The active repository is a single variable, resolved by `vim.fs.root(bufnr, ".git")` on `BufEnter` and `DirChanged` and stored — not resolved inside the component. `vim.fs.root` walks the filesystem upward, which is cheap once and wasteful sixty times a second. A single variable is sufficient rather than a per-window one because lualine's default `inactive_sections` contain only `filename` and `location`: `lualine_b` is drawn for the focused window alone, so there is never a second window asking for a different repository's summary at the same moment.

Alternative considered: computing counts inside the component with a time-based cache — rejected, it puts the spawn on the redraw path where a slow one is felt as a stutter, and it makes the "does not block the editor" requirement depend on the cache always being warm.

### Refresh is event-driven and debounced, with no polling timer

The autocmds:

| Event | Why |
| --- | --- |
| `BufWritePost` | a write can create unstaged changes |
| `FocusGained`, `VimResume` | picks up anything done in another terminal — the catch-all |
| `DirChanged` | the active repository may have changed |
| `BufEnter` | re-resolves the active repository, and refreshes if it changed |
| `User GitSignsChanged` | gitsigns staged, unstaged or reset something |
| `User Neogit*` | any neogit operation completed — commit, push, pull, fetch, checkout, revert |

`User Neogit*` is a glob rather than the seven exact names. The names are neogit's and would have to be tracked across its updates; the prefix will not change, and an extra refresh from an event that turns out not to have changed anything costs one debounced spawn and renders an identical string.

`GitSignsUpdate` is deliberately **not** listened for. It fires on every buffer diff recomputation — on essentially every edit — and reports nothing this component shows. `GitSignsChanged` is the index-touching one and is the one that matters.

Every trigger goes through one `vim.uv` timer restarted at ~150 ms, so a burst — a `:wall` across ten buffers, neogit firing `NeogitStatusRefreshed` alongside `NeogitCommitComplete` — spawns once. A second guard drops a request while an invocation is already in flight for that repository, and marks it to re-run once when that one returns, so the final state is never missed.

No polling timer. A timer would spawn `git` forever in a repository nobody is touching, and `FocusGained` already covers the case it would exist for — returning from a shell in another window. The one gap it leaves is a `git` command run inside an embedded `:terminal`, which fires no `FocusGained`; that updates on the next write or buffer change instead. Accepted, and noted in the risks.

Alternatives considered: watching `.git` with `vim.uv.new_fs_event` — rejected, it fires many times per git operation, needs its own debounce anyway, has to be torn down and re-established per repository, and is unreliable on network and Windows filesystems. A `vim.uv.new_timer` on a several-second repeat — rejected as above.

### Redraw only when the rendered string changed

`vim.system`'s callback runs off the main loop, so the result is applied inside `vim.schedule`. It compares the newly rendered string with the stored one and calls `vim.cmd("redrawstatus")` only when they differ. Most refreshes — `FocusGained` on an untouched repository — change nothing and should cost no repaint.

### Placed after `branch`, before `diff`

`lualine_b` becomes `{ "branch", <summary>, "diff", "diagnostics" }`, rendering as ` main  +2 ●5 ◆3 ↑1  +3 ~2 -1  E1 W2`.

The ordering is chosen to keep the two `+N` apart. `branch` is repository-scoped and so is the summary, so they group; `diff` and `diagnostics` are buffer-scoped and group after. Placing the summary *after* `diff` instead would render `-1 +2` — a buffer's removed-lines count immediately against a repository's untracked-files count, the one adjacency worth avoiding. lualine's default `component_separators` put a `` between every pair, which separates them further.

The two `+N` remaining on one line at all is a deliberate acceptance, on the user's reasoning: lualine's `diff` is buffer-only and this is repository-wide, so they answer different questions and both are wanted. Recorded here so a later reader does not "fix" it by deleting one.

### No colour, no highlight group

The segments render in `lualine_b`'s own highlight, uncoloured. lualine's `diff` colours its three parts, and it needs to: `+3 ~2 -1` are three bare numbers distinguished only by punctuation. Here the four symbols are already distinct and already carry the meaning, so colour would add a fourth palette to the line and a set of highlight groups to keep in step with every colorscheme — against the capability's own requirement to configure no further than it needs to, and against the theme-following requirement, which is currently satisfied by spending nothing on it.

Alternative considered: `diff`-style per-segment colours via a table return — rejected as above. If it is ever wanted it is a change to the render step alone.

### Not built on gitsigns' status dict

gitsigns exposes `b:gitsigns_status_dict`, and it is the obvious-looking source. It is buffer-local: `added`/`changed`/`removed` line counts for the one file, which is exactly what lualine's `diff` already draws from it. It carries nothing about other files, nothing about untracked files, and nothing about the upstream. There is no repository-wide equivalent to read.

Alternative considered: iterating gitsigns' attached buffers and summing — rejected, it counts only files that happen to be open, so `●5` would mean "five of the files you have open", which is not what the spec says and not what the user asked.

### No new plugin

Plugins exist that put a git summary on the status line, and all of them bring a status line integration, a configuration surface, and an update to track, for what is one `git` call and one parse. The configuration's own `plugin-management` bias is toward taking upstream defaults where a plugin is warranted; here the whole implementation is smaller than the spec for configuring someone else's. Written locally it also stays inside the single file `statusline` requires.

## Risks / Trade-offs

- **A very large repository makes `-uall` slow** → The invocation is asynchronous and never on the redraw path, debounced at 150 ms, and single-flighted per repository. The user sees the previous counts until the new ones land, which the spec explicitly permits.
- **A git command run inside an embedded `:terminal` fires no `FocusGained`** → The summary is stale until the next write, buffer change or directory change. Accepted: the in-editor paths that matter (gitsigns, neogit) have their own events, and adding a `TermLeave` or `ShellCmdPost` trigger later is one line if it ever grates.
- **`User Neogit*` is a glob over another plugin's event names** → If neogit renames its prefix the refreshes stop firing and the summary goes stale after neogit operations. Detectable by the verification steps in `tasks.md`; the fallback is the explicit name list.
- **Naming `lualine_b` pins its three defaults** → An upstream change to `lualine_b`'s contents would no longer arrive on update. This is the same cost `lualine_x` already pays, unavoidable given lualine replaces a named section wholesale, and the file already carries a comment explaining it for `lualine_x`. The mitigation is to restate the three exactly and comment why.
- **Two `+N` on one line mean different things** → Accepted deliberately; see the placement decision. Mitigated by ordering and by the separator between them.
- **The file grows** → `lua/plugins/lualine.lua` gains the parse, the cache and the autocmds, and stops being a short spec. This is required by the `statusline` capability's own single-file rule, not chosen. Mitigated by keeping the addition as one clearly delimited block above the returned spec.
- **`git` missing or failing** → `vim.system`'s error path and any non-zero exit are treated as "no summary": the cache entry is cleared and nothing is drawn. No notification, per the spec.

## Migration Plan

None. The change is additive to a status line that already exists, introduces no state on disk, claims no key and adds no dependency. Rollback is reverting `lua/plugins/lualine.lua`.
