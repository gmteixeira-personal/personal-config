# documentation Specification

## Purpose

Fixes what the Neovim configuration says about itself at its own entry point: a tracked README that describes the setup — its layout and load order, the conventions it fixes, the keys it binds, and the plugins it loads — at a depth that answers a reader's question without restating the specifications, and that cannot fall out of date silently as the configuration changes.

## Requirements

### Requirement: The configuration carries a README at its root

A tracked `README.md` SHALL exist at the root of the Neovim configuration directory, alongside `init.lua`. It SHALL be plain markdown that renders without any build step, so that it is readable in the repository tree, in a clone, and in the editor itself.

It SHALL be the document a reader arriving at this directory is expected to read first, and every other requirement in this capability constrains its content.

#### Scenario: The README is present and tracked

- **WHEN** the Neovim configuration directory is listed
- **THEN** `README.md` SHALL be present at its root
- **AND** it SHALL be tracked by the enclosing repository rather than ignored

#### Scenario: Readable without tooling

- **WHEN** the README is opened as a text file with no markdown renderer
- **THEN** its content SHALL be legible as written
- **AND** it SHALL NOT depend on a generator, a template step, or an external asset to be complete

### Requirement: The README states what the configuration is and what it costs to run

The README SHALL open by identifying what the reader is looking at — a personal Neovim configuration — and SHALL state what is required to get from a fresh clone to a working editor.

It SHALL distinguish what the configuration provisions for itself from what it does not. Where the configuration acquires something on its own, the README SHALL say so and SHALL NOT print an install command the user does not need. Where a dependency must be present beforehand and is not self-provisioned, the README SHALL name it, because that is the only class of failure a reader cannot resolve by starting the editor again.

That accounting SHALL be complete rather than representative. A prerequisite counts as external whenever the configuration does not install it, **including the runtime a tool the configuration does install needs in order to run**: acquiring a binary is not the same as supplying what executes it, and a README that claims a tool is provisioned while its runtime is not names the wrong thing as satisfied. The set the README accounts for SHALL therefore be derived from what the configuration declares — its editor floor, the programs its own bootstrap and its tool installer invoke, the runtimes the declared tools execute on, and the external programs a capability spawns at the moment it is used — and not from whichever prerequisites happen to be missing on any one machine.

Each external prerequisite SHALL be named with the consequence of its absence, stated as what the reader will observe rather than as the internal reason: a launch that does not complete, a capability that is absent or silently inert, or a degradation that leaves the editor working. Prerequisites SHALL be grouped or marked by that consequence, so that a reader who has a symptom and no diagnosis can read backwards from what they are seeing to the thing they have not installed, and a reader who wants only a subset of the languages can tell which prerequisites they may skip.

Where the editor can report which of these are present, the README SHALL name that in-editor check, so the list is verifiable on the reader's own machine rather than only readable.

#### Scenario: A reader learns what to do first

- **WHEN** a reader who has just obtained the configuration reads the README's opening
- **THEN** it SHALL identify the configuration and the editor it is for
- **AND** it SHALL state what to run to reach a working editor

#### Scenario: Self-provisioned components are not presented as manual steps

- **WHEN** the README describes acquiring a component the configuration installs on its own
- **THEN** it SHALL state that no manual step is required
- **AND** it SHALL NOT instruct the reader to install it by hand

#### Scenario: External prerequisites are named

- **WHEN** the configuration depends on something that must already be present on the machine and that it does not install
- **THEN** the README SHALL name that dependency
- **AND** it SHALL state what fails or degrades without it

#### Scenario: A runtime behind an installed tool is a prerequisite

- **WHEN** the configuration installs a tool that cannot run without a runtime, interpreter, or SDK the configuration does not itself install
- **THEN** the README SHALL name that runtime among the external prerequisites
- **AND** it SHALL identify which of the configuration's capabilities are lost when it is absent
- **AND** the README SHALL NOT present that tool as fully provisioned on the strength of the installation alone

#### Scenario: The prerequisite account covers everything the configuration declares

- **WHEN** the README's prerequisites are compared against what the configuration declares — the editor version it requires, the programs its bootstrap and its tool installer invoke, the runtimes its declared tools execute on, and the external programs its capabilities spawn when used
- **THEN** every such dependency the configuration does not install SHALL appear in the README
- **AND** nothing the configuration does install for itself SHALL be listed as a manual step

#### Scenario: A symptom leads back to the missing prerequisite

- **WHEN** a reader observes that the editor failed to start, that a capability is missing or does nothing, or that something works in a degraded form
- **THEN** the README SHALL group or mark its prerequisites by that consequence
- **AND** each entry SHALL state the observable effect of its absence rather than only the internal reason for the dependency

#### Scenario: Optional prerequisites are distinguishable from required ones

- **WHEN** a reader wants only some of the languages or capabilities the configuration supports
- **THEN** the README SHALL make clear which prerequisites are needed for the editor itself and which are needed only for a capability
- **AND** it SHALL state what each optional one buys, so the reader can decide to skip it

#### Scenario: The list is checkable in the editor

- **WHEN** the README presents the prerequisites
- **THEN** it SHALL name the in-editor check that reports which of them the machine has
- **AND** the reader SHALL be able to confirm the list against their own machine without leaving the editor

### Requirement: The README describes the file layout and the startup order

The README SHALL describe where each kind of configuration lives — the entrypoint, the modules that are not plugins, the per-plugin files, and any subdirectory of them — so that a reader can predict which file to open from the category of the thing they want to change.

It SHALL state the order in which the configuration's own files load and SHALL identify which parts of that order are load-bearing rather than incidental, because an ordering constraint that is not stated is one a later change breaks without knowing.

#### Scenario: Locating a setting from its category

- **WHEN** a reader wants to change a setting and knows only what kind of setting it is
- **THEN** the README SHALL name the file or directory that setting belongs in

#### Scenario: Load order and its constraints

- **WHEN** the README describes startup
- **THEN** it SHALL state the order the configuration's own modules load in
- **AND** it SHALL state which ordering constraints exist and what depends on each

#### Scenario: Adding a plugin

- **WHEN** a reader wants to add a plugin
- **THEN** the README SHALL state where the file goes
- **AND** it SHALL state whether anything else must be edited for that file to take effect

### Requirement: The README states the editor conventions that hold regardless of filetype

The README SHALL describe the editing behaviour the configuration fixes for every buffer — how text is displayed, indented, wrapped and searched, what persists across sessions, where new windows open, and how text is exchanged with the system clipboard — in terms of what the reader will observe rather than as a list of option names and values.

Where a convention departs from Neovim's default in a way that would otherwise read as a malfunction, the README SHALL say why, so the reader can tell a deliberate choice from a bug.

#### Scenario: Observable behaviour, not an option dump

- **WHEN** the README describes an editor convention
- **THEN** it SHALL state what the user sees or experiences
- **AND** it SHALL NOT consist only of option names paired with values

#### Scenario: A surprising default is explained

- **WHEN** a convention overrides a Neovim default in a way a reader could mistake for broken behaviour
- **THEN** the README SHALL state the reason for the override

### Requirement: The README documents the keys the configuration binds

The README SHALL present the configuration's key mappings so that a reader can look up what a key does and can find the key for a thing they want to do. Both directions matter: a reader who pressed something by accident and a reader hunting for a binding are the same document's audience.

Mappings SHALL be grouped by the family they belong to — the prefix they are reached under, or the fact that they are deliberately unprefixed — and each entry SHALL give the key, what it does, and the modes it applies in where that is not obvious. Mappings a plugin defines SHALL be documented alongside the general ones and attributed to the plugin that provides them, since the reader pressing the key does not know or care which file declared it.

The leader key SHALL be stated explicitly, because every prefixed mapping in the document is unreadable without it.

#### Scenario: Looking up an unknown key

- **WHEN** a reader wants to know what a key the configuration binds does
- **THEN** the README SHALL name that key and state its effect

#### Scenario: Finding the key for a task

- **WHEN** a reader knows what they want to do and not which key does it
- **THEN** the README SHALL group the mappings so the relevant family can be found by its purpose

#### Scenario: The leader is stated

- **WHEN** the README shows a mapping reached under the leader key
- **THEN** the README SHALL state which key the leader is

#### Scenario: Plugin mappings are included and attributed

- **WHEN** a plugin defines a mapping
- **THEN** the README SHALL document it with the others
- **AND** it SHALL identify the plugin that provides it

#### Scenario: A deliberately unprefixed mapping is marked as such

- **WHEN** a mapping overrides a built-in key rather than sitting under a prefix
- **THEN** the README SHALL say what it displaces
- **AND** it SHALL state what the reader gets in place of the displaced built-in

### Requirement: The README lists the plugins grouped by the job each does

The README SHALL account for every plugin the configuration loads, grouped by the job each performs rather than listed alphabetically or in the order the files happen to appear, so that a reader can see which tool answers a given need and can tell overlapping tools apart.

Where several plugins occupy the same territory, the README SHALL state the boundary between them — what each is for and when to reach for one rather than another — because the reason for having more than one is exactly what a bare list omits.

#### Scenario: Every loaded plugin appears

- **WHEN** the plugin list in the README is compared to the plugin files in the configuration
- **THEN** every plugin the configuration loads SHALL appear in the README
- **AND** no plugin the configuration does not load SHALL appear

#### Scenario: Grouped by purpose

- **WHEN** a reader wants to know which plugin handles a given concern
- **THEN** the README SHALL group the plugins by purpose
- **AND** the group SHALL be findable from the concern rather than from the plugin's name

#### Scenario: Overlapping tools are distinguished

- **WHEN** more than one plugin covers a related area
- **THEN** the README SHALL state what each one is for
- **AND** it SHALL state the boundary that decides which one applies

### Requirement: Detail beyond orientation is delegated to the specs, not duplicated

The README works at the level of orientation and reference: enough for a reader to use and modify the configuration. Exhaustive per-capability behaviour — the full set of scenarios for a capability, its edge cases, and the reasoning behind each — SHALL remain in `openspec/specs/`, which the README SHALL name as the authoritative source for that detail.

The README SHALL NOT restate a specification's scenarios. Where the README and a spec describe the same behaviour, the spec governs, and the README SHALL be corrected rather than the spec being bent to match it.

#### Scenario: The reader is pointed at the specs

- **WHEN** a reader needs behaviour the README describes only in outline
- **THEN** the README SHALL name `openspec/specs/` as where that detail is specified

#### Scenario: Scenarios are not copied into the README

- **WHEN** the README describes a capability that has a spec
- **THEN** it SHALL summarize the behaviour
- **AND** it SHALL NOT reproduce that spec's requirement and scenario blocks

#### Scenario: A disagreement resolves toward the spec

- **WHEN** the README and a spec under `openspec/specs/` describe the same behaviour differently
- **THEN** the spec SHALL be taken as correct
- **AND** the README SHALL be the document that is changed

### Requirement: The README stands on its own within this directory

The README SHALL be complete for a reader who sees only the Neovim configuration directory, so that it can serve as the source another document draws from rather than as a fragment that only makes sense inside a larger one.

It SHALL confine itself to the Neovim configuration. Setup that belongs to the enclosing repository — how that repository is obtained, staged, or guarded — SHALL NOT be restated here, and the README SHALL NOT require the reader to have read the enclosing repository's own documentation first.

#### Scenario: Complete on its own

- **WHEN** the Neovim configuration directory is read in isolation
- **THEN** the README SHALL be intelligible without any document outside that directory
- **AND** it SHALL NOT defer an explanation of the configuration to a document outside it

#### Scenario: Enclosing-repository concerns stay out

- **WHEN** the README is inspected for instructions belonging to the enclosing repository
- **THEN** it SHALL NOT contain that repository's bootstrap, staging, or commit-guard procedure

### Requirement: The README tracks the configuration it describes

A change that adds, removes, or repurposes something the README names — a plugin, a keymap, an editor-wide convention, a file or directory in the layout, or a step required to reach a working editor — SHALL update the README in that same change.

The README SHALL NOT name a plugin the configuration no longer loads, a key it no longer binds, or a file that no longer exists. A description that has outlived what it describes is worse than none, because it is trusted.

#### Scenario: A change updates the description with the code

- **WHEN** a change alters a plugin, a keymap family, an editor-wide convention, or the file layout
- **THEN** that same change SHALL update the affected part of the README

#### Scenario: No stale references

- **WHEN** the README is checked against the configuration
- **THEN** every plugin, key, and path it names SHALL exist in the configuration
- **AND** nothing it describes SHALL have been removed or renamed without the README following

#### Scenario: Removal is a documentation change too

- **WHEN** a change removes a plugin or a keymap the README documents
- **THEN** that same change SHALL remove it from the README
