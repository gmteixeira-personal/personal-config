## ADDED Requirements

### Requirement: The tab row is hidden while a workspace holds one tab

A workspace showing exactly one tab SHALL NOT draw the tab row, and the line it
occupied SHALL go to the panes below it. The row SHALL return as soon as the
workspace holds a second tab, so the row is drawn exactly when it has something
to distinguish. The setting SHALL be declared in the tracked configuration file
so it reaches every machine.

#### Scenario: One tab draws no row

- **WHEN** a workspace holding exactly one tab is displayed
- **THEN** no tab row SHALL be drawn
- **AND** the line it would have occupied SHALL be part of the pane area

#### Scenario: A second tab brings the row back

- **WHEN** a second tab is created in that workspace
- **THEN** the tab row SHALL be drawn
- **AND** it SHALL list both tabs

#### Scenario: Closing back down to one tab hides it again

- **WHEN** a workspace holding two tabs is reduced to one
- **THEN** the tab row SHALL stop being drawn
- **AND** the remaining tab SHALL keep its panes and their running processes

#### Scenario: The setting is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its `[ui]` section SHALL hide the tab row when a workspace has a
  single tab

### Requirement: Tab actions work while the row is hidden

Hiding the row SHALL NOT disable or rebind any tab action. Creating, renaming,
switching, moving, and closing a tab SHALL work from the same keys as before,
whether or not the row is drawn.

#### Scenario: A tab is created with the row hidden

- **WHEN** the new-tab key is pressed in a workspace showing one tab and no row
- **THEN** a second tab SHALL be created and focused
- **AND** the row SHALL appear listing both tabs

#### Scenario: Switching by number is unaffected

- **WHEN** the prefix is pressed followed by a bare digit
- **THEN** the tab at that position SHALL become active, as before this change

### Requirement: The tab row setting survives a restore and a reload

The setting SHALL come from the tracked configuration file rather than from a
machine-local edit, and SHALL take effect in a running server when herdr is
asked to reload its configuration.

#### Scenario: A restored machine hides the row

- **WHEN** this repository is checked out into a fresh home directory and herdr
  starts with a single tab
- **THEN** no tab row SHALL be drawn, with no further setup

#### Scenario: The setting applies without restarting

- **WHEN** the setting is added and herdr is asked to reload its configuration
- **THEN** the row SHALL disappear in the running server
- **AND** open sessions SHALL survive the reload
