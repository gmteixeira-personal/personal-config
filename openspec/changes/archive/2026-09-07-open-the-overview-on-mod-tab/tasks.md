## 1. The binding

- [x] 1.1 Add `Mod+Tab repeat=false { toggle-overview; }` directly below `Mod+O repeat=false { toggle-overview; }` in the `binds` block of `.config/niri/config.kdl`, and verify `niri validate` reports the config as valid
- [x] 1.2 Extend the comment above the pair to record that both chords do the same thing, that `Mod+Tab` is there because it is where the hand goes and `Mod+O` stays because it costs nothing to keep, and that `repeat=false` is on both because the action is a toggle that key repeat would otherwise flicker — verify by reading the block back and checking it explains both chords rather than only the new one

## 2. The commented example the binding makes fatal

- [x] 2.1 Delete the `// Mod+Tab { focus-workspace-previous; }` line and its comment from the workspace-switching section of the same file, and verify no commented-out binding for `Mod+Tab` remains anywhere in the file
- [x] 2.2 Record in the comment above the new binding what that example bound the chord to, that nothing bound `focus-workspace-previous` so nothing was lost, and that the example could not be left in place because the compositor rejects a file that binds one chord twice — verify the recorded failure matches what `niri validate` actually reports for a duplicate binding

## 3. The modifier's two meanings

- [x] 3.1 Record in the same comment that `Mod` is Super on a virtual console and Alt when the compositor runs nested, so that `Mod+Tab` and `Alt+Tab` are the same chord in a nested session — verify the note points at the existing explanation of `Mod` in the file rather than restating it

## 4. Verification

- [x] 4.1 Reload the config and verify `Mod+Tab` opens the Overview and a second press closes it
- [x] 4.2 Verify `Mod+O` still opens and closes the Overview
- [x] 4.3 Hold `Mod+Tab` past the keyboard's repeat delay and verify the Overview toggles once rather than flickering, and that its state on release does not depend on how long the chord was held
- [x] 4.4 Press `Alt+Tab` in an application that binds it and verify the application receives it and the compositor takes no action
