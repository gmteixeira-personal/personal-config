## Purpose

Governs how plugins are acquired, discovered, and pinned, so that a fresh clone of this configuration reaches a working state on first launch without manual setup and so that adding a plugin is a single-file operation.

## ADDED Requirements

### Requirement: Plugin manager bootstraps itself

The configuration SHALL install the plugin manager on first startup if it is not already present, without any manual command from the user. Bootstrap SHALL use `git` to fetch a stable release of the manager, not an unpinned default branch.

#### Scenario: First launch on a machine with no plugins installed

- **WHEN** Neovim starts and the plugin manager is not present on disk
- **THEN** the manager is fetched and prepended to the runtime path
- **AND** plugin specs are then installed
- **AND** the user is not required to run an install command first

#### Scenario: Subsequent launches skip bootstrap

- **WHEN** Neovim starts and the plugin manager is already present on disk
- **THEN** no clone is attempted
- **AND** startup is not blocked on network access

#### Scenario: Bootstrap failure is reported, not swallowed

- **WHEN** the bootstrap clone fails, for example because `git` is missing or the network is unreachable
- **THEN** the failure is shown to the user with the error output from the failed command
- **AND** the message names the directory the manager was expected at

### Requirement: Plugin specs are discovered from a directory, one plugin per file

Every file under `lua/plugins/` SHALL return a plugin specification for exactly one plugin, and the plugin manager SHALL import that directory as a whole. Adding a plugin SHALL require creating one file and nothing else: no registration list, no edit to `init.lua`, and no edit to any other plugin file.

#### Scenario: Adding a plugin

- **WHEN** a contributor adds a new file under `lua/plugins/` returning a valid spec
- **AND** restarts Neovim
- **THEN** that plugin is installed and configured
- **AND** no other file in the configuration was modified

#### Scenario: Removing a plugin

- **WHEN** a contributor deletes a file from `lua/plugins/`
- **AND** restarts Neovim
- **THEN** that plugin is no longer loaded
- **AND** it is reported as removable by the manager

#### Scenario: A plugin's configuration is self-contained

- **WHEN** a contributor opens a file under `lua/plugins/`
- **THEN** that plugin's options, keymaps, dependencies, and load conditions are all in that one file

### Requirement: Plugin versions are pinned in a committed lockfile

The plugin manager SHALL record the resolved commit of every installed plugin in a lockfile at the configuration root, so the same set of plugin versions can be restored on another machine.

#### Scenario: Restoring pinned versions elsewhere

- **WHEN** the configuration including its lockfile is cloned to a second machine
- **AND** plugins are restored from the lockfile
- **THEN** each plugin is checked out at the same commit recorded on the first machine
