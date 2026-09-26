## ADDED Requirements

### Requirement: The next workspace is reached with prefix+u

The prefix followed by `u` SHALL make the workspace below the active one in the sidebar's workspace list the active workspace. The action SHALL be herdr's `next_workspace`, which herdr ships unbound, and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key steps down the list

- **WHEN** two or more workspaces exist, the active one is not last in the list, and the prefix is pressed followed by `u`
- **THEN** the workspace directly below it in the list SHALL become the active workspace
- **AND** no workspace, tab, or pane SHALL be created or closed

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `next_workspace` to `prefix+u`

### Requirement: The previous workspace is reached with prefix+i

The prefix followed by `i` SHALL make the workspace above the active one in the sidebar's workspace list the active workspace. The action SHALL be herdr's `previous_workspace`, which herdr ships unbound, and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key steps up the list

- **WHEN** two or more workspaces exist, the active one is not first in the list, and the prefix is pressed followed by `i`
- **THEN** the workspace directly above it in the list SHALL become the active workspace
- **AND** no workspace, tab, or pane SHALL be created or closed

#### Scenario: The keys reverse each other

- **WHEN** the prefix followed by `u` moves to the next workspace, and the prefix followed by `i` is pressed straight after
- **THEN** the workspace that was active before the first key SHALL be active again

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `previous_workspace` to `prefix+i`

### Requirement: The workspace step keys displace nothing

Binding the two step keys SHALL NOT change any other workspace or tab action. The workspace navigation surface, workspace creation and closing, and moving between tabs SHALL keep the keys they have.

#### Scenario: The workspace navigation surface is untouched

- **WHEN** the prefix is pressed followed by `w`
- **THEN** the workspace navigation surface SHALL open, as before this change

#### Scenario: Creating and closing workspaces is untouched

- **WHEN** the prefix is pressed followed by `c` or by `d`
- **THEN** a workspace SHALL be created or closed respectively, as before this change

#### Scenario: Moving between tabs is untouched

- **WHEN** the prefix is pressed followed by `n` or by `p`
- **THEN** focus SHALL move to the next or the previous tab, as before this change
- **AND** the active workspace SHALL NOT change

### Requirement: The workspace step keys survive a restore and a reload

Both bindings SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine has the keys

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the prefix followed by `u` SHALL step to the next workspace and the prefix followed by `i` to the previous one, with no further setup

#### Scenario: The bindings apply without restarting

- **WHEN** the bindings are added and herdr is asked to reload its configuration
- **THEN** both keys SHALL work in the running server
- **AND** open sessions SHALL survive the reload
