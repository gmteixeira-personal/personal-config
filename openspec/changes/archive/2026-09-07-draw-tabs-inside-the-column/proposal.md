## Why

A column in tabbed display mode carries a strip of tabs beside it naming the windows stacked inside. The compositor draws that strip outside the column, 9 logical pixels clear of it — a 4-pixel bar held off the window by a 5-pixel gap — and the column has only the 2 pixels of `gaps` to give it. The strip therefore lands in space the column does not own, and what is in that space decides whether it can be seen at all.

Against the left edge of the output there is nothing there, so the strip is drawn off-screen and the tabs are invisible: the column that most needs its tabs read — the one filling the screen or sitting at the end of the scroll — is the one that never shows them. Away from the edge the space belongs to the neighbouring column, so the strip is drawn over that window's right edge instead. That second case is quieter but it is the same fault, and it contradicts a requirement this capability already states: that the focus marker is the only thing drawn between two tiled windows beyond the gap it fills.

## What Changes

- The compositor draws the tab strip inside the column rather than outside it, so the strip is bounded by the column that owns it and is visible wherever that column sits.
- The strip stops overlapping the adjacent column, restoring the existing rule that nothing but the focus marker is drawn in the space between two tiled windows.
- The column's window gives up the width the strip and its gap occupy while the column is tabbed. This is the cost of the change and is accepted, not worked around.
- The setting is stated in the layout block of the compositor configuration with the reason recorded, in the same style as the gaps, the focus ring and the corner radius already in that block.
- No change to the strip's position, thickness, length or colour. It stays on the left, and it keeps inheriting the focus ring's stated colour rather than gaining a value of its own.

## Capabilities

### New Capabilities
<!-- None. The tab strip is a decoration the compositor draws around a window, which `window-appearance` already covers. -->

### Modified Capabilities
- `window-appearance`: adds the requirement that the tab strip is drawn within the column's own bounds, so it is visible at the edge of the output and does not intrude on the neighbouring column.

## Impact

- `.config/niri/config.kdl`, `layout` block — one added `tab-indicator` block holding one setting plus its comment.
- Interacts with the existing `gaps 2` and `focus-ring` settings in the same block, and with `Mod+W` (`toggle-column-tabbed-display`) which is what puts a column into the mode this affects. None of them changes value.
- The strip's colour is unset and stays unset: with no colour of its own the compositor paints the strip in the focus ring's colour, which this configuration already states as a palette entry. Nothing else needs to move to keep the strip on the palette.
- Takes effect on config reload; no restart of the compositor or of any client is required.
