## Context

See proposal.md — Why. The relevant state is that `.config/niri/config.kdl` carries
niri's `input` block with the pointer settings still commented out as shipped, so
`accel-profile` and `accel-speed` are at libinput's defaults for every pointing
device on the machine.

The hardware is an HP 420/425 Programmable BT Mouse and a PIXA3815 touchpad. There
is no trackpoint, despite the `trackpoint` block being present in the file.

niri exposes no runtime interface for input settings — `niri msg` can change output
configuration temporarily but has no equivalent for `input` — so the configuration
file is the only place the profile can be set.

## Goals / Non-Goals

**Goals:**

- Fix the ratio between mouse movement and cursor movement so it does not vary with
  speed.
- Keep the number of settings that affect that ratio to one, so that a pointer which
  feels wrong has one place to be corrected.

**Non-Goals:**

- Choosing a pointer speed. This change removes a variable; it does not tune what is
  left.
- Touching scroll behaviour, button mapping, or the touchpad.
- Programming the mouse's own hardware resolution.

## Decisions

### Flat profile, not adaptive with a lower speed

libinput's `adaptive` profile applies a speed-dependent multiplier; `accel-speed`
shifts that whole curve up or down. Lowering the speed therefore makes an
overshooting pointer overshoot by less, but the ratio still changes with hand speed
and the movement still cannot be learned. `accel-profile "flat"` is the only setting
that removes the dependency rather than scaling it, which is what the spec requires.

### `accel-speed` stays unset

Under the flat profile `accel-speed 0` — the default — is the unscaled 1:1 mapping,
and the mouse's own reported resolution decides how far the cursor travels. Setting a
value would add a second factor between hand and cursor for no gain while the first
one has not yet been lived with.

If the pointer does turn out to be too slow or too fast, `accel-speed` is where that
gets fixed, because the alternative is not available: the HP 420 is programmable, but
only from HP's own Windows software, and libratbag carries no driver for it, so its
hardware resolution cannot be changed from this machine.

### Set on the compositor, not on the device

Hardware resolution would be the layer that costs the compositor nothing, and
`piper`/`libratbag` is the graphical tool for it — but libratbag supports neither
device here, and hardware resolution scales speed rather than selecting a profile, so
it could not satisfy the requirement even on supported hardware. The compositor is
both the only available layer and the correct one.

### The `mouse` block only

niri configures `touchpad`, `mouse` and `trackpoint` separately and has no setting
that covers all pointers at once, so scope follows the file's own structure. The
touchpad is excluded on the merits — see the spec — and the `trackpoint` block is
left alone because no such device exists on this machine; configuring it would be
writing for hardware that is not here.

## Risks / Trade-offs

- **A hand trained on adaptive will find flat slow at first, particularly for large
  crossings of the screen.** → The correction is one uncommented line and niri
  reloads on save, so trying a value takes seconds rather than a session. The
  adaptation is also the point: the reason to accept it is that the movement being
  learned stays learned.

- **The Bluetooth mouse disconnects and reconnects.** → The setting is written
  against the `mouse` device class rather than against one device, so a reconnected
  or replaced mouse picks it up with nothing to re-apply.

- **Rollback.** → Re-comment the line. The file returns to the state this change
  found it in, and niri reloads on save.
