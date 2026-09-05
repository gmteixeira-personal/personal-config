## Why

The bar is the one part of the session still wearing a stranger's clothes. waybar has no tracked configuration, so it runs `/etc/xdg/waybar/config.jsonc` and the stylesheet beside it, and that stylesheet paints nearly every module its own saturated block — white battery, green CPU, purple memory, yellow audio, blue network, grey clock — over a half-opaque slab with a grey rule under it. Every other surface this session presents has been flattened and darkened deliberately; the bar is a row of coloured tiles sitting on top of that work.

The geometry is the same complaint measured rather than described. The stock bar reserves 30 logical pixels for 13-pixel text, so roughly half the strip it takes from every window on the screen is empty.

The desktop behind it has never been decided at all. No wallpaper daemon runs and `config.kdl` names no colour, so what shows between windows is whatever niri's built-in default happens to be. That was harmless while the bar was opaque. It stops being harmless the moment the bar is transparent, because the bar's legibility then depends on a colour nothing in this repository chooses.

## What Changes

- waybar gains a tracked stylesheet at `.config/waybar/style.css`: the bar draws no background and no border, every module drops its fill, and text is white.
- State that the module backgrounds used to carry — battery critical, network disconnected, temperature critical, audio muted, tray attention, power profile, idle inhibitor active — moves to the text colour, so removing the fills does not make a dying battery look like a healthy one.
- waybar gains a tracked `.config/waybar/config.jsonc` that `include`s the system file and overrides two keys, `height` and `spacing`. The module list is still the system file's; this is a geometry patch, not a fork.
- niri declares the colour it draws behind windows in `.config/niri/config.kdl`, so the surface the transparent bar is read against is chosen rather than inherited.
- The ignore policy gains two allowlist entries so the waybar files are tracked rather than machine-local.
- The required-software documentation stops saying waybar has no tracked configuration, which the first bullet makes untrue, and the rebuild procedure adds waybar to the list of programs the checkout configures.

## Capabilities

### New Capabilities

- `bar-appearance`: What the session's bar looks like and how much of the screen it takes — that it draws no background of its own, that its modules carry no fill, that state survives the loss of those fills, and that the repository declares the bar's appearance without taking ownership of which modules it shows.

### Modified Capabilities

- `window-appearance`: The compositor's own drawing is specified for gaps, borders and decorations but not for the surface behind them, which is left at a built-in default. A transparent bar makes that surface load-bearing, so the colour drawn behind windows becomes a thing the configuration states rather than inherits.
- `desktop-session-declaration`: The requirement that the session's software is named in tracked documentation asserts, in its rationale, that the bar has no tracked configuration at all. Two tracked waybar files make that false.

## Impact

- `.config/waybar/style.css` — new, and newly tracked.
- `.config/waybar/config.jsonc` — new, and newly tracked. Two keys and an `include`.
- `.config/niri/config.kdl` — one added `background-color` in the `layout` block. Nothing else in the file is touched.
- `.gitignore` — two allowlist entries in the wayland-session block.
- `README.md` — the required-software entry for the bar, and the rebuild procedure's statement of what the checkout configures.
- `openspec/specs/window-appearance/spec.md` — one added requirement.
- `openspec/specs/desktop-session-declaration/spec.md` — rationale correction, no scenario changes.
- Packages: none installed or removed.
- Behaviour a reader should expect to change: the bar stops being a row of colours and becomes text over the desktop, and windows gain 6 logical pixels of height. Two modules on the bar render nothing and will keep rendering nothing — the five `sway/*` modules the stock config lists cannot start under niri, and `power-profiles-daemon` is not running on this machine. Neither is caused by this change and neither is fixed by it.
