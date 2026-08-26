## Purpose

Animates the cursor as it moves between positions, so that a large jump — across a screen, a window, or a file — is visually traceable instead of the cursor simply disappearing from one place and reappearing in another.

## Requirements

### Requirement: Cursor movement is animated

A change of cursor position SHALL be shown as a visible trail between the old and new position rather than as an instantaneous jump. The animation SHALL be purely visual.

#### Scenario: A large jump

- **WHEN** the cursor moves a substantial distance, such as jumping to the end of the file
- **THEN** a visible trail is drawn between the two positions

#### Scenario: Movement across windows

- **WHEN** the cursor moves from one window to another
- **THEN** the movement is animated between them

### Requirement: The animation never changes editor state

The animation SHALL NOT alter buffer contents, cursor position, marks, registers, the jumplist, or any editor mode. Text typed while an animation is in progress SHALL be inserted exactly as if no animation were running.

#### Scenario: Buffer contents are untouched

- **WHEN** the cursor animates across a buffer
- **THEN** the buffer contents are byte-identical before and after
- **AND** the buffer is not marked as modified

#### Scenario: Typing during an animation

- **WHEN** the user types while an animation is still in progress
- **THEN** every keystroke is applied in order
- **AND** none is dropped or delayed

#### Scenario: Final cursor position is exact

- **WHEN** an animation completes
- **THEN** the cursor is at exactly the position the movement targeted
