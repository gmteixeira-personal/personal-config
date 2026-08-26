## Why

The status line answers "what is this buffer?" but not "what does this repository owe?". lualine's stock `diff` component in `lualine_b` reports the *current buffer's* added, changed and removed lines against the index — useful while editing one file, silent about the other nine that are dirty, the three already staged, the two untracked, and the commit sitting unpushed. Today the only way to learn any of that is `<leader>gg` into neogit, `<leader>gs` into a Telescope status picker, or a shell. All three are deliberate acts; the question they answer is one the user wants answered continuously and without asking, which is precisely what `statusline` exists to do.

## What Changes

- Add one component to `lualine_b`, immediately after `branch`, summarising the **repository** — not the buffer — as up to four segments separated by single spaces:

  | Segment | Meaning |
  | --- | --- |
  | `+N` | untracked files |
  | `●N` | files with unstaged changes |
  | `◆N` | files with staged changes |
  | `↑N` | commits on the branch not yet on its upstream |

  Rendered bare, with no brackets, e.g. ` main +2 ●5 ◆3 ↑1`.

- **Each segment is hidden when its count is zero**, independently of the others. A tree with two untracked files and nothing else shows `+2` alone. A clean tree with everything pushed shows nothing at all, and the component occupies no width.
- Counts are **file counts**, not line or hunk counts — consistent with `+N` untracked, which can only be a file count.
- The stock `diff` component **stays**. It is buffer-scoped and the new one is repository-scoped; they answer different questions and the two `+N` next to one another mean different things by design — `+3` from `diff` is lines added to this buffer, `+2` from the new component is untracked files in the repository.
- The counts are gathered **asynchronously**, off a single `git` invocation per refresh, and refreshed on events rather than on a clock. Nothing the status line draws may block a redraw.
- **No new plugin.** The component is written into the existing `lua/plugins/lualine.lua`, which `statusline` already requires to be the capability's only file.

## Capabilities

### New Capabilities

None. This is a reporting addition to the status line the `statusline` capability already owns, and it introduces no interaction, no mapping and no command of its own.

### Modified Capabilities

- `statusline`: three requirements are added and two are modified.
  - **Added** — *The status line summarizes the repository's uncommitted work and unpushed commits*: the four segments, their symbols, file counts rather than line counts, and per-segment suppression of a zero.
  - **Added** — *The summary tracks the repository as it changes, without being asked*: what must bring it up to date, and that gathering it may not block a redraw.
  - **Added** — *The summary is absent, not broken, where there is nothing to summarize*: outside a repository, and with no `git` on the path.
  - **Modified** — *The status line reports the editor's state rather than the file's name alone*: the repository summary joins the list of what is reported, and the buffer-scoped and repository-scoped summaries are stated to be distinct and both required.
  - **Modified** — *The capability is configured no further than it needs to be*: it currently states that the recording indicator is the **only** presentation choice the configuration makes. That becomes two. It also gains the rule that naming a section in order to place one of those two obliges the configuration to restate that section's upstream defaults exactly — which is what `lualine_x` already does and what `lualine_b` will now have to do. No change to how many status lines are drawn.

`git-integration` is untouched: gitsigns keeps its sign column, its `]c`/`[c`, and its `<leader>h` hunk actions, and this change reads none of its state. `git-repository-ui` (neogit) is untouched: the new component listens for its completion events but neogit neither gains nor loses behaviour.

## Impact

- **Modified file**: `lua/plugins/lualine.lua` — the whole change. `lualine_b` is named for the first time, so `branch`, `diff` and `diagnostics` must be respelled alongside the addition, exactly as `lualine_x` already respells its three defaults and for the same reason.
- **No new dependency.** No plugin is added and `lazy-lock.json` does not change.
- **Runtime requirement**: a `git` executable on `PATH` — already assumed by gitsigns, the Telescope git pickers and neogit. Its absence must degrade to an empty component, not an error.
- **Keys and commands**: none claimed. Nothing is added to `lua/config/keymaps.lua` and no `<leader>` prefix is touched.
- **Cost**: one `git status --porcelain=v2 --branch` per refresh, spawned off the main loop. Refreshes are debounced and event-driven; there is no polling timer.
