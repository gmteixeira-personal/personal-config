## RENAMED Requirements

- FROM: `### Requirement: Tiled windows meet without a gap`
- TO: `### Requirement: The gap between tiled windows is the width of the focus marker`

- FROM: `### Requirement: A focus indicator survives the removal of gaps and borders`
- TO: `### Requirement: A focus indicator survives the removal of borders`

## MODIFIED Requirements

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
