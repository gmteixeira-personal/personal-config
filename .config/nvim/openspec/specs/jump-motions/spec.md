# jump-motions Specification

## Purpose
Puts any position that is visible on screen one short keystroke sequence away, by labelling the candidate positions as the user types and letting a label be pressed to land on it — including from inside an operator, where the operation is applied somewhere else on screen and the cursor comes back.
## Requirements
### Requirement: A visible position is reached by typing what is there and pressing its label

Pressing `s` SHALL start a jump: each character the user types narrows the set of matching positions on screen, and every remaining match SHALL be shown with a distinct label next to it. Pressing a label SHALL move the cursor to that match. The jump SHALL be available in normal, visual, and operator-pending mode, and in visual mode it SHALL extend the selection to the chosen match rather than replacing it.

Labels SHALL be drawn without shifting the text they annotate, so line and column positions the user is reading do not move while choosing.

A jump SHALL be abandonable at any point with `<Esc>`, leaving the cursor, the selection, the buffer, and the registers exactly as they were before the jump started.

#### Scenario: Jumping to a word further down the screen

- **WHEN** the user presses `s` and types the first characters of a word visible lower in the window
- **THEN** each position matching what was typed is labelled
- **AND** pressing one of those labels moves the cursor to that position

#### Scenario: Only one match remains

- **WHEN** the typed characters narrow the candidates to a single match
- **THEN** the cursor moves there without a label having to be pressed

#### Scenario: Extending a selection

- **WHEN** the user is in visual mode with a selection active and jumps to a position further along
- **THEN** the selection is extended from its original start to the chosen position

#### Scenario: Abandoning a jump

- **WHEN** the user presses `s`, types one or more characters, and then presses `<Esc>`
- **THEN** the cursor is where it was before `s` was pressed
- **AND** the buffer is unmodified

#### Scenario: Nothing on screen matches

- **WHEN** the user types characters that match no position in the visible area
- **THEN** no label is shown
- **AND** the jump can still be abandoned with `<Esc>` and leaves no trace

### Requirement: An operator can be applied at a remote position and the cursor comes back

In operator-pending mode, `r` SHALL start a jump; once a position is chosen, the pending operator SHALL be applied there, taking a further motion or text object at that position, and the cursor SHALL then return to the position the operator was started from.

This SHALL hold for every operator that takes a motion, including yank, delete, and change. For `c`, the return SHALL happen when the resulting insert is left, since the edit is made at the remote position.

#### Scenario: Yanking a word elsewhere on screen

- **WHEN** the user presses `yr`, jumps to a word visible elsewhere in the window, and types `iw`
- **THEN** that word is yanked into the unnamed register
- **AND** the cursor is back at the position it was at when `yr` was pressed

#### Scenario: Deleting a remote text object

- **WHEN** the user presses `dr`, jumps to a position inside a bracketed expression, and types `i(`
- **THEN** the contents of those brackets are deleted
- **AND** the cursor is back where the delete was started from

#### Scenario: Abandoning a remote operation

- **WHEN** the user presses `dr` and then `<Esc>` before choosing a label
- **THEN** no deletion occurs
- **AND** the cursor has not moved
- **AND** the registers are unchanged

### Requirement: A syntax node around the cursor is selected and grown

Pressing `S` SHALL select the smallest syntax node containing the cursor, and SHALL offer labels for the enclosing nodes so that the selection can be grown to a chosen ancestor in one press. Repeating the key SHALL grow the selection to the next enclosing node. The key SHALL be available in normal and operator-pending mode, so that an operator such as `d` or `y` can take a syntax node as its motion.

Visual-mode `S` SHALL NOT be claimed by this capability: it belongs to the surround capability, which shadows it by design.

#### Scenario: Selecting the expression under the cursor

- **WHEN** the cursor is inside a function call in a buffer whose language has a parser available
- **AND** the user presses `S`
- **THEN** the innermost node containing the cursor is selected
- **AND** the enclosing nodes are labelled so a larger one can be selected in one press

#### Scenario: Growing the selection

- **WHEN** a syntax node is selected and the user presses `S` again
- **THEN** the selection grows to the next enclosing node

#### Scenario: Operating on a syntax node

- **WHEN** the user presses `d` followed by `S` and chooses a node
- **THEN** that node's text is deleted

#### Scenario: Visual-mode `S` still surrounds

- **WHEN** the user has a visual selection and presses `S`
- **THEN** the surround capability's add-around-selection command runs
- **AND** no node selection is started

### Requirement: A search result can be widened to the syntax node containing it

Pressing `R` SHALL start a labelled search whose chosen match is expanded to the syntax node containing it, rather than to the matched characters alone. It SHALL be available in operator-pending and visual mode.

#### Scenario: Operating on the node around a match

- **WHEN** the user presses `dR`, types characters matching text inside a statement elsewhere on screen, and presses that match's label
- **THEN** the whole syntax node containing the match is deleted, not only the matched characters

#### Scenario: Extending a selection to a remote node

- **WHEN** the user is in visual mode and uses `R` to choose a match elsewhere on screen
- **THEN** the selection is extended to cover the syntax node containing that match

### Requirement: Syntax-based modes depend only on the editor's bundled parsers

The syntax node modes SHALL use the tree-sitter support built into the editor and the parsers available in its runtime. No plugin providing parsers SHALL be required for this capability.

In a buffer whose language has no parser available, the syntax node modes SHALL report that plainly and leave the buffer, the cursor, and the selection unchanged. They SHALL NOT raise an unhandled error and SHALL NOT make the other modes in this capability unavailable.

#### Scenario: A language with a parser in the runtime

- **WHEN** the user invokes a syntax node mode in a buffer whose language has a parser available in the editor's runtime
- **THEN** node selection works
- **AND** no parser plugin was installed to make it work

#### Scenario: A language with no parser

- **WHEN** the user invokes a syntax node mode in a buffer whose language has no parser available
- **THEN** the editor reports that no parser is available
- **AND** the buffer and cursor are unchanged
- **AND** `s` and the character motions continue to work in that buffer

### Requirement: Character motions continue in their own direction without a repeat key

After `f`, `t`, `F`, or `T`, pressing the same motion key again SHALL advance to the next occurrence in that motion's own direction rather than prompting for a new character. `;` and `,` SHALL keep their meanings of repeating forwards and backwards for all four.

A character motion SHALL keep its stock semantics: the same target character, the same inclusive or exclusive behaviour, and the same effect when used with an operator or a count.

#### Scenario: Advancing through occurrences forwards

- **WHEN** the user presses `f` and a character, then presses `f` again
- **THEN** the cursor moves to the next occurrence of that same character after the current one

#### Scenario: Advancing through occurrences backwards

- **WHEN** the user presses `F` and a character, then presses `F` again
- **THEN** the cursor moves to the previous occurrence of that same character

#### Scenario: The repeat keys still work

- **WHEN** the user has used a character motion and presses `;` or `,`
- **THEN** the motion repeats forwards or backwards as it does in stock behaviour

#### Scenario: A character motion with an operator

- **WHEN** the user presses `d` followed by `t` and a character
- **THEN** the text up to but not including that character is deleted, as it ordinarily is

### Requirement: An in-progress search labels its visible matches

While a search started with `/` or `?` is being typed, every match in the visible area SHALL be labelled, and pressing a label SHALL end the search at that match. Pressing `<CR>` instead SHALL complete the search exactly as it ordinarily does, moving to the next match in the search direction.

`<C-s>` in the search command line SHALL toggle the labels off and on, so a search whose pattern contains characters that collide with labels can still be typed. Toggling SHALL NOT alter the pattern already typed.

The search pattern, the search history, `n`, `N`, and the search highlight SHALL behave as they do without this capability, including the `<Esc>` mapping that dismisses the highlight.

#### Scenario: Jumping to a labelled match

- **WHEN** the user types `/` and a pattern with several visible matches
- **AND** presses the label shown beside one of them
- **THEN** the cursor lands on that match
- **AND** the search is finished

#### Scenario: Completing the search normally

- **WHEN** the user types `/` and a pattern and presses `<CR>`
- **THEN** the cursor moves to the next match in the search direction, as it ordinarily does
- **AND** the pattern is added to the search history

#### Scenario: Repeating a search afterwards

- **WHEN** the user has finished a labelled search and presses `n`
- **THEN** the cursor moves to the next occurrence of that pattern
- **AND** `<Esc>` still dismisses the highlight

#### Scenario: Turning labels off mid-search

- **WHEN** the user is typing a search and presses `<C-s>`
- **THEN** the labels disappear
- **AND** the pattern typed so far is intact
- **AND** further typed characters go into the pattern

### Requirement: The capability does not displace an existing mapping other than the keys it declares

Beyond normal-mode `s` and `S`, operator-pending `r` and `R`, the four character motions, and the search command line, this capability SHALL NOT take any key sequence that has a meaning in stock Neovim or in this configuration. In particular it SHALL NOT claim visual-mode `S`, `<C-s>` outside the search command line, the `<leader>w` window mappings including `<leader>wr` and `<leader>wR`, the `<leader>b` buffer mappings, `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>`, `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>`, `<M-;>`, or the surround commands `ys`, `ds`, and `cs`.

Normal-mode `s` and `S` are claimed deliberately: substitute remains reachable as `cl`, and linewise change as `cc`.

#### Scenario: Existing mappings survive

- **WHEN** the user presses any mapping this configuration defined before this change
- **THEN** it does what it did before
- **AND** no jump motion intercepts it

#### Scenario: Surround commands are unaffected

- **WHEN** the user presses `ys`, `ds`, or `cs` followed by their usual arguments
- **THEN** the surround edit is made
- **AND** no jump is started by the `s` in the sequence

#### Scenario: `<C-s>` still writes the buffer

- **WHEN** the user presses `<C-s>` in normal, insert, or visual mode
- **THEN** the buffer is written, as it was before this change

#### Scenario: Window rotation survives

- **WHEN** the user presses `<leader>wr` or `<leader>wR`
- **THEN** the windows rotate, as they did before this change

### Requirement: The capability costs nothing until it is used

The plugin providing this capability SHALL NOT load during editor startup. It SHALL load when one of its keys is first pressed, and that first press SHALL take effect rather than being consumed by the load.

#### Scenario: A session that never jumps

- **WHEN** the editor starts and none of this capability's keys is pressed
- **THEN** the plugin is not loaded
- **AND** startup time is unaffected

#### Scenario: The first press is not swallowed

- **WHEN** the user presses `s` for the first time in a session
- **THEN** the plugin loads
- **AND** the jump starts rather than the press being consumed

### Requirement: The capability is declared in its own plugin file

Every mapping in this capability SHALL be declared in a single file under `lua/plugins/`, and SHALL NOT appear in the general keymaps module. Deleting that file SHALL remove the capability entirely, restoring stock `s`, `S`, `r`, `R`, the stock character motions, and the stock search command line.

#### Scenario: Locating a mapping

- **WHEN** a contributor looks for where a jump mapping is defined
- **THEN** it is declared in the plugin's file under `lua/plugins/`
- **AND** it is absent from `lua/config/keymaps.lua`

#### Scenario: Removing the capability

- **WHEN** the plugin file is deleted and the editor is restarted
- **THEN** `s` substitutes a character again
- **AND** `f`, `t`, `F`, `T`, `/` and `?` behave as they do in stock Neovim
