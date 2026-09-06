## ADDED Requirements

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
