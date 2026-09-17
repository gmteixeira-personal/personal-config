# gui-text-editor Specification

## Purpose
Defines which program this session edits text with in a window of its own rather than inside a terminal, how it is reached, and what its window has to match so that the same buffer does not read as two different programs depending on which one is open.

## Requirements

### Requirement: The session states which program edits text in its own window

The session SHALL name a graphical text editor, and that program SHALL be one this session installs.

Nothing named one before. The program was present and usable, and it was still not the session's graphical editor in any sense a configuration can check — no file said so, so nothing could offer it or list it. This is the same absence `file-manager` records, and it has the same cause: the program is a cargo build, and `cargo install` copies out the binary alone.

#### Scenario: The editor is identifiable from tracked configuration

- **WHEN** the tracked configuration is inspected for the session's graphical text editor
- **THEN** it SHALL name one program
- **AND** that program SHALL be installed

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

### Requirement: The desktop entry is provided by this repository

Where the graphical editor ships no desktop entry of its own, this repository SHALL provide one, and that entry SHALL be tracked here rather than left as untracked local state.

An entry that exists only on the machine it was written on is indistinguishable, from the repository's point of view, from an entry that does not exist: the session cannot be rebuilt from a checkout, and the file is one tidy-up away from being gone with nothing recording that it was ever there.

#### Scenario: The entry is in the checkout

- **WHEN** the repository is inspected for the graphical editor's desktop entry
- **THEN** the entry SHALL be present as a tracked file

#### Scenario: A fresh checkout has the entry

- **WHEN** the repository is checked out on a machine where the editor is installed
- **THEN** the launcher SHALL offer the editor with no further step

### Requirement: The entry draws its own window rather than asking for a terminal

The graphical editor's desktop entry SHALL NOT declare that the program requires a terminal, and SHALL NOT name a terminal command in what it executes.

This is the opposite of what `file-manager` requires of its entry, and the difference is the whole point of the capability: that entry runs a terminal program and has to be given a terminal, while this one runs a program that draws its own window. Declaring a terminal here would wrap a window inside a window. The question the other two entries in this repository have to answer — which terminal this session runs — does not arise.

#### Scenario: The entry declares no terminal

- **WHEN** the graphical editor's desktop entry is inspected
- **THEN** it SHALL NOT declare that the program requires a terminal

#### Scenario: The entry names no terminal

- **WHEN** the command the entry executes is read
- **THEN** it SHALL be the editor's own command
- **AND** it SHALL NOT contain the name of a terminal emulator

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

### Requirement: The editor draws the terminal's font at the terminal's size

The graphical editor SHALL be configured with the same font family and the same point size the session's terminal is configured with, and SHALL NOT be left on the font its package defaults to.

The default is a family this session does not run at a size larger than the terminal's, so the same buffer opened in both is visibly different text. The editor and the terminal are two views of one program, and the difference reads as a fault in whichever one is looked at second.

There is no mechanism tying the two files together, so each SHALL record that the other exists and that the values are a pair.

#### Scenario: The families match

- **WHEN** the graphical editor's tracked configuration and the terminal's are compared
- **THEN** they SHALL name the same font family

#### Scenario: The sizes match

- **WHEN** the two configurations are compared
- **THEN** they SHALL state the same point size

#### Scenario: The pairing is recorded

- **WHEN** the graphical editor's tracked configuration is read
- **THEN** it SHALL state that the values restate the terminal's
- **AND** it SHALL name the terminal's configuration file

### Requirement: The editor rasterizes that font the way the terminal does

The graphical editor's tracked configuration SHALL state the hinting and the antialiasing this machine's font configuration already gives the terminal.

Matching the family and the size is not enough to make the two look alike. The terminal rasterizes through the system font stack and so inherits this machine's answer; the editor rasterizes through its own and reads none of it, defaulting to heavier hinting and a different antialiasing mode. The same glyph at the same size therefore comes out visibly bolder, which is read as a different font rather than as a different rasterizer.

The configuration SHALL record where the terminal's answer comes from, so that a later override of the system defaults can be followed through to this file.

#### Scenario: The rasterization is stated rather than defaulted

- **WHEN** the graphical editor's tracked configuration is inspected
- **THEN** it SHALL state a hinting setting
- **AND** it SHALL state an antialiasing setting

#### Scenario: The values are traceable to the system answer

- **WHEN** that part of the configuration is read
- **THEN** it SHALL name the system font configuration as the source of the values

### Requirement: The editor frames its grid the way the terminal does

The graphical editor SHALL be given the same window padding the session's terminal is given.

Neither window is a whole number of text rows tall, and both put the pixels left over below the last row at the bottom. With padding the leftover is framed; with none it pools in a single band under the status line, which is what makes one window look taller than the other at the same size. Matching the padding makes the two grid areas the same and the two row counts the same.

Where the editor offers no way to set this in its own configuration file, the setting SHALL be made wherever the editor does read it, and both places SHALL record that this is why the setting is not with the rest of them.

#### Scenario: The padding matches the terminal's

- **WHEN** the padding the graphical editor is given is compared with the terminal's
- **THEN** they SHALL be equal on every side

#### Scenario: The grids agree

- **WHEN** the editor and the terminal are opened at the same window size
- **THEN** they SHALL report the same number of text rows

#### Scenario: A setting made elsewhere is accounted for

- **WHEN** the graphical editor's own tracked configuration is read and a setting it cannot carry is looked for
- **THEN** it SHALL name the file that carries the setting instead
- **AND** that file SHALL state why the setting is there rather than with the others

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
