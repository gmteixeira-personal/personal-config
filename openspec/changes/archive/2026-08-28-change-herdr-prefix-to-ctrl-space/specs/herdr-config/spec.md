## ADDED Requirements

### Requirement: The prefix key is ctrl+space

herdr's prefix key SHALL be `ctrl+space`. The shipped default of `ctrl+b` SHALL NOT apply, nor SHALL the previous `ctrl+f`, and the binding SHALL be declared in the tracked configuration file so it survives a reinstall and reaches every machine.

#### Scenario: The prefix is bound

- **WHEN** the herdr configuration is read
- **THEN** its keys section SHALL name `ctrl+space` as the prefix

#### Scenario: A prefixed action responds to it

- **WHEN** `ctrl+space` is pressed and followed by the key of a prefixed action
- **THEN** that action SHALL run
- **AND** pressing `ctrl+b` or `ctrl+f` first SHALL NOT run it

#### Scenario: Every existing prefixed action keeps its second key

- **WHEN** the new prefix is pressed and followed by `\`, `e`, `=`, `+`, or `shift` and a digit from 1 to 9
- **THEN** the same action SHALL run as ran under the previous prefix
- **AND** no `[[keys.command]]` block SHALL have had its `key` value changed

#### Scenario: The released key reaches the pane

- **WHEN** `ctrl+f` is pressed in a pane running a program that binds it
- **THEN** herdr SHALL NOT consume it
- **AND** the program in the pane SHALL receive it

#### Scenario: A change applies without restarting

- **WHEN** the prefix is changed in the configuration file and herdr is asked to reload its configuration
- **THEN** the new prefix SHALL take effect in the running server
- **AND** open sessions SHALL survive the reload

## REMOVED Requirements

### Requirement: The prefix key is ctrl+f

**Reason**: `ctrl+space` is free now that the Flow Launcher global hotkey on the Windows host moved to `shift+space`, and it is a better prefix than `ctrl+f` — a two-hand chord reachable with either thumb, leaving the left hand free for the second key of every prefixed action.

**Migration**: Replaced by "The prefix key is ctrl+space" in this same capability. Press `ctrl+space` wherever `ctrl+f` was pressed; every second key is unchanged.
