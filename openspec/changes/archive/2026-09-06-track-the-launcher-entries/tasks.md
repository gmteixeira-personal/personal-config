## 1. The carve-out

- [x] 1.1 Establish that the obstacle is git's own rule rather than rule ordering: confirm a block 3 entry for a path under `.local/` is never consulted, because git will not re-include a file whose parent directory is excluded
- [x] 1.2 Establish that `.local/` is on block 4's bulk list and not its secret list, so that narrowing it is a size decision and not a security one
- [x] 1.3 Write block 5 after block 4, re-including each ancestor and immediately re-excluding its contents, so `.local/` (2.2 GB) and `.local/share/keyrings/` are not traversed to reach 20 KB
- [x] 1.4 Amend the header from four blocks to five, and narrow "never loosen block 4" to its secret half, recording why block 5 cannot live in block 3
- [x] 1.5 Verify with `git check-ignore` that the six intended files are trackable and that `claude-code-url-handler.desktop`, `mimeapps.list`, `.local/bin/claude`, `.local/bin/openspec`, `.local/bin/vivid`, `.local/state` and `.local/lib` are still ignored
- [x] 1.6 Verify `git status --porcelain` still completes in well under a second

## 2. The machine-absolute paths

- [x] 2.1 Find every tracked file naming this machine's home directory and separate the ones this session introduced from the ones that predate it
- [x] 2.2 Establish that a desktop entry cannot use `$HOME` — `$` is reserved in `Exec`, which takes an absolute path or a command name — so the bare command name is the only portable form
- [x] 2.3 Confirm `.local/bin` is on `PATH` for the processes that will spawn these commands, and that `shell-environment` already requires it rather than it being incidental
- [x] 2.4 Change both desktop entries' `Exec` to the bare command name and re-validate them with `desktop-file-validate`
- [x] 2.5 Change the bar's two `on-click` values to the same bare names, reload the bar and verify one process survives
- [x] 2.6 Retarget both symbolic links from absolute to relative, and verify each still resolves
- [x] 2.7 Verify no staged file contains `/home/gmteixeira`

## 3. Tracking

- [x] 3.1 Stage the four files and two links by name, never with `git add -A`
- [x] 3.2 Verify `git status` reports the six individually rather than collapsing them into `?? .local/`
- [x] 3.3 Verify the pre-commit hook passes on the staged set

## 4. Close-out

- [x] 4.1 Run `openspec validate track-the-launcher-entries --strict` and verify it passes
- [x] 4.2 Verify `git status` names only the intended paths, then commit
