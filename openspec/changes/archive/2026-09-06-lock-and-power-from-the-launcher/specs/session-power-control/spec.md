## Purpose

Defines how the machine is powered off and restarted from the graphical session — that both verbs are reachable without a terminal, that each is confirmed before it acts and refused by default, that the transition is requested for now rather than scheduled for later, and that a confirmation dismissed leaves the machine exactly as it was found.

## ADDED Requirements

### Requirement: The machine is powered off and restarted from the session's launcher

The session SHALL offer powering the machine off and restarting it as entries in its own launcher, each findable by typing a prefix of the verb it performs. Neither SHALL require a terminal, a shell command, or a desktop shell the session does not run.

The session runs no shell menu and no bar power button, and the compositor holds a `handle-power-key` inhibitor, so the hardware key is not a route either. Without launcher entries the only way to end a session is to open a terminal and type the systemd verb, which is a lot of window for an action that ends every window.

The verbs SHALL be findable under more than their exact names. A user reaching for this reaches for whichever word their previous system used — shut down, power off, halt, restart, reboot — and a launcher that matches only one of each pair is a launcher that appears to be missing the entry.

#### Scenario: Powering off is reachable by name

- **WHEN** the launcher is opened and a prefix of the power-off verb is typed
- **THEN** an entry that powers the machine off SHALL be offered
- **AND** choosing it SHALL NOT require a terminal window

#### Scenario: Restarting is reachable by name

- **WHEN** the launcher is opened and a prefix of the restart verb is typed
- **THEN** an entry that restarts the machine SHALL be offered

#### Scenario: An alternative word finds the entry

- **WHEN** a common synonym for either verb is typed into the launcher — among them "shutdown", "halt" and "restart"
- **THEN** the entry for that verb SHALL be among the matches

### Requirement: Powering off and restarting are confirmed before they act

Choosing either verb SHALL present a confirmation before anything is requested of the system, and that confirmation SHALL be presented in the launcher rather than in a dialog from a toolkit the session does not otherwise use.

The confirmation SHALL default to the choice that does nothing, so that a confirming keypress arriving immediately after the one that opened it cancels rather than commits. The choice that proceeds SHALL name the verb it performs, and SHALL NOT be labelled only with an affirmative word.

The launcher is a fuzzy matcher over every desktop entry on the machine, and two letters plus Enter is enough to select an entry the user was not looking for. For every other entry in that list a wrong pick opens a window that can be closed; for these two it discards whatever is unsaved everywhere. A default of "yes" would carry the mistyped Enter straight through the confirmation and give the confirmation nothing to do.

Naming the verb is what makes the confirmation readable when it is met without having been read for. "Yes" answers a question the user may have skimmed past; "Power Off" states what happens next regardless.

#### Scenario: The confirmation is shown first

- **WHEN** the power-off or restart entry is chosen from the launcher
- **THEN** a confirmation SHALL be shown
- **AND** nothing SHALL have been requested of the system at the moment it appears

#### Scenario: Enter twice does not power the machine off

- **WHEN** the power-off entry is chosen and the confirmation is confirmed without any selection being moved
- **THEN** the machine SHALL remain running
- **AND** the confirmation SHALL have closed

#### Scenario: The confirming choice names the verb

- **WHEN** the confirmation for either verb is shown
- **THEN** the choice that proceeds SHALL contain the name of the verb it performs

#### Scenario: A dismissed confirmation changes nothing

- **WHEN** the confirmation is dismissed
- **THEN** the machine SHALL remain running
- **AND** the session SHALL be in the state it was in before the entry was chosen
- **AND** no window SHALL have been closed and no application SHALL have been asked to exit

### Requirement: A confirmed transition is requested immediately, not scheduled

Once confirmed, the transition SHALL be requested of the system's service manager to take effect at once. It SHALL NOT be scheduled for a later time, SHALL NOT be announced to logged-in users on a delay, and SHALL NOT leave the machine running while a countdown elapses.

The verb the user chose is the verb they wanted performed. A delayed shutdown is a different action wearing the same name: the machine stays up, the session stays live, and the transition happens at a moment the user is no longer watching for — which is the moment they are most likely to have started something new in the meantime.

#### Scenario: Power off happens now

- **WHEN** the power-off confirmation is confirmed
- **THEN** the machine SHALL begin powering off without a further delay having been introduced by the session
- **AND** no shutdown SHALL be left pending for a future time

#### Scenario: Restart happens now

- **WHEN** the restart confirmation is confirmed
- **THEN** the machine SHALL begin restarting without a further delay having been introduced by the session

#### Scenario: Nothing is left scheduled after a dismissal

- **WHEN** the confirmation is dismissed
- **THEN** no shutdown or restart SHALL be pending

### Requirement: Neither verb prompts for a credential the session cannot answer

Powering off and restarting SHALL complete for the user of the active local session without an authentication prompt, and the session SHALL NOT rely on an authentication agent it does not run.

This session registers no polkit authentication agent — the same absence that made a wireless passphrase unaskable before the launcher's Wi-Fi menu supplied one itself. An action that raises a polkit prompt here does not fail visibly; it stalls with nothing on screen, and the user is left looking at a launcher that closed and a machine that did not power off.

#### Scenario: No prompt appears

- **WHEN** either verb is confirmed by the user of the active local session
- **THEN** the transition SHALL proceed
- **AND** no authentication prompt SHALL be raised

### Requirement: The power commands are reproducible from tracked files

Every file needed for the power commands to be reachable and to run SHALL be tracked, and none of them SHALL name the home directory of the machine it was written on.

These commands are not one file: the script acts, the launcher entries are how they are found, the icons are what the entries name, and the link on `PATH` is what the entries resolve. Tracking the script alone produces a clone where the program exists and nothing opens it — the gap the launcher entries for the radio menus were added to close, and that the calculator's specification already states for itself.

#### Scenario: A clone can power the machine off

- **WHEN** the repository is cloned into a home directory with a different name and the session is started
- **THEN** the power-off, restart and lock entries SHALL be reachable from the launcher
- **AND** no file SHALL have to be recreated by hand for that to hold

#### Scenario: No tracked file names this machine

- **WHEN** the tracked files that make up the power commands are inspected for an absolute path naming a home directory
- **THEN** none SHALL contain one
