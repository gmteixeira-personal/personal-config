## Purpose

Defines where each kind of configuration lives and the order it is applied at startup, so that any setting can be located from its category alone and so that settings which must exist before plugins load reliably do.

## ADDED Requirements

### Requirement: Single entrypoint with deterministic load order

`init.lua` SHALL be the only file Neovim loads directly at startup. It SHALL apply general options first, general keymaps second, and initialize the plugin manager third. Nothing that runs before the plugin manager may depend on a plugin being present.

#### Scenario: Startup applies configuration in order

- **WHEN** Neovim starts
- **THEN** general options are in effect before any plugin spec is evaluated
- **AND** general keymaps are in effect before any plugin spec is evaluated
- **AND** the plugin manager initializes last

#### Scenario: Entrypoint contains no settings of its own

- **WHEN** a contributor opens `init.lua`
- **THEN** it contains only the three module loads and no option assignments, keymaps, or plugin specs

### Requirement: Leader key is Space and is set before plugins load

The leader key SHALL be `<Space>`. The local leader SHALL be set explicitly rather than left at its default. Both SHALL be assigned before the plugin manager initializes, because plugin specs that declare `<leader>`-prefixed mappings resolve the leader at definition time.

#### Scenario: Plugin-defined leader mapping resolves to Space

- **WHEN** a plugin spec declares a mapping on `<leader>e`
- **AND** Neovim has finished starting
- **THEN** pressing `<Space>` followed by `e` triggers that mapping

#### Scenario: Space alone does not move the cursor

- **WHEN** the user presses `<Space>` in normal or visual mode and does not complete a mapping
- **THEN** the cursor does not move right
- **AND** no error is raised

### Requirement: General options live in one module

Editor options that take effect with no plugin installed SHALL live in `lua/config/options.lua`. No file under `lua/plugins/` may set a general editor option.

#### Scenario: Locating a global option

- **WHEN** a contributor needs to find or change a global editor option
- **THEN** that option is set in `lua/config/options.lua`
- **AND** it is not also set in any file under `lua/plugins/`

### Requirement: General keymaps live in one module

Keymaps that work with no plugin installed SHALL live in `lua/config/keymaps.lua`. No file under `lua/plugins/` may declare a mapping that would still make sense with every plugin removed.

#### Scenario: Locating a general mapping

- **WHEN** a contributor needs to find or change a mapping that does not invoke a plugin
- **THEN** it is declared in `lua/config/keymaps.lua`
- **AND** it is not declared in any file under `lua/plugins/`

### Requirement: Plugin-specific options and keymaps live with their plugin

A plugin's own settings and the keymaps that invoke it SHALL both be declared in that plugin's file under `lua/plugins/`, and SHALL NOT appear in `lua/config/options.lua` or `lua/config/keymaps.lua`. A plugin file is therefore the single, complete description of that plugin, and the general modules never contain code conditional on a plugin being installed.

#### Scenario: A plugin's settings are not in the general options module

- **WHEN** a setting configures the behavior of one specific plugin
- **THEN** it is declared in that plugin's file under `lua/plugins/`
- **AND** it is absent from `lua/config/options.lua`

#### Scenario: A plugin's mapping is not in the general keymaps module

- **WHEN** a keymap invokes a function provided by a plugin
- **THEN** it is declared in that plugin's file under `lua/plugins/`
- **AND** it is absent from `lua/config/keymaps.lua`

#### Scenario: Removing a plugin removes its options and keymaps with it

- **WHEN** a plugin's file is deleted from `lua/plugins/`
- **AND** Neovim is restarted
- **THEN** the keymaps that plugin declared are no longer defined
- **AND** no leftover setting for that plugin remains in `lua/config/`
- **AND** no error is raised about a missing module or missing plugin

#### Scenario: The general modules load standalone

- **WHEN** `lua/config/options.lua` and `lua/config/keymaps.lua` are loaded with no plugins installed at all
- **THEN** both load without error
- **AND** neither references a plugin module
