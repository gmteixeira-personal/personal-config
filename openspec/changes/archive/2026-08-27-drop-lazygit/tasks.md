## 1. Repository

- [x] 1.1 Stop tracking `.config/lazygit/config.yml` and remove the directory it was the only file in
- [x] 1.2 Delete the block 3 allowlist entry that named it, leaving the gh and caveman entries beside it untouched

## 2. Machine state

- [x] 2.1 Confirm the lazygit package is not installed
- [x] 2.2 Confirm no configuration, state, share, or cache directory for it remains in the home directory
- [x] 2.3 Sweep the whole home directory for any file bearing the tool's name, and confirm the only matches belong to an unrelated plugin's own checkout
- [x] 2.4 Check the project's current release and commit activity before writing a reason for the retirement into the spec

## 3. Verification

- [x] 3.1 Confirm `git ls-files` reports no path under `.config/lazygit/`
- [x] 3.2 Confirm `git check-ignore -v` on the former config path reports a deny-by-default rule rather than an allowlist exception
- [x] 3.3 Confirm the remaining references to the tool are historical only — archived changes and the first-commit account in `dotfiles-repo`
