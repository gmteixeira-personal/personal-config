# fuzzy-finder Specification

## Purpose

Defines what an interactive shell in this configuration offers through a fuzzy finder: which keys open a picker over which set of candidates, what the picker leaves on the command line, and what a shell does on a machine where the finder is not installed.

## Requirements

### Requirement: Three pickers are reachable by key at the prompt

An interactive shell SHALL bind one key each to a picker over files under the current directory, a picker over the shell's own command history, and a picker over directories under the current directory. Each SHALL be reachable by a single keystroke from a prompt with no command typed and from a prompt with a partial command typed.

The file picker SHALL insert what was chosen into the command line at the cursor, leaving the line unrun. The history picker SHALL replace the command line with the chosen entry, leaving it unrun. The directory picker SHALL change the shell's working directory to the chosen directory.

#### Scenario: Choosing a file mid-command

- **WHEN** the command line reads a command and a space, the file picker key is pressed, and an entry is chosen
- **THEN** the chosen path SHALL be inserted at the cursor
- **AND** the command line SHALL NOT be run

#### Scenario: Choosing a history entry

- **WHEN** the history picker key is pressed and an entry is chosen
- **THEN** the command line SHALL hold that entry
- **AND** it SHALL NOT be run until the user presses Enter

#### Scenario: Choosing a directory

- **WHEN** the directory picker key is pressed and an entry is chosen
- **THEN** the shell's working directory SHALL be the chosen directory

#### Scenario: Leaving a picker without choosing

- **WHEN** any of the three pickers is open and it is dismissed without a selection
- **THEN** the command line SHALL be exactly what it was before the key was pressed
- **AND** the working directory SHALL be unchanged

### Requirement: Fuzzy completion is available on a key

An interactive shell SHALL offer a key that opens the fuzzy finder over the completions for the current token, so that a long candidate list can be narrowed by typing any part of a candidate rather than only its prefix. The chosen candidate SHALL replace the current token.

This SHALL NOT replace the shell's own completion key, which SHALL keep its prefix-matching behavior.

#### Scenario: Narrowing a long completion list

- **WHEN** the current token has many completions and the fuzzy completion key is pressed
- **THEN** a picker over those completions SHALL open
- **AND** the chosen candidate SHALL replace the current token

#### Scenario: The ordinary completion key is untouched

- **WHEN** the shell's own completion key is pressed
- **THEN** it SHALL complete as it did before this configuration added the fuzzy finder

### Requirement: The pickers are available in both shells

The pickers SHALL be present in an interactive fish and in an interactive bash, on the same keys, so that dropping to bash does not silently take the capability away.

#### Scenario: The same key in bash

- **WHEN** a user drops from fish to an interactive bash and presses the history picker key
- **THEN** a picker over that shell's history SHALL open

### Requirement: The pickers survive the editing mode being reinstalled

In fish, the picker bindings SHALL still be in effect after the vi binding set is applied or reapplied, since applying it clears the binding table. A binding SHALL NOT be lost by the user or a script switching editing modes during a session, and SHALL be in effect at a real prompt rather than merely having been issued during start-up.

#### Scenario: Switching editing mode preserves the pickers

- **WHEN** the vi binding set is applied again in a running fish
- **THEN** each picker key SHALL still resolve to its picker

#### Scenario: The bindings are what the keys resolve to at the prompt

- **WHEN** an interactive fish has finished starting and the bindings in effect are inspected
- **THEN** each picker key SHALL report the picker as its action
- **AND** SHALL NOT report an action installed by the prompt plugin or any other component

### Requirement: The pickers work in both fish editing modes

Each picker key SHALL perform the same action whether the shell is in vi insert mode or vi normal mode, so the capability does not depend on which mode the prompt happens to be in.

#### Scenario: The same key in normal mode

- **WHEN** a picker key is pressed in vi normal mode, and again in vi insert mode
- **THEN** the same picker SHALL open in both

### Requirement: A machine without the finder starts a clean shell

Where the fuzzy finder is not installed, an interactive shell SHALL start with no error, warning, or message about it, and SHALL simply not offer the pickers. The dependency SHALL be optional at run time rather than required at configuration time.

#### Scenario: The finder is absent

- **WHEN** an interactive fish or bash starts on a machine with no fuzzy finder installed
- **THEN** the shell SHALL start with no output about it
- **AND** every other binding, shorthand, and environment setting SHALL be in effect

### Requirement: No picker key displaces an existing binding

A key bound to a picker SHALL NOT be one this configuration or the prompt plugin already binds to another action. Where a collision exists, the picker SHALL be moved to a key that has none rather than taking the existing action away.

#### Scenario: Existing bindings still work

- **WHEN** an interactive fish has started with the pickers installed
- **THEN** every key this configuration bound before the pickers existed SHALL still perform its original action

### Requirement: A non-interactive shell gets no picker setup

A script or tool runner starting a non-interactive shell SHALL have no picker binding, widget, or completion installed on its behalf, since there is no reader to press a key.

#### Scenario: A script sees nothing

- **WHEN** a non-interactive fish or bash reads this configuration
- **THEN** no picker binding SHALL be in effect
- **AND** the shell SHALL start with no error
