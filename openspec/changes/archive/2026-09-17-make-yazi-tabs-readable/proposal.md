## Why

The `file-manager` capability already requires that yazi's status bar state its own foregrounds, that its text be readable against the background it sits on, and that any colour chosen here be a 24-bit literal rather than one of foot's palette slots. The tab bar was never covered, and it ships with the same fault, key for key:

```
[tabs]
active   = { bg = "blue", bold = true }          # no fg -- foot's #aaaaaa on #24acd4, 1.14:1
inactive = { fg = "blue", bg = "gray" }          # #24acd4 on #e6e6e6, 2.12:1
```

Those are the same two values, and the same two ratios, that `[mode]`'s `normal_main` and `normal_alt` shipped with before the status bar was fixed. Fixing the status bar and not the tab bar left the window with a readable bottom and an unreadable top, which is how it was reported: the tab labels are hard to read.

Fixing the tab bar also settles a question the status bar left open. `normal_main` was set to white, measured at 2.65:1, and recorded as knowingly below the 4.5:1 threshold — with the note that `#11111b` over the same blue reaches 7.08:1 and is the value to use if white read thin. It does. Copying white into the tab bar would have spread a below-threshold value to two more elements rather than one, so the dark value is taken instead, and taken in all three places at once.

## What Changes

- `.config/yazi/theme.toml` gains a `[tabs]` section setting `active = { fg = "#11111b", bg = "blue", bold = true }` and `inactive = { fg = "blue", bg = "#313244" }`. These are `[mode]`'s two values restated, so the tab bar and the status bar are coloured alike: 7.08:1 and 4.75:1, both over the threshold.
- `[mode] normal_main` and `[status] progress_label` change from `fg = "#ffffff"` to `fg = "#11111b"`. Both sit on the same blue, so both move from 2.65:1 to 7.08:1. This is the swap the file already named as the better number; it is made now because leaving it would have split the tab bar from the status bar the moment the tabs were fixed.
- The comments recording why each value was chosen are rewritten to match. The file no longer carries a value marked as below the threshold, because it no longer has one.
- `sep_inner` and `sep_outer`, the rounded caps around each tab, are left shipped. yazi derives them from the tab styles, so they follow without being named.
- `bg = "blue"` stays a slot name in the new `[tabs] active`, for the reason already recorded for `[mode]`: it is the colour on screen, the change is not about it, and naming a literal would mean picking a blue nobody decided on.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `file-manager`: the capability's legibility requirements are written about the status bar and stop there, and one of them explicitly tolerates a chosen colour below 4.5:1 as long as the ratio is recorded. Both change. "The file manager's status bar states its own foregrounds" is widened to every coloured element of the chrome, the tab bar included. "Status bar text is readable against the background it is drawn on" is replaced outright rather than edited, because it loses a scenario: the tolerance for a below-threshold value goes with it, now that no value in the file needs it. A requirement is added that the tab bar and the status bar are coloured from the same values rather than independently.

## Impact

- `.config/yazi/theme.toml` — one added section, two changed foregrounds, rewritten comments. Already tracked.
- No change to `.config/yazi/init.lua`, `keymap.toml`, the unselected Catppuccin Mocha flavor under `flavors/`, or `.config/foot/foot.ini`. foot's sixteen palette slots stay at foot's defaults, as that file records.
- Running yazi windows do not pick this up. The theme is read at startup, so every open window has to be restarted.
- The row under the cursor is untouched, as the capability already requires: at 7.08:1 it is unchanged, and it now measures the same as the badges and the active tab rather than better than them.
