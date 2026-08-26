## Purpose

Makes the reminders a developer leaves in the source — `TODO`, `FIXME`, `HACK` and their kin — visible at a glance rather than buried in the comment around them, reachable from anywhere in the buffer with one keystroke, and listable across the whole project so what is still outstanding can be read as a set.

## Requirements

### Requirement: A marker keyword is distinguished from the comment it sits in

Where a comment begins with one of the recognised keywords followed by a colon, the keyword SHALL be drawn in a colour of its own and the remainder of that line SHALL be tinted, so the note reads as one marked unit rather than as ordinary comment text.

The recognised keywords SHALL cover, at minimum, six groups, each with its own colour and its own set of accepted spellings:

- a task group, spelled `TODO`
- a defect group, spelled `FIX`, `FIXME`, `BUG`, or `ISSUE`
- a workaround group, spelled `HACK`
- a warning group, spelled `WARN`, `WARNING`, or `XXX`
- a performance group, spelled `PERF`, `OPTIM`, `PERFORMANCE`, or `OPTIMIZE`
- an informational group, spelled `NOTE` or `INFO`

Two markers from different groups SHALL be distinguishable from each other by colour alone. Highlighting SHALL update as the buffer is edited, without a save or a manual refresh, and SHALL follow the active colorscheme when the user switches themes.

#### Scenario: A task marker in a source file

- **WHEN** the user opens a file containing a comment that begins `TODO:`
- **THEN** the keyword is drawn in its own colour
- **AND** the rest of that comment line is tinted so the note is legible as one unit

#### Scenario: Two different markers in one file

- **WHEN** a file contains both a `TODO:` comment and a `FIXME:` comment
- **THEN** the two keywords are drawn in different colours

#### Scenario: A marker typed into an open buffer

- **WHEN** the user types a new `HACK:` comment into a buffer
- **THEN** it is highlighted as soon as the line is typed
- **AND** the buffer does not have to be written or reloaded

#### Scenario: Changing the colorscheme

- **WHEN** the user switches to a different colorscheme
- **THEN** the marker colours are those of the new colorscheme
- **AND** the keyword groups remain distinguishable from each other

#### Scenario: A word that is not a marker

- **WHEN** a comment mentions one of the keywords in prose without a following colon
- **THEN** it is not highlighted as a marker

### Requirement: A marked line carries an icon in the sign column, and never at the git indicator's expense

A line carrying a marker SHALL show an icon for that marker's group in the sign column.

The sign column of this configuration is one column wide and permanently reserved, and the git capability writes its per-line change indicators into it. Where a line is both marked and changed relative to the git index, the git indicator SHALL be the one displayed: a marker SHALL NOT take the column from it. On a line with no git indicator, the marker icon SHALL be shown.

#### Scenario: A marked line that is unchanged

- **WHEN** a buffer contains a `TODO:` comment on a line matching the git index
- **THEN** that line's sign column shows the marker icon

#### Scenario: A marked line that is also changed

- **WHEN** the user edits the line a `TODO:` comment sits on, so the line now differs from the git index
- **THEN** the sign column shows the git change indicator for that line
- **AND** the marker's own highlighting on the line is unaffected

#### Scenario: The column does not widen

- **WHEN** a buffer contains marked lines
- **THEN** the sign column is the same width it is in any other buffer
- **AND** the buffer text does not shift sideways

### Requirement: Recognition does not depend on a tree-sitter parser

Marker recognition SHALL work in every filetype this configuration opens, using the tree-sitter support and parsers the editor itself provides and nothing more. No parser plugin SHALL be required, and none SHALL be installed for this capability.

The consequence is accepted deliberately: because comment boundaries cannot be established without a parser for the buffer's language, text matching a keyword SHALL be highlighted wherever it appears in the buffer, including inside a string literal or on a line of code. A marker SHALL NOT be silently left unhighlighted in a filetype whose language has no parser available.

#### Scenario: A filetype with no parser available

- **WHEN** the user opens a file whose language has no tree-sitter parser available and it contains a `TODO:` comment
- **THEN** the marker is highlighted and signed
- **AND** no parser plugin was installed to make it work

#### Scenario: Marker text outside a comment

- **WHEN** a line of code contains the text `TODO:` inside a string literal
- **THEN** it is highlighted as a marker
- **AND** the buffer is otherwise unaffected

### Requirement: `]t` and `[t` move between the markers in the buffer

Pressing `]t` SHALL move the cursor to the next marker in the current buffer, and `[t` to the previous one, counting markers of every recognised group.

When there is no further marker in that direction, the cursor SHALL stay where it is and the editor SHALL say so plainly. No error SHALL be raised, and the buffer SHALL be unchanged.

These two keys are claimed deliberately from the editor's built-in tag-stack mappings. Those commands SHALL remain reachable as `:tnext` and `:tprevious`, and no other bracket pair — including `]c` / `[c` for hunks and `]d` / `[d` for diagnostics — SHALL be affected.

#### Scenario: Jumping to the next marker

- **WHEN** the cursor is above a `TODO:` comment in the buffer and the user presses `]t`
- **THEN** the cursor moves to that comment

#### Scenario: Jumping backwards

- **WHEN** the cursor is below a marker and the user presses `[t`
- **THEN** the cursor moves to the nearest marker above it

#### Scenario: No marker left in that direction

- **WHEN** the cursor is past the last marker in the buffer and the user presses `]t`
- **THEN** the cursor does not move
- **AND** the editor reports that there is no further marker
- **AND** no error is raised

#### Scenario: A buffer with no markers at all

- **WHEN** the user presses `]t` in a buffer containing no markers
- **THEN** the cursor does not move
- **AND** the editor reports it rather than raising an error

#### Scenario: Tag navigation is still available

- **WHEN** the user runs `:tnext` or `:tprevious`
- **THEN** the tag stack is walked as it is without this capability

#### Scenario: Other bracket pairs survive

- **WHEN** the user presses `]c`, `[c`, `]d`, or `[d`
- **THEN** each moves between hunks or diagnostics as it did before this change

### Requirement: Every marker in the project is listable under a `<leader>t` prefix

A `<leader>t` prefix SHALL carry the listings of markers beyond the cursor's line:

- one mapping SHALL open the fuzzy picker over every marker found under the editor's working directory
- one mapping SHALL put that same set into the quickfix list, which is shared by every window
- one mapping SHALL put it into the current window's location list instead, so a window can hold a marker list of its own without disturbing the quickfix list another window is working through

Every entry SHALL name the file, the line, the keyword, and the note's text, and choosing an entry SHALL open that file at that line. A search SHALL cover the working directory recursively and SHALL respect the ignore rules the content search already honours, so files the project excludes from version control are not listed.

The listings SHALL additionally exclude the OpenSpec planning directory. The markers written there are quoted inside proposals, spec scenarios, and design notes -- they describe this capability rather than record outstanding work -- and they outnumber the real markers in this repository. The exclusion SHALL be scoped to that directory by path, not to a filetype: a marker in a README or in any other note or document SHALL still be listed. It SHALL hold wherever the editor's working directory sits relative to the planning directory.

The exclusion SHALL apply to the listings only. A marker inside an excluded file SHALL still be highlighted, signed, and reachable with `]t` and `[t` while that file is open.

`<leader>t` itself SHALL run no command.

#### Scenario: Listing markers across the project in the picker

- **WHEN** the user opens the marker picker from the `<leader>t` prefix
- **THEN** every marker under the working directory is listed with its file, line, keyword, and text
- **AND** narrowing the query filters the list

#### Scenario: Opening a listed marker

- **WHEN** the user selects an entry in the marker picker
- **THEN** that file opens with the cursor on the marked line

#### Scenario: Markers as a quickfix list

- **WHEN** the user runs the quickfix mapping under the `<leader>t` prefix
- **THEN** the quickfix list holds every marker in the project
- **AND** the built-in quickfix commands walk it

#### Scenario: Markers as a window-local list

- **WHEN** the user runs the location-list mapping under the `<leader>t` prefix
- **THEN** the current window's location list holds the markers
- **AND** the quickfix list is left as it was

#### Scenario: Planning prose is not listed as work

- **WHEN** the user asks for any of the three listings in a project whose OpenSpec planning directory contains comments beginning with a recognised keyword
- **THEN** none of those are listed
- **AND** the markers elsewhere in the project are listed as they otherwise would be

#### Scenario: A marker in a document outside the planning directory

- **WHEN** a note or document outside the OpenSpec planning directory contains a `TODO:` marker
- **THEN** the listings include it

#### Scenario: An excluded file is opened

- **WHEN** the user opens a file inside the OpenSpec planning directory that contains a `TODO:` marker
- **THEN** the marker is highlighted and signed in that buffer
- **AND** `]t` moves to it

#### Scenario: A project with no markers

- **WHEN** the user asks for a listing in a project containing no markers
- **THEN** the empty result is reported plainly
- **AND** no error is raised

#### Scenario: The prefix alone runs nothing

- **WHEN** the user presses `<leader>t`
- **THEN** no command runs
- **AND** the editor waits for the next key of the sequence

### Requirement: The picker behaves like every other picker in this configuration

The marker picker SHALL be the same picker component the file, content, buffer, and git searches use, and SHALL take its layout, its joined border, its preview pane, and its in-picker navigation mappings from that component's configuration rather than declaring its own.

#### Scenario: Layout and preview

- **WHEN** the marker picker is open
- **THEN** it is laid out and bordered like the content search
- **AND** the selected marker's file is previewed, positioned on the marked line

#### Scenario: Moving through results

- **WHEN** the user presses the keys that move the selection in any other picker
- **THEN** the selection moves in the marker picker the same way
- **AND** `<Esc>` closes it

### Requirement: The capability does not displace an existing mapping other than the keys it declares

Beyond `]t`, `[t`, and the mappings under the `<leader>t` prefix, this capability SHALL NOT take any key sequence that has a meaning in the editor or in this configuration. In particular it SHALL NOT claim `<leader>ft`, the `<leader>f` and `<leader>g` pickers, the `<leader>h` hunk mappings, `]c` / `[c`, `]d` / `[d`, or bare `t` and `T` in any mode.

#### Scenario: Existing mappings survive

- **WHEN** the user presses any mapping this configuration defined before this change
- **THEN** it does what it did before

#### Scenario: The character motions are untouched

- **WHEN** the user presses `t` or `T` followed by a character
- **THEN** the cursor moves as it did before this change

#### Scenario: The colorscheme picker is untouched

- **WHEN** the user presses `<leader>ft`
- **THEN** the colorscheme picker opens as it did before this change

### Requirement: The capability costs nothing until a file is opened

The plugin providing this capability SHALL NOT load while the editor starts up with no file argument. It SHALL load when a file buffer is first read, and the markers in the visible part of that buffer SHALL be highlighted and signed without the user having to scroll, edit, or run a command.

Marking a line SHALL NOT widen the sign column or shift the buffer text sideways, in any buffer, at any point.

#### Scenario: Starting the editor with no file

- **WHEN** the editor is started with no file argument and no buffer is opened
- **THEN** the plugin is not loaded

#### Scenario: Opening a file with markers

- **WHEN** the user opens a file containing markers
- **THEN** the markers visible on screen are highlighted and signed with no further action
- **AND** the buffer text does not shift as they appear

#### Scenario: Scrolling to a marker further down

- **WHEN** the user scrolls to a part of the file that was off screen when it was opened
- **THEN** the markers there are highlighted and signed too

### Requirement: The capability is declared in its own plugin file

Everything this capability needs — its keyword groups, its highlighting and sign settings, its jump mappings, and its listing mappings — SHALL be declared in a single file under `lua/plugins/`, and SHALL NOT appear in the general keymaps module. The only permitted trace of it elsewhere is the entry naming the `<leader>t` prefix in the keymap-hint plugin's group list.

Deleting that file SHALL remove the capability entirely, restoring the editor's built-in `]t` and `[t` and leaving every other mapping working exactly as before.

#### Scenario: Locating a mapping

- **WHEN** a contributor looks for where `]t` is defined
- **THEN** it is declared in this capability's file under `lua/plugins/`
- **AND** it is absent from `lua/config/keymaps.lua`

#### Scenario: Removing the capability

- **WHEN** the plugin file is deleted and the editor is restarted
- **THEN** `]t` and `[t` walk the tag stack again
- **AND** no marker highlighting, signs, or listings remain
