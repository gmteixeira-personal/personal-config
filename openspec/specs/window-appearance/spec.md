# window-appearance Specification

## Purpose

Defines how much space the session leaves between tiled windows and which decorations they carry, splitting what the compositor decides from what each client decides, so that the parts of a window's appearance that cannot be set from one place are at least written down in one.

## Requirements

### Requirement: The gap between tiled windows is the width of the focus marker

The compositor SHALL leave a gap between adjacent tiled windows equal to the width of the focus marker, and the two values SHALL be changed together.

The gap was previously required to be zero, on the reasoning that a gap is a floating-desktop affordance separating windows whose edges would otherwise be ambiguous, and that a tiling layout decides every edge. That argument rules out a gap wide enough to read as empty space; it does not reach zero. The marker is drawn outward from the focused window into the gap, so a gap narrower than the marker leaves the marker no space of its own, and a gap wider leaves it floating inside a band of desktop. At an equal value the marker fills exactly the gap belonging to the window it marks, and the seam between two windows is one constant size whichever of them has focus.

Both values are converted from logical to physical pixels by the same rule, so setting them equal keeps them aligned on a fractionally scaled output, where neither lands on a whole physical pixel on its own.

#### Scenario: Two tiled windows are adjacent

- **WHEN** two windows are tiled side by side
- **THEN** the space between them SHALL be the width of the focus marker

#### Scenario: The two values move together

- **WHEN** the focus marker's width is changed
- **THEN** the gap SHALL be changed to the same value
- **AND** the configuration SHALL record that each depends on the other

### Requirement: A focus indicator survives the removal of borders

Where window borders are off, the session SHALL still mark which window has focus, and that marker SHALL be the only thing drawn between windows beyond the gap it fills.

Removing borders and the focus indicator together leaves adjacent windows with nothing to say which one receives input.

The marker's width SHALL be stated by the compositor configuration rather than inherited from the compositor's own default, and SHALL be narrow enough that the marker reads as a division between two windows rather than as a surface of its own.

The width was previously fixed at the compositor's default, on the reasoning that at zero gaps the marker is no longer competing with a gap for attention. That decides the width from what the marker is competing with, which is not what the width does. The marker is the entire seam between two tiled windows — only the focused window carries one, so the stated width is the whole seam rather than half of it — and the question the width answers is how wide that seam should be. The compositor's default answers it at the size of a band.

Where the configuration states the width, it SHALL record why that value and not the default, for the same reason every other value this session sets in that file records its own: the default is what a reader will otherwise assume was never considered.

#### Scenario: The focused window is identifiable

- **WHEN** several windows are tiled with borders off
- **THEN** the focused window SHALL be visually distinguishable from the others

#### Scenario: The marker's width is stated rather than inherited

- **WHEN** the compositor configuration is inspected for the focus marker
- **THEN** it SHALL state the marker's width
- **AND** that width SHALL be narrower than the compositor's own default

#### Scenario: The marker is the whole space between two windows

- **WHEN** two tiled windows are adjacent and one of them is focused
- **THEN** the only coloured space between them SHALL be the focused window's marker

### Requirement: The focus marker's colour is stated, and comes from the session's palette

The compositor configuration SHALL state the colour of the focus marker on the active monitor rather than inherit the compositor's default, and that colour SHALL be a value from the palette the session already declares elsewhere.

The width of the marker is already required to be stated, on the reasoning that a value never written down is one a reader assumes was never chosen, and one a compositor update is free to change. The colour is the same value in a different unit and the same argument reaches it. It was left inherited when the width was decided, and named at the time as the obvious next thing to bring into the palette.

Palette membership is what makes the colour checkable. The session restates one palette by hand across several configuration files, none of which can share a definition with another, and a value belonging to no palette cannot have its origin recorded. The colour behind windows, declared in the same file, is already a member; the marker drawn in front of them is the remaining value in that block that is not.

The colour MAY be a palette entry carried at a stated opacity rather than at full strength. The entry stays named and checkable that way, and the marker can be moved without leaving the palette for a value mixed by hand — which the palette makes necessary, because below its blue the entries are greys. Where an opacity is used, the configuration SHALL record the value the marker composites to over the declared background, because the stated value is then no longer the value on screen and a reader cannot check it against the session's other copies of the palette without that arithmetic.

Where the configuration states the colour, it SHALL record which palette entry it is and why that entry rather than the compositor's default, for the same reason the width and the corner radius record theirs.

#### Scenario: The colour is stated rather than inherited

- **WHEN** the compositor configuration is inspected for the focus marker
- **THEN** it SHALL state the marker's colour on the active monitor
- **AND** that colour SHALL NOT be the compositor's own default

#### Scenario: The colour is checkable against the rest of the session

- **WHEN** the stated colour is compared with the palette the session's other surfaces declare
- **THEN** it SHALL be an entry of that palette, at full strength or at a stated opacity
- **AND** the configuration SHALL name the entry and the palette

#### Scenario: The colour is stated at an opacity

- **WHEN** the marker's colour is a palette entry carried at less than full opacity
- **THEN** the configuration SHALL record the value it composites to over the declared background

### Requirement: The focus marker is dimmer than the compositor's default against the declared background

The stated colour of the focus marker SHALL be less luminous than the compositor's default, measured against the colour this configuration declares for the surface behind windows.

The default is chosen to be legible against an unknown background. This session declares its background, and declares a dark one, so the default is brighter than the job needs: the marker is drawn as a thin line against a near-black ground, and at the default it is the most luminous thing on the display while marking the window the user is already looking at.

Dimmer is a floor, not a licence to make the marker unreadable. The marker remains the only indication of which window takes input — no border is drawn — so it SHALL stay distinguishable at a glance from the surface behind windows and from an unfocused window's edge, and it SHALL keep a hue rather than fall back to a grey, because hue is what separates the marker from the shadow already drawn around every window.

#### Scenario: The marker is dimmer than the default

- **WHEN** the stated colour and the compositor's default are each compared against the declared background colour
- **THEN** the stated colour SHALL be the less luminous of the two

#### Scenario: The marker still names the focused window

- **WHEN** several windows are tiled and one is focused
- **THEN** the marker SHALL remain identifiable at a glance against the declared background
- **AND** it SHALL be a colour rather than a grey

### Requirement: Clients are asked to omit their own decorations

The compositor SHALL ask clients to omit client-side decorations, and a client this configuration tracks settings for SHALL be configured to prefer no decoration.

Both halves are needed and neither is binding. The compositor's request is a hint a client may refuse, and a client's preference is a hint the compositor may override. Setting only one leaves the outcome to whichever default happens to win.

#### Scenario: The compositor makes the request

- **WHEN** the compositor configuration is inspected
- **THEN** it SHALL ask clients to omit client-side decorations

#### Scenario: A tracked client states its preference

- **WHEN** the configuration of a client this repository tracks settings for is inspected
- **THEN** it SHALL state a preference for no decoration

#### Scenario: A client that refuses

- **WHEN** a client draws its own decorations regardless of the request
- **THEN** that SHALL be understood as the client's decision
- **AND** the configuration SHALL NOT be treated as broken on account of it

### Requirement: The decoration setting's restart dependency is recorded

Documentation SHALL record that the decoration request reaches clients through a Wayland global the compositor offers when it starts, and therefore that both the compositor and any client holding a long-lived connection must be restarted before a change takes effect.

Nothing reports this. The configuration reloads and validates, the option is plainly present, and decorations keep being drawn — the only evidence is a line in the client's log saying no decoration manager is available. A terminal run as a server is the sharpest case: it holds one connection for every window it opens, so windows opened long after the change still inherit the connection's original view.

#### Scenario: A reader learns why the setting appears inert

- **WHEN** the documentation for the decoration setting is read
- **THEN** it SHALL state that the compositor must be restarted for the change to reach clients
- **AND** it SHALL state that a client holding a long-lived connection must also be restarted

#### Scenario: The failure is silent

- **WHEN** the decoration setting is changed and nothing is restarted
- **THEN** the configuration SHALL still validate
- **AND** decorations SHALL continue to be drawn with no error reported by the compositor

### Requirement: The surface behind windows has a declared colour

The compositor SHALL be configured with the colour it draws where no window is present, rather than relying on its built-in default.

Every other part of this capability decides what the compositor draws around windows; the colour behind them was the one part left to whatever the compositor shipped. That was invisible while nothing depended on it. It stops being invisible once a transparent bar is read against it, because an undeclared colour is one that can change under a compositor update and take the bar's legibility with it. Declaring it also means the value is stated in the same file as the gaps and the borders, where a reader looking for what the session draws will already be.

#### Scenario: The colour is stated in the configuration

- **WHEN** the compositor configuration is inspected
- **THEN** it SHALL declare the colour drawn behind windows

#### Scenario: An empty workspace shows the declared colour

- **WHEN** a workspace with no windows is displayed
- **THEN** the colour shown SHALL be the one the configuration declares

### Requirement: Windows are drawn with rounded corners

The compositor SHALL draw windows with a stated corner radius, and SHALL clip each window's own content to that radius.

The radius alone rounds what the compositor draws around a window. A client painting to its full rectangle still fills the corner it was given, so without clipping the result is a rounded frame with a square window inside it — visible wherever a window's own background differs from the surface behind it.

The radius SHALL be stated in the configuration rather than left to the compositor's default, for the same reason the focus marker's width is: a value that is never written down is one a reader assumes was never chosen, and one a compositor update is free to change.

#### Scenario: A tiled window's corners

- **WHEN** a window is displayed
- **THEN** its corners SHALL be rounded to the stated radius

#### Scenario: The client's own painting is clipped

- **WHEN** a window paints a background colour of its own to its full rectangle
- **THEN** the corner SHALL still be rounded
- **AND** no square edge of the client's background SHALL appear inside it

#### Scenario: The radius is stated

- **WHEN** the compositor configuration is inspected for the corner radius
- **THEN** it SHALL state a value

### Requirement: Windows cast a shadow, and the shadow follows the stated corners

The compositor SHALL draw a shadow around windows. The shadow SHALL follow the corner radius the configuration states rather than the window's bounding rectangle.

The compositor has no way to learn the corner radius of a window that rounds its own corners; absent a stated radius it must assume the window is square, and the shadow it draws then cuts across the inside of every rounded corner. There is a setting that hides those artifacts by drawing the shadow behind the window instead of around it, and it is the wrong fix here: stating the radius removes the cause, and the setting exists for the case where the radius cannot be known.

The two settings therefore depend on each other and SHALL be read together. Turning the shadow on while the radius is unstated produces artifacts; removing the radius later, with the shadow still on, reintroduces them.

#### Scenario: A window has a shadow

- **WHEN** a window is displayed above the surface behind it
- **THEN** a shadow SHALL be drawn around it

#### Scenario: The shadow respects the corner

- **WHEN** a window with rounded corners casts a shadow
- **THEN** the shadow SHALL follow the rounded corner
- **AND** no shadow SHALL be drawn inside the window's rounded corner

#### Scenario: The dependency is recorded

- **WHEN** the compositor configuration is read around the shadow settings
- **THEN** it SHALL record that the shadow's correctness depends on the stated corner radius

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

The inherited colours are the focus marker's whole set, not only the one it draws with. The marker's colour for an inactive monitor is presently the compositor's default and off the palette, on the recorded reasoning that one output is attached and therefore nothing renders it; a strip of tabs renders it, because every tab but one is inactive. Placing the strip within the column made that value visible for the first time. Bringing it onto the palette is a separate decision about a value that is now judgeable rather than chosen sight unseen, and this capability does not decide it — but the configuration SHALL NOT state that nothing renders it.

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
