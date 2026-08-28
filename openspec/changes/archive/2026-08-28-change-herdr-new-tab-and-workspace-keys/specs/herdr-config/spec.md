## ADDED Requirements

### Requirement: A new tab is created with prefix+t

The prefix followed by `t` SHALL create a tab in the active workspace. The action SHALL be the one herdr's shipped `prefix+c` performed — the same tab, created the same way, honouring the same name prompt — and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key creates a tab

- **WHEN** the prefix is pressed followed by `t`
- **THEN** a tab SHALL be created in the active workspace
- **AND** it SHALL become the focused tab

#### Scenario: The shipped key no longer creates a tab

- **WHEN** the prefix is pressed followed by `c`
- **THEN** a tab SHALL NOT be created

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `new_tab` to `prefix+t`

### Requirement: A new workspace is created with prefix+c

The prefix followed by `c` SHALL create a workspace and focus it. The action SHALL be the one herdr's shipped `prefix+shift+n` performed, and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key creates a workspace

- **WHEN** the prefix is pressed followed by `c`
- **THEN** a workspace SHALL be created
- **AND** it SHALL become the active workspace

#### Scenario: The shipped chord is left unbound

- **WHEN** the prefix is pressed followed by `shift` and `n`
- **THEN** a workspace SHALL NOT be created
- **AND** no other action SHALL run in its place

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `new_workspace` to `prefix+c`

### Requirement: The other tab and workspace keys are unaffected

Moving the two creation keys SHALL NOT change any other tab or workspace action. Moving between tabs, renaming, and closing SHALL keep the keys they have, and `prefix+n` SHALL continue to move to the next tab rather than creating anything.

#### Scenario: Moving between tabs is untouched

- **WHEN** the prefix is pressed followed by `n` or by `p`
- **THEN** focus SHALL move to the next or the previous tab, as before this change
- **AND** no tab or workspace SHALL be created

#### Scenario: A bare digit still switches tab

- **WHEN** the prefix is pressed followed by a digit
- **THEN** the tab at that position SHALL become active, as before this change

#### Scenario: No custom command block is disturbed

- **WHEN** the prefix is pressed followed by `\`, `e`, `=`, or `+`
- **THEN** the same action SHALL run as ran before this change
- **AND** no `[[keys.command]]` block SHALL have had its `key` value changed

### Requirement: The creation keys survive a restore and a reload

Both bindings SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine has the keys

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the prefix followed by `t` SHALL create a tab and the prefix followed by `c` SHALL create a workspace, with no further setup

#### Scenario: The bindings apply without restarting

- **WHEN** the bindings are added and herdr is asked to reload its configuration
- **THEN** both keys SHALL work in the running server
- **AND** open sessions SHALL survive the reload
