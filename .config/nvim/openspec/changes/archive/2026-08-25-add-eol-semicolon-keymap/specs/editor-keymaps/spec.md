## ADDED Requirements

### Requirement: `<M-;>` terminates the current line with a semicolon and moves the cursor after it

Pressing `<M-;>` in insert mode SHALL place a `;` at the end of the current line and move the cursor to immediately after that `;`, with the editor still in insert mode. The semicolon SHALL be placed after the line's last non-blank character, so trailing whitespace does not end up before it. When the line already ends in a semicolon, no second one SHALL be inserted, and the cursor SHALL still be left immediately after the existing one. The mapping SHALL NOT raise an error on any line, including an empty one.

The key SHALL be an Alt chord rather than a Ctrl one, so that it reaches the editor from any terminal: Ctrl combined with `;` has no representation in the legacy terminal key encoding and is not delivered at all by the terminals this configuration is used from.

The mapping SHALL be declared in `lua/config/keymaps.lua` and SHALL call no plugin.

#### Scenario: Terminating a statement from mid-line

- **WHEN** the cursor is inside a line being typed in insert mode and the user presses `<M-;>`
- **THEN** a `;` is appended to that line
- **AND** the cursor sits immediately after that `;`
- **AND** the editor is still in insert mode
- **AND** what the user types next continues after the semicolon

#### Scenario: The line already ends in a semicolon

- **WHEN** the current line's last non-blank character is `;` and the user presses `<M-;>`
- **THEN** the line is unchanged
- **AND** no second semicolon is added
- **AND** the cursor sits immediately after the existing `;`

#### Scenario: Trailing whitespace

- **WHEN** the current line ends in one or more spaces and the user presses `<M-;>`
- **THEN** the `;` is placed after the last non-blank character
- **AND** it is not separated from the code by the trailing whitespace
- **AND** the cursor sits immediately after the `;`, before the remaining whitespace

#### Scenario: A blank line

- **WHEN** the current line is empty or contains only whitespace and the user presses `<M-;>`
- **THEN** a `;` is placed at the end of the line, leaving any indentation intact
- **AND** the cursor sits immediately after it
- **AND** no error is raised

### Requirement: `<M-;>` terminates every line a visual selection touches

Pressing `<M-;>` in visual mode SHALL place a `;` at the end of every line the selection touches, by the same placement rule as the insert-mode mapping, and SHALL then leave visual mode. Lines the selection covers only partially SHALL be terminated in full, so the result does not depend on which columns were highlighted. Lines that are empty or hold only whitespace SHALL be left untouched. The cursor SHALL be left immediately after the semicolon on the last line that was terminated.

#### Scenario: Terminating a block of statements

- **WHEN** the user selects three consecutive statement lines and presses `<M-;>`
- **THEN** each of the three lines ends in `;`
- **AND** visual mode is left
- **AND** the cursor sits immediately after the semicolon on the third line

#### Scenario: A partial selection still terminates whole lines

- **WHEN** the selection starts mid-way through one line and ends mid-way through another
- **AND** the user presses `<M-;>`
- **THEN** both lines are terminated at their own ends
- **AND** no semicolon is placed at the selection boundaries

#### Scenario: Blank lines inside the selection

- **WHEN** the selection spans lines with one or more blank lines among them
- **AND** the user presses `<M-;>`
- **THEN** the blank lines are unchanged
- **AND** the non-blank lines are each terminated

#### Scenario: Lines already terminated

- **WHEN** some lines in the selection already end in `;`
- **AND** the user presses `<M-;>`
- **THEN** those lines are unchanged
- **AND** no line gains a second semicolon
