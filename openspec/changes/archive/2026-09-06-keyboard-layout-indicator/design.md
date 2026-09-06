## Context

See `proposal.md` — Why. Measured on this machine:

- waybar 0.15.0 carries `niri/language` as a built-in module, next to the
  `niri/workspaces` and `niri/window` already in `modules-left`.
- `man 5 waybar-niri-language` gives `{short}` ("us"), `{shortDescription}`
  ("en"), `{long}` ("English (Dvorak)") and `{variant}`, plus `format-<lang>`
  for per-language overrides.
- The module is addressed as `#language` and **additionally carries a CSS class
  matching the active layout's short name**, which the man page demonstrates as
  `#language.us { color: … }`.
- No notification daemon is running — no mako, dunst or swaync — though
  `notify-send` is present.
- `niri msg keyboard-layouts` reports the layouts as `EurKEY (US)` and
  `Portuguese`, which are the `{long}` forms.

## Goals / Non-Goals

**Goals:**

- The layout is readable without asking for it, and a change is noticeable
  without reading.

**Non-Goals:**

- A history or a switcher. The bar reports; `Mod+Alt+Space` switches.

## Decisions

### The built-in module, not a custom one over `niri msg event-stream`

The general escape hatch would be a `custom/` module tailing the event stream and
printing on `KeyboardLayoutSwitched`. It is the right answer when no built-in
module exists; one does, so that would be a long-running script, a pipe and a
restart story bought for a result waybar already produces.

### `{short}`, not `{long}`

`{long}` is what the compositor reports — "EurKEY (US)", "Portuguese" — and is
wide enough to push the window title along every time the layout changes. It is
also not the name the tracked configuration uses: `.config/niri/config.kdl` says
`layout "eu,pt"`, and the bar saying `eu` means the two can be read as the same
thing without translation.

`{shortDescription}` was the other candidate and is worse here: it is a language
code rather than a layout name, so EurKEY would surface as something like `en`,
which is neither what the config says nor distinguishable from a plain US
layout.

### Colour by the module's own layout class

`bar-appearance` requires state to be carried by text colour rather than a fill,
and the module supplies exactly the hook for it: a CSS class named for the
active layout's short name. So `#language.eu` and `#language.pt` take different
colours, and the layout is legible from the colour before the two letters are
read.

The label is `{short}` regardless, so if the class names ever fail to match what
is expected the module degrades to both layouts sharing the resting colour —
the reading stays correct and only the glanceability is lost. That is why the
text carries the name rather than the colour carrying it alone.

### Between workspaces and the window title

The left group is what you are looking at; the right group is how the machine is
set, which is where this would otherwise belong. It goes left anyway, and second,
because the window title is variable-width and grows: anything after it moves
whenever the focused window changes, and an indicator that moves is one the eye
has to find again. Second position pins it against the workspaces, which are
fixed width.

### Reloaded with a signal, not through systemd

`pkill -SIGUSR2 waybar`, which `.config/waybar/style.css` already documents at
its head. The bar is spawned by the compositor, so `systemctl --user start` adds
a second one beside it rather than replacing it.

## Risks / Trade-offs

- **The CSS class does not match `eu`/`pt`** → Both layouts render in the
  resting colour; the label still names the layout correctly. Corrected by
  reading the class off the running bar and adjusting one selector.
- **A third layout is added and has no colour** → It falls back to the resting
  colour and is still named. Adding a colour is one selector.
- **The module widens the left group by three characters** → It is fixed width
  in practice, both layout names being two letters, so nothing after it moves.
