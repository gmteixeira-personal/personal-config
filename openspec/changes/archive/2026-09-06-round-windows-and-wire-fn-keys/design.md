## Context

See proposal.md — Why. What shapes the approach here is where each of the three pieces was actually broken, which was not where the file suggested.

The brightness bindings were correct: the keys send `KEY_BRIGHTNESSUP` and `KEY_BRIGHTNESSDOWN`, niri delivers them, and the bindings named them. They spawned `brightnessctl`, which this machine does not have. A compositor `spawn` that cannot find its program reports nothing.

`Fn+F4` was the opposite: the program was fine and the key was wrong. The key sends `KEY_F15` on the AT keyboard rather than `KEY_MICMUTE`, so `XF86AudioMicMute` never matched. Establishing that needed the raw evdev stream, which is `root:input`, and the keysym then needed the compiled keymap rather than the evdev name — `KEY_F15` is keycode 193, `symbols/pc` does not include the `fkeys` file that would give 193 the `F15` keysym, and the `inet(evdev)` model symbols claim it first under the name `XF86Launch6`.

The corners and the shadow were simply never set, and niri's shipped configuration carries both as commented-out examples.

## Goals / Non-Goals

**Goals:**

- Every key printed on the function row that this session claims to support does something, and does it without a package install.
- The reason a binding names an unrelated-looking keysym survives in the file, so it is not "corrected" later.
- The corner radius is stated once, where both the window rule and the shadow can rely on it.

**Non-Goals:**

- Remapping the hardware. `Fn+F4` keeps sending `KEY_F15`; nothing here writes a udev hwdb entry or a `setkeycodes` rule.
- A general backlight tool. The script does one thing for one binding, not a CLI to replace `brightnessctl`.
- External-monitor brightness. That is DDC/CI, a different mechanism entirely, and no key asks for it.
- Volume and speaker mute. Those keys already work; they are named in the specs only to fix which stream each mute key owns.

## Decisions

### Drive the backlight through logind rather than installing `brightnessctl`

`brightnessctl` was the obvious answer and turns out to be a wrapper around the mechanism we would use anyway. Fedora's package ships one binary — no udev rule, no setuid bit — so it cannot write `/sys/class/backlight` directly for an ordinary user either. It reaches the backlight through logind's `SetBrightness`, which logind grants to the session that owns the seat.

Alternatives considered:

- **Install `brightnessctl`.** One `dnf install`, but it puts part of the session's behaviour outside the repository: the file reproduces on a fresh machine and the key still does nothing.
- **udev rule plus `video` group.** Works without logind, and permanently grants every process the user runs write access to every backlight. A far larger grant than the keys need, for no gain over an interface that is already there.
- **Call `busctl` inline from the binding.** A step is `current ± percent of max`, which needs two sysfs reads and arithmetic. That is a script whether or not it is written on one line, and a one-line version has nowhere to put the reason it exists.

### Steps are a percentage of `max_brightness`, with a floor above zero

`max_brightness` is 38400 on this panel and a two-digit number on others, so a raw step is not portable between machines and not meaningful on any of them. The floor exists because the bottom of the range is a black screen and the key that undoes it is on an unlit keyboard; one percent is dim and still readable.

### Bind `XF86Launch6` rather than remapping the key to `KEY_MICMUTE`

A hwdb entry could rename `KEY_F15` to `KEY_MICMUTE` at the kernel level, which would make the existing `XF86AudioMicMute` binding match and need no new line in `config.kdl`.

Rejected because it moves the fix out of this repository's reach: hwdb lives under `/etc` or `/usr/lib`, needs `systemd-hwdb update` and a privileged step on every machine, and the whole point of the surrounding decisions is that a checkout reproduces the behaviour. Binding the keysym the keyboard already sends keeps the fix in the one file that is tracked, at the cost of a name that looks wrong — which is what the comment is for.

The existing `XF86AudioMute` and `XF86AudioMicMute` bindings stay. `Fn+F1` sends `XF86AudioMute` on this keyboard and uses one of them, and neither costs anything on a keyboard that never sends it.

### State the corner radius in a window rule, and leave `draw-behind-window` off

niri cannot know the corner radius of a client that rounds its own corners, so with the radius unstated it assumes square windows and its shadow cuts across the inside of every corner. `draw-behind-window` hides that by moving the shadow behind the window; stating `geometry-corner-radius` removes the cause instead, and `clip-to-geometry` makes the client's own painting respect the same radius. With the radius stated, `draw-behind-window` has nothing left to fix.

### Keep the script beside the configuration it serves

`.config/niri/brightness-step` with a symlink at `.local/bin/brightness-step`, matching `fuzzel-calc`, `fuzzel-wifi` and `fuzzel-bluetooth`. niri's own `PATH` includes `~/.local/bin`, so the binding names the script bare rather than by absolute path, and nothing in the tracked file contains this machine's home directory.

## Risks / Trade-offs

- **The keysym name is a property of the keymap, not the key.** Changing the XKB model, or an xkeyboard-config release that reassigns keycode 193, silently breaks `Fn+F4` again → the binding's comment records the full chain from `KEY_F15` to `XF86Launch6` so the next reader can re-derive it; the diagnosis is `xkbcli compile-keymap` plus one `libinput debug-events` capture.
- **`SetBrightness` is granted to the seat's session.** A brightness step invoked from somewhere that is not the graphical session — an SSH shell, a different seat — fails → acceptable, since the only caller is a compositor binding.
- **The script takes the first entry in `/sys/class/backlight`.** A machine with two backlight devices would get an arbitrary one → this laptop has exactly one, and `brightnessctl`'s own default behaves the same way.
- **Shadows and clipping cost GPU time per frame** → both are compositor features intended for continuous use, and the panel is a single internal display.
- **`clip-to-geometry` applies to every window.** A client that deliberately paints outside its geometry loses that → nothing in this session does, and the alternative is square corners on any window with its own background.

## Migration Plan

niri re-reads `config.kdl` on save, so every part is live without restarting the session; the script is a new file with no state. Rollback is reverting the commit and deleting the two script paths — nothing outside the repository changes, no package is installed, and no group membership or udev rule is left behind to undo.
