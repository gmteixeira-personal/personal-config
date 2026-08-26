## Purpose

Lets the user browse and manipulate the filesystem from inside the editor by editing a directory listing as if it were an ordinary buffer, reachable from a single keystroke.

## ADDED Requirements

### Requirement: `<leader>e` toggles a floating file explorer

Pressing `<leader>e` in normal mode SHALL open the file explorer in a floating window. Pressing `<leader>e` again while that window is focused SHALL close it and return the user to the buffer they came from. The mapping SHALL be declared with the explorer plugin's own spec, not in the general keymaps module.

#### Scenario: Opening the explorer

- **WHEN** the user presses `<leader>e` while editing a file
- **THEN** a floating window opens listing the contents of that file's directory

#### Scenario: Closing with the same key

- **WHEN** the explorer float is open and focused
- **AND** the user presses `<leader>e`
- **THEN** the float closes
- **AND** the previously edited buffer is focused again with its cursor position unchanged

#### Scenario: Opening with no file loaded

- **WHEN** the user presses `<leader>e` from an empty start screen with no file open
- **THEN** the explorer opens on the current working directory
- **AND** no error is raised

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
