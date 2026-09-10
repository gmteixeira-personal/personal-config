## Why

The desk has three screens: two identical externals side by side, and the laptop sitting physically below and between them. The compositor knew none of that. It auto-placed all three in a left-to-right row at their default scales, so the pointer left the laptop sideways when the panel it should have been reaching was underneath, and the laptop rendered at the same scale it uses on its own despite now sitting lower and further away than the two screens either side of it.

Positioning alone is expressible in the compositor's own configuration, and was: an `output` block per screen with an explicit `position`. Scale is not, because the scale the laptop wants depends on which other screens are attached. The configuration language has no conditionals — one `output` block carries one scale, applied whenever that output is present — so a docked scale would follow the laptop everywhere and an undocked scale would be wrong at the desk. That is the gap this change closes.

## What Changes

- Introduce a per-connected-set output layout: each distinct set of attached screens gets its own profile fixing every attached output's scale and position, and the profile is applied automatically when that set appears.
- Declare the docked set — the two externals and the laptop — as the externals side by side with the laptop centred beneath them, and the laptop at a scale a fifth larger than it uses alone.
- Declare the undocked set — the laptop by itself — at the panel's own scale, at the origin.
- Move output geometry out of the compositor configuration entirely, so that scale and position for a given screen are stated in exactly one place rather than split across two files that would each be applied in turn and disagree.
- Match the two externals by make, model and serial rather than by connector name, because they are the same monitor model and the pair can return on swapped connectors after a redock — which under a connector-name match would mirror the desk left to right with nothing in the configuration having changed.
- Leave a set with no matching profile alone: the compositor auto-places it as it does today.

## Capabilities

### New Capabilities

- `output-layout`: where the compositor places each connected screen in the global coordinate space and at what scale, and how that placement depends on which screens are connected.

### Modified Capabilities

<!-- None. `window-placement` governs the placement of columns within an output and is unaffected; `graphical-session-startup` governs how the session is launched, not what it displays on. -->

## Impact

- Adds a dependency on `kanshi`, which is packaged in Fedora and speaks `zwlr_output_manager_v1` — a protocol the compositor already implements.
- `~/.config/kanshi/config` is new and holds the profiles.
- `~/.config/niri/config.kdl` loses its `output` blocks and gains `kanshi` in its startup spawns, alongside the bar, the notification daemon and the idle manager.
- `.gitignore` gains an allowlist entry naming `~/.config/kanshi/config`. The repository is rooted at `$HOME` and denies by default, so a configuration file that is not named is not merely untracked but invisible — it does not appear in `git status` at all, and the profiles would have been left behind on the machine that wrote them.
- No change to how windows are laid out on any one screen, to which workspace they open on, or to any keybinding. The directional monitor actions already bound to `Mod+Shift+<direction>` gain a meaningful "down" at the desk, where before every screen was in one row.
