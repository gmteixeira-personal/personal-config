## 1. Install the plugin

- [x] 1.1 Create `lua/plugins/diffview.lua` for `sindrets/diffview.nvim`, with no `event`, following `lua/plugins/neogit.lua`'s shape: `cmd` so the commands exist before the plugin does, and `keys` for the mappings below.
- [x] 1.2 Write one `toggle(matches, open)` helper the mappings share: close where a view it matches is open, open where none is.
- [x] 1.3 Decide openness from `require("diffview.lib")` -- `get_current_view()` for the current tabpage, then a scan of `lib.views` for one left open in another -- never from the windows on screen, so that hiding the file panel cannot make a mapping open a second view.
- [x] 1.4 Give each mapping a predicate rather than a name: `class.__name` separates a repository diff from a file history, and `path_args` separates the whole-repository diff from the single-file one, so no mapping can dismiss another's view.
- [x] 1.5 Bind `<leader>gd` to the single-file toggle, opening `:DiffviewOpen -- <current file>`, reporting and opening nothing where the buffer has no file behind it.
- [x] 1.6 Bind `<leader>gm` to the whole-repository toggle.
- [x] 1.7 Bind `<leader>gh` to the file-history toggle.
- [x] 1.8 Bind `<leader>gr` to `:DiffviewRefresh` -- not a toggle, since it acts on a view already open.
- [x] 1.9 Close the file panel for single-file views from the `view_opened` hook, so `:DiffviewOpen -- some/file` typed by hand behaves as the mapping does.
- [x] 1.10 Comment the file to the standard of the rest of `lua/plugins/`: which keys came from where, why `keys` rather than buffer-local mappings, why `cmd` is there when neogit reaches the plugin by `require` anyway, why openness is read from the registry rather than from the panel, why the predicates are needed, and that the in-view keys are taken as they come.

## 2. Point neogit at it, and give up its placement keys

- [x] 2.1 Set `integrations.diffview = true`, keeping the existing note on why a `nil` integration is not used.
- [x] 2.2 Add `diff_viewer = "diffview"`, with a comment on why the viewer is named rather than auto-detected.
- [x] 2.3 Rewrite the comment that argues diffview is not installed.
- [x] 2.4 Remove `<leader>gr`, `<leader>gv` and `<leader>gh`, leaving `<leader>gg` as the only mapping.
- [x] 2.5 Make `<leader>gg` a toggle on `require("neogit.buffers.status")`'s own `is_open()` and `instance():close()`, opening with `kind = "replace"`.
- [x] 2.6 Record in place where the other three keys went and that `:Neogit kind=...` still reaches every arrangement, and update the `<leader>g` ownership comment.

## 3. Take `<leader>gd` off gitsigns

- [x] 3.1 Remove the `<leader>gd` mapping from `lua/plugins/gitsigns.lua`, leaving the sign column, `]c` / `[c` and the `<leader>h` actions untouched.
- [x] 3.2 Record at the head of the file where the mapping went and that `:Gitsigns diffthis` still diffs against the index, and correct the `]c` / `[c` comment, which referred to the diff gitsigns itself used to open.

## 4. Keep the buffer list and saved sessions clean

- [x] 4.0a In `lua/plugins/diffview.lua`, remember the listed buffers before the first view opens -- from the mapping, before the command runs, and again from `view_opened` as a fallback for the typed command.
- [x] 4.0b From `view_closed`, once the last view has gone, delete every listed buffer that joined the list since, skipping any that is displayed in a window or has unsaved changes. Schedule it: the view is still in `lib.views` while the hook runs.
- [x] 4.0c Comment why the snapshot rather than the view's own file list is the test -- `File:_create_local_buffer` re-lists a buffer the user already had, so only a before-and-after comparison can tell the two apart.

- [x] 4.1 In `lua/plugins/auto-session.lua`, add a `pre_save_cmds` entry that closes every open diffview view before a session is written.
- [x] 4.2 Read `package.loaded["diffview.lib"]` rather than requiring it, so a session that never opened diffview does not load it at quit, and snapshot `lib.views` before iterating, since closing a view removes it from that list.
- [x] 4.3 Comment why `close_unsupported_windows` is not enough on its own: it drops the file panel and the `diffview://` side, but the other side of a diff is the real file and survives the cull.

## 5. Verification

- [x] 5.1 Confirm the prefix reads as intended: `<leader>gg` status, `<leader>gd` this file, `<leader>gm` repository, `<leader>gh` history, `<leader>gr` refresh, `<leader>gv` unbound, Telescope's four intact, and no buffer-local `<leader>gd` from gitsigns.
- [x] 5.2 Press `<leader>gd` on a changed file and confirm a single-file view scoped to that path, with the two versions side by side and no file panel; press it again and confirm it closes.
- [x] 5.3 Press `<leader>gd` in a buffer with no file behind it and confirm it reports that and opens nothing.
- [x] 5.4 With one file's diff open, press `<leader>gm` and confirm the one-file view is not closed and the repository view opens; then `<leader>gd` and confirm it closes only its own.
- [x] 5.5 Press `<leader>gg` and confirm the status view replaces the current window; press it again and confirm it closes and returns to the buffer being edited.
- [x] 5.6 Press `<leader>gr` with no view open and confirm nothing opens and no error is raised; with a view open, confirm it stays open and no error is raised.
- [x] 5.7 In a repository with several changed files, press `<leader>gm` and confirm a file panel listing every difference, with the selected file side by side and its differing lines highlighted in both.
- [x] 5.8 Select a different file in the panel and confirm its difference replaces the one shown, with the panel still visible.
- [x] 5.9 With one file staged, one unstaged and one untracked, confirm all three are listed and the panel distinguishes which are staged.
- [x] 5.10 Open the repository view from a split layout and confirm the layout is untouched; press `<leader>gm` again and confirm the same buffers and cursor positions come back.
- [x] 5.11 With the view open, hide the file panel with `<leader>b`, then press `<leader>gm` and confirm the view closes rather than a second one opening.
- [x] 5.12 With the view open, jump to a file with `gf` so the view is left behind in its own tabpage, then press `<leader>gm` and confirm the view closes and no second view is opened.
- [x] 5.13 Press `<leader>gh` on a file with more than one commit behind it and confirm a list of the commits that touched it; press it again and confirm the view closes.
- [x] 5.14 With the history open, press `<leader>gm` and confirm the history is not closed and the repository diff opens.
- [x] 5.15 Press `<leader>gm` in a clean repository and confirm an empty file list and no error, then in a directory that is not a git repository and confirm the failure is reported without an error trace.
- [x] 5.16 Ask a view for its own help with `g?` and confirm it lists its keys; then leave for an ordinary buffer and confirm `<leader>e` opens Oil and the view's `<tab>` is gone.
- [x] 5.17 Build a throwaway repository with two branches editing the same line, merge to force a conflict, and open the conflicted file in the three-way view: confirm both sides and the working file are shown, that either side's version of a region can be taken into the working file, and that resolving every region leaves no conflict markers.
- [x] 5.18 Confirm the next-conflict and previous-conflict motions move between regions with all sides staying aligned.
- [x] 5.19 From neogit's status buffer, open the entry under the cursor through the diff popup and confirm it opens in diffview with the status buffer still there to return to.
- [x] 5.20 From the status buffer, ask for the difference between two revisions and confirm the repository's revisions are offered as choices.
- [x] 5.21 Expand an entry in the status buffer in place and confirm the inline diff still works and stages nothing by being displayed.
- [x] 5.22 Ask neogit to stage a conflicted file and confirm it opens the three-way view rather than reporting "Conflicts must be resolved before staging", and that closing it still conflicted leaves the file unmerged and unstaged.
- [x] 5.23 Confirm `]c` and `[c` still move between hunks in an ordinary buffer and between differences inside a view.
- [x] 5.24 Quit the editor with a view open, relaunch in the same directory, and confirm nothing the view brought in is restored. Confirmed in a real editor by the user, in `~/repos/ycrm`: before the `pre_save_cmds` fix, opening an empty editor, pressing `<leader>gm` and quitting reopened the file the diff had been showing; after it, the next launch opens with nothing, which is correct for an editor opened only to read a diff. Not scriptable here -- auto-session writes nothing under `nvim --headless`, even when `:AutoSession save` is called outright.
- [x] 5.25 Confirm the hook's own behaviour: it closes every open view, leaves the files being edited alone, and does not load diffview for a session that never opened it.
- [x] 5.26 Read several files in a view, close it, and confirm none of them remains in the buffer list; confirm the buffers the user opened themselves -- including one left hidden -- all survive; and confirm a buffer the view loaded that has since been edited is kept with its changes.
- [x] 5.27 Confirm the other half of the session requirement in a real editor -- with one or more files genuinely being edited, open a view, quit, and relaunch: the files being edited should come back and nothing the view loaded should. Closed by the user. Not exercised by the checks in this repository: auto-session writes nothing under `nvim --headless`, even when `:AutoSession save` is called outright, so this one could only ever be confirmed by hand. The requirement itself is live in `openspec/specs/repository-diff-view/spec.md` under "A view open at quit does not reach the saved session", which is what to hold the code to if it ever misbehaves.
