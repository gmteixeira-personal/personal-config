## Why

Zooming a pane to fill its tab is one of the most frequently used herdr actions in these sessions, and its only key is `prefix+z`. On the keyboard in use, `z` sits under the left hand while the prefix `ctrl+f` is also a left-hand chord, so the pair is an awkward same-hand roll. `\` is reached by the right hand and is free, which makes the zoom toggle a two-hand motion like every other prefixed action that gets used at this rate.

## What Changes

- Add a `prefix+\` binding that toggles zoom on the focused pane, doing exactly what `prefix+z` does.
- Keep `prefix+z` bound as it is today. This change adds a second key for one action; it does not move or retire the first.
- Because herdr's `[keys]` table accepts a single key per built-in action, the second key is declared as a `[[keys.command]]` shell binding that calls herdr's own `pane zoom --toggle` on the focused pane, rather than as a second `[keys]` entry.
- No change to the prefix key, the theme, or any other herdr preference.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities
- `herdr-config`: the tracked herdr configuration gains a requirement that zoom is reachable from `prefix+\` as well as from its built-in key, alongside the existing requirement fixing the prefix itself.

## Impact

- `.config/herdr/config.toml` — one new `[[keys.command]]` block.
- Depends on the `herdr` binary being on `PATH` at the moment the key is pressed; herdr supplies `HERDR_BIN_PATH` and `HERDR_ACTIVE_PANE_ID` to the command, so neither is assumed.
- Applied with `herdr server reload-config`; open sessions survive.
- Touches the same tracked file as the open `add-herdr-equalize-panes` change, which adds its own `[[keys.command]]` blocks. The two are independent — different keys, different actions — and whichever lands second simply appends another block.
- Behavioural side effect to accept: a shell-backed binding round-trips through the socket API, so the toggle is marginally slower than the built-in key. It is not perceptible at human speed, and `prefix+z` remains the direct path.
