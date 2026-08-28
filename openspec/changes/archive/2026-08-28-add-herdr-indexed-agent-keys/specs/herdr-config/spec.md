## ADDED Requirements

### Requirement: An agent is reachable by number

The prefix followed by `shift` and a digit from 1 to 9 SHALL focus the agent at that position in the agent panel. The binding SHALL be declared in the tracked configuration file.

#### Scenario: The key focuses an agent

- **WHEN** the prefix is pressed followed by `shift` and a digit naming an agent present in the panel
- **THEN** the pane running that agent SHALL take focus
- **AND** the workspace and tab holding it SHALL become active if they were not already

#### Scenario: A digit with no agent behind it

- **WHEN** the prefix is pressed followed by `shift` and a digit higher than the number of agents in the panel
- **THEN** focus SHALL NOT move

#### Scenario: The numbers follow the panel's order

- **WHEN** the agent panel's order changes because an agent's state changed
- **THEN** the digits SHALL address the new order rather than the order at the time the session started
- **AND** the digit for a given agent MAY therefore differ between one press and the next

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `focus_agent` across the digits 1 to 9

### Requirement: The other numbered keys are unaffected

Adding the agent family SHALL NOT change what the unmodified digits do, and SHALL NOT change how a workspace is selected. The prefix followed by a bare digit SHALL continue to switch tabs, and selecting a workspace by number through the workspace list SHALL continue to work as it does today.

#### Scenario: A bare digit still switches tab

- **WHEN** the prefix is pressed followed by a digit with no modifier
- **THEN** the tab at that position SHALL become active
- **AND** the focused agent SHALL NOT change as a side effect

#### Scenario: The workspace list is untouched

- **WHEN** the workspace list is opened from the prefix and a digit is pressed
- **THEN** the workspace at that position SHALL become active, as before this change

### Requirement: The indexed binding survives a restore and a reload

The binding SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine has the keys

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the numbered agent keys SHALL work with no further setup

#### Scenario: The binding applies without restarting

- **WHEN** the binding is added and herdr is asked to reload its configuration
- **THEN** the keys SHALL work in the running server
- **AND** open sessions SHALL survive the reload
