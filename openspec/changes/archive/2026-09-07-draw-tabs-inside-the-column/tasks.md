## 1. Compositor configuration

- [x] 1.1 Add a `tab-indicator` block holding only `place-within-column` to the `layout` block of `.config/niri/config.kdl`, between `shadow` and `struts`, and verify `niri validate` reports the config as valid
- [x] 1.2 Write the comment above the setting recording that the compositor's default draws the strip outside the column where the session's 2-pixel gap cannot hold it, that the strip is therefore lost off-screen at the edge of the output and painted over the neighbouring column elsewhere, and that the column's window pays for the fix in width — verify by reading the block back and checking it answers why the setting is set without the reader needing the change history
- [x] 1.3 Record in the same comment that no colour is stated for the strip on purpose, because an unset strip inherits the `focus-ring` colours directly above and stating one would put `#89b4facc` in the file twice — verify a reader cannot mistake the absent colour for an oversight
- [x] 1.4 Record in the same comment that `width` and `gap` stay at the compositor's defaults of 4 and 5, that together they are what the window gives up while the column is tabbed, and that they are the dials if that proves too much — verify the numbers in the comment match the compositor's defaults on the installed version

## 2. The comment this change falsifies

- [x] 2.1 Correct the note on `focus-ring { inactive-color "#505050" }` in the same file, which states that only a second monitor could render that colour and that nobody has looked at it — every inactive tab now renders it. Verify the note no longer claims the value is unrendered and points at the tab strip as what renders it
- [x] 2.2 Verify the corrected note still records that the value is off the palette and undecided, so the open question survives the correction rather than being closed by it

## 3. Verification

- [ ] 3.1 Reload the config, put a column into tabbed display mode with `Mod+W`, move it against the left edge of the output, and verify its tabs are visible on screen
- [ ] 3.2 Place a tabbed column with another column to its left and verify no part of the strip is drawn over the neighbouring window, and that the only coloured space between the two columns is the focus ring of whichever has focus
- [x] 3.3 Verify the tabbed column's outer bounds are unchanged and the window inside it is narrower, by comparing the same column tabbed and untabbed
- [ ] 3.4 Verify with more than one window in the column that the active tab is drawn in the focus ring's active colour and the inactive tabs in its inactive colour, and record whether the resulting grey is acceptable for the follow-up decision the design defers
