# file-manager Specification

## Purpose

Defines which program this session browses files with and how it is reached: that it is startable without a terminal already open, and what its desktop entry has to declare given that the program ships none of its own.

## Requirements

### Requirement: The session states which program browses files

The session SHALL name a file manager, and that program SHALL be one this session installs.

Nothing named one before. The program was present and usable, and it was still not the session's file manager in any sense a configuration can check — there was no file that said so, so nothing could offer it, list it, or open a directory with it. A tool that only the person who installed it knows about is a tool the session does not have.

#### Scenario: The file manager is identifiable from tracked configuration

- **WHEN** the tracked configuration is inspected for the session's file manager
- **THEN** it SHALL name one program
- **AND** that program SHALL be installed

### Requirement: The file manager is reachable without a terminal

The file manager SHALL be startable from the session's launcher, without a terminal already open and without typing a command.

It is a terminal program, which is what makes this worth requiring rather than assuming. Starting it means having a terminal first, and the session's answer to "start a program without a terminal" is the launcher — the same route locking, powering off, the radios and the calculator already take. A file manager reachable only from a shell is reachable only by someone who did not need a file manager to find their way there.

#### Scenario: The launcher offers it

- **WHEN** the launcher is opened and the file manager's name is typed
- **THEN** the file manager SHALL be among the matches

#### Scenario: Choosing it starts it

- **WHEN** the file manager is chosen from the launcher
- **THEN** it SHALL open in a terminal window
- **AND** no terminal SHALL have to be open beforehand

### Requirement: The desktop entry is provided by this repository

Where the file manager ships no desktop entry of its own, this repository SHALL provide one, and that entry SHALL be tracked here rather than left as untracked local state.

An entry that exists only on the machine it was written on is indistinguishable, from the repository's point of view, from an entry that does not exist: the session cannot be rebuilt from a checkout, and the file is one tidy-up away from being gone with nothing recording that it was ever there. The entries this repository already ships for locking, powering off and the radios are tracked for the same reason.

#### Scenario: The entry is in the checkout

- **WHEN** the repository is inspected for the file manager's desktop entry
- **THEN** the entry SHALL be present as a tracked file

#### Scenario: A fresh checkout has the entry

- **WHEN** the repository is checked out on a machine where the file manager is installed
- **THEN** the launcher SHALL offer the file manager with no further step

### Requirement: The entry asks for a terminal rather than naming one

The file manager's desktop entry SHALL declare that it requires a terminal, and SHALL NOT name a terminal command in what it executes.

The session's launcher is already required to give such an entry the terminal this session runs, so naming one here would state the same answer twice, in a file that has no way to stay in step with the launcher's copy. The entry that opens the editor does name its terminal, and that is not a precedent to follow blindly: it does so because a MIME association makes it launchable by a component that cannot be told which terminal to use, and the file manager has no such association. Where an entry's only route in is the launcher, the launcher's answer is the whole answer.

The consequence SHALL be accepted rather than hedged: this entry works from the launcher and from anything else that honours the terminal declaration, and does not work from a component that picks a terminal off a fixed list. Should the file manager ever be given a MIME association, that is when the question is reopened.

#### Scenario: The entry declares its need

- **WHEN** the file manager's desktop entry is inspected
- **THEN** it SHALL declare that the program requires a terminal

#### Scenario: The entry names no terminal

- **WHEN** the command the entry executes is read
- **THEN** it SHALL be the file manager's own command
- **AND** it SHALL NOT contain the name of a terminal emulator

### Requirement: The entry is found by what it does, not only by its name

The file manager's desktop entry SHALL declare keywords describing the task, so that a query naming the task finds it.

The program's name says nothing about what it is for. A user reaching for a file manager types what they want — files, browse, manager — and the launcher is already required to match a query against an entry's keywords, so an entry without them answers only to a name the user has to have learned first. Every other entry this repository ships carries keywords for this reason.

#### Scenario: A task word finds the entry

- **WHEN** a word describing the task rather than the program is typed into the launcher
- **THEN** the file manager SHALL be among the matches

#### Scenario: The entry hides itself when the program is gone

- **WHEN** the file manager is not installed on the machine
- **THEN** the launcher SHALL NOT offer the entry
