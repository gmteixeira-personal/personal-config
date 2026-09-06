## Why

Caps Lock is a mode with no announcement. The key that used to carry it is Control on this machine, so the lock now lives on `Shift+F12`, and the keyboard's own indicator LED is on a key that no longer means anything — the light is beside a Control key. Nothing else reports the state. The first symptom is a line of capitals, and by then it has already been typed.

The bar already admits exactly this kind of module. Its rule is that a module earns its place either by being acted on from the bar or by presenting a change the user has to notice without looking for it, and the layout indicator is there on the second ground: a slipped modifier changes the layout, the first symptom is a character arriving wrong, and the cause is not obvious from the symptom. Caps Lock is the same argument with a different key.

## What Changes

- The bar gains a Caps Lock indicator, immediately right of the workspaces and left of the layout indicator.
- The indicator is present only while the lock is on. The widget collapses the rest of the time, which is almost always.
- The reading is taken from the kernel's Caps Lock LED under `/sys/class/leds`, which is world-readable, rather than from waybar's own `keyboard-state` module, which reads `/dev/input` through libevdev and requires this user to join the `input` group.
- A new script runs for the life of the bar and prints a line only when the lock changes.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `bar-appearance`: The capability already admits a module whose change must be noticed without being looked for, and names the keyboard layout as the case. It gains the Caps Lock indicator as the second, including that the widget is absent while the lock is off. It also gains a requirement on where a module's reading may come from — that presenting a reading SHALL NOT widen what the user's processes are allowed to read — which is the deciding constraint here and is not stated anywhere in the capability today.

## Impact

- `.config/waybar/config.jsonc` — the module in `modules-left` and its own options block.
- `.config/waybar/style.css` — the module added to the no-fill rule, and one colour rule for the lock being on.
- `.config/waybar/waybar-capslock` — new script, with `.local/bin/waybar-capslock` symlinked to it, following the pattern the `fuzzel-*` menus and `brightness-step` already use.
- `.gitignore` — two allowlist entries, one per script path.
- Packages: none. Groups: none — this is the whole reason the reading comes from the LED rather than from libevdev.
- Reload: waybar re-reads its configuration on `SIGUSR2`, so the indicator is live without restarting the session.
- Cost: one long-lived shell that wakes ten times a second and forks nothing, measured at zero CPU ticks over three seconds.
