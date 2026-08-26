## 1. Verify the ground before writing against it

- [x] 1.1 Confirm `git status --porcelain=v2 --branch -uall` in a dirty repository emits the `# branch.ab +N -M` line only when `# branch.upstream` is present, and emits neither on a detached HEAD or a branch with no upstream
- [x] 1.2 Confirm the `XY` field of a `1 `/`2 ` record uses `.` for unchanged, and that a file staged and then edited again reports `MM`
- [x] 1.3 Confirm an unmerged path is reported as a `u ` record and not also as a `1 ` record, so counting it in `●` does not double-count it
- [x] 1.4 Confirm `-uall` lists the files inside an untracked directory individually, and that a `.gitignore`d directory is still not descended into
- [x] 1.5 Confirm `nvim_create_autocmd("User", { pattern = "Neogit*" })` matches the patterns neogit emits — check with a commit through `<leader>gg`
- [x] 1.6 Confirm gitsigns emits `User GitSignsChanged` on a `<leader>hs` stage, and that `GitSignsUpdate` is the noisy per-edit one that must not be listened for

## 2. The refresh mechanism

- [x] 2.1 In `lua/plugins/lualine.lua`, above the returned spec, add the block that will hold the cache, the parse, the refresh and the render — one clearly delimited section, per design.md's mitigation for the file growing
- [x] 2.2 Add the per-repository cache: a table keyed by repository root holding the rendered string, plus the single active-root variable
- [x] 2.3 Write the parse: read the `# branch.ab` line for `↑`, count `? ` records into `+`, count `1 `/`2 ` records with `X ~= "."` into `◆` and `Y ~= "."` into `●`, and count `u ` records into `●`
- [x] 2.4 Write the render: join the non-zero segments with single spaces in the order `+`, `●`, `◆`, `↑`, omitting each zero segment independently, and producing the empty string when all are zero
- [x] 2.5 Write the refresh: `vim.system({ "git", "status", "--porcelain=v2", "--branch", "-uall" }, { cwd = root, text = true }, cb)`, with the callback parsing, rendering, storing, and calling `vim.cmd("redrawstatus")` inside `vim.schedule` **only when the rendered string differs from the stored one**
- [x] 2.6 Treat a non-zero exit, a spawn error, and a missing `git` alike: clear that root's cache entry and draw nothing — no notification, no error, no trace
- [x] 2.7 Add the debounce: one `vim.uv.new_timer()` restarted at 150 ms, so a burst of triggers spawns once
- [x] 2.8 Add the single-flight guard: a request arriving while an invocation is in flight for that root sets a re-run flag rather than spawning, and the flag is honoured when the in-flight one returns

## 3. The triggers

- [x] 3.1 Resolve the active repository root with `vim.fs.root(bufnr, ".git")` on `BufEnter` and `DirChanged`, storing it — never inside the component
- [x] 3.2 Refresh on `BufWritePost`, `FocusGained`, `VimResume` and `DirChanged`
- [x] 3.3 Refresh on `User GitSignsChanged`; deliberately do **not** listen for `GitSignsUpdate`, and leave a comment saying why
- [x] 3.4 Refresh on `User Neogit*`, with a comment recording that the glob is chosen over the seven exact event names so neogit's own renames do not have to be tracked
- [x] 3.5 Create every autocmd inside the existing `opts = function()`, not at file scope, for the same reason the file already gives for `opts` being a function — file-scope work runs during lazy.nvim's spec collection
- [x] 3.6 Kick one refresh when lualine loads, so the summary is present without waiting for the first event
- [x] 3.7 Clear the active root and draw nothing when `vim.fs.root` finds no repository for the focused buffer

## 4. The component and its placement

- [x] 4.1 Add the component function: return the active root's stored string and nothing else — no `require`, no spawn, no filesystem access on the redraw path
- [x] 4.2 Give it a `cond` that is false when that string is empty, so an all-zero repository costs the section no width
- [x] 4.3 Name `lualine_b` as `{ "branch", <summary>, "diff", "diagnostics" }` — the summary after `branch` and before `diff`, per the placement decision
- [x] 4.4 Restate `branch`, `diff` and `diagnostics` exactly as upstream orders them, and comment that naming the section replaces it wholesale, mirroring the comment `lualine_x` already carries
- [x] 4.5 Add no highlight group and no colour table — leave the segments in `lualine_b`'s own highlight, and comment why colour is not spent here
- [x] 4.6 Write the file's new comments in the style of the rest of it: a comment at each decision that would otherwise read as arbitrary — why one `git` call, why `-uall`, why the string is pre-rendered, why the placement keeps the two `+N` apart

## 5. Verify against the spec

- [x] 5.1 In a repository with two untracked files, five unstaged, three staged and one unpushed commit, confirm the line reads `+2 ●5 ◆3 ↑1`
- [x] 5.2 Commit and push everything, and confirm the summary disappears entirely and takes no width — no symbol with a zero beside it
- [x] 5.3 Leave only untracked files and confirm `+2` shows alone, with no `●`, `◆` or `↑`
- [x] 5.4 Change forty lines in six blocks of one file and confirm the unstaged segment reads `●1`, not a line or hunk count
- [x] 5.5 With four other files dirty, focus a fifth unmodified file and confirm the unstaged segment still reads `●4`
- [x] 5.6 Stage a file then edit it again, and confirm it is counted in both `●` and `◆`
- [x] 5.7 Create a merge conflict and confirm the conflicted file is counted in `●`
- [x] 5.8 Check out a branch with no upstream and confirm no `↑` is shown, the other segments still are, and no error is raised; repeat on a detached HEAD
- [x] 5.9 Stage a hunk with `<leader>hs` and confirm the counts move with no further action
- [x] 5.10 Commit through neogit and confirm `◆` clears and `↑` rises by one; push and confirm `↑` clears
- [x] 5.11 Commit in another terminal, return to the editor, and confirm the summary updates on focus
- [x] 5.12 Open a file outside any repository and confirm nothing is shown and no error is raised; confirm the previous repository's counts are gone
- [x] 5.13 Open files from two different repositories and confirm the summary follows whichever is focused
- [x] 5.14 Run Neovim with `git` removed from `PATH` and confirm the summary is absent, no notification appears, and mode, filename, diagnostics and position all still draw
- [x] 5.15 Confirm lualine's `diff` still draws the focused buffer's `+`/`~`/`-` line counts alongside the summary, and that both are present at once

## 6. Verify the cost

- [x] 6.1 Write ten buffers at once with `:wall` and confirm, by logging or by `git` process count, that one invocation results rather than ten
- [x] 6.2 Hold a key to force continuous redraws and confirm no `git` process is spawned by redrawing alone
- [x] 6.3 In a repository large enough for the count to take a noticeable time, confirm typing and redrawing stay responsive throughout and the summary updates when the counts land
- [x] 6.4 Confirm `FocusGained` on an unchanged repository causes no visible repaint — the redraw is skipped when the rendered string is unchanged

## 7. Finish

- [x] 7.1 Split the window and confirm each split still carries its own status line, and that the summary draws in the focused one
- [x] 7.2 Switch colorscheme through Themery and confirm the summary repaints with the rest of the line, including between two variants of one theme
- [x] 7.3 Start a macro recording and confirm the recording indicator still appears in `lualine_x` alongside the summary in `lualine_b`
- [x] 7.4 Run `openspec validate add-statusline-git-status --strict` and resolve anything it reports
- [x] 7.5 Commit `lua/plugins/lualine.lua`
