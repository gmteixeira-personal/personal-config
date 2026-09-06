## Why

`Mod+Alt+Space` switches between the two configured layouts, `eu` and `pt`. It
is the launcher's `Mod+Space` with one modifier added, and the `keyboard-mapping`
design accepted that cost knowingly: a slipped Alt on the way to the launcher
changes the keyboard layout instead of opening it, and nothing announces it. The
first sign is a character coming out wrong.

Recovery is the same chord again, but only once you have worked out what
happened. `niri msg keyboard-layouts` answers the question and is a command, not
an indicator — it requires already suspecting the layout.

The bar is where the session's state is read passively. A layout indicator is
exactly the second kind of module `bar-appearance` admits: not one acted on from
the bar, but one whose change has to be noticed without looking for it.

## What Changes

- `.config/waybar/config.jsonc` names `niri/language` in `modules-left`, between
  `niri/workspaces` and `niri/window`.
- The module is formatted to `{short}`, so it reads `eu` or `pt` — the same
  names the `xkb` block uses, rather than niri's longer "EurKEY (US)" and
  "Portuguese".
- `.config/waybar/style.css` gives it the module treatment the rest of the bar
  has, no fill, and colours it per layout using the CSS class the module adds
  for the active layout's short name.

No new package: `niri/language` is built into waybar 0.15.0, alongside the
`niri/workspaces` and `niri/window` already in use.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `bar-appearance`: gains a requirement that the active keyboard layout is shown
  on the bar. The existing requirements about naming the module list and about
  state surviving the removal of the fills both already constrain how, and are
  unchanged.

## Impact

- `.config/waybar/config.jsonc` — one entry in `modules-left`, one options block.
- `.config/waybar/style.css` — the module added to the shared no-fill rule, plus
  a per-layout colour.
- The bar is reloaded with `pkill -SIGUSR2 waybar`, which the stylesheet already
  documents at its head. Starting it through systemd instead would leave a
  second bar running alongside the one the compositor spawned.

## Non-Goals

A transient notification on switch. `notify-send` is present but no notification
daemon is running — not mako, dunst or swaync — so this would mean installing
one for a single toast. It would also report only at the moment of switching,
which is the moment least in need of it: the case that hurts is returning to a
machine already in the wrong layout.
