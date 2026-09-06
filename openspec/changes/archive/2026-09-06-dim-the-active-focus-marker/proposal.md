## Why

The focus ring's colour is the one value in niri's appearance block that was never chosen. `background-color` is Catppuccin Mocha mantle, the gap and the ring's width are both 2 with a comment saying why, the corner radius and the shadow are stated and cross-referenced — and `active-color` is still `#7fc8ff`, niri's shipped default, sitting untouched inside the block that argues for everything around it.

It reads as too bright, which is what surfaced it. That is not a coincidence: the default was picked to be legible against whatever a new user's background happens to be, and this session's background is a deliberately dark mantle. A saturated near-cyan drawn 2 logical pixels wide against `#181825` is the highest-contrast thing on the screen, and it is marking the window the user is already looking at.

The bar has already answered the same question. Its focused workspace is Catppuccin Mocha blue `#89b4fa`, with a comment saying the colour exists to name the one thing that has focus. The window ring says exactly that about a window, in a different blue, for no stated reason.

## What Changes

- The focus ring's `active-color` becomes Catppuccin Mocha blue at `cc` opacity, `#89b4facc`, replacing niri's default `#7fc8ff`. The solid entry was tried first and read as a step down that had not gone far enough; the suffix takes it the rest of the way without leaving the palette. Relative luminance runs 0.53 for the default, 0.45 solid, 0.30 as shipped; contrast against the mantle behind it 9.7:1, 8.3:1, 5.8:1. The ring dims and stays a blue line rather than becoming a grey one.
- The value gains a comment recording why it is that colour and not the default, as every other stated value in the file does, including the composited value the suffix produces and the direction to move it in.
- `inactive-color` is not touched. The focus ring draws only around the focused window, so its inactive colour is visible only on a second monitor, and no second monitor is attached.
- The `border` block is not touched. It is `off`, and its colours are the defaults that come with the disabled block.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `window-appearance`: The capability requires the focus marker's *width* to be stated rather than inherited, and requires the configuration to record why that value and not the default. It says nothing about the marker's colour, which is inherited today. It gains a requirement that the marker's colour is stated too, that it comes from the palette the session already declares, and that it is dimmer than the compositor's default against that background.

## Impact

- `.config/niri/config.kdl` — one value in the `focus-ring` block, plus its comment.
- Packages: none. Groups: none.
- Reload: niri watches its own configuration and reloads on write, so the ring changes colour without restarting the session or any client. Unlike the decoration request this capability already records a restart dependency for, nothing here is negotiated with clients at connection time.
- Reversal: restore the one hex value.
