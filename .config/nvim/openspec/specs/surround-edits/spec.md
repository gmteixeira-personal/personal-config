# surround-edits Specification

## Purpose
Treats the pair of delimiters around a piece of text as one editable thing. Text that already exists can be given a surrounding pair, have that pair taken away, or have it swapped for a different one, in a single command aimed at the pair rather than at each of its two halves.
## Requirements
### Requirement: A pair can be put around the text a motion covers

An add-surround command SHALL take a motion or text object and a delimiter character, and place the corresponding pair around exactly the text that motion covers. The text itself SHALL be unchanged, and the cursor SHALL be left at the start of the surrounded text.

The delimiter SHALL be identified by either half of the pair. Naming the opening half SHALL additionally place a space inside each delimiter; naming the closing half SHALL not, so that both spacings are reachable without a separate command.

#### Scenario: Quoting a word

- **WHEN** the cursor is on the word `word` and the user adds `"` around the inner-word text object
- **THEN** the line reads `"word"`

#### Scenario: Surrounding a motion's range

- **WHEN** the user adds a pair using a motion that covers several words
- **THEN** the pair encloses exactly the text that motion covers
- **AND** no other text on the line is altered

#### Scenario: Padded and unpadded brackets

- **WHEN** the user adds a pair around a word naming the opening bracket
- **THEN** a space stands inside each bracket
- **AND** naming the closing bracket instead produces the same pair with no spaces

#### Scenario: A motion covering nothing

- **WHEN** the user invokes add-surround with a motion that covers no text
- **THEN** the buffer is unchanged
- **AND** no error is raised

### Requirement: A pair can be put around a visual selection

With text selected in visual mode, a single key followed by a delimiter character SHALL place that pair around the selection. This SHALL work for a characterwise selection and for a linewise one, and the selected text SHALL be unchanged.

This key SHALL shadow the built-in visual-mode `S`. The built-in remains reachable by its equivalents.

#### Scenario: Quoting a selection

- **WHEN** the user selects `some text` in visual mode and adds `"` around it
- **THEN** the line reads `"some text"`
- **AND** the text between the quotes is unchanged

#### Scenario: Surrounding a linewise selection

- **WHEN** the user selects whole lines and adds a pair around them
- **THEN** the pair encloses all the selected lines

#### Scenario: The shadowed built-in

- **WHEN** the user wants the built-in visual-mode linewise change that this key shadowed
- **THEN** it is reachable through its ordinary equivalents

### Requirement: A surrounding pair can be deleted

A delete-surround command SHALL take a delimiter character and remove the nearest enclosing pair of that kind, together with any padding space it added, leaving the text between the delimiters in place.

#### Scenario: Unquoting

- **WHEN** the cursor is inside `"word"` and the user deletes the `"` surround
- **THEN** the line reads `word`

#### Scenario: Deleting the nearest of several

- **WHEN** the cursor is inside nested pairs of the same kind and the user deletes that surround
- **THEN** the innermost enclosing pair is removed
- **AND** the outer pairs remain

#### Scenario: No such surrounding pair

- **WHEN** the user deletes a surround of a kind that does not enclose the cursor
- **THEN** the buffer is unchanged
- **AND** no error is raised

### Requirement: A surrounding pair can be replaced with another

A change-surround command SHALL take the delimiter to find and the delimiter to put in its place, and replace the nearest enclosing pair of the first kind with a pair of the second, leaving the text between them unchanged.

#### Scenario: Single quotes to double

- **WHEN** the cursor is inside `'word'` and the user changes the `'` surround to `"`
- **THEN** the line reads `"word"`

#### Scenario: Brackets to braces

- **WHEN** the cursor is inside a bracket pair and the user changes it to braces
- **THEN** the brackets are replaced by braces
- **AND** the text between them is unchanged

### Requirement: Quotes, brackets, and tags are all reachable, and any character can be a delimiter

The delimiter characters SHALL cover at least the three quote characters, the three bracket kinds, and HTML/XML tags, for adding, deleting, and replacing alike. Deleting and replacing SHALL additionally accept a short alias standing for "whichever quote is there" and one for "whichever bracket is there", so that a pair can be operated on without first looking at which kind it is.

A character that has no pair of its own SHALL be usable as a delimiter, placing that same character on both sides.

#### Scenario: Operating on a tag

- **WHEN** the cursor is inside an HTML element and the user changes its tag surround to another tag
- **THEN** the opening and closing tag names are both changed
- **AND** the element's content is unchanged

#### Scenario: Deleting whichever quote is there

- **WHEN** the cursor is inside a quoted string and the user deletes the surround using the any-quote alias
- **THEN** that quote pair is removed, whichever of the three it was

#### Scenario: A character with no pair

- **WHEN** the user adds a surround using a character that has no closing counterpart
- **THEN** that same character is placed on both sides of the text

### Requirement: A surround edit is one undo step and repeats with the dot command

Each add, delete, or replace SHALL be a single entry in the undo history, undone and redone whole. Each SHALL also be repeatable with `.`, repeating the same operation with the same delimiters at the new cursor position.

#### Scenario: Undoing a surround

- **WHEN** the user adds a pair around a word and presses `u` once
- **THEN** both halves of the pair are gone
- **AND** the buffer matches its state before the command

#### Scenario: Repeating a surround

- **WHEN** the user quotes one word, moves to another word, and presses `.`
- **THEN** the second word is quoted the same way

### Requirement: The commands do not displace an existing mapping

The commands SHALL be reachable without taking any key sequence that has a meaning in stock Neovim or in this configuration. In particular they SHALL NOT claim bare `s` or bare `S` in normal or operator-pending mode, nor `r` or `R` in operator-pending mode, all of which belong to the jump-motions capability; and SHALL NOT use the `<leader>b`, `<leader>c`, `<leader>f`, `<leader>g`, `<leader>h`, `<leader>m`, `<leader>q`, or `<leader>w` prefixes, nor the `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>`, `<C-n>`, `<C-s>`, `<C-Up>`/`<C-Down>`, `<S-Left>`/`<S-Right>`, or `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` mappings this configuration already defines. The single exception is visual-mode `S`, which the visual add command shadows by design and which the jump-motions capability leaves alone for that reason.

#### Scenario: Bare `s` is not a surround command

- **WHEN** the user presses `s` in normal mode
- **THEN** the jump-motions capability's jump starts
- **AND** no surround command is invoked and no surround command waits on the key

#### Scenario: The existing mappings survive

- **WHEN** the user presses any mapping this configuration defined before this change
- **THEN** it does what it did before
- **AND** no surround command intercepts it

#### Scenario: An operator followed by a non-surround key

- **WHEN** the user presses an operator whose two-key surround form exists, followed by an ordinary motion
- **THEN** the operator applies to that motion with no wait
- **AND** no surround command runs

#### Scenario: The surround commands still resolve

- **WHEN** the user presses `ys`, `ds`, or `cs` followed by their usual arguments
- **THEN** the surround edit is made
- **AND** the `s` in the sequence does not start a jump

### Requirement: The capability costs nothing until it is used

The plugin providing this capability SHALL NOT load during editor startup. It SHALL load when one of its commands is first invoked, and that first invocation SHALL take effect rather than being consumed by the load.

#### Scenario: A session that never surrounds

- **WHEN** the editor starts and no surround command is invoked
- **THEN** the plugin is not loaded
- **AND** startup time is unaffected

#### Scenario: The first invocation is not swallowed

- **WHEN** the user invokes a surround command for the first time in a session
- **THEN** the plugin loads
- **AND** the command performs its edit rather than being consumed

### Requirement: The capability is declared in its own plugin file

Every mapping in this capability SHALL be declared in a single file under `lua/plugins/`, and SHALL NOT appear in the general keymaps module. Deleting that file SHALL remove the capability entirely.

#### Scenario: Locating a mapping

- **WHEN** a contributor looks for where a surround mapping is defined
- **THEN** it is declared in the plugin's file under `lua/plugins/`
- **AND** it is absent from `lua/config/keymaps.lua`

#### Scenario: Removing the capability

- **WHEN** the plugin's file is deleted and the editor is restarted
- **THEN** none of its mappings is defined
- **AND** no error is raised about a missing module
- **AND** nothing else in the configuration is affected

