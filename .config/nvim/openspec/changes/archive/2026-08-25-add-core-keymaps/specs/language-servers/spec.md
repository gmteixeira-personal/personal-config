## MODIFIED Requirements

### Requirement: Built-in language mappings are preserved

The editor's built-in language-server mappings — rename, code action, references, implementation, hover and type definition — SHALL remain bound to their default keys and SHALL continue to work from those keys.

A mapping MAY be *added* on a second key that invokes the same action, but a default SHALL NOT be *replaced*, and no mapping SHALL be added that is a strict prefix of a default, because a prefix mapping puts every default beneath it behind a key-sequence timeout. In particular `gr` SHALL NOT be bound, as it prefixes `grn`, `gra`, `grr`, `gri` and `grt`.

#### Scenario: Renaming a symbol

- **WHEN** the cursor is on a symbol in a buffer with an attached server
- **AND** the user invokes the built-in rename mapping
- **THEN** the editor prompts for a new name and applies it to every reference the server reports

#### Scenario: Listing references

- **WHEN** the user invokes the built-in references mapping on a symbol
- **THEN** the locations that reference that symbol are listed

#### Scenario: Hovering

- **WHEN** the user invokes the built-in hover mapping on a symbol
- **THEN** the server's documentation for that symbol is displayed in a floating window

#### Scenario: A default is not delayed by an added alias

- **WHEN** the user presses a built-in `gr`-prefixed mapping such as the rename or references default
- **THEN** it executes as soon as the sequence is complete
- **AND** the editor does not wait to see whether a shorter mapping was intended

#### Scenario: An alias and its default both reach the same action

- **WHEN** an action is reachable from both its default key and an added alias
- **THEN** both invoke the same action with the same result
- **AND** neither is the only way to reach it

## ADDED Requirements

### Requirement: Frequently used language-server actions have short aliases

In a buffer with an attached server, the following SHALL be reachable from these keys in addition to their built-in defaults:

- `<leader>rn` — rename the symbol under the cursor.
- `<leader>ca` — list and apply the code actions available at the cursor.
- `gi` — jump to the implementation of the symbol under the cursor.
- `K` — display the server's documentation for the symbol under the cursor.

These SHALL be buffer-local and SHALL be established only when a server attaches, so that a buffer with no server keeps whatever the key does by default. Notably `gi` SHALL retain its built-in jump-to-last-insert-position behaviour in every buffer with no server attached.

#### Scenario: Renaming from the alias

- **WHEN** the cursor is on a symbol in a buffer with an attached server and the user presses `<leader>rn`
- **THEN** the editor prompts for a new name
- **AND** applies it to every reference the server reports

#### Scenario: Applying a code action

- **WHEN** the cursor is on a line for which the server offers a fix and the user presses `<leader>ca`
- **THEN** the available actions are listed
- **AND** selecting one applies it to the buffer

#### Scenario: No code action available

- **WHEN** the user presses `<leader>ca` where the server offers nothing
- **THEN** the user is told there are no code actions
- **AND** the buffer is unchanged

#### Scenario: Jumping to an implementation

- **WHEN** the cursor is on an interface member and the user presses `gi`
- **THEN** the implementation is opened with the cursor on it
- **AND** the previous position is added to the jumplist

#### Scenario: `gi` outside an LSP buffer

- **WHEN** the user presses `gi` in a buffer with no attached language server
- **THEN** the cursor returns to the position of the last insertion and insert mode is entered

#### Scenario: Hovering from `K`

- **WHEN** the cursor is on a symbol in a buffer with an attached server and the user presses `K`
- **THEN** the server's documentation for that symbol appears in a floating window
- **AND** the window is dismissed by any cursor movement

### Requirement: `[d` and `]d` move between diagnostics

In a buffer with an attached server, `]d` SHALL move the cursor to the next diagnostic in the buffer and `[d` to the previous one. Movement SHALL wrap from the last diagnostic to the first and from the first to the last, so that repeated presses cycle through every problem in the buffer.

#### Scenario: Stepping forward through problems

- **WHEN** a buffer contains two or more diagnostics and the cursor is above the first
- **AND** the user presses `]d`
- **THEN** the cursor moves to the first diagnostic
- **WHEN** the user presses `]d` again
- **THEN** the cursor moves to the second

#### Scenario: Stepping backward

- **WHEN** the cursor is below a diagnostic and the user presses `[d`
- **THEN** the cursor moves to that diagnostic

#### Scenario: Wrapping at the end

- **WHEN** the cursor is on the last diagnostic in the buffer and the user presses `]d`
- **THEN** the cursor moves to the first diagnostic in the buffer

#### Scenario: A buffer with no diagnostics

- **WHEN** the buffer has no diagnostics and the user presses `]d` or `[d`
- **THEN** the cursor does not move
- **AND** no error is raised
