## REMOVED Requirements

### Requirement: The repository declares the bar's appearance without owning its module list

**Reason**: The requirement was written when the tracked bar configuration overrode two geometry keys and nothing else, and it forbade exactly the thing the bar has needed since: naming its own modules. The packaged module list is written for a different compositor, and most of its entries cannot start under this session's. Commit `0349715` restated both lists to name the modules that can, which the requirement as written forbids — so the spec has been contradicting the file it governs ever since. Removing two more modules makes that contradiction load-bearing, and it is settled here rather than carried further.

The half of the requirement that was right is not lost. Including the system file rather than copying it, and restating only the keys being overridden, both survive into the requirement that replaces this one, along with the scenario that checks the bar reports doing so at start-up.

**Migration**: Replaced by **The repository declares the bar's appearance and names the modules it shows**, below. No configuration changes to satisfy the replacement that were not already true: the tracked file already includes the system configuration and already names its own modules.

## ADDED Requirements

### Requirement: The repository declares the bar's appearance and names the modules it shows

Tracked configuration for the bar SHALL declare how it looks and how much space it takes, and SHALL name the modules it displays. It SHALL obtain each module's own options from the system configuration by including that file rather than copying it, and SHALL restate only the keys it intends to override.

The module list and the module options are two different things, and only one of them is the repository's business. The packaged list is written for a different compositor: most of its entries cannot start under this session's compositor, and a module that cannot start is still one the bar builds and polls to render nothing. Inheriting that list means shipping a bar whose contents are decided by a file that does not know what is running. Naming the list is the only way to be rid of those entries.

The options are the opposite case. They are long, they belong to a packaged file that updates, and none of them is a decision made here. Copying them in to change a format string would take ownership of every default as a side effect, and the copy would silently stop tracking the packaged file the moment it changed.

#### Scenario: Module options are overridden without copying them

- **WHEN** the tracked bar configuration is inspected
- **THEN** it SHALL include the system configuration rather than replace it
- **AND** it SHALL restate only the module option keys it intends to override

#### Scenario: The module list names what the session can run

- **WHEN** the tracked bar configuration's module lists are inspected
- **THEN** every module named SHALL be one this session's compositor can drive
- **AND** no module SHALL be present that cannot start under it

#### Scenario: The bar starts from the tracked files

- **WHEN** the bar is started
- **THEN** it SHALL report using the tracked configuration and the tracked stylesheet
- **AND** it SHALL report including the system configuration

### Requirement: A module earns its place by being acted on

The bar SHALL carry a module only where the reading it presents is one the user acts on from the bar, or one whose change the user needs to notice without looking. A module presenting a figure that moves continuously and prompts no action SHALL NOT be carried.

The bar is read passively, all day, and every module on it is a standing claim on attention. A percentage that changes every second trains the reader to stop looking, which costs the modules beside it their glanceability too. Load is the clearest case: when it matters, the question is which process, and the bar cannot answer that — the tools that can are one keystroke away. Removing such a module is not hiding information; it is declining to present information in the one place where it cannot be followed up.

This is not a rule against numbers. A battery percentage prompts an action and is worth carrying; a volume level is one the user changes from the bar itself. The test is whether the reading leads anywhere.

#### Scenario: A continuously moving figure with no action is absent

- **WHEN** the bar is displayed
- **THEN** no module SHALL present a continuously varying utilisation figure that the bar offers no way to act on

#### Scenario: A reading that prompts an action is kept

- **WHEN** the bar is displayed on a machine running on battery
- **THEN** the battery reading SHALL be present

#### Scenario: Removing a module removes its whole footprint

- **WHEN** a module is removed from the bar
- **THEN** it SHALL be absent from the tracked module list
- **AND** the tracked configuration SHALL carry no options for it
- **AND** the tracked stylesheet SHALL carry no rules naming it
