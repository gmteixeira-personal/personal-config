## ADDED Requirements

### Requirement: `H` and `L` move to the start and end of the line, in two steps outward

`H` SHALL move the cursor towards the start of the current line and `L` towards its end. Each key SHALL have two landing places, ordered from the inner one to the outer one:

- `H`: the first non-blank character, then column zero.
- `L`: the last non-blank character, then the end of the line, past any trailing whitespace.

The landing place SHALL be chosen from where the cursor already is, not from how many times the key has been pressed: when the cursor is on the inner landing place the key SHALL move it to the outer one, and from anywhere else on the line the key SHALL move it to the inner one. No press SHALL be counted and no state SHALL be carried between presses, so the outer landing place is reached the same way whether the cursor got to the inner one by pressing the key, by `^`, or by typing.

Both keys SHALL address the buffer line, not the screen line: on a wrapped line they SHALL move to the ends of the whole line rather than of the visual row.

Neither key SHALL move to the top or bottom of the visible screen, as they did before. That motion SHALL NOT be bound to any other key by this configuration.

#### Scenario: Pressing `H` from the middle of an indented line

- **WHEN** the cursor is in the middle of a line that begins with indentation
- **AND** the user presses `H`
- **THEN** the cursor moves to the first non-blank character of that line
- **AND** the line's text is unchanged

#### Scenario: Pressing `H` again at the first non-blank

- **WHEN** the cursor is on the first non-blank character of an indented line
- **AND** the user presses `H`
- **THEN** the cursor moves to column zero, in front of the indentation

#### Scenario: Reaching column zero without a second press

- **WHEN** the cursor is on the first non-blank character of an indented line, having arrived there by pressing `^` rather than `H`
- **AND** the user presses `H`
- **THEN** the cursor moves to column zero
- **AND** the result is the same as it would be after a first `H` that landed there

#### Scenario: Pressing `L` on a line with trailing whitespace

- **WHEN** the cursor is in the middle of a line that ends in trailing whitespace
- **AND** the user presses `L`
- **THEN** the cursor moves to the last non-blank character of that line
- **AND** pressing `L` again moves it onto the last character of the line, past the trailing whitespace

#### Scenario: A line with no trailing whitespace

- **WHEN** the cursor is in the middle of a line whose last character is not blank
- **AND** the user presses `L`
- **THEN** the cursor moves to that last character
- **AND** pressing `L` again leaves it there

#### Scenario: A line with no indentation

- **WHEN** the cursor is in the middle of a line that starts with a non-blank character
- **AND** the user presses `H`
- **THEN** the cursor moves to column zero
- **AND** pressing `H` again leaves it there

#### Scenario: An empty line

- **WHEN** the cursor is on an empty line and the user presses `H` or `L`
- **THEN** the cursor does not move
- **AND** no error is raised

#### Scenario: The screen motions are gone

- **WHEN** the cursor is anywhere in a buffer longer than the window
- **AND** the user presses `H` or `L`
- **THEN** the cursor stays on the line it was on
- **AND** the view does not scroll

### Requirement: The line-boundary motions work as motions, not only as cursor moves

`H` and `L` SHALL be bound in normal, visual and operator-pending mode, so that they can be given to an operator and can extend a visual selection. In every mode the landing place SHALL be chosen by the same rule, from the cursor position at the moment the key is pressed.

They SHALL NOT be bound in select mode, where typing a printable character replaces the selection.

Where the underlying motion carries behaviour of its own — a following `j` or `k` staying at the end of the line after `L`, or a visual-block `L` selecting to each line's own end — that behaviour SHALL be preserved.

#### Scenario: Deleting to the end of the line

- **WHEN** the cursor is in the middle of a line and the user types `dL`
- **THEN** the text from the cursor to the last non-blank character is deleted
- **AND** the deletion is charwise, not linewise

#### Scenario: Selecting back to the first non-blank

- **WHEN** the cursor is in the middle of an indented line and the user types `vH`
- **THEN** the selection extends back to the first non-blank character of that line

#### Scenario: Deleting the indentation

- **WHEN** the cursor is on the first non-blank character of an indented line and the user types `dH`
- **THEN** the indentation in front of the cursor is deleted
- **AND** the rest of the line is left where it is

#### Scenario: Moving down after `L`

- **WHEN** the user presses `L` to land on the end of a long line
- **AND** then presses `j` onto a shorter line
- **THEN** the cursor is at the end of the shorter line, as it would be after `$`

#### Scenario: Replacing a selection in select mode

- **WHEN** a selection is active in select mode and the user types `H`
- **THEN** the selection is replaced by the character `H`
- **AND** the cursor does not move to the start of the line
