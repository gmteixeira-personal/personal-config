## ADDED Requirements

### Requirement: A window opened only to carry a drag is floated rather than tiled

Where a window exists only for the length of a drag-and-drop gesture, the compositor SHALL open it floating.

A scrolling tiling layout has no cheap place to put a window. Opening one as a column moves every other column on the workspace aside to make room, and closing it moves them all back — motion that is the right answer for a window being opened to work in, and the wrong answer for one that will be gone in the seconds it takes to drag a file out of it. The user is at that moment aiming a pointer at the window they mean to drop into, and the layout has just moved it.

Floating also puts the window above the tiled ones rather than beside them, which is what a drag needs: the source and the target have to be visible at the same time, and a tiled source is one that may have scrolled the target off the output.

#### Scenario: The drag window opens floating

- **WHEN** a window is opened to carry a drag
- **THEN** the compositor SHALL open it floating

#### Scenario: The workspace is not rearranged

- **WHEN** a drag window opens on a workspace holding tiled columns
- **THEN** those columns SHALL NOT be moved to make room for it

#### Scenario: The target stays visible

- **WHEN** a drag window is open over a workspace
- **THEN** it SHALL be drawn above the tiled windows rather than displacing one

### Requirement: The floating rule is stated in the compositor configuration, and says how it identifies the window

The compositor configuration SHALL state the floating rule, SHALL record why the window is floated, and SHALL record how the rule identifies it — including that the identifier it matches on is not the window's full application identifier.

The compositor tiles by default, so this behaviour exists only while the configuration asks for it. The match itself needs its own note because it is not a literal: the rule matches a fragment of the application identifier rather than the whole of it, and a reader who assumes the value is the identifier will not be able to reconcile it with what the window actually reports. Recording the full identifier beside the fragment is what lets the rule be checked without running the program.

#### Scenario: The rule is present

- **WHEN** the compositor configuration's window rules are inspected
- **THEN** one SHALL float the drag window

#### Scenario: The reason is recorded

- **WHEN** the configuration is read around that rule
- **THEN** it SHALL record why the window is floated rather than tiled

#### Scenario: The match is explained

- **WHEN** the configuration is read around that rule
- **THEN** it SHALL record the window's full application identifier
- **AND** it SHALL state that the value matched against it is a fragment rather than the whole
