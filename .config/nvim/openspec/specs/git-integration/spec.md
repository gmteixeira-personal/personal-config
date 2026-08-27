## Purpose

Shows which lines of the current buffer differ from the version recorded in git, and lets the user stage, discard, preview, and attribute those differences without leaving the buffer.

## Requirements

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

### Requirement: The whole file's difference from the index can be opened with one key

The user SHALL be able to open the current file's complete difference from the git index from a single mapping, without typing a command. The two versions SHALL be shown side by side in a vertical split, the indexed version on the left and the working buffer on the right, scroll-bound so the same region of the file is visible in both.

This SHALL be reachable at `<leader>gd`, alongside the repository-level views already under the `<leader>g` prefix.

On opening, the cursor SHALL be left in the window the file is being edited in, which is where gitsigns puts it. The mapping SHALL NOT move focus into the diff; the existing window-motion keys reach it and return from it.

The indexed version SHALL NOT join the buffer list, so that cycling buffers never lands on it.

The mapping SHALL exist only in buffers inside a git repository, as the other gitsigns mappings do.

#### Scenario: Opening the diff for a changed file

- **WHEN** the user has modified a file tracked by git
- **AND** presses `<leader>gd`
- **THEN** the window splits vertically
- **AND** the left window shows the file's content as recorded in the git index
- **AND** the right window shows the buffer being edited
- **AND** the differing lines are highlighted in both

#### Scenario: The cursor stays with the file

- **WHEN** the user presses `<leader>gd`
- **THEN** the cursor is left in the window the file is being edited in
- **AND** the buffer's content and cursor position are as they were before the diff was opened

#### Scenario: The indexed version does not join the buffer list

- **WHEN** the diff is open
- **AND** the user cycles to the next or previous buffer
- **THEN** the indexed version is not among the buffers cycled through

#### Scenario: Moving between differences

- **WHEN** the diff is open and the user presses `]c` or `[c`
- **THEN** the cursor moves to the next or previous difference, with both windows staying aligned

#### Scenario: Opening the diff for an unchanged file

- **WHEN** the file matches the git index exactly
- **AND** the user presses `<leader>gd`
- **THEN** the diff opens showing two identical sides
- **AND** no error is raised

#### Scenario: Pressing the key while already in a diff

- **WHEN** the diff is open and the user presses `<leader>gd` again
- **THEN** no second diff is opened
- **AND** no error is raised

#### Scenario: A file outside a git repository

- **WHEN** the user opens a file that is not inside a git repository
- **THEN** the mapping does not exist in that buffer
- **AND** pressing the key raises no error
