# retired-tooling Specification

## Purpose
Records the tools that were once part of this configuration and have since been withdrawn, and states what must be absent for each one, so that a retired tool cannot return quietly through a stale configuration file, a leftover allowlist entry, or a state directory nobody thought to remove.

## Requirements

### Requirement: lazygit is retired

lazygit SHALL NOT be part of this configuration. No configuration for it SHALL be tracked, no allowlist entry SHALL name a path under `.config/lazygit/`, and on a machine this repository is deployed to the package SHALL NOT be installed and no configuration, state, or cache directory belonging to it SHALL remain.

It is retired because it is no longer used here, and for no other reason: the project is actively maintained, and the git workflow it served is covered by the Neovim git plugins this configuration already loads and by the `/git:*` command suite. Retiring it removes a tool, not a capability, and this requirement is a record of a preference rather than a judgement on the software.

#### Scenario: No lazygit configuration is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** no path under `.config/lazygit/` SHALL appear

#### Scenario: The allowlist no longer names it

- **WHEN** the root ignore file is inspected
- **THEN** no allowlist entry SHALL name `.config/lazygit/config.yml` or any other path under that directory
- **AND** `git check-ignore -v .config/lazygit/config.yml` SHALL report a deny-by-default rule rather than an allowlist exception

#### Scenario: No leftover state on the machine

- **WHEN** a machine running this configuration is inspected
- **THEN** `.config/lazygit/`, `.local/state/lazygit/`, `.local/share/lazygit/`, and `.cache/lazygit/` SHALL each be absent
- **AND** a search of the home directory SHALL find no file belonging to the tool, excluding assets that an unrelated third-party package ships inside its own installation directory

#### Scenario: The package is not installed

- **WHEN** the system package manager is queried for lazygit
- **THEN** it SHALL report the package as not installed

#### Scenario: Re-adding it is a deliberate act

- **WHEN** someone wants lazygit back
- **THEN** it SHALL require a new allowlist entry and a change that supersedes this requirement, not merely creating the configuration file again
