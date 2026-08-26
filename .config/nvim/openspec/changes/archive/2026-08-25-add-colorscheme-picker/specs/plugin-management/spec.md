## MODIFIED Requirements

### Requirement: Plugin specs are discovered from a directory, one plugin per file

Every file under `lua/plugins/` SHALL return a plugin specification for exactly one plugin, and the plugin manager SHALL import that directory as a whole. Adding a plugin to a directory the manager already imports SHALL require creating one file and nothing else: no registration list, no edit to `init.lua`, and no edit to any other plugin file.

Plugin files MAY be grouped in a subdirectory of `lua/plugins/` where they form a set that is chosen among or reasoned about together. Because the manager's import does not descend into subdirectories on its own, each such subdirectory SHALL be imported explicitly by the plugin manager's configuration, and that configuration SHALL say so where the import is declared. A subdirectory that is not imported contributes no plugins and reports no error, so the requirement to name it is what keeps a plugin file from being ignored in silence.

Grouping SHALL NOT change what a plugin file contains: one plugin per file, and that file remains the complete description of it.

#### Scenario: Adding a plugin

- **WHEN** a contributor adds a new file under `lua/plugins/` returning a valid spec
- **AND** restarts Neovim
- **THEN** that plugin is installed and configured
- **AND** no other file in the configuration was modified

#### Scenario: Adding a plugin to an imported subdirectory

- **WHEN** a contributor adds a new file to a subdirectory of `lua/plugins/` that is already imported
- **AND** restarts Neovim
- **THEN** that plugin is installed and configured
- **AND** no other file in the configuration was modified

#### Scenario: Introducing a new subdirectory

- **WHEN** a contributor creates a new subdirectory under `lua/plugins/` and puts a plugin file in it
- **THEN** the plugin is installed only once that subdirectory is named in the plugin manager's configuration
- **AND** the configuration states, where imports are declared, that a subdirectory must be named there

#### Scenario: Removing a plugin

- **WHEN** a contributor deletes a file from `lua/plugins/`
- **AND** restarts Neovim
- **THEN** that plugin is no longer loaded
- **AND** it is reported as removable by the manager

#### Scenario: A plugin's configuration is self-contained

- **WHEN** a contributor opens a file under `lua/plugins/`
- **THEN** that plugin's options, keymaps, dependencies, and load conditions are all in that one file
