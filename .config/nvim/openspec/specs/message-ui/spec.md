## Purpose

Takes the command line, the editor's messages, its notifications, and the command-line completion list off the single bottom screen row they share and gives each its own floating view, so that a long message is read by scrolling rather than by acknowledging a `Press ENTER` prompt, a message that has scrolled past can be recalled instead of being lost, and the `:` prompt is typed into near the middle of the screen rather than at its far edge.

## Requirements

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

### Requirement: The command line keeps its zero rows under a front end that writes the option back

Where the graphical front end this session runs restores the command-line height it read at startup, and that restoration lands after this capability has set the height to zero, the configuration SHALL set it back.

This capability's first requirement is that the command line is a floating input rather than the bottom screen row, and the zero height is what frees that row. A front end that writes the height back does not merely differ cosmetically from the terminal: it reinstates the row the requirement exists to remove, and the row is empty, because the input it would hold is drawn in the float. Below the status line it reads as the window being wrongly sized rather than as an option being wrong.

The correction SHALL be driven by the option changing rather than by a delay chosen to land after the front end's startup, and SHALL survive the front end writing the value more than once. It SHALL stop watching the option once startup is over, so that a later deliberate change to the command-line height is left alone.

#### Scenario: The row is not left behind

- **WHEN** the editor has started under that front end and has settled
- **THEN** the command-line height SHALL be zero
- **AND** no empty row SHALL be drawn between the status line and the bottom of the window beyond the window's own leftover

#### Scenario: More than one write is survived

- **WHEN** the front end writes the command-line height back more than once during startup
- **THEN** the height SHALL still be zero afterwards

#### Scenario: A later change is left alone

- **WHEN** the command-line height is set deliberately after startup is over
- **THEN** it SHALL keep the value it was given

#### Scenario: The terminal is unaffected

- **WHEN** the editor is started in a terminal
- **THEN** the correction SHALL do nothing
- **AND** the command-line height SHALL be what it was before

### Requirement: The command line and the messages are taken under a front end that claims them only while it starts

Where the graphical front end this session runs attaches its UI declaring that it externalises the command line or the messages, and then stops declaring it, this capability SHALL take those widgets once the declaration is withdrawn.

The component decides which widgets to take by reading the front end's declaration once, as it attaches, and a widget it sees claimed is a widget it does not take for the rest of the session. The front end's declaration stands for roughly the first tenth of a second and is gone afterwards, which is inside the window where that single read happens. The outcome is not a degraded command line but the editor's built-in one: the floating input never appears, the bottom screen row comes back, and nothing reports it, because from the component's point of view it did as it was told.

Re-taking SHALL be driven by the declaration actually being withdrawn rather than by a delay chosen to outlast the front end's startup, SHALL stop once it has been withdrawn, and SHALL give up rather than wait indefinitely if it never is. Giving up SHALL leave the capability as it was found.

#### Scenario: The floating command line appears under the front end

- **WHEN** the editor has started under that front end and `:` is pressed
- **THEN** the command line SHALL be drawn as a floating input
- **AND** it SHALL NOT be drawn on the bottom screen row

#### Scenario: The widgets are actually held

- **WHEN** the capability is inspected after startup under that front end
- **THEN** it SHALL report that it holds the command-line and message widgets
- **AND** what it reports SHALL match what it reports in a terminal

#### Scenario: A front end that keeps the claim is left alone

- **WHEN** the front end does not withdraw its declaration
- **THEN** the capability SHALL stop trying
- **AND** it SHALL be left in the state the front end's declaration produced

#### Scenario: The terminal is unaffected

- **WHEN** the editor is started in a terminal
- **THEN** the capability SHALL take the same widgets it took before
- **AND** nothing SHALL be re-taken

### Requirement: A self-diagnosis is silenced only after the condition it names has been corrected

Where the component providing this capability reports that it cannot work under the front end this session runs, that report SHALL NOT be silenced on the grounds that a later reading of the same state disagrees with it. It MAY be silenced only once the configuration corrects the condition the report names, and only because the report is then describing a state that no longer holds.

The distinction is the whole requirement. A report raised inside a window and a reading taken after that window has closed are not the same measurement, and the second is not evidence about the first. Treating it as evidence is what turned a correct report into a suppressed one and left the capability inert under the front end with nothing saying so.

The silencing SHALL be scoped to the front end where the correction is applied, and SHALL NOT be reachable without it: whatever carries the correction and whatever carries the silencing SHALL be read as one thing, and the configuration SHALL state that the second is not a substitute for the first.

The check that produces the report SHALL keep running, and its findings SHALL remain reachable through the editor's health report. The silencing SHALL be established against the notifications the notification backend actually holds after a start under that front end; a message-routing filter matching the report's text SHALL NOT be accepted as evidence, because the component raises these reports by calling the backend directly and they never reach the routing layer.

#### Scenario: The condition is corrected first

- **WHEN** the configuration silencing the report is read
- **THEN** it SHALL name the correction that makes the report stale
- **AND** it SHALL state that the silencing does not stand without it

#### Scenario: The report is not shown once corrected

- **WHEN** the editor is started under that front end
- **THEN** no notification of the report SHALL be shown
- **AND** the capability SHALL hold the widgets the report said it could not

#### Scenario: Verified at the surface the user sees

- **WHEN** the silencing is checked
- **THEN** it SHALL be checked against the notifications the backend holds after a start under that front end
- **AND** a filter matching the report's text SHALL NOT be accepted as evidence on its own

#### Scenario: The check still runs

- **WHEN** the editor's health report for this capability is run under that front end
- **THEN** it SHALL still report what the check found

#### Scenario: Unrelated errors are unaffected

- **WHEN** this capability raises any other error
- **THEN** it SHALL be shown as it was before

### Requirement: The command-line input is highlighted for the kind of input it is, and what that needs is written down

The floating command-line input SHALL be syntax-highlighted according to what is being entered: a search pattern as a regular expression, a shell command line as shell. Where the editor bundles neither the grammar nor its highlighting query for one of those languages, this capability SHALL NOT gain a parser-management plugin; the files SHALL be installed on the machine, outside this repository, and the configuration SHALL record what they are and how to produce them.

A compiled grammar is not a thing to track here, and a highlighting query belongs to a version of a grammar rather than to this configuration. That leaves the repository able to hold only the statement of what is required, which is precisely what was missing: the two languages were absent on the machine for as long as this capability existed, the editor's health report said so on every run, and the configuration said the opposite.

The record SHALL name both halves. A grammar on its own changes nothing — this capability asks for the language's highlighting query and gives up quietly when there is none — so naming only the grammar describes a state that still renders the input as plain text. It SHALL name the paths both halves are installed at, the command that produces the grammar, and where the query comes from.

The grammar SHALL be pinned to the revision the query is written against, and the record SHALL say why: a query matches a grammar's node names, and a newer grammar can rename a node and leave the query matching nothing, which fails as unhighlighted text rather than as an error.

Absence SHALL remain a degradation rather than a fault. On a machine without the files, the affected inputs SHALL render unhighlighted, every other part of this capability SHALL work, and the editor's health report SHALL be what says they are missing.

#### Scenario: A search pattern is highlighted

- **WHEN** a search is opened from the floating command line and a pattern is typed
- **THEN** the pattern SHALL be highlighted as a regular expression

#### Scenario: A shell command line is highlighted

- **WHEN** a shell command line is opened from the floating command line
- **THEN** what is typed SHALL be highlighted as shell

#### Scenario: No parser-management plugin is added

- **WHEN** the plugin list is inspected
- **THEN** it SHALL contain no plugin whose purpose is installing or updating grammars

#### Scenario: Both halves are recorded

- **WHEN** the configuration for this capability is read
- **THEN** it SHALL name the installed path of each grammar and of each highlighting query
- **AND** it SHALL state that a grammar without its query changes nothing

#### Scenario: The record is enough to rebuild from

- **WHEN** the same files have to be produced on another machine
- **THEN** the configuration SHALL name the source of each grammar and each query
- **AND** it SHALL give the command that builds a grammar

#### Scenario: The grammar is pinned to its query

- **WHEN** the recorded grammar revisions are read
- **THEN** each SHALL be the revision the corresponding query is written against
- **AND** the configuration SHALL state that an unpinned grammar can leave the query matching nothing

#### Scenario: A machine without them still works

- **WHEN** the editor starts where the grammars are not installed
- **THEN** the floating command line SHALL still open
- **AND** the affected inputs SHALL render unhighlighted
- **AND** no error SHALL be raised
