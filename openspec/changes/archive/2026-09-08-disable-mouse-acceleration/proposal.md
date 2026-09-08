## Why

The mouse runs libinput's default `adaptive` pointer acceleration profile, which
varies the ratio between hand movement and cursor movement according to how fast
the hand is moving. The same physical distance therefore lands the cursor
somewhere different depending on the speed it was crossed at, so no hand movement
can be learned as corresponding to a screen distance. Aiming becomes a correction
loop — overshoot, come back — rather than a single movement.

The profile is at that default by inheritance rather than by decision: niri ships
its `input` block with every libinput setting commented out, and this
configuration has never uncommented the pointer ones. Nothing has yet said what
this machine's pointer should do.

## What Changes

- Set `accel-profile "flat"` in the `mouse` block of `.config/niri/config.kdl`,
  making the cursor-to-hand ratio constant at every speed.
- Leave `accel-speed` at its default of 0. Under the flat profile that is the
  unscaled 1:1 ratio, and the mouse's own hardware resolution then decides how
  far the cursor travels.
- Leave the `touchpad` block on the adaptive profile. A touchpad is a small
  surface that has to reach a whole screen, which is the case adaptive exists
  for; the argument for flat does not carry across to it.
- Leave the `trackpoint` block untouched. This machine has no trackpoint.

## Capabilities

### New Capabilities

- `pointer-acceleration`: how the session translates physical movement of a
  pointing device into cursor movement — which acceleration profile each class of
  device uses, and why the answer differs between a mouse and a touchpad.

### Modified Capabilities

<!-- None. No existing spec covers pointer behaviour. -->

## Impact

- `.config/niri/config.kdl`, the `mouse` block inside `input`.
- No new package, daemon, or privileged process. The setting is niri's own, and
  niri applies it on save without a restart or a re-login.
- The touchpad, the keyboard and the scroll behaviour of every device are
  untouched.
