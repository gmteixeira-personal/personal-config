## ADDED Requirements

### Requirement: The focused pane is closed with prefix+q

The prefix followed by `q` SHALL close the focused pane. The action SHALL be the one herdr's shipped `prefix+x` performed — the pane and the process it runs are ended, and the remaining panes take its space — and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key closes the focused pane

- **WHEN** the prefix is pressed followed by `q` in a tab holding more than one pane
- **THEN** the focused pane SHALL be closed
- **AND** the surviving panes SHALL take its space
- **AND** focus SHALL move to one of them

#### Scenario: The key does not detach

- **WHEN** the prefix is pressed followed by `q`
- **THEN** the session SHALL NOT detach
- **AND** the terminal SHALL still be showing herdr afterwards

#### Scenario: The shipped key no longer closes a pane

- **WHEN** the prefix is pressed followed by `x`
- **THEN** no pane SHALL be closed

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `close_pane` to `prefix+q`

### Requirement: The active workspace is closed with prefix+d

The prefix followed by `d` SHALL close the active workspace, after asking for confirmation. The action SHALL be the one herdr's shipped `prefix+shift+d` performed, and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key closes the active workspace

- **WHEN** the prefix is pressed followed by `d` and the confirmation is accepted
- **THEN** the active workspace SHALL be closed with its tabs and panes
- **AND** another workspace SHALL become active

#### Scenario: The confirmation still guards it

- **WHEN** the prefix is pressed followed by `d`
- **THEN** a confirmation SHALL be asked for before anything is closed
- **AND** declining it SHALL leave the workspace, its tabs, and its panes intact

#### Scenario: The shipped chord detaches instead of closing

- **WHEN** the prefix is pressed followed by `shift` and `d`
- **THEN** no workspace SHALL be closed
- **AND** the session SHALL detach

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `close_workspace` to `prefix+d`

### Requirement: The active tab is closed with prefix+shift+q

The prefix followed by `shift` and `q` SHALL close the active tab with the panes in it. The action SHALL be the one herdr's shipped `prefix+shift+x` performed, and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key closes the active tab

- **WHEN** the prefix is pressed followed by `shift` and `q` in a workspace holding more than one tab
- **THEN** the active tab SHALL be closed with its panes
- **AND** another tab of that workspace SHALL become active

#### Scenario: The shipped chord no longer closes a tab

- **WHEN** the prefix is pressed followed by `shift` and `x`
- **THEN** no tab SHALL be closed

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `close_tab` to `prefix+shift+q`

### Requirement: The session is detached with prefix+shift+d

The prefix followed by `shift` and `d` SHALL detach the session, leaving it running for a later attach. Its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key detaches

- **WHEN** the prefix is pressed followed by `shift` and `d`
- **THEN** the session SHALL detach
- **AND** the shell that launched herdr SHALL be shown

#### Scenario: The detached session survives

- **WHEN** the session is reattached after such a detach
- **THEN** its workspaces, tabs, and panes SHALL be as they were
- **AND** the processes running in them SHALL still be running

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `detach` to `prefix+shift+d`

### Requirement: Moving between tabs is unaffected

Moving the closing and detach keys SHALL NOT change how focus moves between tabs. Every tab navigation key SHALL keep the key it has.

#### Scenario: Moving between tabs is untouched

- **WHEN** the prefix is pressed followed by `n`, by `p`, or by a digit
- **THEN** focus SHALL move to the next tab, the previous tab, or the tab at that position, as before this change

#### Scenario: No custom command block is disturbed

- **WHEN** the prefix is pressed followed by `\`, `e`, `=`, or `+`
- **THEN** the same action SHALL run as ran before this change
- **AND** no `[[keys.command]]` block SHALL have had its `key` value changed

### Requirement: The closing keys survive a restore and a reload

All four bindings SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine has the keys

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the prefix followed by `q` SHALL close the focused pane, `shift` and `q` the active tab, `d` the active workspace, and `shift` and `d` SHALL detach, with no further setup

#### Scenario: The bindings apply without restarting

- **WHEN** the bindings are added and herdr is asked to reload its configuration
- **THEN** all four keys SHALL work in the running server
- **AND** open sessions SHALL survive the reload
