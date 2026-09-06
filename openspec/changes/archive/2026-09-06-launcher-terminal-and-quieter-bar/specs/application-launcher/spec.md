## Purpose

Defines what the session's application launcher must do with the desktop entries it presents — in particular that an entry which asks to be run inside a terminal is given the terminal this session actually runs, rather than one named by a default that assumes a program nobody installed.

## ADDED Requirements

### Requirement: An entry that asks for a terminal is given the session's terminal

The launcher SHALL be configured with a terminal command, and that command SHALL be the terminal this session already runs. Launching a desktop entry that declares it needs a terminal SHALL open that entry in the session's terminal.

The launcher's own default names a terminal through an environment variable. This session sets no such variable and installs no fallback terminal, so the default expands to a command that cannot run. Leaving it unset does not make the launcher pick something sensible; it makes every terminal entry fail. Naming the terminal in tracked configuration is what turns a whole class of entries — editors, monitors, anything console — from silently broken into working.

#### Scenario: A terminal entry launches

- **WHEN** an entry marked as needing a terminal is chosen from the launcher
- **THEN** a terminal window SHALL open
- **AND** the entry's command SHALL be running in it

#### Scenario: The terminal is the session's own

- **WHEN** an entry marked as needing a terminal is launched
- **THEN** the terminal it opens in SHALL be the same terminal the compositor's terminal key opens

#### Scenario: The terminal is not left to the environment

- **WHEN** the launcher's tracked configuration is inspected
- **THEN** it SHALL name the terminal command
- **AND** the command SHALL NOT depend on an environment variable this session does not set

### Requirement: A launcher failure is not silent to the reader of the configuration

Where the launcher's behaviour depends on a setting whose default cannot work in this session, the tracked configuration SHALL record why the setting is present.

This failure gives the user nothing to work with: the launcher closes on selection and no window appears, no error is printed to any log the user reads, and the desktop entry itself is valid. Without a note in the configuration, the next person to tidy the file removes the one line holding it together and reintroduces a bug whose symptom is nothing happening.

#### Scenario: The configuration explains the setting

- **WHEN** the launcher's tracked configuration is read
- **THEN** it SHALL state what breaks without the terminal setting
