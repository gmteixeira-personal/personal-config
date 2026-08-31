## 1. Verify the repository is free of zoxide

- [x] 1.1 Search the tracked files for the tool and verify that `git grep -In zoxide -- ':!openspec/changes/archive'` returns no match, so nothing outside the archived historical record names it
- [x] 1.2 Inspect every fish startup file under `.config/fish/conf.d/` and the bash startup files, and verify that none contains a `zoxide init` line or any other invocation of the `zoxide` command
- [x] 1.3 Inspect the root ignore file and verify no allowlist entry names a path under `.config/zoxide/` or any other path belonging to the tool
- [x] 1.4 If tasks 1.1 through 1.3 turn up anything, remove it and re-run the corresponding check until it comes back clean

## 2. Verify the machine is free of zoxide

- [x] 2.1 Verify the binary is gone by confirming `command -v zoxide` finds nothing on `PATH`
- [x] 2.2 Query the system package manager for zoxide and verify it reports the package as not installed; also check `cargo install --list` for it, since that is the other common install route
- [x] 2.3 Verify `.config/zoxide/`, `.local/share/zoxide/`, `.local/state/zoxide/`, and `.cache/zoxide/` are each absent, and that no database file holding its directory rankings remains
- [x] 2.4 Remove anything tasks 2.1 through 2.3 find, then re-run those checks and verify each comes back clean

## 3. Confirm a fresh shell is clean

- [x] 3.1 Start a new fish shell from this configuration and verify `functions -q __zoxide_hook` exits non-zero, so no hook is defined
- [x] 3.2 In that fresh shell, change directory into a project with an `.envrc` and back out, and verify no error naming zoxide is printed and that direnv still loads and unloads normally

## 4. Clear the stale session

- [ ] 4.1 In the fish session that prints the error, run `exec fish` (or open a new terminal), then change directory and verify the `fish: Unknown command: zoxide` error no longer appears

## 5. Record the retirement

- [x] 5.1 Add the zoxide requirement to the `retired-tooling` delta spec at `openspec/changes/retire-zoxide/specs/retired-tooling/spec.md`, leaving the existing lazygit requirement untouched, and verify `openspec validate retire-zoxide --strict` passes
- [x] 5.2 Verify the delta's scenarios match what tasks 1 through 3 actually observed, correcting the spec if any check found something the scenarios do not describe
