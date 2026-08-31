## Purpose

Defines the general editing behaviour of the editor — how text is displayed, wrapped, indented and searched, what persists between sessions, where new windows open, and how text is exchanged with the system clipboard — for every buffer and with no plugin installed.

## Requirements

### Requirement: Line numbers show absolute position and relative distance

The buffer SHALL display a line number for every line. The line the cursor is on SHALL show its absolute number, and every other line SHALL show its distance from the cursor, so that a vertical motion count can be read directly off the screen.

#### Scenario: Reading the current line

- **WHEN** the cursor is on a line
- **THEN** that line's own number is its absolute position in the file

#### Scenario: Reading a motion count

- **WHEN** the user looks at a line some distance above or below the cursor
- **THEN** the number shown against it is the count needed to move the cursor there

#### Scenario: Numbers follow the cursor

- **WHEN** the cursor moves to a different line
- **THEN** the displayed numbers update so they remain relative to the new position

### Requirement: Colours are rendered at full fidelity on a dark background

The editor SHALL render 24-bit colour rather than a 256-colour approximation, and SHALL treat the terminal background as dark so that colour schemes select their dark variant.

#### Scenario: A colour scheme renders as authored

- **WHEN** a colour scheme defining 24-bit colours is active
- **THEN** those colours are rendered exactly rather than approximated to the nearest terminal colour

#### Scenario: A scheme with light and dark variants

- **WHEN** a colour scheme offers both a light and a dark variant and selects on the background setting
- **THEN** the dark variant is chosen

### Requirement: Indentation is two spaces and never a tab character

Pressing Tab SHALL insert spaces, not a tab character. One level of indentation SHALL be two columns, and this SHALL hold consistently for an inserted Tab, for a shift command, and for the Backspace key removing indentation. New lines SHALL be indented automatically according to the structure of the preceding line.

#### Scenario: Inserting indentation

- **WHEN** the user presses Tab in insert mode
- **THEN** two spaces are inserted
- **AND** no tab character is written to the file

#### Scenario: Shifting a line

- **WHEN** the user shifts a line left or right by one level
- **THEN** its indentation changes by two columns

#### Scenario: Removing indentation

- **WHEN** the cursor is at the start of indented text and the user presses Backspace
- **THEN** a full two-column level is removed rather than a single space

#### Scenario: Continuing a block

- **WHEN** the user opens a new line after one that begins a block
- **THEN** the new line is indented one level deeper automatically

### Requirement: Search is case-insensitive until the query says otherwise

A search query typed in all lower case SHALL match regardless of case. A query containing an upper-case character SHALL match case-sensitively. Matches SHALL be shown and the view moved to them as the query is typed.

Once a search is accepted, every match SHALL remain highlighted until the highlight is explicitly dismissed, so that the distribution of a term across the buffer stays visible while the user works with it. Dismissing the highlight is a mapping rather than an option, and is specified by `editor-keymaps`.

#### Scenario: Lower-case query

- **WHEN** the user searches for a term typed entirely in lower case
- **THEN** occurrences are matched irrespective of their case

#### Scenario: Query containing an upper-case character

- **WHEN** the user searches for a term containing at least one upper-case character
- **THEN** only occurrences matching that exact case are matched

#### Scenario: Feedback while typing

- **WHEN** the user is part-way through typing a search query
- **THEN** the first match is already shown and the view has moved to it
- **AND** the display updates as further characters are typed

#### Scenario: Highlight persists after the search

- **WHEN** the user accepts a search and returns to editing
- **THEN** every occurrence of the term remains highlighted
- **AND** the highlighting survives cursor movement and editing elsewhere in the buffer

#### Scenario: Highlight is dismissed deliberately

- **WHEN** matches are highlighted and the user dismisses the highlight
- **THEN** no matches remain highlighted
- **AND** the search pattern and search history are retained, so `n` and `N` still work

#### Scenario: Abandoning a search

- **WHEN** the user cancels a search part-way through typing
- **THEN** the cursor returns to where it was before the search began

### Requirement: The sign column is always present

The gutter used for signs SHALL be reserved permanently, whether or not any sign is currently displayed, so that text never shifts horizontally when a sign appears or is removed.

#### Scenario: A sign appears

- **WHEN** a sign is placed on a line in a buffer that previously had none
- **THEN** the buffer text does not shift horizontally

#### Scenario: A buffer with no signs at all

- **WHEN** a buffer that will never receive a sign is displayed
- **THEN** the sign column is still reserved
- **AND** the text begins at the same column as in a buffer that does have signs

### Requirement: Undo history survives closing the file

Undo history SHALL be written to disk and restored when a file is reopened, so that changes made in an earlier session can still be undone. This history SHALL be stored outside the edited file's directory and its loss SHALL never affect the file's contents.

#### Scenario: Undoing an edit from a previous session

- **WHEN** the user edits and saves a file, closes the editor, reopens the same file, and undoes
- **THEN** the edit made in the previous session is reverted

#### Scenario: History is stored away from the project

- **WHEN** a file is edited and saved
- **THEN** no undo-history file is created beside it in its own directory

#### Scenario: Missing history is not an error

- **WHEN** a file is opened for which no stored undo history exists
- **THEN** the file opens normally
- **AND** no error is raised

### Requirement: The editor reacts promptly when the user pauses

The delay after which the editor treats the user as idle SHALL be short enough that features triggered by inactivity respond without a perceptible wait.

#### Scenario: A feature triggered by pausing

- **WHEN** the user stops typing and leaves the cursor still
- **THEN** behaviour that waits for the user to become idle is triggered within a quarter of a second

### Requirement: A pending key sequence resolves quickly

When typed keys form the prefix of a longer mapping, the editor SHALL wait only briefly for the sequence to be completed before resolving what was typed.

#### Scenario: Completing a multi-key mapping

- **WHEN** the user types the keys of a multi-key mapping as a deliberate sequence
- **THEN** the mapping is triggered

#### Scenario: Abandoning a sequence

- **WHEN** the user types the prefix of a mapping and then stops
- **THEN** the editor stops waiting within a third of a second
- **AND** the keys typed so far take their own meaning

### Requirement: New windows open right and below

A window split vertically SHALL place the new window to the right of the current one, and a window split horizontally SHALL place it below, so that the existing window keeps its position.

#### Scenario: Splitting vertically

- **WHEN** the user splits the current window vertically
- **THEN** the new window appears to the right of it

#### Scenario: Splitting horizontally

- **WHEN** the user splits the current window horizontally
- **THEN** the new window appears below it

### Requirement: Long lines wrap at word boundaries with indentation preserved

A line too long for the window SHALL be displayed across several screen rows rather than running off the edge. The break SHALL fall at a word boundary rather than mid-word, and the continuation rows SHALL be indented to align with the start of the wrapped line. Wrapping SHALL affect display only.

#### Scenario: A line longer than the window

- **WHEN** a line is wider than the window
- **THEN** it is displayed across multiple screen rows
- **AND** the view does not scroll horizontally to show it

#### Scenario: Breaking between words

- **WHEN** a long line is wrapped
- **THEN** the break falls at a word boundary
- **AND** no word is split across two screen rows

#### Scenario: Continuation rows are aligned

- **WHEN** an indented line wraps
- **THEN** its continuation rows begin at the same indentation as the line itself

#### Scenario: Wrapping does not change the file

- **WHEN** a line is displayed wrapped across several rows
- **THEN** the file's contents are unchanged
- **AND** a motion by line moves over the whole logical line, not one screen row

### Requirement: Changes made outside the editor are picked up

When a file open in a buffer is changed on disk by another program, and the buffer has no unsaved changes of its own, the editor SHALL load the new contents rather than continuing to display stale ones.

#### Scenario: A file changed by another program

- **WHEN** a file open in an unmodified buffer is changed on disk
- **AND** the editor next checks that file
- **THEN** the buffer shows the new contents

#### Scenario: Unsaved local changes are never discarded

- **WHEN** a file is changed on disk while the buffer holds unsaved changes
- **THEN** the buffer's unsaved changes are not silently replaced
- **AND** the conflict is reported to the user

### Requirement: Yanked and deleted text reaches the system clipboard

Text yanked or deleted SHALL be placed on the system clipboard without the user naming a register, and text copied in another application SHALL be available to paste without naming a register. This SHALL hold on a native Linux terminal and under WSL alike.

#### Scenario: Copying out of the editor

- **WHEN** the user yanks text in the editor
- **AND** pastes into another application
- **THEN** the yanked text is pasted

#### Scenario: Pasting into the editor

- **WHEN** the user copies text in another application
- **AND** pastes in the editor without naming a register
- **THEN** that text is inserted

#### Scenario: Deleting also copies

- **WHEN** the user deletes text
- **THEN** the deleted text is available on the system clipboard

### Requirement: The clipboard mechanism is supplied only where the editor cannot find one

The editor's own detection of a clipboard tool SHALL be left in place wherever it succeeds. A clipboard mechanism SHALL be supplied by this configuration only in the environment where that detection finds nothing, and supplying it SHALL NOT override or degrade a tool the editor would otherwise have chosen.

#### Scenario: A native Linux terminal with a clipboard tool present

- **WHEN** the editor runs on a native Linux terminal where a clipboard tool is installed
- **THEN** the editor's own choice of tool is used
- **AND** this configuration supplies no substitute

#### Scenario: An environment where the editor finds its preferred tool

- **WHEN** the editor runs in an environment whose preferred clipboard tool is installed
- **THEN** that tool is used
- **AND** this configuration supplies no substitute

#### Scenario: An environment with no tool the editor recognises

- **WHEN** the editor runs where its detection finds no clipboard tool
- **AND** the environment nonetheless provides a means of reaching the system clipboard
- **THEN** this configuration supplies that means
- **AND** copying and pasting between the editor and other applications works

#### Scenario: No clipboard is reachable at all

- **WHEN** the editor runs where neither its own detection nor this configuration can reach a system clipboard
- **THEN** the editor starts normally and every buffer is fully editable
- **AND** yank and delete continue to work within the editor's own registers
- **AND** the absence is reported by the editor's health check rather than as an error on every yank

### Requirement: General options apply with no plugin installed

Every option in this capability SHALL take effect with no plugin installed, and SHALL be set in one place. No option here SHALL depend on a plugin being present, and none SHALL be set from a plugin's own file.

#### Scenario: Starting with no plugins

- **WHEN** the editor starts with no plugin installed at all
- **THEN** every option in this capability is in effect
- **AND** no error is raised

#### Scenario: Locating an option

- **WHEN** a contributor looks for where one of these options is set
- **THEN** it is set in the general options module
- **AND** it is not also set in any plugin's file
