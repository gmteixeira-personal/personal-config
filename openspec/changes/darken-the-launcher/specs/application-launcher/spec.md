## ADDED Requirements

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
