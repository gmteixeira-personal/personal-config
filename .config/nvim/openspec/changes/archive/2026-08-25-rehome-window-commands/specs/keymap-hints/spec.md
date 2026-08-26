## MODIFIED Requirements

### Requirement: Prefixes are listed as named groups

A key that is only ever a prefix SHALL be listed under its own name rather than as a bare character, so that the list of what `<leader>` begins reads as a menu of subjects. Every `<leader>` prefix this configuration defines mappings under SHALL be named: buffer, code, find, git, hunk, multi-cursor, rename and restart, and window.

A prefix that is named SHALL still not be bound to any command; naming it SHALL affect only how it is displayed.

#### Scenario: Pressing the leader key alone

- **WHEN** the user presses `<leader>` and pauses
- **THEN** each prefix defined under it is listed by name
- **AND** the single-key mappings defined directly under `<leader>` are listed alongside them with their own descriptions

#### Scenario: Entering a named group

- **WHEN** the user presses a named prefix and pauses
- **THEN** the mappings under that prefix are listed with their descriptions

#### Scenario: A named prefix runs nothing

- **WHEN** the user presses a named prefix
- **THEN** no command runs
- **AND** the editor waits for the next key of the sequence

#### Scenario: A prefix that is no longer used

- **WHEN** a prefix stops carrying mappings
- **THEN** it is no longer named
- **AND** pressing it lists nothing
