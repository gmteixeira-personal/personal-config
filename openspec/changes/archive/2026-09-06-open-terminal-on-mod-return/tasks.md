## 1. The binding

- [x] 1.1 Confirm `Mod+Return` is unbound — search `config.kdl` for `Return`, `Enter` and `KP_Enter` and verify no chord names any of them
- [x] 1.2 Add `Mod+Return` to `binds` beside the existing terminal binding, spawning `footclient` with the same hotkey-overlay title
- [x] 1.3 Record in a comment why one program answers to two chords, naming the launcher's `Mod+D` and `Mod+Space` as the precedent, so the next reader does not remove one as a duplicate
- [x] 1.4 Verify niri accepts the edited file with `niri validate`

## 2. Verification

- [ ] 2.1 Press `Mod+Return` and verify a terminal window opens without the session being restarted
- [ ] 2.2 Verify the window is served by the running foot server rather than a standalone foot — check that no new `foot` process appears beside `footclient`
- [ ] 2.3 Press `Mod+T` and verify it still opens a terminal
- [ ] 2.4 Show the hotkey overlay and verify both chords appear, each labelled with the terminal it opens
- [ ] 2.5 Verify no other chord changed behaviour — in particular that `Return` alone still reaches the focused application

## 3. Close-out

- [x] 3.1 Run `openspec validate open-terminal-on-mod-return --strict` and verify it passes
- [x] 3.2 Verify `git status` names only `.config/niri/config.kdl` and the change's own files, then commit
