## MODIFIED Requirements

### Requirement: Tracked documentation describes the Neovim configuration

The repository's tracked documentation SHALL describe what the Neovim configuration under `.config/nvim/` sets up, at the level of orientation: its file layout and load order, how a fresh machine acquires its plugins, the editor-wide conventions it fixes, the keymap families it defines, and the plugins it loads grouped by the job each does.

That description SHALL be a condensation of the README at the root of the Neovim configuration, not an independent account of the same subject. It SHALL name that README as the document it is drawn from, so that a reader wanting more than an orientation is directed to it and an editor knows which document changes first. Where the two disagree, the Neovim configuration's own README SHALL be the one that is right.

It SHALL also state that the Neovim configuration can be taken on its own — that copying the contents of `.config/nvim/` into another machine's `~/.config/nvim` yields the same editor configuration without the rest of this repository.

It SHALL NOT reference the retired `nvim-config` remote, which no longer exists, nor any other repository as the location of that configuration's history.

Detail beyond orientation SHALL remain in `.config/nvim/openspec/specs/`, which the documentation SHALL name as the authoritative per-capability source, so the two cannot disagree about behaviour. That workspace SHALL be the only location the documentation names as specifying a Neovim capability: a Neovim capability found specified elsewhere SHALL be relocated into it rather than documented as an exception to look up separately. Naming the Neovim configuration's README as the source of the orientation SHALL NOT be such an exception — a README describes, a spec specifies, and the reader is sent to each for what it holds.

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

#### Scenario: The section is drawn from the configuration's own README

- **WHEN** a claim in the Neovim section of the tracked documentation is checked
- **THEN** it SHALL be supported by the README at the root of the Neovim configuration
- **AND** the section SHALL introduce no claim about the configuration that README does not make

#### Scenario: The source is named

- **WHEN** a reader of the Neovim section wants the fuller description
- **THEN** the section SHALL name the README at the root of the Neovim configuration as the document it condenses
- **AND** it SHALL do so within the section, not only in the repository's file listing

#### Scenario: The configuration can be taken on its own

- **WHEN** a reader wants the editor configuration and not the rest of the repository
- **THEN** the documentation SHALL state that copying the contents of `.config/nvim/` into `~/.config/nvim` is sufficient
- **AND** it SHALL NOT require any part of this repository outside that directory to be present for the editor configuration to work

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
