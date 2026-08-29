## ADDED Requirements

### Requirement: Creating a tab does not ask for a name

Creating a tab SHALL NOT open a name prompt. The prefixed new-tab key SHALL create the tab and focus it in one keystroke, and herdr SHALL name the new tab itself. The setting SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The new-tab key creates a tab directly

- **WHEN** the prefix is pressed followed by `t`
- **THEN** a new tab SHALL be created immediately
- **AND** no name prompt SHALL be shown
- **AND** the new tab SHALL take focus with its shell ready for input

#### Scenario: The new tab carries a name it was given

- **WHEN** a tab is created without a prompt in a workspace that already holds a tab
- **THEN** the tab row SHALL list the new tab with the name herdr assigned it
- **AND** that name SHALL NOT be empty

#### Scenario: The setting is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its `[ui]` section SHALL disable the new-tab name prompt

### Requirement: A tab can still be renamed afterwards

Removing the prompt SHALL NOT remove the ability to name a tab. Renaming SHALL stay available through the same means it is available today, so a name is a later choice rather than a required one.

#### Scenario: A tab is renamed after creation

- **WHEN** a tab created without a prompt is renamed
- **THEN** the tab row SHALL show the new name
- **AND** the name SHALL survive for the life of the tab

### Requirement: Workspace creation keeps its prompt

This change SHALL apply to tabs only. Creating a workspace SHALL continue to ask for a name exactly as it does today, and the configuration SHALL NOT disable that prompt.

#### Scenario: The workspace key still prompts

- **WHEN** the prefix is pressed followed by `c`
- **THEN** the workspace name prompt SHALL be shown, as before this change

### Requirement: The tab prompt setting survives a restore and a reload

The setting SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine creates tabs without a prompt

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the new-tab key SHALL create a tab with no prompt and no further setup

#### Scenario: The setting applies without restarting

- **WHEN** the setting is added and herdr is asked to reload its configuration
- **THEN** tab creation in the running server SHALL stop prompting
- **AND** open sessions SHALL survive the reload
