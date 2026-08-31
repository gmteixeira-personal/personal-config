## MODIFIED Requirements

### Requirement: Tracked documentation describes the Neovim configuration

The repository's tracked documentation SHALL describe what the Neovim configuration under `.config/nvim/` sets up, at the level of orientation: its file layout and load order, how a fresh machine acquires its plugins, the editor-wide conventions it fixes, the keymap families it defines, and the plugins it loads grouped by the job each does.

It SHALL NOT reference the retired `nvim-config` remote, which no longer exists, nor any other repository as the location of that configuration's history.

Detail beyond orientation SHALL remain in `.config/nvim/openspec/specs/`, which the documentation SHALL name as the authoritative per-capability source, so the two cannot disagree about behaviour. That workspace SHALL be the only location the documentation names for such detail: a Neovim capability found specified elsewhere SHALL be relocated into it rather than documented as an exception to look up separately.

#### Scenario: No reference to the deleted remote

- **WHEN** the tracked documentation is searched for `nvim-config`
- **THEN** no match SHALL be found
- **AND** no other repository SHALL be named as holding the Neovim configuration's history

#### Scenario: The section describes the configuration

- **WHEN** the Neovim section of the tracked documentation is read
- **THEN** it SHALL identify the entrypoint and the order in which the configuration's own files load
- **AND** it SHALL name the plugin manager and state that a fresh machine installs plugins without a manual step
- **AND** it SHALL state the editor conventions that apply regardless of filetype
- **AND** it SHALL describe the keymap families by the prefix each is reached under
- **AND** it SHALL list the loaded plugins grouped by purpose

#### Scenario: Detail is delegated, not duplicated

- **WHEN** a reader needs the exact behaviour of one Neovim capability
- **THEN** the documentation SHALL direct them to `.config/nvim/openspec/specs/`
- **AND** the documentation SHALL NOT restate those specifications' scenarios

#### Scenario: Description tracks the configuration

- **WHEN** a change adds, removes, or repurposes a Neovim plugin, a keymap family, or a global editor convention named in the documentation
- **THEN** that change SHALL update the description in the same change
- **AND** the documentation SHALL NOT name a plugin the configuration no longer loads

#### Scenario: One place to look

- **WHEN** the reader of the Neovim section asks where a capability is specified
- **THEN** the documentation SHALL name `.config/nvim/openspec/specs/` and no other location
- **AND** it SHALL NOT direct the reader to check a second workspace as well
