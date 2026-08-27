## Purpose
Defines how the panes of a herdr tab are sized relative to one another as panes are split and closed, and how an even redistribution is requested on demand rather than waiting for the next structural change.

## ADDED Requirements

### Requirement: Splitting a pane leaves the tab evenly sized

Every pane in a tab SHALL end up with an equal share of the tab after a split, rather than the new pane taking half of only the pane that was split. No pane SHALL be moved and no process running in a pane SHALL be disturbed by the redistribution.

#### Scenario: Two successive vertical splits give three equal columns

- **WHEN** a pane occupying a whole tab is split vertically, and one of the resulting panes is split vertically again
- **THEN** each of the three panes SHALL occupy approximately one third of the tab's width
- **AND** the widths SHALL NOT be one half, one quarter, one quarter

#### Scenario: The processes survive the redistribution

- **WHEN** panes are re-equalized after a split
- **THEN** each pane SHALL keep its identity and the program running in it
- **AND** no pane SHALL change its position in the tab's arrangement

### Requirement: Closing a pane re-equalizes the survivors

When a pane closes, the space it held SHALL be spread evenly across the remaining panes of that tab rather than handed to a single neighbour.

#### Scenario: The freed space is shared

- **WHEN** one of three equal columns is closed
- **THEN** each of the two remaining panes SHALL occupy approximately one half of the tab's width

### Requirement: Panes can be equalized on demand

A manual resize SHALL remain in effect until the next split or close in that tab, and the user SHALL be able to discard it earlier by asking for an equalize directly. That request SHALL be available from a prefixed key so it needs no shell command.

#### Scenario: A manual resize is undone by the key

- **WHEN** a pane is resized by hand and `prefix+E` is then pressed
- **THEN** every pane in the tab SHALL return to an equal share

#### Scenario: A manual resize otherwise sticks

- **WHEN** a pane is resized by hand and no pane in that tab is split or closed afterwards
- **THEN** the resized proportions SHALL remain in effect

### Requirement: The pane layout behaviour travels with the repository

The plugin providing this behaviour SHALL be recorded in this repository so that a machine checked out fresh reaches the same layout behaviour without the plugin set being reconstructed from memory. The plugin's own install tree SHALL NOT be tracked; it is derived by reinstalling from the recorded set.

#### Scenario: The recorded plugin set is present

- **WHEN** `git ls-files` is inspected
- **THEN** `.config/herdr/.plugins.lock` SHALL appear
- **AND** it SHALL name the plugin that provides the equalize behaviour

#### Scenario: The key binding is present

- **WHEN** the tracked herdr configuration is read
- **THEN** it SHALL bind `prefix+E` to the plugin's equalize action
