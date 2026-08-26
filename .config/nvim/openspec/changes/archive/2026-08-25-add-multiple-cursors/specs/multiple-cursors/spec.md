## Purpose

Lets the user edit at several places in a buffer at once, by placing a cursor at each of them and applying one set of keystrokes to all simultaneously, for the changes that are too small to justify a substitute command and not semantic enough for a language server to rename.

## ADDED Requirements

### Requirement: Occurrences of the text under the cursor are selected one at a time

Pressing `<C-n>` in normal mode with the cursor on a word SHALL select that word and place a cursor on it. Pressing `<C-n>` again SHALL select the next occurrence of the same text in the buffer and add a cursor there, leaving the previous cursors in place. Selection SHALL wrap to the start of the buffer once the last occurrence is passed.

In visual mode, `<C-n>` SHALL take the selected text as the search text rather than the word under the cursor, so that a selection smaller or larger than a word can be matched.

#### Scenario: Selecting the first occurrence

- **WHEN** the cursor is on a word and the user presses `<C-n>`
- **THEN** that word is selected
- **AND** a cursor is placed on it

#### Scenario: Adding the next occurrence

- **WHEN** one or more occurrences are already selected and the user presses `<C-n>`
- **THEN** the next occurrence of the same text is selected
- **AND** a cursor is added there
- **AND** the previously selected occurrences keep their cursors

#### Scenario: Wrapping past the last occurrence

- **WHEN** the last occurrence in the buffer is selected and the user presses `<C-n>`
- **THEN** selection resumes from the first occurrence in the buffer

#### Scenario: All occurrences already selected

- **WHEN** every occurrence in the buffer is already selected and the user presses `<C-n>`
- **THEN** no further cursor is added
- **AND** no error is raised

#### Scenario: Matching a selection rather than a word

- **WHEN** the user selects text in visual mode and presses `<C-n>`
- **THEN** the selected text is used as the text to match
- **AND** a cursor is placed on that occurrence

#### Scenario: Text that occurs only once

- **WHEN** the cursor is on a word that appears nowhere else in the buffer and the user presses `<C-n>`
- **THEN** that single occurrence is selected
- **AND** no error is raised

### Requirement: Cursors can be added vertically

Pressing `<C-Down>` SHALL add a cursor on the line below the lowest current cursor, at the same column, and `<C-Up>` SHALL add one on the line above the highest, so that a column of cursors can be built without matching any text.

#### Scenario: Extending downward

- **WHEN** the user presses `<C-Down>`
- **THEN** a cursor is added on the next line at the same column
- **AND** the existing cursors remain

#### Scenario: Extending upward

- **WHEN** the user presses `<C-Up>`
- **THEN** a cursor is added on the previous line at the same column

#### Scenario: Reaching the edge of the buffer

- **WHEN** the user extends past the first or last line of the buffer
- **THEN** no cursor is added beyond the buffer
- **AND** no error is raised

### Requirement: Selections can be extended at every cursor at once

With multiple cursors active, `<S-Right>` SHALL extend the selection one character to the right at every cursor, and `<S-Left>` one character to the left, so that all selections grow and shrink together.

#### Scenario: Extending every selection

- **WHEN** multiple cursors are active and the user presses `<S-Right>`
- **THEN** the selection at every cursor extends by one character
- **AND** the cursors remain aligned with one another

### Requirement: Occurrences can be selected all at once or by pattern

The user SHALL be able to select every occurrence of the text under the cursor in one action, and SHALL be able to place cursors by typing a search pattern rather than by matching existing text. A cursor SHALL also be placeable at the current position without matching anything.

#### Scenario: Selecting every occurrence

- **WHEN** the cursor is on a word and the user invokes select-all
- **THEN** a cursor is placed on every occurrence of that word in the buffer

#### Scenario: Selecting by pattern

- **WHEN** the user invokes the pattern search, types a pattern, and then invokes select-all
- **THEN** a cursor is placed at each match of that pattern

#### Scenario: A pattern matching nothing

- **WHEN** the user searches for a pattern that matches nothing in the buffer
- **THEN** no cursor is added
- **AND** the buffer is unchanged
- **AND** the only feedback is the editor's ordinary "pattern not found" message for a failed search

#### Scenario: Adding a cursor at the current position

- **WHEN** the user invokes add-cursor-at-position
- **THEN** a cursor is placed where the cursor is, matching no text

### Requirement: An edit applies at every cursor simultaneously

With multiple cursors active, text typed in insert mode SHALL be inserted at every cursor, and a normal-mode edit SHALL be applied at every cursor. While multiple cursors are still active, a single undo SHALL revert the first multi-cursor edit of the session as a whole rather than one cursor's worth of it, and SHALL restore the cursors along with the text. A single undo after a further edit in the same session SHALL revert at least that edit, and MAY revert back to the state in which the cursors were placed. Once multiple-cursor mode has been left, undo SHALL be ordinary undo, which unwinds a multi-cursor edit one cursor at a time.

#### Scenario: Typing with several cursors

- **WHEN** several cursors are active and the user enters insert mode and types
- **THEN** the typed text appears at every cursor

#### Scenario: Deleting with several cursors

- **WHEN** several cursors are active and the user deletes a word
- **THEN** a word is deleted at every cursor

#### Scenario: Undoing a multi-cursor edit before leaving the mode

- **WHEN** the user places cursors, makes one edit at them, and then undoes once without having left multiple-cursor mode
- **THEN** the edit is reverted at every cursor
- **AND** the buffer matches its state before the edit
- **AND** the cursors are still active

#### Scenario: Undoing after several edits in one session

- **WHEN** the user makes more than one edit without leaving multiple-cursor mode and then undoes once
- **THEN** at least the most recent edit is reverted at every cursor
- **AND** the buffer is left in a state it held earlier in the session

#### Scenario: Undoing after leaving the mode

- **WHEN** the user makes an edit at several cursors, leaves multiple-cursor mode, and then undoes
- **THEN** undo behaves as it does for any other edit, reverting one cursor's worth of the change at a time

### Requirement: Individual cursors can be skipped, removed, and navigated

Before committing to an edit, the user SHALL be able to move between the current cursors, skip an occurrence so it is matched but not edited, and remove a cursor already placed.

#### Scenario: Moving between cursors

- **WHEN** several cursors are active and the user moves to the next cursor
- **THEN** the active cursor becomes the next one
- **AND** no cursor is added or removed

#### Scenario: Skipping an occurrence

- **WHEN** an occurrence is selected and the user skips it
- **THEN** no cursor remains at that occurrence
- **AND** selection continues from the following occurrence

#### Scenario: Removing a cursor

- **WHEN** the user removes the cursor under the current position
- **THEN** that cursor is removed
- **AND** the remaining cursors are unaffected

### Requirement: Leaving multiple-cursor mode restores ordinary editing

Pressing `<Esc>` SHALL leave multiple-cursor mode, removing every cursor but the one at the current position and leaving all edits already made in place. Once left, every key SHALL have its ordinary meaning again.

#### Scenario: Exiting after an edit

- **WHEN** the user has edited at several cursors and presses `<Esc>`
- **THEN** the extra cursors are removed
- **AND** the edits made at them remain in the buffer

#### Scenario: Exiting without editing

- **WHEN** the user places several cursors and presses `<Esc>` without editing
- **THEN** the extra cursors are removed
- **AND** the buffer is unchanged

#### Scenario: Keys return to their ordinary meaning

- **WHEN** the user has left multiple-cursor mode
- **THEN** keys the mode had bound to its own commands behave as they do in an ordinary buffer

### Requirement: The prefixed commands do not claim the localleader key

The prefix under which this capability's non-primary commands live SHALL NOT be the configuration's localleader key, and SHALL be a prefix only — never bound as a mapping in its own right, so that pressing it alone executes nothing and defers nothing pending a timeout.

#### Scenario: The localleader key is left unbound

- **WHEN** the user presses the localleader key alone in a buffer
- **THEN** no multiple-cursor command runs
- **AND** the key is not claimed by this capability

#### Scenario: The prefix stalls on nothing

- **WHEN** the user presses this capability's prefix alone
- **THEN** nothing is executed and no action is deferred pending a timeout
- **AND** the editor waits for the next key of the sequence

### Requirement: The capability costs nothing until it is used

The plugin providing this capability SHALL NOT load during editor startup. It SHALL load when one of its entry-point keys is first pressed, and that first press SHALL take effect rather than being consumed by the load.

#### Scenario: A session that never uses it

- **WHEN** the editor starts and no multiple-cursor entry point is pressed
- **THEN** the plugin is not loaded
- **AND** startup time is unaffected

#### Scenario: The first press is not swallowed

- **WHEN** the user presses an entry-point key for the first time in a session
- **THEN** the plugin loads
- **AND** that keypress performs its action rather than being consumed

### Requirement: Mappings are declared with the plugin

Every mapping in this capability SHALL be declared in this plugin's own file under `lua/plugins/`, and SHALL NOT appear in the general keymaps module. Deleting that file SHALL remove the capability entirely.

#### Scenario: Locating a mapping

- **WHEN** a contributor looks for where a multiple-cursor mapping is defined
- **THEN** it is declared in the plugin's file under `lua/plugins/`
- **AND** it is absent from `lua/config/keymaps.lua`

#### Scenario: Removing the capability

- **WHEN** the plugin's file is deleted and the editor is restarted
- **THEN** none of its mappings is defined
- **AND** no error is raised about a missing module
- **AND** nothing else in the configuration is affected
