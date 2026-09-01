## Why

Zoom is already reachable from two keys — herdr's shipped `prefix+z` and the `prefix+\` alias added earlier — but neither sits on the home row. `f` is the left index finger's resting key, the cheapest key on the board to hit, and it is currently unbound in the tracked herdr configuration. Since the prefix moved from `ctrl+f` to `ctrl+space`, `f` is also no longer implicated in the prefix chord, so a `prefix+f` zoom is a two-hand motion with no same-hand roll.

## What Changes

- Add a `prefix+f` binding that toggles zoom on the focused pane, doing exactly what `prefix+z` and `prefix+\` do.
- Keep both existing zoom keys bound as they are. This change adds a third key for one action; it retires nothing.
- Because herdr's `[keys]` table accepts a single key per built-in action, the new key is declared as a `[[keys.command]]` shell binding calling `herdr pane zoom --toggle` on the focused pane — the same mechanism the `prefix+\` alias already uses.
- No change to the prefix key, the theme, or any other herdr preference.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `herdr-config`: the existing "Zoom is reachable from prefix+backslash" requirement is widened so zoom is reachable from `prefix+f` as well, and the requirement that the built-in zoom key keeps working is extended to cover all three keys toggling one shared state.

## Impact

- `.config/herdr/config.toml` — one new `[[keys.command]]` block, alongside the `prefix+\` block it mirrors.
- Depends on the `herdr` binary being on `PATH` when the key is pressed; herdr supplies `HERDR_BIN_PATH` and `HERDR_ACTIVE_PANE_ID` to the command, so neither is assumed.
- Applied with `herdr server reload-config`; open sessions survive.
- `f` is unbound in the tracked configuration today. If herdr 0.8.2 ships a built-in action on `prefix+f`, the custom binding displaces it — `herdr config check` after the edit is the check for that.
- Behavioural side effect to accept: a shell-backed binding round-trips through the socket API, so this toggle is marginally slower than the built-in key. Not perceptible at human speed, and `prefix+z` remains the direct path.
