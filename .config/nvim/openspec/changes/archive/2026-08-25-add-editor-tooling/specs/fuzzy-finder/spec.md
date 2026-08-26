## Purpose

Lets the user reach any file, any line of text, any open buffer, or any help topic in the project by typing part of its name rather than by remembering and navigating a path.

## ADDED Requirements

### Requirement: `<leader><leader>` searches for files by name

Pressing `<leader><leader>` in normal mode SHALL open an interactive picker over the files in the current working directory. Typing SHALL narrow the list by fuzzy-matching the query against file paths, updating on every keystroke. Selecting an entry SHALL open that file in the current window.

The mapping SHALL be `<leader><leader>` exactly, and `<leader>f` SHALL NOT be bound as a mapping in its own right, so that no `<leader>f`-prefixed mapping waits on a key-sequence timeout.

#### Scenario: Finding a file by a fragment of its name

- **WHEN** the user presses `<leader><leader>` and types a fragment of a filename
- **THEN** the list narrows to files whose paths fuzzy-match that fragment
- **AND** the list updates as each further character is typed

#### Scenario: Opening a match

- **WHEN** the user selects an entry in the file picker
- **THEN** that file opens in the window the picker was invoked from
- **AND** the picker closes

#### Scenario: Dismissing without choosing

- **WHEN** the user cancels the picker without selecting an entry
- **THEN** the picker closes
- **AND** the buffer and cursor position are exactly as they were before it opened

#### Scenario: No mapping stalls on the find prefix

- **WHEN** the user presses `<leader>f`
- **THEN** nothing is executed and no action is deferred pending a timeout
- **AND** the editor waits for the next key of a `<leader>f`-prefixed sequence

### Requirement: `<leader>fg` searches file contents

Pressing `<leader>fg` SHALL open an interactive picker that searches the *text* of files under the current working directory. Results SHALL identify the file and line of each match, and selecting one SHALL open that file with the cursor on the matching line.

#### Scenario: Searching for a string across the project

- **WHEN** the user presses `<leader>fg` and types a search string
- **THEN** matching lines from across the project are listed with their file and line number
- **AND** the results update as the query changes

#### Scenario: Jumping to a match

- **WHEN** the user selects a result from the content search
- **THEN** the containing file opens
- **AND** the cursor is placed on the matched line

#### Scenario: Query with no matches

- **WHEN** the query matches nothing
- **THEN** the picker shows an empty result list
- **AND** no error is raised

### Requirement: `<leader>fb` lists open buffers

Pressing `<leader>fb` SHALL open a picker over the currently open buffers. Selecting one SHALL switch to it.

#### Scenario: Switching buffers

- **WHEN** two or more buffers are open
- **AND** the user presses `<leader>fb` and selects one
- **THEN** the current window displays that buffer

### Requirement: `<leader>fh` searches help

Pressing `<leader>fh` SHALL open a picker over the editor's help tags. Selecting a tag SHALL open the help document at that tag.

#### Scenario: Opening a help topic

- **WHEN** the user presses `<leader>fh` and selects a help tag
- **THEN** the help window opens positioned at that tag

### Requirement: Picker mappings are declared with the finder

Every mapping in this capability SHALL be declared in the fuzzy finder's own plugin file and SHALL NOT appear in the general keymaps module, per the ownership rule in `config-structure`.

#### Scenario: Locating a picker mapping

- **WHEN** a contributor looks for where `<leader><leader>` is defined
- **THEN** it is declared in the fuzzy finder's plugin file under `lua/plugins/`
- **AND** it is absent from `lua/config/keymaps.lua`
