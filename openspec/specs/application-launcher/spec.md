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

### Requirement: A query is matched against an entry's keywords

The launcher SHALL match what is typed against the keywords a desktop entry declares, in addition to the fields it matches by default. The set of fields matched SHALL be stated in the launcher's tracked configuration rather than left to the launcher's default.

The launcher's default field list is `filename,name,generic`, which reads an entry's `Keywords=` line and then ignores it. Every entry this repository ships already carries one written on the opposite assumption — `wifi.desktop` offers `ssid` and `wireless`, `calculator.desktop` offers `arithmetic` — and none of those words has ever matched anything. The failure is invisible from either end: the entry looks correct, the launcher returns no match, and nothing reports that a field was skipped.

It matters most for an entry named after an action rather than after a program. A user reaches for whichever word their previous system used — shut down, power off, halt — and only one of those can be the entry's name. A launcher answering to that one word looks like a launcher missing the entry, not like one matching narrowly.

#### Scenario: A keyword finds its entry

- **WHEN** a word declared in an entry's `Keywords=` line is typed into the launcher
- **THEN** that entry SHALL be among the matches

#### Scenario: The field list is not left to the default

- **WHEN** the launcher's tracked configuration is inspected
- **THEN** it SHALL name the entry fields a query is matched against
- **AND** that list SHALL include keywords

#### Scenario: The default fields keep working

- **WHEN** an entry's name, generic name, or desktop file name is typed into the launcher
- **THEN** that entry SHALL still be among the matches

### Requirement: The result list is navigated from the home row

The launcher SHALL move the selection to the previous entry on `Control+k` and to the next entry on `Control+j`.

Every other surface in this session already moves on these letters — the compositor between windows, the shell in vi normal mode, the multiplexer between panes. The launcher is the one reached most often and the only one that made the hand leave the home row for the arrow keys. The launcher offers no modal mode to switch on, so the letters exist only if they are bound.

#### Scenario: The selection moves down

- **WHEN** the launcher is showing more than one match and `Control+j` is pressed
- **THEN** the selection SHALL move to the next entry

#### Scenario: The selection moves up

- **WHEN** an entry below the first is selected and `Control+k` is pressed
- **THEN** the selection SHALL move to the previous entry

### Requirement: The input cursor moves from the home row

The launcher SHALL move the text cursor one character left on `Control+h` and one character right on `Control+l`.

#### Scenario: The cursor moves within the query

- **WHEN** a query has been typed, the cursor is at its end, and `Control+h` is pressed
- **THEN** the cursor SHALL move one character to the left
- **AND** no character SHALL be deleted

#### Scenario: The cursor moves back to the end

- **WHEN** the cursor sits before the last character of the query and `Control+l` is pressed
- **THEN** the cursor SHALL move one character to the right

### Requirement: The keys the launcher already shipped keep working

Binding a key to an action SHALL add to that action's keys rather than replace them. The arrow keys, the emacs pair `Control+p`/`Control+n`, the emacs pair `Control+b`/`Control+f`, `BackSpace`, `Delete`, and the word-wise deletions SHALL all keep the behaviour they had.

The launcher takes a list of key combinations per action, and writing a single combination for an action silently drops every combination that action had by default. The failure is quiet: the new key works, so the binding looks correct, and the loss is only noticed later by a hand reaching for an arrow key out of habit.

#### Scenario: The arrows still navigate

- **WHEN** the launcher is showing matches and `Up` or `Down` is pressed
- **THEN** the selection SHALL move by one entry in that direction

#### Scenario: The emacs keys still work

- **WHEN** `Control+p`, `Control+n`, `Control+b`, or `Control+f` is pressed
- **THEN** each SHALL perform the action it performed before the vim letters were bound

#### Scenario: A character is still deleted backward

- **WHEN** a query has been typed and `BackSpace` is pressed
- **THEN** the character before the cursor SHALL be deleted

### Requirement: Clearing the input is one key, and the half-line kills are gone

The launcher SHALL clear the entire query on `Control+d`, regardless of where the cursor sits. The launcher SHALL NOT bind any key to deleting from the cursor to one end of the query.

A launcher query is a single short line. Deleting to one end of it is a distinction that earns no key here — the useful destructive edit is starting over, and the two half-line kills between them held the `Control+u` and `Control+k` that the vim letters and the whole-line clear are worth more of. Word-wise deletion on `Control+w` covers the case where only the last word was wrong.

#### Scenario: The query is cleared from anywhere in it

- **WHEN** a query has been typed, the cursor has been moved into the middle of it, and `Control+d` is pressed
- **THEN** the entire query SHALL be cleared
- **AND** the text after the cursor SHALL NOT be left behind

#### Scenario: No key deletes half a line

- **WHEN** the launcher's tracked configuration is inspected
- **THEN** deleting from the cursor to the start of the query SHALL be bound to no key
- **AND** deleting from the cursor to the end of the query SHALL be bound to no key

### Requirement: A key taken over is accounted for, not left to collide

Where a key this configuration binds already carried one of the launcher's own actions, the tracked configuration SHALL state what that action was and where it went. No key SHALL be bound to two actions.

The launcher refuses to start when a combination appears twice, so a collision does not degrade the launcher — it removes it, at the moment it is pressed, with the session's most-used surface simply not appearing. Two of the four letters bound here were already carrying an action, as was the `Control+d` the whole-line clear now takes, which makes the reassignments the substance of this change rather than a footnote to it. Recorded only as a diff against the launcher's defaults, they are unreadable to the next person editing the file, who has no reason to suspect that `Control+h` was ever a deletion.

#### Scenario: The launcher's configuration is accepted

- **WHEN** the launcher's configuration is checked
- **THEN** the check SHALL report no error
- **AND** no combination SHALL be reported as bound more than once

#### Scenario: The configuration explains a reassignment

- **WHEN** the launcher's tracked configuration is read
- **THEN** for each key this configuration binds that already carried one of the launcher's own actions, it SHALL name that action
- **AND** it SHALL state which key that action is reached by now, or that it is no longer bound
