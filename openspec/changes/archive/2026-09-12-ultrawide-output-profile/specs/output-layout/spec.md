## RENAMED Requirements

- FROM: `### Requirement: The laptop renders larger while docked than alone`
- TO: `### Requirement: The laptop's scale follows its viewing distance in each arrangement`

## ADDED Requirements

### Requirement: The ultrawide desk centres the laptop below the ultrawide

Where a single ultrawide screen and the laptop are the connected set, the session SHALL place the ultrawide along the top and the laptop centred horizontally beneath it.

This is where the two screens physically are: the ultrawide stands on a riser directly above the laptop, not beside it. The compositor's automatic row places the laptop to the ultrawide's left, so the pointer leaves the laptop sideways to reach a screen that is above it, and the downward monitor action has no target.

The horizontal offset that centres the laptop is a function of its logical width, which its scale determines, so the same coupling the three-screen arrangement is subject to applies here: a change to this arrangement's laptop scale SHALL be accompanied by the corresponding change to its position.

#### Scenario: Pointer crosses down into the laptop

- **WHEN** the pointer is moved downwards from a point on the ultrawide that lies within the laptop's horizontal span
- **THEN** the pointer SHALL enter the laptop screen

#### Scenario: Pointer outside the laptop's span

- **WHEN** the pointer is moved downwards from a point on the ultrawide that lies outside the laptop's horizontal span
- **THEN** the pointer SHALL remain on the ultrawide

#### Scenario: The ultrawide is attached

- **WHEN** the ultrawide is connected while the laptop is the only other connected screen
- **THEN** the ultrawide SHALL be positioned above the laptop
- **AND** the laptop SHALL be centred horizontally beneath it

### Requirement: A screen advertising more than one preferred mode has its mode declared

Where a connected screen advertises several of its modes as preferred, the arrangement SHALL state that screen's mode explicitly rather than leave the choice to the compositor.

A single preferred mode is the panel telling the session which mode to use, and inheriting it is right. Several preferred modes is the panel declining to answer, and what the session then inherits is whichever of them is found first — a refresh rate picked by enumeration order. The ultrawide advertises two, only one of which is its full rate, so the arrangement that omits the mode silently runs the panel slow.

Only screens that are actually ambiguous need a declared mode; stating a mode for a screen that already names one preference duplicates the panel's own answer and has to be revisited whenever the panel is replaced.

#### Scenario: A screen names several preferred modes

- **WHEN** the arrangement for a set containing such a screen is applied
- **THEN** that screen SHALL run at the mode the arrangement states

## MODIFIED Requirements

### Requirement: The laptop's scale follows its viewing distance in each arrangement

The laptop panel SHALL render at the scale that suits its viewing distance in the arrangement being applied, and each arrangement SHALL state that scale.

The panel's own comfortable scale is the one for a user sitting directly in front of it. Where an arrangement puts the laptop lower than the screens it is under *and* further away, as the two externals across the desk do, content sized for that scale is too small to read and the panel SHALL be enlarged by a fifth. Where an arrangement puts a screen directly above the laptop, the laptop stays at the distance the user is already sitting at, and enlarging it only wastes a panel that reads perfectly well — so the ultrawide arrangement keeps the unenlarged scale.

The distinction is viewing distance, not the presence of an external screen. Two arrangements can both be docked and want different laptop scales, which is why the scale belongs to the arrangement rather than to the docked state.

Every scale used SHALL divide the panel's pixel width without remainder, because a scale that does not leaves a fractional logical width that the compositor rounds, and the rounding is what the centring offset is then computed from.

Position and scale SHALL be kept consistent with one another within each arrangement: the horizontal offset that centres the laptop is a function of its logical width, which the scale determines, so a change to an arrangement's laptop scale SHALL be accompanied by the corresponding change to that arrangement's position.

#### Scenario: Docked

- **WHEN** the two externals and the laptop are all connected
- **THEN** the laptop SHALL render at the enlarged scale
- **AND** its horizontal position SHALL centre its resulting logical width beneath the externals

#### Scenario: Docked to the ultrawide above it

- **WHEN** the ultrawide and the laptop are the connected set
- **THEN** the laptop SHALL render at the panel's unenlarged scale
- **AND** its horizontal position SHALL centre its resulting logical width beneath the ultrawide

#### Scenario: Laptop alone

- **WHEN** the laptop is the only connected screen
- **THEN** it SHALL render at the panel's unenlarged scale
- **AND** it SHALL be positioned at the origin
