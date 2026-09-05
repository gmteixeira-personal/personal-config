## 1. Install

- [x] 1.1 Install the `noctalia` package from the distribution repository and verify `noctalia --version` reports 5.0.1
- [x] 1.2 Verify the shell carries a backend for the compositor in use, by inspecting the shipped binary for a niri runtime rather than generic Wayland support alone

## 2. Session startup

- [x] 2.1 Replace the compositor's waybar startup entry with one that starts the shell as a daemon, and verify no second bar remains in the startup entries
- [x] 2.2 Verify the compositor configuration still validates with `niri validate`

## 3. Bindings

- [x] 3.1 Repoint the launcher binding at the shell's `panel-toggle launcher` IPC command and verify its hotkey-overlay title names the shell
- [x] 3.2 Repoint the lock binding at the shell's `session lock` IPC command and verify the action exists in `noctalia msg session --help`
- [x] 3.3 Add a clipboard-history binding on a combination the compositor does not already bind, and verify `niri validate` accepts the file rather than reporting a duplicate keybind

## 4. Verification in the live session

- [x] 4.1 Start the shell in the running session and verify it reports a running instance with a bar on the connected output
- [x] 4.2 Toggle the clipboard panel over IPC and verify `noctalia msg status` reports `activePanelId` as the clipboard panel
- [x] 4.3 Stop waybar and verify the shell's bar is the only one drawing, with waybar left with no configuration to preserve

## 5. Clipboard backend

- [x] 5.1 Determine whether the shell needs an external clipboard history daemon by inspecting the shipped binary for cliphist references and clipboard tool invocations, and verify the count is zero
- [x] 5.2 Record the installed-but-unused `cliphist` package in the proposal and spec so it does not read as load-bearing

## 6. Reversibility

- [x] 6.1 Verify the replaced components are still installed and launchable by name, and that no replaced component lost configuration
