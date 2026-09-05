## Purpose

Defines which program provides the graphical session's bar, launcher, lock screen and clipboard history, how the compositor's bindings address it, and what must remain true of the separate components it replaced, so that the session is served by one shell rather than four independent parts and can be returned to those parts without reinstalling anything.

## ADDED Requirements

### Requirement: One shell provides the session's furniture

A single desktop shell SHALL provide the session's bar, launcher, lock screen and clipboard history, and SHALL be started with the graphical session by the compositor.

It SHALL be a shell with explicit support for the compositor in use. A shell that merely targets Wayland in general cannot report workspaces or the focused window, which is most of what a bar is for.

#### Scenario: The shell starts with the session

- **WHEN** the compositor starts
- **THEN** the shell SHALL be started by it
- **AND** the shell SHALL draw its bar on the connected output

#### Scenario: No second bar is started

- **WHEN** the compositor's startup entries are inspected
- **THEN** no other bar SHALL be started alongside it

#### Scenario: The compositor is supported explicitly

- **WHEN** the shell is assessed for suitability
- **THEN** it SHALL carry a backend for the compositor in use, rather than generic Wayland support alone

### Requirement: Bindings address the running shell over its IPC socket

A binding that opens the launcher, the clipboard history or the lock screen SHALL send a message to the already-running shell rather than spawning a new program.

The shell is already running and holds the state these bindings act on. Spawning a separate program per binding would start a second process that cannot see that state, and would reintroduce the per-launch startup cost the single shell exists to avoid.

#### Scenario: A binding opens a panel

- **WHEN** the launcher or clipboard binding is pressed
- **THEN** the running shell SHALL open the corresponding panel
- **AND** no additional program SHALL be launched to draw it

#### Scenario: The lock binding reaches the shell

- **WHEN** the lock binding is pressed
- **THEN** the running shell SHALL lock the session

### Requirement: Clipboard history outlives the window that copied

The session SHALL retain clipboard entries after the window that owned them has closed, and SHALL make them selectable from a panel.

A Wayland selection is owned by the client that set it; when that client exits the selection is gone. Copying in a terminal, closing it, and pasting elsewhere fails on a session with no history, which is the failure this capability exists to remove.

#### Scenario: The source window has closed

- **WHEN** text is copied in a window and that window is then closed
- **THEN** the copied text SHALL still be available from the clipboard panel

#### Scenario: History is reachable from a binding

- **WHEN** the clipboard binding is pressed
- **THEN** a panel of previous clipboard entries SHALL open

### Requirement: A new binding is validated against the compositor's own

A binding introduced for the shell SHALL NOT reuse a key combination the compositor already binds, and the configuration SHALL be validated before the session relies on it.

The compositor rejects a duplicate binding by refusing to load the whole configuration, so an untested collision costs the entire session's configuration rather than the one binding. Validation reports the collision and names both definitions.

#### Scenario: A collision is rejected

- **WHEN** a binding reuses a combination already bound
- **THEN** validation SHALL fail and name both definitions
- **AND** the binding SHALL be moved to a free combination rather than the existing one being displaced

#### Scenario: The configuration validates

- **WHEN** the compositor configuration is validated after the bindings change
- **THEN** it SHALL report the configuration as valid

### Requirement: The replaced components remain installed

The bar, launcher and lock screen the shell replaced SHALL remain installed, and where any of them had configuration, that configuration SHALL remain unchanged.

They are superseded rather than retired: only the session's startup entry and the bindings changed. Keeping them present means the shell can be abandoned by restoring those lines, with nothing to reinstall. This requirement is a record of that reversibility, and is not a judgement on the shell.

#### Scenario: The replaced components are still available

- **WHEN** the machine is inspected for the bar, launcher and lock screen that were replaced
- **THEN** each SHALL still be installed and launchable by name

#### Scenario: A replaced component that had no configuration

- **WHEN** a replaced component ran on its built-in defaults with no configuration file
- **THEN** reverting to it SHALL require restoring only the startup entry or binding that named it
- **AND** no configuration SHALL need to be reconstructed

### Requirement: No unused clipboard backend is carried

Where the shell provides clipboard history natively, a separate clipboard history daemon SHALL NOT be required by this configuration, and any such package installed by mistake SHALL be recorded as unused rather than left to look load-bearing.

An idle daemon that nothing reads is indistinguishable from a working one until the day someone removes it to tidy up, or worse, debugs the clipboard through it.

#### Scenario: The shell needs no external history daemon

- **WHEN** the shell's clipboard implementation is inspected
- **THEN** it SHALL provide history itself
- **AND** SHALL NOT invoke an external clipboard history daemon

#### Scenario: An unused package is recorded

- **WHEN** a clipboard history daemon is installed on the machine but unused
- **THEN** this configuration SHALL record it as unused rather than depend on it
