## Why

The session's windows carried two pieces of visual furniture that serve a floating desktop and not a tiling one: a 16-pixel gap around every window, and a title bar drawn by each application. In a compositor where position is decided by the layout rather than by dragging, a title bar is a strip of pixels showing a name the bar already shows, above a window that cannot be moved by dragging it.

Removing the title bars turned out to be the harder half, and not for the reason it looked like: the option that governs them takes effect through a Wayland protocol the compositor only offers at startup.

## What Changes

- Window gaps go to zero, so tiled windows meet.
- The compositor asks clients to omit their own decorations, and the terminal is configured to prefer no decoration.
- The focus ring stays at the compositor's default width, since with gaps at zero it becomes the only thing separating one window from the next, and the border is already off.
- The dependency this exposed is recorded: the setting is inert until both the compositor and the terminal's server have been restarted, and until then it fails silently — decorations simply keep being drawn.

## Capabilities

### New Capabilities

- `window-appearance`: the session's window spacing and decoration policy, what the compositor and the client each contribute to it, and what has to be restarted before a change to it means anything.

### Modified Capabilities

None. `terminal-emulator` already requires foot's configuration to be tracked and to record its own reload rule; the decoration preference is a new key in that file rather than a change to what the file must do. `desktop-shell` is untouched.

## Impact

- `.config/niri/config.kdl` — `gaps`, `prefer-no-csd`.
- `.config/foot/foot.ini` — a `[csd]` section.
- Not changed: the focus ring, which was briefly narrowed and then returned to the compositor's default; and the border, already off.
- Outstanding on this machine: the compositor and the foot server both predate the change and are still serving the old behavior. The session has not yet been restarted, so the effect is unverified here.
