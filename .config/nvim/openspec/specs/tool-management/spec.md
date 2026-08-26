## Purpose

Acquires and updates the external command-line programs that language support and formatting depend on — language servers and formatters — so that a fresh copy of this configuration provisions its own toolchain instead of requiring the user to install a list of binaries by hand.

## Requirements

### Requirement: Required tools are declared and installed automatically

The configuration SHALL declare the set of language servers and formatters it requires. On startup, any declared tool that is not already installed SHALL be installed without the user issuing a command. Installation SHALL happen in the background: the editor SHALL remain usable while it proceeds.

#### Scenario: First launch on a clean machine

- **WHEN** the configuration is launched with none of the declared tools present
- **THEN** each declared tool is installed
- **AND** the user is not required to run an install command
- **AND** the editor remains usable while installation runs

#### Scenario: Subsequent launches

- **WHEN** the editor is launched and every declared tool is already installed
- **THEN** nothing is downloaded
- **AND** startup is not delayed by an install step

#### Scenario: A tool fails to install

- **WHEN** a declared tool cannot be installed, for example because a runtime it needs is absent from the system
- **THEN** the failure is reported to the user with the reason
- **AND** the other tools still install
- **AND** the editor starts normally without that tool's features

### Requirement: Managed tools are isolated from the system

Tools installed by this mechanism SHALL be written inside the editor's own data directory and SHALL NOT be installed system-wide or onto the user's login `PATH`. Removing that data directory SHALL be sufficient to remove every managed tool.

#### Scenario: No system-wide side effects

- **WHEN** the configuration installs its declared tools
- **THEN** no package is installed outside the editor's data directory
- **AND** the user's shell `PATH` outside the editor is unchanged

#### Scenario: Full reset

- **WHEN** the editor's tool directory is deleted and the editor is relaunched
- **THEN** every declared tool is reinstalled
- **AND** the configuration works as it did before

### Requirement: Managed tools are reachable by their consumers

Managed tools SHALL be resolvable by name from inside the editor before any capability tries to spawn one. A formatter or language server SHALL find its binary whether it was installed by this mechanism or was already present on the system, and a system-installed copy SHALL be usable when no managed copy exists.

#### Scenario: A managed formatter is found

- **WHEN** a formatter installed by this mechanism is invoked on write
- **THEN** it runs successfully
- **AND** it is found without the user configuring an absolute path

#### Scenario: A system-installed tool is used

- **WHEN** a required tool exists on the system `PATH` but has no managed copy
- **THEN** the system copy is used
- **AND** no error is raised about a missing managed tool

### Requirement: Tool versions are tracked separately from plugin versions

The set of installed tools and their versions SHALL be recorded independently of the plugin lockfile. A tool update SHALL NOT require a plugin update, and a plugin update SHALL NOT silently change an installed tool's version.

#### Scenario: Updating plugins does not move tools

- **WHEN** the user updates plugins
- **THEN** the installed tool versions are unchanged

#### Scenario: The plugin lockfile does not describe tools

- **WHEN** a contributor reads the plugin lockfile
- **THEN** it lists plugins only
- **AND** the installed language servers and formatters are not among them
