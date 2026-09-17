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

### Requirement: Every coloured element of the file manager's chrome states its own foregrounds

Every element of the file manager's chrome that states a background SHALL also state a foreground, rather than leaving the foreground to whatever the terminal's default happens to be. Chrome here means the tab bar and the status bar: the framing the file manager draws around the file list, as against the file list itself.

An element that paints a background and not a foreground is not inheriting a considered value; it is inheriting the colour chosen for ordinary text on the terminal's ordinary background, applied over a background nothing compared it against. The two settings live in different files, are made by different people for different reasons, and neither is wrong on its own — which is why the result is unreadable rather than merely ugly, and why no amount of care in either file alone prevents it.

The rule was already stated as "every element that states a background" rather than by naming the elements that were wrong, on the grounds that the fault is structural. That was borne out: the requirement was written about the status bar, and the tab bar turned out to ship the identical pair of values — a background with no foreground at 1.14:1, and a stated pair at 2.12:1 — and to be excluded only by where the sentence stopped. The scope is widened here so that the next element of the chrome to be looked at is covered before it is looked at, rather than after.

#### Scenario: A badge with a background has a foreground

- **WHEN** the file manager's theme is inspected for an element that states a background colour
- **THEN** that element SHALL also state a foreground colour

#### Scenario: The tab bar is inspected on the same terms

- **WHEN** the file manager's theme is inspected for the colours of the active and the inactive tab
- **THEN** each SHALL state both a foreground and a background

#### Scenario: Text is not the terminal's default

- **WHEN** text is drawn on a coloured background anywhere in the chrome
- **THEN** its colour SHALL NOT be the terminal's default foreground

### Requirement: Text in the file manager's chrome is readable against the background it is drawn on

Text drawn on a coloured background in the file manager's chrome SHALL reach a contrast ratio of at least 4.5:1 against that background.

This is a raised floor. It previously read "measurably more readable than what the program's shipped theme produces", because the shipped values were 1.14:1 and 2.12:1 against a 4.5:1 threshold and stating any value at all was most of the work. The allowance that went with it — a chosen colour MAY fall below the threshold provided the configuration records the measured ratio — is withdrawn, because the case it was written for is gone. It covered white text on the mode badge at 2.65:1, and the dark value the same comment named as the better number reaches 7.08:1 on the same background. Nothing in the configuration now needs the allowance, and leaving it in place would license copying a below-threshold value into each new element instead of copying the one that passes.

The measured ratio SHALL still be recorded beside each colour chosen for legibility, along with the ratio it replaced. Withdrawing the allowance removes the reason a ratio might be uncomfortable to write down; it does not remove the reason to write it down, which is that the next person to touch the value cannot otherwise tell a measured choice from a guess.

#### Scenario: A chosen colour meets the threshold

- **WHEN** the contrast ratio is measured between text in the chrome and the background it is drawn on
- **THEN** it SHALL be at least 4.5:1

#### Scenario: The measured ratio is recorded

- **WHEN** the theme is read around a colour chosen for legibility
- **THEN** it SHALL record the contrast ratio the choice produces
- **AND** it SHALL record the ratio it replaced

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

### Requirement: The tab bar and the status bar are coloured from the same values

The colours of the tab bar SHALL be the colours of the status bar: the active tab SHALL be drawn in the same foreground and background as the mode badge, and the inactive tab in the same foreground and background as the pale chip beside it.

They frame the same window, one along the top and one along the bottom, and they are the only two coloured things in it. Chosen independently they would drift — the same blue in two shades, or the same badge in two foregrounds — and the drift would be visible in a way neither value is wrong enough to explain. Chosen together they read as one piece of chrome, which is what a user reports when they ask for the top to look like the bottom.

The program makes this easy to get wrong rather than hard: it ships the tab bar and the status bar with the same two values, so they start matched and only a partial fix separates them. That is exactly what happened — the status bar was fixed for legibility and the tab bar was left shipped — and the requirement exists so that the next legibility fix to either one is made to both.

The consequence SHALL be accepted rather than worked around: the active tab's foreground is shared with the mode badge and with the position badge at the right end, so a change to that colour is a change to three elements at once, and there is no supported way to change one of them alone.

#### Scenario: The active tab matches the mode badge

- **WHEN** the theme's active tab and its mode badge are compared
- **THEN** they SHALL state the same foreground colour
- **AND** they SHALL state the same background colour

#### Scenario: The inactive tab matches the pale chip

- **WHEN** the theme's inactive tab and the chip beside the mode badge are compared
- **THEN** they SHALL state the same foreground colour
- **AND** they SHALL state the same background colour

#### Scenario: The sharing is recorded

- **WHEN** the theme is read around the tab colours
- **THEN** it SHALL record that those values are the status bar's restated
- **AND** it SHALL record that changing the shared foreground changes the tab bar and the status bar together

### Requirement: The row under the cursor is left alone

The file manager's highlighting of the row under the cursor SHALL NOT be changed by configuration that sets out to improve legibility elsewhere.

It is already the best-contrasted element in the window, at 7.08:1, so a change made in the name of readability would make it worse. It is also not addressable: the program styles that row by reversing the row's own colours rather than by a theme key, so the only lever is the colour every row of that file type is drawn in — which would repaint rows that are not under the cursor to fix one that is.

#### Scenario: The highlight is unchanged

- **WHEN** the file manager's theme is inspected after a legibility change
- **THEN** it SHALL contain no setting for the row under the cursor

#### Scenario: The reason is recorded

- **WHEN** the configuration is read
- **THEN** it SHALL record that the row under the cursor was considered and deliberately left alone

### Requirement: A file yanked in one file manager window is pastable in another

The file manager SHALL share its yank list between the windows open for one user on one machine, so that a file yanked or cut in one window can be pasted from another without repeating the navigation that found it.

Two windows of this file manager are two processes, and a yank list held per process is a yank list that exists only where it was made. The second window is then worse than useless for the task a second window is opened for: the file is on screen in one and unreachable from the other, and the way out is to close it and walk the first window to both places in turn. Sharing the list is what makes the two windows one file manager rather than two.

The sharing SHALL cover cut as well as copy. They are one list in the program, and a rule that moved one and not the other would have the second window able to complete a copy and silently unable to complete a move — a distinction the user has no way to see before pasting.

#### Scenario: A copy crosses windows

- **WHEN** a file is yanked in one file manager window
- **AND** a paste is made in a second window open at another directory
- **THEN** the file SHALL be copied into that directory

#### Scenario: A cut crosses windows

- **WHEN** a file is cut in one file manager window
- **AND** a paste is made in a second window
- **THEN** the file SHALL be moved into that directory

#### Scenario: A window opened afterwards joins in

- **WHEN** a file is yanked, and a further file manager window is opened after the yank
- **THEN** the new window SHALL be able to paste that file

### Requirement: The shared yank list comes from the file manager's own configuration

The sharing SHALL be turned on in the file manager's own configuration, and SHALL NOT be built out of an external clipboard bridge, a wrapper script, or a file the windows write to by hand.

The program already carries this: it publishes the list over a socket its instances share, and the configuration only has to ask. An arrangement outside the program would have to re-implement what is being asked for and would then be wrong in the ways a re-implementation is wrong — a second source of truth for what is yanked, a lifetime that does not match the program's, and paths that survive the windows that meant them.

The configuration file that asks for it SHALL be tracked in this repository. Held only on the machine it was written on, it is indistinguishable from not existing: a checkout gets two windows that do not talk to each other, with nothing recording that they ever did.

#### Scenario: The setting is in the checkout

- **WHEN** the repository is inspected for the file manager's configuration
- **THEN** a tracked file SHALL turn the yank sharing on

#### Scenario: A fresh checkout shares yanks

- **WHEN** the repository is checked out on a machine where the file manager is installed
- **THEN** two of its windows SHALL share a yank list with no further step

#### Scenario: No outside program is in the path

- **WHEN** the configuration that shares the yank list is read
- **THEN** it SHALL name only the file manager's own facility
- **AND** it SHALL NOT invoke a clipboard tool or write the yank list to a file of its own

### Requirement: The shared list outlives the windows, and the configuration says so

The shared yank list SHALL survive every file manager window closing, and the configuration SHALL record that it does, along with how a pending yank is cleared and where a pending one can be read.

This is not the arrangement one would choose; it is the one the program implements, and stating it is the only defence available. Sharing the list is what writes it to disk: the file manager keeps the shared message in a state file and reloads it at startup, so a yank outlives the window that made it, outlives every window closing, and outlives a reboot. With the sharing off, nothing is written at all — durability is a consequence of this change rather than of the program's defaults, which is exactly why the configuration has to own up to it.

The cost SHALL be recorded rather than hedged: one shared list means a cut left pending in a window nobody is looking at is a move that the next paste anywhere completes, and because the list is durable that paste can come days and a reboot later. A user who expects each window to hold its own yank, or expects closing everything to be a reset, is a user who can move a file by accident.

#### Scenario: A yank survives every window closing

- **WHEN** a file is yanked, every file manager window is closed, and a new one is opened
- **THEN** that yank SHALL still be pending
- **AND** a paste SHALL act on it

#### Scenario: Nothing is stored when the sharing is off

- **WHEN** the file manager runs without the yank sharing turned on, and a file is yanked
- **THEN** no yank SHALL be written to its state file

#### Scenario: The configuration states the reach

- **WHEN** the configuration turning on the sharing is read
- **THEN** it SHALL record that the whole yank list, cut included, is shared with every other window
- **AND** it SHALL record that a pending yank survives closing every window and a reboot
- **AND** it SHALL record how a pending yank is cleared, and where a pending one can be read without opening the file manager

### Requirement: Existing windows are not assumed to have joined

Where the sharing is turned on, the configuration SHALL record that it takes effect at the file manager's startup, so that windows already open when the setting was added are not assumed to be part of it.

The file is read once per process. A user who adds the setting and tests it in the two windows already on screen sees it not work, and has no way to tell that from the setting being wrong — which is the failure that sends people looking for a plugin to install.

#### Scenario: The startup requirement is recorded

- **WHEN** the configuration is read
- **THEN** it SHALL state that already-running windows SHALL be restarted before they share anything
