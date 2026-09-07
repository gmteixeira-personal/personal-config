## 1. The desktop entry

- [x] 1.1 Add `~/.local/share/applications/yazi.desktop` declaring `Type=Application`, `Name=yazi`, `GenericName=File Manager`, a `Comment`, `Terminal=true`, `TryExec=yazi` and `Exec=yazi`, and verify `desktop-file-validate` reports no errors
- [x] 1.2 Add `Categories` and a `Keywords` line covering the task rather than the program — files, browse, manager, explorer — and verify each keyword is a word a user would type for a file manager rather than a synonym of the program's name
- [x] 1.3 Write the comment block in the entry recording why it declares `Terminal=true` instead of naming footclient in `Exec` the way `nvim-foot.desktop` does, and that the difference is the MIME association the editor has and this does not — verify a reader comparing the two entries can tell why they differ without the change history
- [x] 1.4 Allow the entry through `.gitignore`, whose policy is deny-by-default, with a comment block naming what it is and why it exists in the same style as the six entries already allowed there — verify `git check-ignore` no longer matches the path

## 2. Verification

- [x] 2.1 Open the launcher, type `yazi`, and verify the entry is offered
- [x] 2.2 Type `files` and verify the entry is offered, confirming the keywords are matched
- [x] 2.3 Choose the entry with no terminal open and verify yazi starts in a foot window
- [x] 2.4 Verify the entry is tracked in git rather than left as untracked local state
