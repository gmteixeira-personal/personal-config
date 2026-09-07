## ADDED Requirements

### Requirement: The tab strip is drawn inside the column it belongs to

Where a column is in tabbed display mode, the compositor SHALL draw the strip of tabs naming that column's windows inside the column's own bounds, and SHALL count the strip as part of the column when sizing it.

Drawn outside, the strip is placed in space the column does not own, and what happens to it is then decided by whatever else is in that space rather than by the strip. Against the edge of the output that space is off-screen, so the tabs cannot be read at all — and the column pressed against the edge is the one whose tabs are most worth reading, because it is either filling the output or sitting at the end of the scroll where the strip is the only thing saying how many windows are stacked in it. Away from the edge the space belongs to the next column along, so the strip is drawn over that window instead. A decoration that names one column has no business painting on another, and this capability already requires that nothing but the focus marker is drawn between two tiled windows beyond the gap it fills.

The gap the session leaves between tiled windows is narrower than the strip and its own offset together, so no gap width that this capability would accept can hold the strip. Widening the gap to fit is therefore not an alternative: it would decide the seam between every pair of windows in the session from the needs of a mode most columns are not in.

Drawing the strip inside makes the column's window narrower by the space the strip occupies, for as long as that column is tabbed. That is the price of the strip being visible and SHALL be accepted rather than avoided by drawing outside again.

#### Scenario: A tabbed column against the edge of the output

- **WHEN** a column in tabbed display mode is placed against the edge of the output
- **THEN** its tabs SHALL be visible on screen
- **AND** no part of the strip SHALL be drawn beyond the edge of the output

#### Scenario: A tabbed column beside another column

- **WHEN** a column in tabbed display mode has another column next to it on the side the strip is drawn
- **THEN** no part of the strip SHALL be drawn over the neighbouring column's window
- **AND** the only coloured space between the two columns SHALL remain the focus marker of whichever of them has focus

#### Scenario: The window pays for the strip

- **WHEN** a column enters tabbed display mode
- **THEN** the window in that column SHALL be narrowed by the space the strip occupies
- **AND** the column's outer size SHALL be unchanged by the strip

### Requirement: The tab strip's placement is stated, and its colour is left to follow the focus marker

The compositor configuration SHALL state that the strip is placed within the column rather than accept the compositor's default of placing it outside, and SHALL record why.

The default places the strip outside, so the behaviour the requirement above describes exists only while the configuration asks for it. This is the same reason every other value the layout block sets carries its own note: an unexplained setting cannot be told apart from one copied out of an example file, and an unstated one is assumed never to have been considered.

The configuration SHALL NOT state a colour for the strip. A strip with no colour of its own is painted by the compositor in the focus marker's colours, which this capability already requires to be a stated palette entry — so leaving it unset is what keeps the strip on the palette, and stating it would create a second copy of the same value to keep in step by hand. Where the configuration records the placement, it SHALL record this too, so that a reader does not read the absent colour as an oversight.

The inherited colours are the focus marker's whole set, not only the one it draws with. The marker's colour for an inactive monitor is presently the compositor's default and off the palette, on the recorded reasoning that one output is attached and therefore nothing renders it; a strip of tabs renders it, because every tab but one is inactive. This change makes that value visible for the first time. Bringing it onto the palette is a separate decision about a value that is now judgeable rather than sight unseen, and this capability does not decide it here — but the configuration SHALL stop claiming that nothing renders it.

#### Scenario: The placement is stated

- **WHEN** the compositor configuration's layout settings are inspected for the tab strip
- **THEN** they SHALL state that the strip is placed within the column

#### Scenario: The reason is recorded

- **WHEN** the configuration is read around that setting
- **THEN** it SHALL record why the session sets it rather than accepting the default
- **AND** it SHALL record that the strip's colour is deliberately left unstated so that it follows the focus marker

#### Scenario: The strip matches the focus marker

- **WHEN** a tabbed column has focus and its strip is compared with the focus marker
- **THEN** the strip's active tab SHALL be drawn in the colour the configuration states for the focus marker
- **AND** the configuration SHALL NOT state that colour a second time for the strip

#### Scenario: The inactive tabs render a colour previously unseen

- **WHEN** a tabbed column holds more than one window
- **THEN** its inactive tabs SHALL be drawn in the focus marker's inactive colour
- **AND** the note recording that colour SHALL NOT state that nothing renders it
