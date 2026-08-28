## Purpose

Moving the selected text around as a unit -- up, down, left and right -- so that reordering lines and shifting a block sideways is a held key rather than a cut, a cursor move and a paste.

## ADDED Requirements

### Requirement: The selected lines can be moved up and down

The user SHALL be able to move a visual selection one line up or one line down with a single key, repeatedly, without leaving visual mode.

The lines the selection displaces SHALL close in behind it, so the file gains and loses no lines: moving a selection down swaps it with the line below, moving it up swaps it with the line above.

The selection SHALL survive the move and still cover the same text afterwards, so the key can be held or pressed again to keep going.

The unnamed register SHALL NOT be touched. Whatever was yanked or deleted before the move is still there to be put afterwards.

A count SHALL apply: `3` followed by the key moves the selection three lines.

#### Scenario: Moving a selected block down

- **WHEN** the user selects two lines in visual mode
- **AND** presses the "move down" key
- **THEN** the two lines swap places with the line that was below them
- **AND** the same two lines are still selected
- **AND** the file has the same number of lines it had before

#### Scenario: Repeating the move

- **WHEN** the selection has just been moved down
- **AND** the user presses the same key again
- **THEN** the selection moves one further line down
- **AND** no re-selection was needed in between

#### Scenario: Moving with a count

- **WHEN** the user selects a line and types `3` followed by the "move down" key
- **THEN** the selection ends three lines further down

#### Scenario: The register is left alone

- **WHEN** the user has yanked some text
- **AND** then selects a block and moves it up or down
- **AND** then puts from the unnamed register
- **THEN** the yanked text is what is put

### Requirement: The selected text can be moved left and right

The user SHALL be able to move a visual selection left or right with a single key, repeatedly, without leaving visual mode.

The step SHALL follow the selection's own shape. For a linewise selection the move is a change of indentation, so it SHALL shift the lines by one indentation step -- the same amount `>` and `<` shift by. For a charwise or blockwise selection the move is through the text, so it SHALL move the selected characters one column, leaving the lines it is not part of alone.

The selection SHALL survive the move, as it does for the vertical moves, and a count SHALL apply in the same way.

#### Scenario: Shifting a block sideways

- **WHEN** the user selects a column of text with blockwise visual mode
- **AND** presses the "move right" key
- **THEN** the selected column moves one character to the right
- **AND** the text outside the selection stays on its own lines
- **AND** the same block is still selected

#### Scenario: Moving a linewise selection left

- **WHEN** the user selects whole lines and presses the "move left" key
- **THEN** the selected lines lose one indentation step of leading whitespace, as `<` would remove
- **AND** the selection is unchanged

### Requirement: A moved block is reindented to where it arrives

When a linewise selection is moved up or down, the moved lines SHALL be reindented to suit their new surroundings rather than keeping the indentation they had before the move.

This applies only to the vertical moves of a linewise selection. A horizontal move is itself a change of indentation and SHALL NOT be reindented on top of that, and a charwise or blockwise move SHALL leave surrounding indentation alone.

#### Scenario: Moving a statement into a nested block

- **WHEN** the user selects a statement sitting at the top level of a function
- **AND** moves it down past the opening of a nested `if`
- **THEN** the statement is indented to the nested block's level

#### Scenario: Moving a statement back out

- **WHEN** the user moves that statement back up past the `if`
- **THEN** it is returned to the outer level's indentation

### Requirement: The movement keys exist in visual mode only

The movement keys SHALL be bound in visual mode and SHALL NOT be bound in normal mode.

In normal mode the same keys SHALL keep the meaning `editor-keymaps` already gives them -- resizing the focused window -- and pressing them there SHALL resize the window, never move a line.

The two meanings are distinguished by mode and by nothing else: the directions SHALL agree between them, so the key that grows the window downward in normal mode is the key that moves the selection downward in visual mode.

#### Scenario: Pressing the keys in normal mode

- **WHEN** the user is in normal mode with a split open
- **AND** presses the movement keys
- **THEN** the focused window is resized
- **AND** no line moves

#### Scenario: Pressing the keys in visual mode

- **WHEN** the user has a selection active
- **AND** presses the movement keys
- **THEN** the selection moves
- **AND** no window is resized
