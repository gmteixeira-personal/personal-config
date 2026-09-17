## MODIFIED Requirements

### Requirement: The editor is reachable from the launcher

The graphical editor SHALL be startable from the session's launcher, without a terminal already open and without typing a command.

The session's answer to "start a program without a terminal" is the launcher, and it is the route that does not depend on having a file to open: opening the editor empty, to start something new, has no file to associate and so reaches it no other way. An editor reachable only from a shell is reachable only by someone who did not need a window of their own.

#### Scenario: The launcher offers it

- **WHEN** the launcher is opened and the editor's name is typed
- **THEN** the editor SHALL be among the matches

#### Scenario: Choosing it starts it

- **WHEN** the editor is chosen from the launcher
- **THEN** it SHALL open in a window of its own
- **AND** no terminal SHALL have to be open beforehand

### Requirement: The entry is found by what it does, and goes away with the program

The graphical editor's desktop entry SHALL declare keywords describing the task, and SHALL name the program's executable in the field a launcher tests before offering an entry.

The program's name says nothing about what it is for, and the launcher is already required to match a query against an entry's keywords. The executable test is what keeps a checkout on another machine from showing an entry that opens nothing: a launcher skips an entry whose named binary is not on its path, and the library that opens files by type skips it the same way, falling through to another entry registered for the type rather than failing silently.

#### Scenario: A task word finds the entry

- **WHEN** a word describing the task rather than the program is typed into the launcher
- **THEN** the graphical editor SHALL be among the matches

#### Scenario: The entry hides itself when the program is gone

- **WHEN** the graphical editor is not installed on the machine
- **THEN** the launcher SHALL NOT offer the entry

#### Scenario: Opening a file by type skips it the same way

- **WHEN** the graphical editor is not installed and a file whose type it is the default for is opened
- **THEN** the entry SHALL be skipped rather than launched
- **AND** the file SHALL reach another entry registered for that type

## ADDED Requirements

### Requirement: The editor is what a file opened from outside a shell opens in

The graphical editor SHALL be the application the session's default-application mapping names for text and source types, and its desktop entry SHALL accept the files a caller supplies and open them.

This is the caller the editor exists for. A file opened from the file manager, from a browser download or through `xdg-open` comes from a program that is not a shell and has no terminal to lend, so the editor that answers has to bring its own window. Naming the terminal spelling of the same editor there was answering a graphical caller with the shell's arrangement, and it put a terminal on screen whose only content was an editor.

Which spelling of the editor a caller gets SHALL depend on where the call came from rather than on which is installed: a shell keeps the terminal editor through the environment variables that name it, and nothing in this capability changes them. The two are the same program and the same configuration, so this is a choice of window, not of editor.

#### Scenario: A text file opened from outside a shell reaches it

- **WHEN** a file of a type the mapping covers is opened from the file manager, from a browser download, or through `xdg-open`
- **THEN** the graphical editor SHALL open in a window of its own

#### Scenario: The file arrives loaded

- **WHEN** the editor is started that way
- **THEN** it SHALL have the file that was opened loaded
- **AND** several files supplied at once SHALL all be loaded

#### Scenario: A shell still gets the terminal editor

- **WHEN** a program started from a shell opens the editor named by the environment
- **THEN** it SHALL be the terminal editor, in the terminal that is already open
- **AND** the graphical editor SHALL NOT be started
