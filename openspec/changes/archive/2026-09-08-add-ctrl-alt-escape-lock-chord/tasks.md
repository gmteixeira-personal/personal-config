## 1. Preconditions

- [x] 1.1 Confirm `Ctrl+Alt+Escape` is unbound, so the new line cannot become a duplicate keybind that silently keeps the last good copy of the file loaded; verify with `grep -n "Escape" ~/.config/niri/config.kdl` showing only `Mod+Escape` and comment text.
- [x] 1.2 Confirm the file currently loads clean, so any later failure belongs to this change; verify with `niri validate --config ~/.config/niri/config.kdl`.

## 2. The binds

- [x] 2.1 Add `Ctrl+Alt+Escape allow-inhibiting=false hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }` directly below the existing `Super+Alt+L` line in `~/.config/niri/config.kdl`, and add `allow-inhibiting=false` to `Super+Alt+L` itself; verify both lines carry the property and the same title with `grep -n "swaylock\"; }" ~/.config/niri/config.kdl`.
- [x] 2.2 Write the comment above the pair explaining why the lock is exempt from inhibiting and why two chords are kept, in the voice of the surrounding comments; verify by reading the block back in context with `sed -n '584,604p' ~/.config/niri/config.kdl`.
- [x] 2.3 Verify the edited file parses: `niri validate --config ~/.config/niri/config.kdl` reports no error.

## 3. Verification on the running session

- [x] 3.1 Verify the running compositor picked the file up without a restart: `niri msg keyboard-layouts` succeeds, and the hotkey overlay (`Mod+Shift+Slash`) lists two entries titled `Lock the Screen: swaylock`.
- [ ] 3.2 Verify `Ctrl+Alt+Escape` locks: press it, confirm the swaylock screen appears dark with the configured indicator, and unlock with the password.
- [ ] 3.3 Verify `Super+Alt+L` still locks and presents the same screen.
- [ ] 3.4 Verify nothing else regressed on the chords the change touched: `Ctrl+Alt+Delete` still raises the quit confirmation and is dismissed without quitting, and `Mod+Escape` still toggles the shortcuts inhibitor.

## 4. Record

- [x] 4.1 Update `~/README.md` if it lists the session's keybindings, so the second lock chord is documented where the first one is; verify with `grep -n -i "Super+Alt+L" ~/README.md` and either an updated entry or a confirmed absence of any keybinding list.
