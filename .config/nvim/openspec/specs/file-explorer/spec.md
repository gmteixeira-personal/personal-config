## Purpose

Lets the user browse and manipulate the filesystem from inside the editor by editing a directory listing as if it were an ordinary buffer, reachable from a single keystroke.

## Requirements

### Requirement: `<leader>e` toggles the file explorer in the current window

Pressing `<leader>e` in normal mode SHALL open the file explorer in the current window, replacing the buffer displayed there and filling the whole window. Pressing `<leader>e` again while the listing is displayed SHALL restore the buffer the window held before, with its cursor position and scroll position unchanged. The mapping SHALL be declared with the explorer plugin's own spec, not in the general keymaps module.

#### Scenario: Opening the explorer

- **WHEN** the user presses `<leader>e` while editing a file
- **THEN** the current window shows the contents of that file's directory
- **AND** the listing occupies the whole window, with no floating border and no part of the previous buffer visible

#### Scenario: Closing with the same key

- **WHEN** the listing is displayed and focused
- **AND** the user presses `<leader>e`
- **THEN** the window returns to the buffer it displayed before the listing was opened
- **AND** that buffer's cursor position and scroll position are unchanged

#### Scenario: Opening with no file loaded

- **WHEN** the user presses `<leader>e` from an empty start screen with no file open
- **THEN** the explorer opens on the current working directory
- **AND** no error is raised

#### Scenario: Closing when there is no buffer to return to

- **WHEN** the listing is displayed in a window that had no previous buffer, such as after starting the editor on a directory
- **AND** the user presses `<leader>e`
- **THEN** the listing is dismissed
- **AND** no error is raised

#### Scenario: The window layout is left alone

- **WHEN** the user presses `<leader>e` in one of several open windows
- **THEN** only that window's contents change
- **AND** the other windows keep their size, position, and buffers

### Requirement: The directory listing is an editable buffer

The explorer SHALL present a directory as a normal, editable buffer. File operations SHALL be expressed as ordinary text edits to that buffer and SHALL take effect only when the buffer is written. Unwritten edits SHALL leave the filesystem untouched.

#### Scenario: Creating a file

- **WHEN** the user adds a new line naming a file that does not exist and writes the buffer
- **THEN** that file is created on disk

#### Scenario: Renaming an entry

- **WHEN** the user edits an existing entry's text and writes the buffer
- **THEN** the corresponding file or directory is renamed on disk

#### Scenario: Discarding edits

- **WHEN** the user edits the listing and closes the explorer without writing
- **THEN** the filesystem is unchanged

#### Scenario: Destructive operations are confirmed

- **WHEN** a pending write includes deleting one or more entries
- **THEN** the user is shown the exact operations to be performed and must confirm before any of them run

### Requirement: The explorer displays icons

Each entry in the listing SHALL be shown with an icon from the configuration's single icon provider, colored by the active theme.

#### Scenario: Entries are iconified

- **WHEN** the explorer lists a directory containing both files and subdirectories
- **THEN** each file shows a filetype-appropriate icon and each subdirectory shows a directory icon
- **AND** icons are colored by highlight groups from the active theme

### Requirement: The explorer replaces the built-in directory browser

Opening a directory path SHALL show the explorer rather than Neovim's built-in netrw browser, so that directory browsing behaves the same however it is reached.

#### Scenario: Opening a directory from the shell

- **WHEN** the user runs `nvim <directory>`
- **THEN** the explorer's listing for that directory is shown, not netrw

### Requirement: Deleting an entry removes it permanently

Deleting an entry through the explorer SHALL remove it from disk. It SHALL NOT be moved to a trash or any other holding area the user could restore it from, and the editor SHALL offer no undo for it once the write has run.

The confirmation shown before a destructive write is therefore the last point at which a deletion can be stopped, and SHALL NOT be presented as though the operation were reversible.

Sending deletions to a trash instead SHALL remain a deliberate configuration change rather than something that could be arrived at by leaving a default alone.

#### Scenario: A deleted file is gone

- **WHEN** the user deletes an entry in the listing and writes the buffer
- **AND** confirms the operation
- **THEN** the file is removed from disk
- **AND** it is not recoverable from a trash or from within the editor

#### Scenario: The confirmation is the last check

- **WHEN** a pending write includes a deletion
- **AND** the user declines the confirmation
- **THEN** nothing is deleted
- **AND** the filesystem is unchanged
