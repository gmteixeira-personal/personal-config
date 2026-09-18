## MODIFIED Requirements

### Requirement: Single entrypoint with deterministic load order

`init.lua` SHALL be the only file Neovim loads directly at startup. It SHALL apply general options first, general keymaps second, the modules that must run before Neovim sources its built-in plugins third, and initialize the plugin manager last. Nothing that runs before the plugin manager may depend on a plugin being present.

A module earns a place before the plugin manager only by needing to run there. Taking over a built-in plugin is such a reason: Neovim sources its built-in plugins after `init.lua` returns, so the global that suppresses one has to be set while `init.lua` is still running. Convenience is not such a reason, and a module with no ordering requirement of its own belongs in the general options or general keymaps module rather than on this list.

#### Scenario: Startup applies configuration in order

- **WHEN** Neovim starts
- **THEN** general options are in effect before any plugin spec is evaluated
- **AND** general keymaps are in effect before any plugin spec is evaluated
- **AND** every module that suppresses a built-in plugin has run before Neovim sources its built-in plugins
- **AND** the plugin manager initializes last

#### Scenario: Entrypoint contains no settings of its own

- **WHEN** a contributor opens `init.lua`
- **THEN** it contains only module loads and no option assignments, keymaps, or plugin specs
- **AND** each load is annotated with why it sits where it does in the order

#### Scenario: A module with no ordering requirement is not added to the entrypoint

- **WHEN** a contributor proposes loading a new module from `init.lua`
- **AND** that module does not have to run before the plugin manager
- **THEN** its contents belong in an existing module rather than in a new entry in the load order

### Requirement: General keymaps live in one module

A keymap SHALL be declared beside the thing it invokes. A keymap that invokes a plugin SHALL live in that plugin's file under `lua/plugins/`. A keymap that invokes a capability with its own module under `lua/config/` SHALL live in that module. Every remaining keymap — one that works with no plugin installed and belongs to no such module — SHALL live in `lua/config/keymaps.lua`, and that module SHALL contain no code conditional on a plugin or an external program being present.

The point is unchanged from when this rule named only `lua/config/keymaps.lua`: a mapping is findable from what it does, and deleting the thing a mapping drives deletes the mapping with it. What changes is that a capability may be driven by a module of its own rather than only by a plugin.

#### Scenario: Locating a general mapping

- **WHEN** a contributor needs to find or change a mapping that drives neither a plugin nor a capability module
- **THEN** it is declared in `lua/config/keymaps.lua`
- **AND** it is not declared in any file under `lua/plugins/`

#### Scenario: Locating a capability module's mapping

- **WHEN** a mapping invokes a capability implemented by its own module under `lua/config/`
- **THEN** it is declared in that module
- **AND** it is absent from `lua/config/keymaps.lua`

#### Scenario: Removing a capability module removes its mappings with it

- **WHEN** a capability module is deleted and its load removed from `init.lua`
- **AND** Neovim is restarted
- **THEN** the keymaps that module declared are no longer defined
- **AND** no leftover setting for it remains elsewhere in `lua/config/`

#### Scenario: The general keymaps module stays plugin-independent

- **WHEN** a contributor opens `lua/config/keymaps.lua`
- **THEN** every mapping in it works with no plugin installed
- **AND** none of them is guarded by a check that a plugin or an external program exists
