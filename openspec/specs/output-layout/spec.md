# output-layout Specification

## Purpose

Defines where each connected screen sits in the compositor's global coordinate space and at what scale it renders, and states that both depend on which screens are connected — so that the session matches the arrangement of the screens on the desk rather than the order the compositor happens to discover them in.

## Requirements

### Requirement: Output geometry follows the set of connected screens

The session SHALL determine every connected output's scale and position from the exact set of screens currently connected, and SHALL re-apply that determination whenever a screen is attached or detached.

Scale and position are not properties of a screen on its own. The same laptop panel wants one scale when it is the only thing in front of the user and another when it sits below two larger screens at a greater distance; its position is meaningless until it is known what else it is being positioned relative to. A per-output declaration can only state one of those answers, and it states it unconditionally, so it is necessarily wrong in every situation but the one it was written for. Keying the whole arrangement on the connected set is what makes both answers expressible at once.

#### Scenario: A screen is attached

- **WHEN** a screen is connected and the resulting set of connected screens has a declared arrangement
- **THEN** every connected output SHALL take the scale and position that arrangement gives it

#### Scenario: A screen is detached

- **WHEN** a screen is disconnected and the remaining set has a declared arrangement
- **THEN** every still-connected output SHALL take the scale and position that arrangement gives it
- **AND** this SHALL happen without the user running a command

### Requirement: The three-screen desk centres the laptop below the externals

Where the two external screens and the laptop are all connected, the session SHALL place the externals side by side along the top and the laptop centred horizontally beneath them.

This is where the screens physically are. The compositor's own default — every output in one row, in discovery order — puts the laptop to one side of screens that stand above it, so the pointer leaves it in a direction the panel is not in, and the directional monitor actions bound to `Mod+Shift+<direction>` have no downward target at all.

The laptop's top edge SHALL overlap both externals' bottom edges, so that the pointer can cross into it from either one. The pointer SHALL be able to travel between the laptop and an external only across the range where their edges actually overlap; outside that range the boundary is closed, and the keyboard monitor actions remain the way to cross.

#### Scenario: Pointer crosses down into the laptop

- **WHEN** the pointer is moved downwards from a point on either external that lies within the laptop's horizontal span
- **THEN** the pointer SHALL enter the laptop screen

#### Scenario: Pointer at an outer edge

- **WHEN** the pointer is moved downwards from a point on either external that lies outside the laptop's horizontal span
- **THEN** the pointer SHALL remain on that external

#### Scenario: Keyboard crossing is unconditional

- **WHEN** the downward monitor action is invoked from either external, from any pointer position
- **THEN** focus SHALL move to the laptop

### Requirement: The laptop renders larger while docked than alone

The laptop panel SHALL render at a scale one fifth larger while the two externals are connected than it does when it is the only connected screen.

Docked, the panel sits lower and further from the user than the screens above it, and content sized for reading at laptop distance is too small to read at desk distance. Undocked, that same enlargement wastes a panel the user is sitting directly in front of.

The scale SHALL be chosen so that it divides the panel's pixel width without remainder, because a scale that does not leaves a fractional logical width that the compositor rounds, and the rounding is what the centring offset is then computed from.

Position and scale SHALL be kept consistent with one another: the horizontal offset that centres the laptop is a function of its logical width, which the scale determines, so a change to the docked scale SHALL be accompanied by the corresponding change to the docked position.

#### Scenario: Docked

- **WHEN** the two externals and the laptop are all connected
- **THEN** the laptop SHALL render at the enlarged scale
- **AND** its horizontal position SHALL centre its resulting logical width beneath the externals

#### Scenario: Laptop alone

- **WHEN** the laptop is the only connected screen
- **THEN** it SHALL render at the panel's unenlarged scale
- **AND** it SHALL be positioned at the origin

### Requirement: Screens of the same model are identified by serial

Where two connected screens share a make and model, the session SHALL identify each by its serial number rather than by the connector it is attached to.

The two externals are the same monitor and can come back on swapped connectors after a redock. Under a connector-name match that swap mirrors the desk left to right, and it does so with nothing in the configuration having changed and no error reported anywhere — the arrangement simply applies to the wrong screens. A serial is fixed to the panel and survives the swap.

The built-in panel is exempt: it is soldered to one connector, so its connector name identifies it as durably as a serial would.

#### Scenario: The externals return on swapped connectors

- **WHEN** the two externals are reconnected such that each occupies the connector the other previously used
- **THEN** each SHALL take the position it had before the swap

### Requirement: Output geometry is declared in exactly one place

The compositor configuration SHALL NOT carry output scale or position. Every such declaration SHALL live with the connected-set arrangements.

Both declarations are applied on every session start, one after the other, and the later one wins. Keeping geometry in both files therefore does not produce a conflict that anyone is told about; it produces a file whose contents are read, believed, and silently overridden, which is worse than either file being wrong on its own.

#### Scenario: Reading the compositor configuration

- **WHEN** the compositor configuration is read to find out where a screen is placed
- **THEN** it SHALL state that geometry is declared elsewhere and where that is

### Requirement: An undeclared set of screens is left to the compositor

Where the connected set has no declared arrangement, the session SHALL make no placement of its own and SHALL leave the compositor's automatic placement in effect.

Arrangements are worth declaring for the sets the user actually works in. A set met once — a projector, a colleague's monitor, one external of the pair on its own — is better served by the compositor's default row than by a guess, and a guess would be indistinguishable from a declared arrangement once applied.

#### Scenario: An unfamiliar screen is attached

- **WHEN** the set of connected screens matches no declared arrangement
- **THEN** the outputs SHALL keep the placement the compositor gives them automatically
- **AND** no error SHALL be reported
