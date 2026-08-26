## MODIFIED Requirements

### Requirement: Buffers are deleted with `<leader>bd`, `<leader>bo` and `<leader>bO`

`<leader>bd` SHALL delete the current buffer. `<leader>bo` SHALL delete every listed buffer except the current one, leaving the current one open. `<leader>bO` SHALL delete every listed buffer including the current one, leaving an empty unnamed buffer.

The set `<leader>bo` and `<leader>bO` act on SHALL be the buffer list — the same set the navigation mappings walk and the buffer picker shows. A buffer that is not listed SHALL NOT be deleted by either mapping, and SHALL be left loaded, so that the scratch and directory buffers plugins keep alive are not swept up by a mapping the user reached for to clear their open files. The number of buffers a bulk deletion reports SHALL therefore be the number the picker was showing.

`<leader>bd` SHALL delete the current buffer whether or not it is listed, since the user is looking at it.

A deleted buffer SHALL be removed from the buffer list, so that it is no longer reached by the navigation mappings or listed by the buffer picker. Any window displaying a buffer that is deleted SHALL close with it; preserving the window layout across a deletion is NOT a goal of these mappings, and the window mappings under `<leader>w` remain the way a layout is managed.

After `<leader>bo`, the buffer that was current SHALL still be displayed, and SHALL be untouched: its contents, its position in the window, its undo history and its buffer-local marks SHALL all survive.

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

#### Scenario: Unlisted buffers survive a bulk clear

- **WHEN** two buffers are listed and the editor also holds unlisted buffers a plugin created
- **AND** the user presses `<leader>bO`
- **THEN** the two listed buffers are deleted
- **AND** the unlisted buffers are still loaded
- **AND** the count reported is two

#### Scenario: The surviving buffer is not disturbed

- **WHEN** several buffers are listed, the current one has been edited and saved, and its cursor is partway down the file
- **AND** the user presses `<leader>bo`
- **THEN** the cursor is where it was
- **AND** `u` still undoes the edits made before the clear

#### Scenario: Nothing left to clear

- **WHEN** exactly one buffer is listed and the user presses `<leader>bo`
- **THEN** that buffer remains listed and displayed
- **AND** no error is raised

#### Scenario: Clearing from an unlisted buffer

- **WHEN** the current window displays an unlisted buffer and other buffers are listed
- **AND** the user presses `<leader>bo`
- **THEN** every listed buffer is deleted
- **AND** the unlisted buffer the user is looking at remains displayed
