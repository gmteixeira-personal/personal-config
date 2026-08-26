## MODIFIED Requirements

### Requirement: Editor messages are shown in views that do not block the editor

Messages the editor emits SHALL be presented in a floating view rather than on the last screen row. A message short enough to fit SHALL appear briefly and disappear on its own without a keypress. A message too long for that view SHALL be presented in a scrollable view the user can read at their own pace and dismiss.

The period a short message stays on screen SHALL be long enough to read a single line and SHALL NOT exceed three seconds, so that transient output does not hold a corner of the editor after it has been read. A message that disappears before the user has finished with it SHALL still be recoverable from the history and from the last-message view.

A scrollable view SHALL NOT be timed: it SHALL stay until the user dismisses it, however long that takes.

Routine messages SHALL NOT produce a `Press ENTER or type command to continue` prompt.

Errors SHALL remain visible: an error message SHALL be presented in a way that distinguishes it from an ordinary message and SHALL NOT be suppressed or silently discarded.

#### Scenario: A short message

- **WHEN** a command emits a one-line message, such as the count of lines written by a save
- **THEN** the message appears in a floating view
- **AND** it disappears on its own without the user pressing a key
- **AND** it is gone within three seconds of appearing

#### Scenario: A short message that was missed

- **WHEN** a one-line message has appeared and timed out before the user read it
- **AND** the user invokes the last-message mapping
- **THEN** that message is displayed again in full

#### Scenario: A long message

- **WHEN** a command emits output longer than the screen, such as a full option or mapping listing
- **THEN** the output is shown in a scrollable view
- **AND** the user can scroll through it and dismiss it
- **AND** it does not time out while the user is reading it
- **AND** the editor is not left waiting on a `Press ENTER` prompt

#### Scenario: An error

- **WHEN** a command fails and the editor reports an error
- **THEN** the error is displayed and visually distinguished from an ordinary message
- **AND** it is recorded in the message history

#### Scenario: Successive messages

- **WHEN** two messages are emitted in quick succession
- **THEN** both are shown
- **AND** the second does not silently erase the first

### Requirement: Notifications are stacked, timed, and dismissible

A notification raised by the editor or by any component SHALL appear as a bordered view in a corner of the editor, showing its text and reflecting its severity. Several notifications outstanding at once SHALL be stacked so that each is readable rather than overwriting one another. Each SHALL disappear on its own after a period, without requiring a keypress, and SHALL be dismissible before that period elapses.

That period SHALL be the same one a short message is held for: long enough to read a single line, and no longer than three seconds. A notification and a short message SHALL NOT be held for different lengths of time, so that two overlays that look alike behave alike.

A notification SHALL NOT take focus, move the cursor, or alter the window layout.

#### Scenario: A single notification

- **WHEN** a component raises a notification
- **THEN** it appears as a bordered view in a corner of the editor
- **AND** it disappears on its own within three seconds

#### Scenario: A notification and a message together

- **WHEN** a notification and a short message are raised at the same moment
- **THEN** neither outlives the other on screen

#### Scenario: Several at once

- **WHEN** three notifications are raised before the first has expired
- **THEN** all three are visible, stacked rather than overlapping
- **AND** each carries its own text

#### Scenario: Focus is untouched

- **WHEN** a notification appears while the user is typing in a buffer
- **THEN** the keystrokes are inserted into the buffer
- **AND** the cursor has not moved into the notification

#### Scenario: Dismissing early

- **WHEN** notifications are on screen and the user invokes the dismiss mapping
- **THEN** they are all removed immediately
- **AND** the text they covered is redrawn intact

#### Scenario: A notification that was missed

- **WHEN** a notification has been raised and has expired
- **AND** the user opens the notification history
- **THEN** it is listed there with its text
