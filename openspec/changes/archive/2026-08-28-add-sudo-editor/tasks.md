## 1. Shell configuration

- [x] 1.1 Add a guarded `SUDO_EDITOR` export to `.bashrc`, placed with the existing `EDITOR` and `VISUAL` exports and above the non-interactive early return; verify `bash -n ~/.bashrc` passes
- [x] 1.2 Resolve the value with `command -v nvim` rather than naming any installation directory; verify the file contains no literal `/usr/bin/nvim` or bob path
- [x] 1.3 Export only when the resolution succeeds, leaving the variable unset otherwise; verify with a shell whose `PATH` excludes every directory holding `nvim` that `SUDO_EDITOR` is unset and the shell starts with no error
- [x] 1.4 Unset the temporary that holds the resolved path; verify no helper variable survives into an interactive shell's environment
- [x] 1.5 Comment the block with why the path is absolute here while `EDITOR` and `VISUAL` stay bare names

## 2. Verification

- [x] 2.1 Confirm a fresh interactive shell exports `SUDO_EDITOR` as an absolute path, and that the path is executable and is the same `nvim` that `command -v nvim` reports
- [x] 2.2 Confirm a non-interactive shell that sources the file gets the same value, via `bash -c 'source ~/.bashrc; echo "$SUDO_EDITOR"'`
- [x] 2.3 Confirm `EDITOR` and `VISUAL` are still the bare name `nvim`
- [x] 2.4 Confirm sourcing the file twice leaves `SUDO_EDITOR` unchanged
- [x] 2.5 Run `sudoedit /etc/wsl.conf` and confirm Neovim opens with this configuration — plugins loaded, statusline present — rather than the sudoers fallback editor
- [x] 2.6 Confirm the edit round-trips: change the file, write and quit, and check the change landed in `/etc/wsl.conf` with root ownership intact
- [x] 2.7 Confirm no root-owned files were created under `~/.config/nvim`, `~/.local/share/nvim` or `~/.local/state/nvim` by that edit
