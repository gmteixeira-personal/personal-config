## 1. The binds

- [x] 1.1 Replace the `Ctrl+Alt+Escape` lock bind in `~/.config/niri/config.kdl` with `Mod+Escape allow-inhibiting=false hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }`, beside the unchanged `Super+Alt+L`; verify with `grep -n 'swaylock"; }' ~/.config/niri/config.kdl`.
- [x] 1.2 Move `toggle-keyboard-shortcuts-inhibit` to `Mod+Shift+Escape`, keeping `allow-inhibiting=false`; verify with `grep -n toggle-keyboard-shortcuts-inhibit ~/.config/niri/config.kdl`.
- [x] 1.3 Rewrite the comments at both sites: why the lock took `Escape`, where the toggle went, and what `Ctrl+Alt+Escape` did when pressed, so the chord is not proposed again as a free one; verify by reading both blocks back.
- [x] 1.4 Verify the file parses and holds no duplicate keybind: `niri validate -c ~/.config/niri/config.kdl` reports `config is valid`.
- [x] 1.5 Verify the running compositor reloaded it: `journalctl --user -b --since '-2 min' | grep niri_config` shows a `loaded config from` line timestamped after the write.

## 2. Confirmation on the running session

- [x] 2.1 Press `Mod+Escape` and confirm the session locks, which is the test the spec now requires of a lock chord; a validating file and a logged reload do not stand in for it.
- [x] 2.2 Confirm `Super+Alt+L` still locks and presents the same screen.

## 3. Record

- [x] 3.1 Update the sentence in `~/README.md` that names the session's lock chords, so it reads `Super+Alt+L` and `Mod+Escape`; verify with `grep -n "Mod+Escape" ~/README.md`.
