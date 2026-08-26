## MODIFIED Requirements

### Requirement: `<leader>fb` lists open buffers

Pressing `<leader>fb` SHALL open a picker over the currently open buffers. Selecting one SHALL switch to it.

The same picker SHALL also be reachable as `<leader>,`, a two-key sequence beside the `<leader><leader>` that opens the file picker, since switching buffers is at least as frequent as opening a file. The two keys SHALL open the same picker and differ in nothing else, and the prefixed form SHALL remain, so the picker is still listed with the rest of `<leader>f`.

#### Scenario: Switching buffers

- **WHEN** two or more buffers are open
- **AND** the user presses `<leader>fb` and selects one
- **THEN** the current window displays that buffer

#### Scenario: Switching buffers from the unprefixed key

- **WHEN** two or more buffers are open
- **AND** the user presses `<leader>,` and selects one
- **THEN** the current window displays that buffer
- **AND** the picker was identical to the one `<leader>fb` opens
