## 1. Window shape

- [x] 1.1 Enable the commented-out corner-radius window rule in `config.kdl`, setting `geometry-corner-radius` and `clip-to-geometry`, and verify `niri validate` accepts the file
- [x] 1.2 Turn the `shadow` block on and verify `niri validate` accepts the file
- [x] 1.3 Leave `draw-behind-window` commented out, and verify the reason is recorded — the stated radius is what lets the shadow follow the corner, so the setting that hides the artifacts has nothing left to hide

## 2. Diagnosing the dead keys

- [x] 2.1 Confirm the brightness bindings themselves are sound — decode the `KEY` bitmasks in `/proc/bus/input/devices` and verify some device advertises `KEY_BRIGHTNESSUP` and `KEY_BRIGHTNESSDOWN`
- [x] 2.2 Verify `brightnessctl` is absent (`rpm -q brightnessctl`), and that the package would not have helped an unprivileged write anyway — `dnf repoquery -l brightnessctl` lists one binary, no udev rule
- [x] 2.3 Verify logind's `SetBrightness` is callable as this user by invoking it with the panel's current value, so the screen does not change
- [x] 2.4 Capture the raw evdev stream with `libinput debug-events --show-keycodes` while pressing `Fn+F4`, plain `F4` and a known-good key, and verify which keycode each produces
- [x] 2.5 Compile the session's keymap with `xkbcli compile-keymap` using the layout and options from `config.kdl`, and verify which keysym keycode 193 carries

## 3. The brightness script

- [x] 3.1 Write `.config/niri/brightness-step`, taking a signed percentage, reading `brightness` and `max_brightness` from sysfs and calling logind's `SetBrightness`, and verify `bash -n` accepts it
- [x] 3.2 Symlink `.local/bin/brightness-step` to it, matching the `fuzzel-*` pattern, and verify the symlink resolves
- [x] 3.3 Add both script paths to `.gitignore`'s allowlist, in the blocks that already carry the compositor's files and the `fuzzel-*` links, and verify `git status` now reports them as untracked rather than ignored
- [x] 3.4 Verify a step up and a step down move the panel and return it to its starting value
- [x] 3.5 Verify the floor and the ceiling clamp — a step past either end lands on the limit rather than overshooting, and the floor is above zero
- [x] 3.6 Verify a malformed argument exits non-zero with a usage line rather than setting a brightness

## 4. The bindings

- [x] 4.1 Point the two brightness bindings at `brightness-step` and verify `niri validate` accepts the file
- [x] 4.2 Verify niri's own `PATH` contains `~/.local/bin`, so the bindings can name the script bare rather than by absolute path
- [x] 4.3 Bind the keysym `Fn+F4` really sends to a capture-stream mute, and verify `niri validate` accepts the file
- [x] 4.4 Record in a comment the chain from `KEY_F15` to `XF86Launch6`, so the binding is not "corrected" to the name the legend implies
- [x] 4.5 Verify the existing `XF86AudioMute` and `XF86AudioMicMute` bindings are still present and unchanged
- [x] 4.6 Remove every temporary diagnostic binding added during section 2, and verify `config.kdl` contains no `logger` call and no leftover probe binding

## 5. Verification

- [x] 5.1 Press the brightness keys and verify the panel changes without the session being restarted
- [x] 5.2 Press `Fn+F4` and verify the bar's microphone indicator flips, and that recording stops while it is muted
- [x] 5.3 Press `Fn+F1` and verify it still mutes the speakers, and that the microphone indicator does not change
- [x] 5.4 Verify windows are drawn with rounded corners and a shadow, and that no shadow is drawn inside a rounded corner
- [x] 5.5 Verify no package was installed and no group was joined — `rpm -q brightnessctl` still reports it absent and `groups` is unchanged

## 6. Close-out

- [x] 6.1 Run `openspec validate round-windows-and-wire-fn-keys --strict` and verify it passes
- [x] 6.2 Verify `git status` names only `.config/niri/config.kdl`, `.gitignore`, the two `brightness-step` paths and the change's own files, then commit
