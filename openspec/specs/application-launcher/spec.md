# application-launcher Specification

## Purpose
Defines what the session's application launcher must do with the desktop entries it presents and what it must look like doing it — that an entry which asks to be run inside a terminal is given the terminal this session actually runs, rather than one named by a default that assumes a program nobody installed, and that the launcher is drawn in the session's own palette rather than the one its package happens to ship.

## Requirements

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

### Requirement: The launcher is drawn in the session's palette

The launcher SHALL be configured with colours drawn from the palette the rest of the session uses, and SHALL NOT be left on the colours its package ships. Every colour the launcher exposes as a setting SHALL be given a value, not only those that are visibly wrong at rest.

The launcher is the surface opened most often and the only one still wearing its upstream theme. That theme is light while the desktop, the bar and the lock screen are all dark, so opening the launcher is a flash of white — the same defect the lock screen's own configuration exists to fix, in the one place it is seen many times a day rather than once.

Setting only the colours that look wrong today is what makes this recur. The launcher's unset colours keep their packaged values, and several of those are reached only in states that are not the resting one — an empty input, a border, a count of matches. Each would arrive light, one state at a time, and read as a new fault rather than as the remainder of this one.

#### Scenario: The launcher opens dark

- **WHEN** the launcher is opened over the desktop
- **THEN** its background SHALL be a dark value from the session's palette
- **AND** it SHALL NOT be lighter than the surface behind it

#### Scenario: No colour is left at the package default

- **WHEN** the launcher's tracked configuration is inspected
- **THEN** every colour setting the launcher defines SHALL be assigned a value

#### Scenario: A state reached only after typing stays in palette

- **WHEN** input is typed into the launcher and a state other than the resting one is shown
- **THEN** the colours of that state SHALL come from the session's palette

### Requirement: The launcher's colours are traceable to their source

The launcher's tracked configuration SHALL record which palette its colour values come from and where this repository's statement of that palette lives.

The session holds one palette across four files in four different formats, and no two of them can share a definition — the compositor reads KDL, the lock screen its own key/value list, the bar CSS, and the launcher an INI file. The palette therefore holds together only because each file names its source; the bar's stylesheet already does this. A file of plausible dark values with no such note cannot be checked against anything, and the next reader has no way to tell a palette value from a guess that happened to look right.

#### Scenario: A reader can trace a colour

- **WHEN** the launcher's tracked configuration is read
- **THEN** it SHALL name the palette the values belong to
- **AND** it SHALL name another tracked file in this repository that uses the same palette
