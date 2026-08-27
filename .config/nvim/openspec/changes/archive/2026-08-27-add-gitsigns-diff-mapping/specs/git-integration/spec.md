## ADDED Requirements

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
