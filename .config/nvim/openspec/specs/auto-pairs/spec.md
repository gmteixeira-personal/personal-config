# auto-pairs Specification

## Purpose
Removes the closing half of a delimiter from what the user has to type. Opening a quote, bracket, or brace in insert mode leaves a complete, balanced pair behind with the cursor between the two halves, and the closing half stays out of the way — typed over rather than duplicated, deleted with its partner rather than orphaned.
## Requirements
### Requirement: An opening delimiter inserts its closing counterpart

Typing `(`, `[`, `{`, `"`, `'`, or a backtick in insert mode SHALL insert both that character and its closing counterpart, leaving the cursor between them, so that the buffer is left balanced without the user typing the closing character.

The characters typed SHALL be the ones the user pressed. No delimiter is substituted for another, and no delimiter is inserted that the user did not open.

#### Scenario: Opening a quote

- **WHEN** the user types `"` in insert mode on an empty line
- **THEN** the line contains `""`
- **AND** the cursor sits between the two quotes

#### Scenario: Opening a bracket

- **WHEN** the user types `(` in insert mode
- **THEN** `()` is inserted
- **AND** the cursor sits between them

#### Scenario: Nesting pairs

- **WHEN** the user opens a pair and then opens another pair inside it
- **THEN** both pairs are complete
- **AND** the cursor sits inside the innermost one

### Requirement: Typing a closing delimiter that is already there moves over it

With the cursor immediately before a closing delimiter, typing that same closing delimiter SHALL move the cursor past the existing one rather than inserting a second, so that typing a pair out in full — opening character, contents, closing character — produces the same result as letting the pair be completed automatically.

#### Scenario: Typing the closing quote out

- **WHEN** the user types `"`, then `abc`, then `"`
- **THEN** the line contains `"abc"`
- **AND** the cursor sits after the closing quote

#### Scenario: Typing a closing bracket out

- **WHEN** the user has `(|)` with the cursor at `|` and types `)`
- **THEN** the line still contains `()`
- **AND** the cursor sits after the closing bracket

#### Scenario: A closing delimiter with no partner

- **WHEN** the user types a closing delimiter where no matching opening delimiter is pending
- **THEN** that character is inserted literally

### Requirement: Deleting an opening delimiter deletes the empty pair with it

Pressing backspace with the cursor between the two halves of an empty pair SHALL delete both halves in one press, so that undoing an unwanted pair costs the same one keystroke that created it.

The two halves SHALL be deleted only while the pair is empty. With content between them, backspace SHALL delete one character as it ordinarily does, leaving the closing delimiter in place.

#### Scenario: Backspacing an empty pair

- **WHEN** the user has `"|"` with the cursor at `|` and presses backspace
- **THEN** both quotes are deleted
- **AND** the line is left as it was before the pair was opened

#### Scenario: Backspacing a pair with content

- **WHEN** the user has `"abc|"` with the cursor at `|` and presses backspace
- **THEN** `c` is deleted
- **AND** both quotes remain

### Requirement: A quote in prose or in a word is not paired

A quote character SHALL NOT be paired where pairing it would be wrong more often than right: immediately after an alphanumeric character, where the quote is an apostrophe rather than an opening delimiter, and immediately before an alphanumeric character, where the text to the right is already there to be quoted rather than to be pushed aside.

#### Scenario: An apostrophe in a contraction

- **WHEN** the user types `don` and then `'`
- **THEN** a single `'` is inserted
- **AND** no closing quote is added

#### Scenario: A quote typed before a word

- **WHEN** the cursor sits immediately before a word character and the user types `"`
- **THEN** a single `"` is inserted
- **AND** no closing quote is added

#### Scenario: An escaped quote

- **WHEN** the cursor sits immediately after a backslash and the user types `"`
- **THEN** a single `"` is inserted
- **AND** no closing quote is added

### Requirement: A bracket is not paired where the line already closes it

Typing an opening bracket SHALL NOT add a closing bracket when an unmatched closing bracket of that kind already stands later on the line, so that inserting a call or an index into existing code does not leave a stray delimiter behind.

#### Scenario: Opening a bracket before an existing close

- **WHEN** the line is `foo|)` with the cursor at `|` and the user types `(`
- **THEN** a single `(` is inserted
- **AND** the line reads `foo()`

### Requirement: A newline inside a pair opens the pair out

Pressing `<CR>` with the cursor between the two halves of a pair SHALL leave the closing half on its own line below and place the cursor on an indented line between the two, so that a block opened with `{` does not have to be closed by hand.

`<CR>` SHALL keep this behaviour only in insert mode and only between a pair. Elsewhere it SHALL do what it ordinarily does, and it SHALL NOT be taken away from the completion menu.

#### Scenario: A newline inside a brace pair

- **WHEN** the user has `{|}` with the cursor at `|` and presses `<CR>`
- **THEN** the closing brace is left on a line of its own
- **AND** the cursor is on an indented empty line between the two braces

#### Scenario: A newline elsewhere

- **WHEN** the user presses `<CR>` in insert mode with no pair around the cursor
- **THEN** a newline is inserted as it ordinarily is

#### Scenario: A newline with the completion menu open

- **WHEN** the completion menu is open and the user presses `<CR>`
- **THEN** whatever the completion menu does with `<CR>` is what happens
- **AND** no pairing behaviour intercepts it

### Requirement: An existing word can be wrapped without retyping it

The user SHALL be able to put a pair around the word ahead of the cursor from insert mode, by a single key that offers the positions the closing delimiter could take and places it at the one chosen. That key SHALL NOT be one of `<M-h>`, `<M-j>`, `<M-k>`, or `<M-l>`, which the window-resize mappings hold.

#### Scenario: Wrapping the next word

- **WHEN** the cursor sits before a word, the user opens a pair and invokes the wrap key, then chooses a position
- **THEN** the closing delimiter is placed at the chosen position
- **AND** the word is left between the two halves of the pair

#### Scenario: The resize mappings are untouched

- **WHEN** the user presses `<M-h>`, `<M-j>`, `<M-k>`, or `<M-l>`
- **THEN** the window is resized
- **AND** no wrap prompt appears

### Requirement: Automatic pairing stays out of bulk and non-typing input

Automatic pairing SHALL NOT apply where the input is not a person typing a delimiter: while a macro is recording or replaying, in visual block insert, and in replace mode. In each of those the delimiter SHALL be inserted literally.

#### Scenario: Recording a macro

- **WHEN** the user records a macro that types an opening delimiter
- **THEN** the recorded keystrokes contain only what was typed
- **AND** replaying the macro produces the same text each time it runs

#### Scenario: Inserting across a visual block

- **WHEN** the user inserts an opening delimiter across a visual block selection
- **THEN** that character alone is inserted on every line of the block

#### Scenario: Replace mode

- **WHEN** the user types an opening delimiter in replace mode
- **THEN** one character is overwritten with it
- **AND** no closing delimiter is inserted

### Requirement: Completion is unaffected

The completion engine's behaviour SHALL be unchanged: its keys keep their meanings, accepting an item that carries its own brackets SHALL insert exactly one pair of them, and no delimiter typed while the menu is open SHALL produce a doubled character.

#### Scenario: Accepting a function completion

- **WHEN** the user accepts a completion item for a function that the language server marks as callable
- **THEN** exactly one pair of parentheses follows the name
- **AND** the cursor sits between them

#### Scenario: Completion keys keep their meaning

- **WHEN** the user opens, navigates, accepts, or dismisses the completion menu
- **THEN** each of those keys behaves as it did before this capability existed

### Requirement: The capability costs nothing until insert mode is entered

The plugin providing this capability SHALL NOT load during editor startup. It SHALL load when insert mode is first entered, and the pairing behaviour SHALL be in force from the first character typed in that first insert session.

#### Scenario: A session that never inserts

- **WHEN** the editor starts and insert mode is never entered
- **THEN** the plugin is not loaded
- **AND** startup time is unaffected

#### Scenario: The first character of the first insert

- **WHEN** the user enters insert mode for the first time in a session and types an opening delimiter
- **THEN** the pair is completed
- **AND** the keystroke is not consumed by the load

### Requirement: The capability is declared in its own plugin file

This capability SHALL be declared in a single file under `lua/plugins/`, and SHALL NOT add anything to the general keymaps module. Deleting that file SHALL remove the capability entirely.

#### Scenario: Removing the capability

- **WHEN** the plugin's file is deleted and the editor is restarted
- **THEN** typing an opening delimiter inserts that one character
- **AND** no error is raised about a missing module
- **AND** nothing else in the configuration is affected

