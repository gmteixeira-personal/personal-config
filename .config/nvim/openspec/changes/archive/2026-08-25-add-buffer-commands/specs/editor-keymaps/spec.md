## ADDED Requirements

### Requirement: The buffer list is walked with `<leader>b` and a direction

The user SHALL be able to move through the buffer list without naming a buffer: `<leader>bn` and `<leader>bp` SHALL display the next and the previous listed buffer in the current window, and `<leader>bf` and `<leader>bl` SHALL display the first and the last one. Movement SHALL wrap, so the next buffer after the last is the first and the previous buffer before the first is the last.

These mappings SHALL change only which buffer the current window displays. The window layout, the other windows, and the contents of every buffer SHALL be untouched.

#### Scenario: Stepping forward

- **WHEN** three buffers are listed and the second is displayed
- **AND** the user presses `<leader>bn`
- **THEN** the current window displays the third buffer

#### Scenario: Stepping backward

- **WHEN** three buffers are listed and the second is displayed
- **AND** the user presses `<leader>bp`
- **THEN** the current window displays the first buffer

#### Scenario: Wrapping at the end of the list

- **WHEN** the last listed buffer is displayed and the user presses `<leader>bn`
- **THEN** the current window displays the first listed buffer
- **AND** no error is raised

#### Scenario: Wrapping at the start of the list

- **WHEN** the first listed buffer is displayed and the user presses `<leader>bp`
- **THEN** the current window displays the last listed buffer
- **AND** no error is raised

#### Scenario: Jumping to an end of the list

- **WHEN** several buffers are listed and one in the middle is displayed
- **AND** the user presses `<leader>bl`
- **THEN** the current window displays the last listed buffer
- **WHEN** the user then presses `<leader>bf`
- **THEN** the current window displays the first listed buffer

#### Scenario: Only one buffer

- **WHEN** exactly one buffer is listed and the user presses any of the four
- **THEN** that buffer remains displayed
- **AND** no error is raised

#### Scenario: Other windows are left alone

- **WHEN** two windows are open showing different buffers
- **AND** the user presses `<leader>bn` in one of them
- **THEN** only that window's displayed buffer changes
- **AND** the layout is unchanged

### Requirement: `<leader>bc` creates an empty buffer

Pressing `<leader>bc` SHALL open a new, empty, unnamed buffer in the current window, so that text can be written before a filename is chosen. The buffer it replaces SHALL remain loaded and listed, and SHALL be reachable again with `<leader>bb`.

#### Scenario: Creating a buffer to write in

- **WHEN** the user presses `<leader>bc`
- **THEN** the current window displays a new empty buffer with no filename
- **AND** the cursor is in it, ready for input

#### Scenario: The previous buffer survives

- **WHEN** the user presses `<leader>bc` while editing a file
- **AND** then presses `<leader>bb`
- **THEN** that file is displayed again
- **AND** its contents and cursor position are unchanged

### Requirement: Buffers are deleted with `<leader>bd`, `<leader>bo` and `<leader>bO`

`<leader>bd` SHALL delete the current buffer. `<leader>bo` SHALL delete every buffer except the current one, leaving the current one open. `<leader>bO` SHALL delete every buffer including the current one, leaving an empty unnamed buffer.

A deleted buffer SHALL be removed from the buffer list, so that it is no longer reached by the navigation mappings or listed by the buffer picker. Any window displaying a buffer that is deleted SHALL close with it; preserving the window layout across a deletion is NOT a goal of these mappings, and the window mappings under `<leader>w` remain the way a layout is managed.

After `<leader>bo`, the buffer that was current SHALL still be displayed, with its contents and its position in the window intact.

#### Scenario: Deleting the current buffer

- **WHEN** two buffers are listed and the user presses `<leader>bd`
- **THEN** the current buffer is no longer listed
- **AND** the other buffer is displayed

#### Scenario: A deleted buffer leaves the navigation set

- **WHEN** three buffers are listed and the user deletes one with `<leader>bd`
- **AND** then walks the list with `<leader>bn`
- **THEN** only the two remaining buffers are reached

#### Scenario: Deleting a buffer shown in a split

- **WHEN** a buffer is displayed in two windows and the user presses `<leader>bd`
- **THEN** the buffer is deleted
- **AND** the windows that displayed it are closed

#### Scenario: Clearing everything but the current buffer

- **WHEN** five buffers are listed and the user presses `<leader>bo`
- **THEN** only the buffer that was current remains listed
- **AND** it is still displayed in the current window

#### Scenario: Clearing every buffer

- **WHEN** five buffers are listed and the user presses `<leader>bO`
- **THEN** none of the five remains listed
- **AND** the current window displays an empty unnamed buffer

#### Scenario: Deleting the only buffer

- **WHEN** one buffer is listed and the user presses `<leader>bd`
- **THEN** an empty unnamed buffer is displayed
- **AND** the editor does not exit

### Requirement: Deleting a buffer with unsaved changes asks first

A mapping that deletes a buffer SHALL NOT discard unsaved changes silently, and SHALL NOT merely fail. When a buffer being deleted has unsaved changes, the user SHALL be asked whether to save them, discard them, or cancel, and the answer SHALL be honoured: saving SHALL write the buffer and then delete it, discarding SHALL delete it without writing, and cancelling SHALL leave the buffer listed and loaded with its changes intact.

This SHALL hold for `<leader>bd`, `<leader>bo` and `<leader>bO` alike, and SHALL apply to each modified buffer the mapping would delete.

#### Scenario: Saving when asked

- **WHEN** the current buffer has unsaved changes and the user presses `<leader>bd`
- **AND** answers that the changes should be saved
- **THEN** the buffer is written to disk
- **AND** it is then deleted

#### Scenario: Discarding when asked

- **WHEN** the current buffer has unsaved changes and the user presses `<leader>bd`
- **AND** answers that the changes should be discarded
- **THEN** the buffer is deleted
- **AND** the file on disk is unchanged

#### Scenario: Cancelling

- **WHEN** the current buffer has unsaved changes and the user presses `<leader>bd`
- **AND** cancels
- **THEN** the buffer is still listed and still displayed
- **AND** its unsaved changes are intact

#### Scenario: A modified buffer among many

- **WHEN** several buffers are listed and one of them has unsaved changes
- **AND** the user presses `<leader>bo`
- **THEN** the user is asked about that buffer
- **AND** the unmodified buffers are deleted without a prompt

#### Scenario: Nothing is lost without an answer

- **WHEN** any of the three deleting mappings would delete a modified buffer
- **THEN** that buffer is not deleted until the user has answered
