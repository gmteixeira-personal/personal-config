## ADDED Requirements

### Requirement: Zoom is reachable from prefix+backslash

Pressing the prefix followed by `\` SHALL toggle zoom on the focused pane. The action SHALL be the same one the built-in zoom key performs — the focused pane fills its tab, and pressing the key again restores the previous layout — and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key zooms the focused pane

- **WHEN** the prefix is pressed followed by `\` in a tab holding more than one pane
- **THEN** the focused pane SHALL fill the tab
- **AND** the other panes of that tab SHALL be hidden while it is zoomed

#### Scenario: The key restores the layout

- **WHEN** the prefix is pressed followed by `\` while the focused pane is zoomed
- **THEN** the tab SHALL return to the pane sizes it had before the zoom
- **AND** focus SHALL stay on the same pane

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** it SHALL declare a binding for `\` that toggles zoom

### Requirement: The built-in zoom key keeps working

Adding the second key SHALL NOT remove or rebind herdr's built-in zoom key. Both keys SHALL toggle the same state, so alternating between them SHALL behave as pressing either one twice.

#### Scenario: The built-in key still zooms

- **WHEN** the prefix is pressed followed by `z`
- **THEN** the focused pane SHALL toggle zoom exactly as it did before this change

#### Scenario: The two keys share one state

- **WHEN** a pane is zoomed with one of the two keys and the other key is then pressed
- **THEN** the pane SHALL be unzoomed
- **AND** no second zoom SHALL be stacked on the first

### Requirement: The binding survives a restore and a reload

The binding SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine has the key

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the prefix followed by `\` SHALL toggle zoom with no further setup

#### Scenario: The binding applies without restarting

- **WHEN** the binding is added and herdr is asked to reload its configuration
- **THEN** the key SHALL work in the running server
- **AND** open sessions SHALL survive the reload
