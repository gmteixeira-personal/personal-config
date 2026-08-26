## MODIFIED Requirements

### Requirement: Hunks can be staged, reset, previewed, and blamed

The user SHALL be able to act on the block of changed lines under the cursor from within the buffer:

- **Stage** it, adding exactly those lines to the git index and leaving the rest of the file unstaged.
- **Reset** it, discarding those changes and restoring the lines to their indexed content.
- **Preview** it, displaying the before-and-after of that block without modifying anything.
- **Blame** the current line, showing who last changed it and when.

The user SHALL additionally be able to **reset the whole buffer**, discarding every unstaged change in the file at once and restoring it to its indexed content.

Staging and resetting SHALL also be available over a **visual selection**, acting on exactly the selected line range rather than on the hunk that encloses it, so that part of a hunk can be staged or discarded independently of the rest.

These SHALL be reachable under a `<leader>h` prefix. `<leader>h` SHALL NOT itself be bound as a mapping. Resetting a single hunk and resetting the whole buffer SHALL be distinct keys under that prefix, distinguished by case, so that the wider action cannot be reached by a slip of one key.

#### Scenario: Staging one hunk of several

- **WHEN** a file has two separate changed blocks
- **AND** the cursor is inside the first and the user stages it
- **THEN** only the first block's lines are added to the git index
- **AND** the second block remains unstaged

#### Scenario: Resetting a hunk

- **WHEN** the cursor is inside a changed block and the user resets it
- **THEN** those lines are restored to their content in the git index
- **AND** the indicator for that block is cleared

#### Scenario: Resetting the whole buffer

- **WHEN** a file has several separate changed blocks and the user resets the buffer
- **THEN** every unstaged change in the file is discarded
- **AND** the buffer matches its content in the git index
- **AND** no indicator remains in the sign column

#### Scenario: Buffer reset leaves staged work alone

- **WHEN** one hunk has been staged and others have not
- **AND** the user resets the buffer
- **THEN** the unstaged changes are discarded
- **AND** the already-staged changes remain in the git index

#### Scenario: Staging part of a hunk

- **WHEN** a changed block spans six lines
- **AND** the user selects three of them in visual mode and stages the selection
- **THEN** only those three lines are added to the git index
- **AND** the remaining three stay unstaged and still marked in the sign column

#### Scenario: Resetting part of a hunk

- **WHEN** the user selects a range of changed lines in visual mode and resets the selection
- **THEN** only the selected lines are restored to their indexed content
- **AND** changed lines outside the selection are untouched

#### Scenario: Previewing is non-destructive

- **WHEN** the user previews the hunk under the cursor
- **THEN** the old and new content of that block are displayed
- **AND** neither the buffer nor the git index is modified

#### Scenario: Blaming a line

- **WHEN** the user requests blame for the current line
- **THEN** the commit, author, and date that last changed that line are shown

#### Scenario: Acting outside a hunk

- **WHEN** the cursor is on an unchanged line and the user invokes stage or reset
- **THEN** nothing is staged or reset
- **AND** no error is raised

#### Scenario: Resetting a buffer with no changes

- **WHEN** the file matches the git index exactly and the user resets the buffer
- **THEN** the buffer is unchanged
- **AND** no error is raised

#### Scenario: Acting outside a git repository

- **WHEN** the file is not inside a git repository
- **THEN** none of these mappings exist in that buffer
- **AND** pressing the keys raises no error
