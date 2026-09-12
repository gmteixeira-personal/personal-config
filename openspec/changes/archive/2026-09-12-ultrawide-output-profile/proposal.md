## Why

The desk now has a second docked arrangement: a single LG ultrawide standing directly above the laptop. The connected set is the ultrawide plus the laptop, which matches neither of the two declared arrangements, so the session falls through to the compositor's automatic placement — the ultrawide lands to the right of the laptop instead of above it, and the laptop keeps a scale chosen for a set it is not in. The ultrawide also advertises two of its modes as preferred, so the automatic choice can settle on 99.997 Hz on a 160 Hz panel.

## What Changes

- Declare a third arrangement for the ultrawide-plus-laptop set: the ultrawide along the top, the laptop centred horizontally beneath it, matching where the two screens physically sit.
- Keep the laptop at its own unenlarged scale in this arrangement. The existing enlargement was justified by the laptop sitting lower *and further away* than screens across the desk; under an ultrawide standing immediately above it, only the first half holds, so the panel reads comfortably at the scale it uses alone.
- Generalise the laptop-scale requirement accordingly. It currently reads as docked-versus-alone, which no longer describes the set of arrangements: enlargement follows viewing distance, not the mere presence of an external.
- Pin the ultrawide's mode. A screen that advertises more than one mode as preferred SHALL have its mode stated explicitly, so the refresh rate is chosen rather than inherited.

## Capabilities

### New Capabilities

None. The behaviour belongs to the existing output-layout capability.

### Modified Capabilities

- `output-layout`: adds a requirement for the ultrawide arrangement; reframes the laptop-scale requirement from docked-versus-alone to per-arrangement, driven by viewing distance; adds a requirement that a screen advertising several preferred modes has its mode declared.

## Impact

- `~/.config/kanshi/config` — one new profile; no change to the existing `docked` or `mobile` profiles.
- `~/.config/niri/config.kdl` — no functional change. Its note on where geometry lives cites "the laptop plus a single external" as an example of an undeclared set, which one such set no longer is; the example needs replacing.
- No change to the compositor, the bar, or any startup wiring. The bar has no per-output targeting and follows the new geometry on its own.
- The three-and-the-ultrawide set (all four screens) remains undeclared and stays on automatic placement.
