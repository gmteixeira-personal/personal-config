## Why

Two of the laptop's function keys did nothing at all. `Fn+F5` and `Fn+F6` carry brightness legends and moved no backlight; `Fn+F4` carries a microphone legend and muted nothing. Neither failed loudly: the compositor bindings existed, the configuration validated, and pressing the keys produced no window, no error and no log line. A key that is printed on the hardware and inert in the session is worse than one that was never wired, because the legend keeps promising a behaviour the machine does not have.

Both failures had already been written into `config.kdl` by the packaged example configuration this session started from — one binding spawning a program that is not installed, one binding naming a keysym this keyboard does not send. Neither is discoverable by reading the file, which is why both survived this long.

Separately, windows had square corners and no shadow. That is the compositor's default rather than a decision, and the two settings interact: a shadow drawn around a window the compositor believes is square leaves artifacts inside a rounded corner, so the corner radius has to be stated where the shadow can see it.

## What Changes

- Windows gain a corner radius and are clipped to it, and the compositor draws shadows. The radius is stated in a window rule, which is also what lets the shadow follow the corner instead of cutting across it.
- The brightness bindings stop spawning `brightnessctl`. A new `brightness-step` script sets the backlight through logind's `SetBrightness`, which is the same interface `brightnessctl` itself uses on this distribution and needs neither the package nor write access to `/sys/class/backlight`.
- `Fn+F4` is bound by the keysym it actually produces. The key reports `KEY_F15`, which this keymap names `XF86Launch6`, not `XF86AudioMicMute` — so the binding that was supposed to catch it never matched. The new binding toggles the PipeWire source.
- The existing `XF86AudioMute` and `XF86AudioMicMute` bindings stay. They are correct for a keyboard that sends those codes, and this one sends `XF86AudioMute` from `Fn+F1`.

## Capabilities

### New Capabilities

- `hardware-function-keys`: What the laptop's Fn row does to the session — which key acts on the backlight and which on the microphone, that a binding must name the keysym the keyboard actually sends rather than the one its legend implies, and that the action a key performs must not depend on a package the machine does not carry.

### Modified Capabilities

- `window-appearance`: The capability states what the compositor draws around windows — gaps, focus marker, decorations, the surface behind them — but says nothing about the shape of a window's own corners or about anything drawn outside its edges. It gains a requirement for the corner radius and one for the shadow, including the dependency between them.

## Impact

- `.config/niri/config.kdl` — a window rule for the corner radius and clipping, `on` in the existing `shadow` block, and three binding lines changed or added.
- `.config/niri/brightness-step` — new script, with `.local/bin/brightness-step` symlinked to it, following the same pattern as the `fuzzel-*` tools this repository already ships.
- `.gitignore` — two allowlist entries, one per script path. The policy ignores everything and re-includes by name, so a new tracked file is not tracked until it is named.
- Packages: none added. The change specifically avoids `brightnessctl`, which would otherwise be a dependency this repository cannot install on a fresh machine without a privileged step.
- Groups: none. `SetBrightness` is granted to the session that owns the seat, so the user does not join `video` and no udev rule is installed.
- Machines: none beyond this one. All of it is compositor and laptop-hardware configuration, and the WSL machine runs no compositor and has no backlight.
- Reload: niri re-reads `config.kdl` on save, so every part of this is live without restarting the session.
