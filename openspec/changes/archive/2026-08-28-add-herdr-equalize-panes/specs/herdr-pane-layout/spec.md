## Purpose
Defines how the panes of a herdr tab are sized relative to one another as panes are split and closed, whether that sizing happens automatically or only on request, and how both the automatic behaviour and a one-shot equalize are driven from the keyboard.

## ADDED Requirements

### Requirement: Automatic equalizing has two states

Pane sizing SHALL be in one of two states: an automatic state in which the panes of a tab are re-equalized whenever the tab's set of panes changes, and a manual state in which nothing is resized unless an equalize is asked for. The automatic state SHALL be the state in effect when neither has been chosen.

#### Scenario: The automatic state is the default

- **WHEN** the equalizing behaviour has been installed and neither state has been selected
- **THEN** the automatic state SHALL be in effect

#### Scenario: The state survives a reload

- **WHEN** a state is selected and herdr reloads its configuration or a client reattaches
- **THEN** that state SHALL still be in effect
- **AND** selecting a state SHALL NOT require a reload to take effect

### Requirement: Equal columns first, then equal rows within each column

Equalizing a tab SHALL give every column the same width, and then every row within a column the same height. A column SHALL count as one column however many panes are stacked inside it: the space a divider separates SHALL be divided among the columns or rows on either side of it, never among the panes on either side of it.

This SHALL be the rule wherever equalizing happens — the automatic state and a requested equalize SHALL produce the same layout from the same tab.

#### Scenario: A stacked column is still one column

- **WHEN** a tab holds three columns and the middle one is split into three stacked panes, and the tab is equalized
- **THEN** each of the three columns SHALL be approximately one third of the tab's width
- **AND** the middle column SHALL NOT be wider than the other two
- **AND** the three panes stacked inside it SHALL each be approximately one third of that column's height

#### Scenario: Three columns come out in thirds

- **WHEN** a pane occupying a whole tab is split to the right, and one of the resulting panes is split to the right again, and the tab is equalized
- **THEN** each of the three panes SHALL occupy approximately one third of the tab's width
- **AND** the widths SHALL NOT be one half, one quarter, one quarter

#### Scenario: The freed space is shared

- **WHEN** one pane of an equalized tab is closed and the tab is equalized
- **THEN** the surviving columns SHALL again be of equal width
- **AND** the rows within any column SHALL again be of equal height

#### Scenario: The processes survive the redistribution

- **WHEN** panes are re-equalized
- **THEN** only divider positions SHALL change
- **AND** each pane SHALL keep its identity, its position in the tab's arrangement, and the program running in it

### Requirement: The automatic state keeps a tab equalized as it changes

While the automatic state is in effect, a tab SHALL be re-equalized whenever a pane in it is created, closed, moved, or its process exits, without any key being pressed.

#### Scenario: A split keeps the columns even

- **WHEN** the automatic state is in effect and a pane in a tab of equal columns is split to the right
- **THEN** every column SHALL again be of equal width once the split settles

#### Scenario: Splitting inside a column does not widen it

- **WHEN** the automatic state is in effect and a pane is split downward
- **THEN** the rows of that column SHALL be of equal height
- **AND** the column SHALL keep the width it had

#### Scenario: A close re-evens the survivors

- **WHEN** the automatic state is in effect and a pane is closed or its process exits
- **THEN** the tab SHALL be re-equalized without a key being pressed

### Requirement: In the manual state nothing is resized on its own

While the manual state is in effect, herdr's own sizing SHALL stand: creating, closing, or moving a pane SHALL leave every other pane's size untouched. A deliberately uneven layout SHALL survive any number of splits and closes.

#### Scenario: A split behaves as herdr alone would

- **WHEN** the manual state is in effect and a pane is split
- **THEN** the new pane SHALL take half of the pane that was split
- **AND** no other pane in the tab SHALL change size

#### Scenario: An uneven layout is kept

- **WHEN** the manual state is in effect and a pane is resized by hand, then another pane in that tab is closed
- **THEN** the resized proportions SHALL be preserved apart from the space the closed pane released

### Requirement: A single key switches between the states

One prefixed key SHALL move between the two states in either direction, so that the automatic behaviour can be turned off and back on without editing a file or restarting herdr. Neither direction SHALL resize anything by itself: switching into the automatic state leaves the panes as they stand and the tab evens out at the next pane change, so the key never rearranges a layout the moment it is pressed. Each press SHALL report the state it landed in, so the current state is never in doubt.

#### Scenario: Turning the automatic state off

- **WHEN** the automatic state is in effect and the toggle key is pressed
- **THEN** the manual state SHALL take effect
- **AND** a notification SHALL name the manual state
- **AND** no pane SHALL be resized by the press itself

#### Scenario: The report is visible

- **WHEN** the toggle key is pressed
- **THEN** the notification SHALL be drawn where the user is looking, inside herdr's own frame
- **AND** it SHALL NOT be handed to the outer terminal, which may deliver it nowhere

#### Scenario: Turning the automatic state on

- **WHEN** the manual state is in effect with unevenly sized panes and the toggle key is pressed
- **THEN** the automatic state SHALL take effect
- **AND** a notification SHALL name the automatic state
- **AND** the panes SHALL keep the sizes they had until the next pane is created, closed, moved, or exits

### Requirement: Panes can be equalized on demand in either state

Equalizing the current tab once SHALL be available from the keyboard regardless of which state is in effect, so the manual state does not mean resizing panes by hand. That request SHALL be reachable from more than one key, and SHALL NOT change which state is in effect.

#### Scenario: An on-demand equalize in the manual state

- **WHEN** the manual state is in effect with unevenly sized panes and the equalize key is pressed
- **THEN** the panes of the current tab SHALL be equalized
- **AND** the manual state SHALL still be in effect afterwards

#### Scenario: Either key equalizes

- **WHEN** the panes are uneven
- **THEN** pressing `prefix+e` SHALL equalize them
- **AND** pressing `prefix+=` SHALL equalize them
- **AND** neither SHALL be the key that switches between the states

### Requirement: The pane layout behaviour travels with the repository

The plugin providing the behaviour, the script that switches between the states, and the key bindings that reach them SHALL all be tracked in this repository, so that a machine checked out fresh has the behaviour itself and not merely a reference to it. Nothing herdr writes for the plugin SHALL be tracked — its registry names absolute paths and an install timestamp, and its config directory holds the selected state — so the repository SHALL also record the single command that registers the plugin with herdr on a new machine. The selected state SHALL NOT be tracked, being a per-machine runtime choice rather than a preference.

#### Scenario: The plugin is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** the plugin's manifest and its implementation SHALL appear
- **AND** neither herdr's plugin registry nor its per-plugin config directory SHALL appear

#### Scenario: Registering the plugin is documented

- **WHEN** the repository's README is read
- **THEN** it SHALL give the single command that registers the plugin with herdr
- **AND** it SHALL say that the key bindings do nothing until that command has run

#### Scenario: The toggle script is tracked and runnable

- **WHEN** `git ls-files` is inspected
- **THEN** `.config/herdr/herdr-equalize-toggle` SHALL appear
- **AND** the file SHALL be executable

#### Scenario: The key bindings are present

- **WHEN** the tracked herdr configuration is read
- **THEN** it SHALL bind `prefix+plus` to the toggle script
- **AND** it SHALL bind `prefix+e` and `prefix+=` to the plugin's equalize action

#### Scenario: The selected state stays out of the repository

- **WHEN** the file holding the selected state is checked after the toggle has been pressed
- **THEN** it SHALL be reported as ignored
