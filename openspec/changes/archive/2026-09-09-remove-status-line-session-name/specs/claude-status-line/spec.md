## ADDED Requirements

### Requirement: The status line reports location and state, not the session's name

The status line SHALL report where the session is and what state it is in. It SHALL NOT show the session's name, whether that name was set by the user with `/rename` or derived by Claude Code, and it SHALL NOT read the session registry to find one.

The name is chosen by the user and is already known to them, so the width it takes is width the location and the badges do not get.

#### Scenario: A session the user renamed

- **WHEN** the user has set a session name with `/rename`
- **THEN** the status line SHALL NOT show that name
- **AND** the badge row SHALL open with the git-state badge

#### Scenario: A session with no name set

- **WHEN** no session name has been set
- **THEN** the status line SHALL render exactly as it does for a renamed session
- **AND** the badge row SHALL open with the git-state badge

#### Scenario: The session registry is unreadable

- **WHEN** the session registry directory is missing, unreadable, or holds no entry for this session
- **THEN** the status line SHALL render unaffected
- **AND** no error SHALL reach the rendered line
