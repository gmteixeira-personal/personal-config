## MODIFIED Requirements

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
