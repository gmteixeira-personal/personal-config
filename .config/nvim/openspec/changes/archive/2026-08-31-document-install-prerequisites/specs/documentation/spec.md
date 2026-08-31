## MODIFIED Requirements

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
