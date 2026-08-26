## Purpose

Takes the command line, the editor's messages, its notifications, and the command-line completion list off the single bottom screen row they share and gives each its own floating view, so that a long message is read by scrolling rather than by acknowledging a `Press ENTER` prompt, a message that has scrolled past can be recalled instead of being lost, and the `:` prompt is typed into near the middle of the screen rather than at its far edge.

## ADDED Requirements

### Requirement: The command line is a floating input, not the bottom screen row

Entering command-line mode SHALL open a floating input near the centre of the editor rather than writing to the last screen row. The input SHALL show the character that opened it — `:`, `/`, `?`, `=`, or the one that opens a filter command — so that which command line is active is readable without recalling which key was pressed.

The last screen row SHALL NOT be reserved for the command line while no command line is open; the row SHALL be available to the buffer.

Everything about what the command line *does* SHALL be unchanged: the text typed SHALL be the text executed, command-line history SHALL be reachable by the same keys and SHALL record entries as before, completion SHALL be requested by the same key, and abandoning the line SHALL execute nothing.

#### Scenario: Opening a command line

- **WHEN** the user presses `:`
- **THEN** a floating input opens away from the bottom edge of the editor
- **AND** it is marked as a command line
- **AND** the character typed next appears in it

#### Scenario: Executing a command

- **WHEN** the user types a command in the floating input and presses `<CR>`
- **THEN** the command runs exactly as it would have from the bottom-row command line
- **AND** the input closes

#### Scenario: Abandoning a command line

- **WHEN** the user presses `<Esc>` with text in the input
- **THEN** the input closes
- **AND** no command runs
- **AND** the buffer is unchanged

#### Scenario: Command-line history

- **WHEN** the user opens a command line and presses the history-recall key
- **THEN** the previous entry appears in the input
- **AND** entries executed since the editor started are among those recalled

#### Scenario: The bottom row is not reserved

- **WHEN** no command line is open
- **THEN** the row that would have held it displays buffer content or the status line
- **AND** opening and closing a command line does not resize any window

### Requirement: A search opened from the command line still searches incrementally

`/` and `?` SHALL open the floating input in the same way as `:`, and the search SHALL remain incremental: matches SHALL update in the buffer as the pattern is typed, accepting the search SHALL move the cursor and leave the matches highlighted, and abandoning it SHALL return the cursor to where it started.

#### Scenario: Typing a search pattern

- **WHEN** the user presses `/` and types a pattern that matches text in the buffer
- **THEN** the matching text is highlighted in the buffer as each character is typed
- **AND** the pattern is shown in the floating input

#### Scenario: Accepting a search

- **WHEN** the user presses `<CR>` on a matching pattern
- **THEN** the cursor moves to the match
- **AND** the matches stay highlighted until the highlight is dismissed

#### Scenario: Abandoning a search

- **WHEN** the user presses `<Esc>` part-way through typing a pattern
- **THEN** the cursor is back where it was when the search was opened
- **AND** nothing is highlighted

### Requirement: Editor messages are shown in views that do not block the editor

Messages the editor emits SHALL be presented in a floating view rather than on the last screen row. A message short enough to fit SHALL appear briefly and disappear on its own without a keypress. A message too long for that view SHALL be presented in a scrollable view the user can read at their own pace and dismiss.

Routine messages SHALL NOT produce a `Press ENTER or type command to continue` prompt.

Errors SHALL remain visible: an error message SHALL be presented in a way that distinguishes it from an ordinary message and SHALL NOT be suppressed or silently discarded.

#### Scenario: A short message

- **WHEN** a command emits a one-line message, such as the count of lines written by a save
- **THEN** the message appears in a floating view
- **AND** it disappears on its own without the user pressing a key

#### Scenario: A long message

- **WHEN** a command emits output longer than the screen, such as a full option or mapping listing
- **THEN** the output is shown in a scrollable view
- **AND** the user can scroll through it and dismiss it
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

A notification SHALL NOT take focus, move the cursor, or alter the window layout.

#### Scenario: A single notification

- **WHEN** a component raises a notification
- **THEN** it appears as a bordered view in a corner of the editor
- **AND** it disappears on its own after a period

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

### Requirement: Messages and notifications can be recalled after they are gone

A message or notification that has disappeared SHALL still be retrievable. The user SHALL be able to open, from a mapping and without typing a command:

- the full history of messages emitted this session,
- the most recent message on its own,
- the history of notifications raised this session,

and SHALL be able to dismiss everything currently displayed. Each SHALL be reachable under a single `<leader>` prefix, and that prefix SHALL NOT be bound to a command of its own, so that pressing it executes nothing and the sequence completes on the next key.

Each history SHALL be scrollable and SHALL be searchable by the editor's ordinary means once open. Opening a history SHALL NOT clear it.

#### Scenario: Recalling a message that has disappeared

- **WHEN** a message has appeared and timed out
- **AND** the user opens the message history
- **THEN** that message is listed in it

#### Scenario: The last message

- **WHEN** the user invokes the last-message mapping
- **THEN** the most recent message is displayed in full, including the part that was truncated when it first appeared

#### Scenario: Notification history

- **WHEN** several notifications have been raised and have expired
- **AND** the user opens the notification history
- **THEN** each is listed with its text

#### Scenario: History survives being read

- **WHEN** the user opens a history, closes it, and opens it again
- **THEN** the same entries are still listed

#### Scenario: The prefix runs nothing

- **WHEN** the user presses the prefix these mappings live under and pauses
- **THEN** no command has run
- **AND** the mappings under it are listed with their descriptions

### Requirement: The command-line completion list is drawn as a popup

When completion is requested on the command line, the candidates SHALL be presented in a floating list near the command-line input rather than as a single row of words along the bottom of the screen. Selecting among them SHALL use the keys the editor already uses for command-line completion, and accepting a candidate SHALL insert exactly the text the editor would have inserted.

This SHALL apply to the command line only. Insert-mode completion SHALL be untouched — it is `completion`'s, and no candidate list, key, or source of it changes here.

#### Scenario: Completing a command name

- **WHEN** the user types a partial command name and presses the completion key
- **THEN** the candidates are listed in a floating popup
- **AND** cycling through them with the usual keys fills each into the input in turn

#### Scenario: Completing a path

- **WHEN** the user types a partial filename as a command argument and requests completion
- **THEN** the matching paths are listed in the popup
- **AND** accepting one inserts exactly that path

#### Scenario: Insert-mode completion is unaffected

- **WHEN** the user types an identifier prefix in insert mode
- **THEN** the insert-mode candidate list appears as it did before this capability existed
- **AND** its keys and its sources are unchanged

### Requirement: The presentation follows the active colorscheme

Every view this capability draws — the command-line input, the message views, the notifications, and the completion popup — SHALL take its colours from the active colorscheme. Switching colorscheme SHALL restyle them with no further configuration and without restarting the editor.

#### Scenario: Switching colorscheme

- **WHEN** the user switches to another colorscheme and then opens a command line
- **THEN** the input is drawn in the new colorscheme's colours

#### Scenario: A notification after a switch

- **WHEN** a notification is raised after a colorscheme switch
- **THEN** it is drawn in the new colorscheme's colours

### Requirement: The capability changes presentation only

Routing a message or a command line through a floating view SHALL NOT change the meaning of any keystroke, the effect of any command, or the contents of any buffer. In particular:

- A key that is not a command-line or message action SHALL do exactly what it did before.
- A macro SHALL record and replay a command-line sequence unchanged, and the fact that a recording is in progress SHALL remain visible to the user.
- Text typed while a message view or a notification is on screen SHALL be inserted in full, in order, into the buffer that has focus.
- The command-line window, opened with `q:` or from the command line itself, SHALL still open and behave as the editor defines it.

#### Scenario: Recording a macro

- **WHEN** the user records a macro containing a `:` command and replays it
- **THEN** the command runs on replay exactly as it did when recorded
- **AND** while recording, the user can see that a recording is in progress

#### Scenario: Typing over a notification

- **WHEN** a notification is on screen and the user types into the buffer
- **THEN** every character is inserted, in order
- **AND** none is consumed by the notification

#### Scenario: The command-line window

- **WHEN** the user presses `q:`
- **THEN** the command-line window opens with the command history as an editable buffer
- **AND** executing a line from it runs that command

#### Scenario: A prompt that requires an answer

- **WHEN** a command asks the user a question that must be answered, such as the save/discard/cancel dialog on a modified buffer
- **THEN** the question is displayed
- **AND** the user's answer is read and acted on

### Requirement: Startup messages are captured, and startup errors are still shown

The component providing this capability SHALL be active early enough that messages emitted during startup are routed through it and appear in the message history, rather than being written to the bottom row before it loads.

An error raised before or while this capability loads SHALL still reach the user by whatever means the editor has at that moment; a failure in this capability SHALL NOT leave the editor unable to report errors.

#### Scenario: A startup message

- **WHEN** a component emits a message during startup
- **AND** the user opens the message history afterwards
- **THEN** that message is listed

#### Scenario: This capability fails to load

- **WHEN** the component providing this capability fails to load
- **THEN** the failure is reported to the user
- **AND** the editor remains usable with its built-in command line and messages

### Requirement: The capability is declared in its own plugin file

Everything this capability needs — the component, its notification backend, its view configuration, and its mappings — SHALL be declared in a single file under `lua/plugins/`, other than the one line naming its `<leader>` prefix for `keymap-hints`. Deleting that file SHALL restore the editor's built-in command line, messages, notifications, and command-line completion list, and SHALL leave every other capability working.

#### Scenario: Locating the configuration

- **WHEN** a contributor looks for where this capability is configured
- **THEN** all of it is in one file under `lua/plugins/`

#### Scenario: Removing the capability

- **WHEN** that file is deleted and the editor is restarted
- **THEN** the command line, messages, and notifications are the editor's built-in ones
- **AND** no error is raised
- **AND** every other mapping behaves as it did
