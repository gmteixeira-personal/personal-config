## MODIFIED Requirements

### Requirement: Prefixes are listed as named groups

A key that is only ever a prefix SHALL be listed under its own name rather than as a bare character, so that the list of what `<leader>` begins reads as a menu of subjects. Every `<leader>` prefix this configuration defines mappings under SHALL be named: buffer, code, find, git, hunk, multi-cursor, notices, quit, restart and sessions, todo markers, and window.

Where one prefix carries mappings for more than one subject, its name SHALL name every subject rather than picking one and leaving the rest unlabelled.

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

#### Scenario: A prefix covering two subjects

- **WHEN** the user presses `<leader>` and pauses
- **THEN** `q` is listed under a name covering both quitting and sessions
- **AND** pausing after `q` lists the quit mappings and the session mappings together, each with its own description

#### Scenario: The notices prefix

- **WHEN** the user presses `<leader>` and pauses
- **THEN** the prefix that carries the message and notification history mappings is listed under a name
- **AND** pressing it lists those mappings with their descriptions

#### Scenario: The todo prefix

- **WHEN** the user presses `<leader>` and pauses
- **THEN** the prefix that carries the marker listings is listed under a name
- **AND** pausing after it lists the picker, quickfix, and location-list mappings with their descriptions
