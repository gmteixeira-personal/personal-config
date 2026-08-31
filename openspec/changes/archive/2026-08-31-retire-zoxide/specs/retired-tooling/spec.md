## ADDED Requirements

### Requirement: zoxide is retired

zoxide SHALL NOT be part of this configuration. No configuration for it SHALL be tracked, no shell startup file SHALL initialize it, no allowlist entry SHALL name a path belonging to it, and on a machine this repository is deployed to the package SHALL NOT be installed and no configuration, state, data, or cache directory belonging to it SHALL remain.

It is retired because it was not being used here, and for no other reason: the project is actively maintained, and plain `cd`, the shell's own directory history, and the `mkcd` function cover the navigation it served. Retiring it removes a tool, not a capability, and this requirement is a record of a preference rather than a judgement on the software.

Because zoxide works by installing a shell hook, its removal has a failure mode the other retired tools do not: a shell session started while zoxide was still present keeps the hook function resident in memory after the binary is gone, and prints an error on every directory change. That state belongs to the running session, not to the configuration, and a shell started fresh from this configuration SHALL be free of it.

#### Scenario: No zoxide configuration is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** no tracked path SHALL name zoxide
- **AND** a search of the tracked file contents SHALL find no occurrence of `zoxide`, excluding archived OpenSpec changes, which are a historical record

#### Scenario: No shell startup file initializes it

- **WHEN** the fish startup files under `.config/fish/conf.d/` and the bash startup files are inspected
- **THEN** none SHALL contain a `zoxide init` line or any other invocation of the `zoxide` command

#### Scenario: A fresh shell defines no zoxide hook

- **WHEN** a new fish shell is started from this configuration and a directory is entered
- **THEN** no `__zoxide_hook` or `__zoxide_pwd` function SHALL be defined
- **AND** no error naming zoxide SHALL be printed

#### Scenario: The allowlist no longer names it

- **WHEN** the root ignore file is inspected
- **THEN** no allowlist entry SHALL name a path under `.config/zoxide/` or any other path belonging to the tool

#### Scenario: No leftover state on the machine

- **WHEN** a machine running this configuration is inspected
- **THEN** `.config/zoxide/`, `.local/share/zoxide/`, `.local/state/zoxide/`, and `.cache/zoxide/` SHALL each be absent
- **AND** the database file the tool keeps its directory rankings in SHALL be absent
- **AND** a search of the home directory SHALL find no file belonging to the tool, excluding assets that an unrelated third-party package ships inside its own installation directory

#### Scenario: The package is not installed

- **WHEN** the system package manager is queried for zoxide
- **THEN** it SHALL report the package as not installed
- **AND** `zoxide` SHALL NOT resolve to an executable on `PATH`

#### Scenario: Re-adding it is a deliberate act

- **WHEN** someone wants zoxide back
- **THEN** it SHALL require a change that supersedes this requirement, not merely reinstalling the binary or restoring an init line
