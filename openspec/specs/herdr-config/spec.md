# herdr-config Specification

## Purpose
Defines how herdr, the terminal workspace manager these sessions run inside, is configured across machines: which part of its directory is configuration that belongs in this repository, which part is machine-local runtime state that must never enter it, and the prefix key its configuration fixes.

## Requirements

### Requirement: herdr preferences travel with the repository

The herdr configuration file SHALL be tracked, so that preferences set on one machine are present on the next without being rebuilt by hand. The allowlist entry SHALL name that single file rather than its directory.

#### Scenario: The configuration file is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** `.config/herdr/config.toml` SHALL appear

#### Scenario: A restored machine keeps the preferences

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the preferences in the tracked file SHALL be in effect
- **AND** herdr SHALL NOT fall back to its shipped defaults for any setting the file names

### Requirement: herdr runtime state is never tracked

Everything in herdr's configuration directory other than the configuration file and the scripts its keybindings invoke SHALL remain ignored. That state is machine-local, is recreated on demand, and in the case of the sockets is not a regular file at all. A script bound to a key is neither: it is configuration in executable form, it belongs beside the file that names it, and it SHALL be tracked.

Plugin trees under that directory SHALL be ignored by name rather than by the default deny, because each managed plugin checkout carries its own repository and git would otherwise offer it as an embedded one.

#### Scenario: Runtime state stays ignored

- **WHEN** the client and server sockets, the log files, the session record, the plugin lock, and the plugin registry in that directory are checked
- **THEN** each SHALL be reported as ignored

#### Scenario: A plugin tree is never offered

- **WHEN** a plugin has been installed and `git status` lists untracked files
- **THEN** it SHALL NOT list the plugin's checkout
- **AND** the checkout SHALL NOT be stageable as an embedded repository

#### Scenario: Only the configuration file is offered

- **WHEN** `git status` lists untracked files with the directory populated by a running herdr
- **THEN** the only paths from that directory it may list SHALL be the configuration file and the scripts its keybindings invoke

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

- **WHEN** the prefix is pressed and followed by `\`, `e`, `=`, `+`, or `shift` and a digit from 1 to 9
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
