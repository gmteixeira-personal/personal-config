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

Everything in herdr's configuration directory other than the configuration file SHALL remain ignored. That state is machine-local, is recreated on demand, and in the case of the sockets is not a regular file at all.

#### Scenario: Runtime state stays ignored

- **WHEN** the client and server sockets, the log files, the session record, and the plugin lock in that directory are checked
- **THEN** each SHALL be reported as ignored

#### Scenario: Only the configuration file is offered

- **WHEN** `git status` lists untracked files with the directory populated by a running herdr
- **THEN** the only path from that directory it may list SHALL be the configuration file

### Requirement: The prefix key is ctrl+f

herdr's prefix key SHALL be `ctrl+f`. The shipped default of `ctrl+b` SHALL NOT apply, and the binding SHALL be declared in the tracked configuration file so it survives a reinstall and reaches every machine.

#### Scenario: The prefix is bound

- **WHEN** the herdr configuration is read
- **THEN** its keys section SHALL name `ctrl+f` as the prefix

#### Scenario: A prefixed action responds to it

- **WHEN** `ctrl+f` is pressed and followed by the key of a prefixed action
- **THEN** that action SHALL run
- **AND** pressing `ctrl+b` first SHALL NOT run it

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
