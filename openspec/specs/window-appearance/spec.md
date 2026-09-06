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
