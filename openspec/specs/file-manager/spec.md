# file-manager Specification

## Purpose

Defines which program this session browses files with and how it is reached: that it is startable without a terminal already open, and what its desktop entry has to declare given that the program ships none of its own.

## Requirements

### Requirement: The session states which program browses files

The session SHALL name a file manager, and that program SHALL be one this session installs.

Nothing named one before. The program was present and usable, and it was still not the session's file manager in any sense a configuration can check — there was no file that said so, so nothing could offer it, list it, or open a directory with it. A tool that only the person who installed it knows about is a tool the session does not have.

#### Scenario: The file manager is identifiable from tracked configuration

- **WHEN** the tracked configuration is inspected for the session's file manager
- **THEN** it SHALL name one program
- **AND** that program SHALL be installed

### Requirement: The file manager is reachable without a terminal

The file manager SHALL be startable from the session's launcher, without a terminal already open and without typing a command.

It is a terminal program, which is what makes this worth requiring rather than assuming. Starting it means having a terminal first, and the session's answer to "start a program without a terminal" is the launcher — the same route locking, powering off, the radios and the calculator already take. A file manager reachable only from a shell is reachable only by someone who did not need a file manager to find their way there.

#### Scenario: The launcher offers it

- **WHEN** the launcher is opened and the file manager's name is typed
- **THEN** the file manager SHALL be among the matches

#### Scenario: Choosing it starts it

- **WHEN** the file manager is chosen from the launcher
- **THEN** it SHALL open in a terminal window
- **AND** no terminal SHALL have to be open beforehand

### Requirement: The desktop entry is provided by this repository

Where the file manager ships no desktop entry of its own, this repository SHALL provide one, and that entry SHALL be tracked here rather than left as untracked local state.

An entry that exists only on the machine it was written on is indistinguishable, from the repository's point of view, from an entry that does not exist: the session cannot be rebuilt from a checkout, and the file is one tidy-up away from being gone with nothing recording that it was ever there. The entries this repository already ships for locking, powering off and the radios are tracked for the same reason.

#### Scenario: The entry is in the checkout

- **WHEN** the repository is inspected for the file manager's desktop entry
- **THEN** the entry SHALL be present as a tracked file

#### Scenario: A fresh checkout has the entry

- **WHEN** the repository is checked out on a machine where the file manager is installed
- **THEN** the launcher SHALL offer the file manager with no further step

### Requirement: The entry asks for a terminal rather than naming one

The file manager's desktop entry SHALL declare that it requires a terminal, and SHALL NOT name a terminal command in what it executes.

The session's launcher is already required to give such an entry the terminal this session runs, so naming one here would state the same answer twice, in a file that has no way to stay in step with the launcher's copy. The entry that opens the editor does name its terminal, and that is not a precedent to follow blindly: it does so because a MIME association makes it launchable by a component that cannot be told which terminal to use, and the file manager has no such association. Where an entry's only route in is the launcher, the launcher's answer is the whole answer.

The consequence SHALL be accepted rather than hedged: this entry works from the launcher and from anything else that honours the terminal declaration, and does not work from a component that picks a terminal off a fixed list. Should the file manager ever be given a MIME association, that is when the question is reopened.

#### Scenario: The entry declares its need

- **WHEN** the file manager's desktop entry is inspected
- **THEN** it SHALL declare that the program requires a terminal

#### Scenario: The entry names no terminal

- **WHEN** the command the entry executes is read
- **THEN** it SHALL be the file manager's own command
- **AND** it SHALL NOT contain the name of a terminal emulator

### Requirement: The entry is found by what it does, not only by its name

The file manager's desktop entry SHALL declare keywords describing the task, so that a query naming the task finds it.

The program's name says nothing about what it is for. A user reaching for a file manager types what they want — files, browse, manager — and the launcher is already required to match a query against an entry's keywords, so an entry without them answers only to a name the user has to have learned first. Every other entry this repository ships carries keywords for this reason.

#### Scenario: A task word finds the entry

- **WHEN** a word describing the task rather than the program is typed into the launcher
- **THEN** the file manager SHALL be among the matches

#### Scenario: The entry hides itself when the program is gone

- **WHEN** the file manager is not installed on the machine
- **THEN** the launcher SHALL NOT offer the entry

### Requirement: The file manager's status bar states its own foregrounds

Every element of the file manager's status bar that states a background SHALL also state a foreground, rather than leaving the foreground to whatever the terminal's default happens to be.

An element that paints a background and not a foreground is not inheriting a considered value; it is inheriting the colour chosen for ordinary text on the terminal's ordinary background, applied over a background nothing compared it against. The two settings live in different files, are made by different people for different reasons, and neither is wrong on its own — which is why the result is unreadable rather than merely ugly, and why no amount of care in either file alone prevents it.

The rule is stated as "every element that states a background" rather than by naming the two elements that are wrong today, because the fault is structural. An element that gains a background later gains this fault with it.

#### Scenario: A badge with a background has a foreground

- **WHEN** the file manager's theme is inspected for an element that states a background colour
- **THEN** that element SHALL also state a foreground colour

#### Scenario: Text is not the terminal's default

- **WHEN** text is drawn on a coloured background in the status bar
- **THEN** its colour SHALL NOT be the terminal's default foreground

### Requirement: Status bar text is readable against the background it is drawn on

Text in the file manager's status bar SHALL be readable against the background it sits on, and SHALL be measurably more readable than what the program's shipped theme produces in this session.

Readable is a floor rather than a target here. The starting point is 1.14:1 for the badges and 2.12:1 for the chips against a 4.5:1 threshold, so any stated value is an improvement and stating one is most of the work. Where a chosen value still falls below the threshold, the configuration SHALL record the measured ratio, so that a value which is better but not yet good is not mistaken for a value that was checked and passed.

#### Scenario: The measured ratio is recorded

- **WHEN** the theme is read around a colour chosen for legibility
- **THEN** it SHALL record the contrast ratio the choice produces
- **AND** it SHALL record the ratio it replaced

#### Scenario: A value below the threshold is marked as such

- **WHEN** a chosen colour produces a ratio below 4.5:1
- **THEN** the configuration SHALL state that it is below the threshold rather than presenting it as sufficient

### Requirement: Colours chosen here do not depend on the terminal's palette slots

Where this configuration chooses a colour for the file manager, it SHALL state a 24-bit value rather than name one of the terminal's sixteen palette slots.

The session's terminal configuration deliberately leaves those slots at the terminal's own defaults, on the recorded reasoning that nothing this session emits asks for one. A colour named by slot is therefore a colour this session has not chosen, and moving the slots later would move it without anyone intending to. A colour the configuration keeps on purpose — because it is the value already on screen and the change is not about it — MAY stay named by slot, and the configuration SHALL say that is why.

Repainting the slots is not an alternative route to this requirement. The unreadable text is unset rather than badly set, so it stays the terminal's default foreground whatever the slots become; the measured ratios against this session's own palette are 1.10:1 and 1.23:1, no better than the 1.14:1 being fixed.

#### Scenario: A chosen colour is a literal

- **WHEN** the theme is inspected for a colour this change selects
- **THEN** it SHALL be a 24-bit value

#### Scenario: A retained colour is explained

- **WHEN** the theme names a palette slot rather than a literal
- **THEN** the configuration SHALL record that the value is being kept rather than chosen

### Requirement: The row under the cursor is left alone

The file manager's highlighting of the row under the cursor SHALL NOT be changed by configuration that sets out to improve legibility elsewhere.

It is already the best-contrasted element in the window, at 7.08:1, so a change made in the name of readability would make it worse. It is also not addressable: the program styles that row by reversing the row's own colours rather than by a theme key, so the only lever is the colour every row of that file type is drawn in — which would repaint rows that are not under the cursor to fix one that is.

#### Scenario: The highlight is unchanged

- **WHEN** the file manager's theme is inspected after a legibility change
- **THEN** it SHALL contain no setting for the row under the cursor

#### Scenario: The reason is recorded

- **WHEN** the configuration is read
- **THEN** it SHALL record that the row under the cursor was considered and deliberately left alone
