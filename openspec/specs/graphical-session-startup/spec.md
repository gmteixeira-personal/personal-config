# graphical-session-startup Specification

## Purpose

Defines how the Wayland compositor is launched so that systemd's `graphical-session.target` activates, because a compositor started outside that path leaves every graphical user unit permanently unstarted while showing no error anywhere.

## Requirements

### Requirement: Starting the compositor activates the graphical session target

Launching the compositor by name SHALL start a full session: the session environment SHALL be imported into the systemd user manager, and `graphical-session.target` SHALL become active.

Run as a bare command the compositor imports nothing, so the user manager never learns the display variable. Units that are wanted by `graphical-session.target` and conditioned on that variable then stay inactive forever, and enabling them appears to succeed while doing nothing. The failure is silent in both directions: no unit reports an error, and the compositor works normally.

#### Scenario: The target activates

- **WHEN** the compositor is started by typing its name
- **THEN** `graphical-session.target` SHALL be active
- **AND** the systemd user manager SHALL carry the Wayland display variable

#### Scenario: A unit wanted by the target autostarts

- **WHEN** a user unit is enabled with `WantedBy=graphical-session.target` and the compositor is then started by name
- **THEN** that unit SHALL start without further intervention

### Requirement: Compositor subcommands still reach the binary

Whatever makes the bare name start a session SHALL NOT shadow the compositor's own subcommands. Invoking the name with arguments SHALL run the real binary.

The compositor's IPC and configuration checking are invoked as subcommands of the same name. A wrapper that redirected every invocation would break them, and would do so at the moment they are most needed — checking a configuration edit before restarting.

#### Scenario: A subcommand runs the binary

- **WHEN** the compositor name is invoked with arguments, such as its IPC or validation subcommand
- **THEN** the real binary SHALL run with those arguments
- **AND** no session SHALL be started

#### Scenario: The bare name starts a session

- **WHEN** the compositor name is invoked with no arguments
- **THEN** a session SHALL be started
