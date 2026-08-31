## ADDED Requirements

### Requirement: Tracked documentation names the software the configuration requires

The repository's tracked documentation SHALL name the software the tracked configuration depends on, so that a reader can tell what a fresh machine still needs without reading the configuration files to work it out.

Each entry SHALL be placed in exactly one of three groups, and the group SHALL say what it means:

- **Required** — the configuration does not work without it.
- **Optional** — the configuration is written to tolerate its absence, and the documentation SHALL say what is lost rather than implying it is merely unimportant.
- **Carried by the repository** — the tracked files already provide it, and installing it separately is unnecessary.

Every entry SHALL state what breaks, or what is lost, when the software is absent. Naming the software alone SHALL NOT be sufficient, because the failures that matter most here are the silent ones.

Every entry SHALL name where the software comes from — a system package, a version manager, a per-user install — but SHALL NOT prescribe a distribution's package-manager command line, which would bind the documentation to one machine.

The documentation SHALL also name the software that must be **absent** from a machine running this configuration, so that a retired tool's absence is documented rather than merely implied by the absence of its configuration.

The Neovim configuration's own prerequisites SHALL NOT be restated. The documentation already condenses `.config/nvim/README.md`, which states them; this requirement SHALL direct the reader there rather than maintain a second copy.

#### Scenario: A reader can tell what is missing

- **WHEN** a reader has completed the bootstrap procedure on a fresh machine
- **THEN** the documentation SHALL name every piece of software the tracked configuration depends on
- **AND** a reader SHALL NOT have to read the tracked configuration files to discover a dependency

#### Scenario: Required software is distinguished from optional

- **WHEN** an entry in the inventory is read
- **THEN** it SHALL be identifiable as required, optional, or already carried by the repository
- **AND** an entry the configuration is written to tolerate the absence of SHALL NOT be presented as required

#### Scenario: Consequences are stated

- **WHEN** an entry names software that is absent from a machine
- **THEN** the documentation SHALL state what stops working, or what is lost, in that case
- **AND** where the failure is silent, the documentation SHALL say so

#### Scenario: What the repository already provides is not installed again

- **WHEN** a reader looks for the prompt or the fish plugin manager
- **THEN** the documentation SHALL state that the tracked files already provide them
- **AND** it SHALL NOT direct the reader to install them separately

#### Scenario: Acquisition is named without a package-manager command

- **WHEN** an entry is read on a machine whose distribution differs from the one the configuration was last deployed to
- **THEN** the entry SHALL name where the software comes from
- **AND** it SHALL NOT depend on a package-manager command line that is correct for only one distribution

#### Scenario: A retired tool is named as absent

- **WHEN** the inventory is read
- **THEN** it SHALL name the software that must not be installed on a machine running this configuration
- **AND** that naming SHALL agree with the `retired-tooling` specification

#### Scenario: The Neovim prerequisites are delegated

- **WHEN** a reader wants the Neovim configuration's own prerequisites
- **THEN** the documentation SHALL direct them to the Neovim section and to `.config/nvim/README.md`
- **AND** it SHALL NOT maintain a second list of them

#### Scenario: The inventory tracks the configuration

- **WHEN** a change makes the tracked configuration depend on a tool it did not depend on before, or removes the last thing that used one
- **THEN** that change SHALL update the inventory in the same change
- **AND** the inventory SHALL NOT name software nothing tracked here uses

## MODIFIED Requirements

### Requirement: Bootstrap into a new environment

The repository SHALL be adoptable by a fresh home directory that already contains conflicting files, without those files being silently overwritten.

#### Scenario: Adopting a non-empty home directory

- **WHEN** the repository is brought into a home directory that already contains files with the same names as tracked files
- **THEN** the procedure SHALL surface the conflicting paths before any file is overwritten
- **AND** the existing content SHALL be preserved or explicitly replaced by choice, never lost without notice

#### Scenario: Documented bootstrap procedure

- **WHEN** a new environment is set up
- **THEN** a tracked document SHALL describe the steps to obtain the repository, install the commit guard, and resolve conflicts
- **AND** it SHALL name the software that has to be present for the tracked configuration to do anything, rather than leaving a completed bootstrap as the last documented step
