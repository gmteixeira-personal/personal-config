## ADDED Requirements

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
