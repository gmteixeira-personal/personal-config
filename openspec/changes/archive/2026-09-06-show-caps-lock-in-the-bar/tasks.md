## 1. The reading

- [x] 1.1 Confirm the lock cannot be observed from the compositor — check that niri's event stream carries no lock state, and that the lock lives in the keymap rather than in a binding a module could hook
- [x] 1.2 Verify the kernel publishes the lock as an LED and that it is readable without any grant — read `/sys/class/leds/*::capslock/brightness` as this user
- [x] 1.3 Verify the cost of the direct alternative before declining it — confirm waybar's `keyboard-state` reads `/dev/input`, which this user cannot read without joining `input`

## 2. The script

- [x] 2.1 Write `.config/waybar/waybar-capslock`, printing one JSON line per lock transition and nothing on an unchanged poll, and verify `bash -n` accepts it
- [x] 2.2 Make the wait fork-free, and verify the process consumes zero CPU ticks over three seconds
- [x] 2.3 Verify the script prints the current state once at startup and then stays running
- [x] 2.4 Record in the script's header which source was declined and what it would have cost
- [x] 2.5 Symlink `.local/bin/waybar-capslock` to it, matching the `fuzzel-*` and `brightness-step` pattern, and verify the symlink resolves

## 3. The module

- [x] 3.1 Add `custom/capslock` to `modules-left` between `niri/workspaces` and `niri/language`, and record why it sits inboard of the layout indicator
- [x] 3.2 Add the module's options block with no `interval`, and record why an interval would discard the running process
- [x] 3.3 Add the module to the stylesheet's no-fill rule and give the on state its own colour, and verify that colour is used nowhere else in the file
- [x] 3.4 Add both script paths to `.gitignore`'s allowlist and verify `git status` reports them as untracked rather than ignored

## 4. Verification

- [x] 4.1 Reload the bar with `SIGUSR2` to the compositor-spawned process, and verify one waybar remains rather than two
- [x] 4.2 Verify waybar spawned the script, resolving it from `PATH` rather than from a path naming this machine's home directory
- [x] 4.3 Toggle the lock and verify the indicator appears and disappears with it, without the bar being restarted
- [x] 4.4 Verify the module occupies no width while the lock is off
- [x] 4.5 Verify no package was installed and no group was joined

## 5. Close-out

- [x] 5.1 Run `openspec validate show-caps-lock-in-the-bar --strict` and verify it passes
- [x] 5.2 Verify `git status` names only the two waybar files, `.gitignore`, the two script paths and the change's own files, then commit
