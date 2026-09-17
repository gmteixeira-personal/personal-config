## ADDED Requirements

### Requirement: A file yanked in one file manager window is pastable in another

The file manager SHALL share its yank list between the windows open for one user on one machine, so that a file yanked or cut in one window can be pasted from another without repeating the navigation that found it.

Two windows of this file manager are two processes, and a yank list held per process is a yank list that exists only where it was made. The second window is then worse than useless for the task a second window is opened for: the file is on screen in one and unreachable from the other, and the way out is to close it and walk the first window to both places in turn. Sharing the list is what makes the two windows one file manager rather than two.

The sharing SHALL cover cut as well as copy. They are one list in the program, and a rule that moved one and not the other would have the second window able to complete a copy and silently unable to complete a move — a distinction the user has no way to see before pasting.

#### Scenario: A copy crosses windows

- **WHEN** a file is yanked in one file manager window
- **AND** a paste is made in a second window open at another directory
- **THEN** the file SHALL be copied into that directory

#### Scenario: A cut crosses windows

- **WHEN** a file is cut in one file manager window
- **AND** a paste is made in a second window
- **THEN** the file SHALL be moved into that directory

#### Scenario: A window opened afterwards joins in

- **WHEN** a file is yanked, and a further file manager window is opened after the yank
- **THEN** the new window SHALL be able to paste that file

### Requirement: The shared yank list comes from the file manager's own configuration

The sharing SHALL be turned on in the file manager's own configuration, and SHALL NOT be built out of an external clipboard bridge, a wrapper script, or a file the windows write to by hand.

The program already carries this: it publishes the list over a socket its instances share, and the configuration only has to ask. An arrangement outside the program would have to re-implement what is being asked for and would then be wrong in the ways a re-implementation is wrong — a second source of truth for what is yanked, a lifetime that does not match the program's, and paths that survive the windows that meant them.

The configuration file that asks for it SHALL be tracked in this repository. Held only on the machine it was written on, it is indistinguishable from not existing: a checkout gets two windows that do not talk to each other, with nothing recording that they ever did.

#### Scenario: The setting is in the checkout

- **WHEN** the repository is inspected for the file manager's configuration
- **THEN** a tracked file SHALL turn the yank sharing on

#### Scenario: A fresh checkout shares yanks

- **WHEN** the repository is checked out on a machine where the file manager is installed
- **THEN** two of its windows SHALL share a yank list with no further step

#### Scenario: No outside program is in the path

- **WHEN** the configuration that shares the yank list is read
- **THEN** it SHALL name only the file manager's own facility
- **AND** it SHALL NOT invoke a clipboard tool or write the yank list to a file of its own

### Requirement: The shared list outlives the windows, and the configuration says so

The shared yank list SHALL survive every file manager window closing, and the configuration SHALL record that it does, along with how a pending yank is cleared and where a pending one can be read.

This is not the arrangement one would choose; it is the one the program implements, and stating it is the only defence available. Sharing the list is what writes it to disk: the file manager keeps the shared message in a state file and reloads it at startup, so a yank outlives the window that made it, outlives every window closing, and outlives a reboot. With the sharing off, nothing is written at all — durability is a consequence of this change rather than of the program's defaults, which is exactly why the configuration has to own up to it.

The cost SHALL be recorded rather than hedged: one shared list means a cut left pending in a window nobody is looking at is a move that the next paste anywhere completes, and because the list is durable that paste can come days and a reboot later. A user who expects each window to hold its own yank, or expects closing everything to be a reset, is a user who can move a file by accident.

#### Scenario: A yank survives every window closing

- **WHEN** a file is yanked, every file manager window is closed, and a new one is opened
- **THEN** that yank SHALL still be pending
- **AND** a paste SHALL act on it

#### Scenario: Nothing is stored when the sharing is off

- **WHEN** the file manager runs without the yank sharing turned on, and a file is yanked
- **THEN** no yank SHALL be written to its state file

#### Scenario: The configuration states the reach

- **WHEN** the configuration turning on the sharing is read
- **THEN** it SHALL record that the whole yank list, cut included, is shared with every other window
- **AND** it SHALL record that a pending yank survives closing every window and a reboot
- **AND** it SHALL record how a pending yank is cleared, and where a pending one can be read without opening the file manager

### Requirement: Existing windows are not assumed to have joined

Where the sharing is turned on, the configuration SHALL record that it takes effect at the file manager's startup, so that windows already open when the setting was added are not assumed to be part of it.

The file is read once per process. A user who adds the setting and tests it in the two windows already on screen sees it not work, and has no way to tell that from the setting being wrong — which is the failure that sends people looking for a plugin to install.

#### Scenario: The startup requirement is recorded

- **WHEN** the configuration is read
- **THEN** it SHALL state that already-running windows SHALL be restarted before they share anything
