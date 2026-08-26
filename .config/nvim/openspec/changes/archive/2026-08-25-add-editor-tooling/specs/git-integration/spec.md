## Purpose

Shows which lines of the current buffer differ from the version recorded in git, and lets the user stage, discard, preview, and attribute those differences without leaving the buffer.

## ADDED Requirements

### Requirement: Changed lines are marked in the sign column

For a file tracked by a git repository, the sign column SHALL indicate, per line, whether that line was added, changed, or is adjacent to a deletion, relative to the git index. Indicators SHALL update as the buffer is edited, without requiring a save or a manual refresh.

#### Scenario: Editing a tracked file

- **WHEN** the user modifies a line in a file tracked by git
- **THEN** that line is marked as changed in the sign column
- **AND** the mark appears without saving the buffer

#### Scenario: Adding and deleting lines

- **WHEN** the user adds new lines
- **THEN** those lines are marked as added
- **WHEN** the user deletes lines
- **THEN** the position where they were removed is marked as a deletion

#### Scenario: Reverting an edit

- **WHEN** the user undoes an edit so the line matches the git index again
- **THEN** the indicator for that line disappears

#### Scenario: A file outside a git repository

- **WHEN** the user opens a file that is not inside a git repository
- **THEN** no indicators are shown
- **AND** no error is raised

### Requirement: `]c` and `[c` move between hunks

Pressing `]c` SHALL move the cursor to the next block of changed lines in the buffer, and `[c` to the previous one. When the buffer is in diff mode, these keys SHALL retain their built-in diff-navigation behavior rather than being shadowed.

#### Scenario: Jumping forward through changes

- **WHEN** the buffer contains two or more separate blocks of changed lines
- **AND** the cursor is above the first
- **AND** the user presses `]c`
- **THEN** the cursor moves to the first changed block
- **WHEN** the user presses `]c` again
- **THEN** the cursor moves to the second

#### Scenario: Jumping backward

- **WHEN** the cursor is below a changed block and the user presses `[c`
- **THEN** the cursor moves to that block

#### Scenario: Diff mode is not shadowed

- **WHEN** the buffer is open in diff mode and the user presses `]c`
- **THEN** the editor's built-in next-difference behavior applies

### Requirement: Hunks can be staged, reset, previewed, and blamed

The user SHALL be able to act on the block of changed lines under the cursor from within the buffer:

- **Stage** it, adding exactly those lines to the git index and leaving the rest of the file unstaged.
- **Reset** it, discarding those changes and restoring the lines to their indexed content.
- **Preview** it, displaying the before-and-after of that block without modifying anything.
- **Blame** the current line, showing who last changed it and when.

These SHALL be reachable under a `<leader>h` prefix. `<leader>h` SHALL NOT itself be bound as a mapping.

#### Scenario: Staging one hunk of several

- **WHEN** a file has two separate changed blocks
- **AND** the cursor is inside the first and the user stages it
- **THEN** only the first block's lines are added to the git index
- **AND** the second block remains unstaged

#### Scenario: Resetting a hunk

- **WHEN** the cursor is inside a changed block and the user resets it
- **THEN** those lines are restored to their content in the git index
- **AND** the indicator for that block is cleared

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
