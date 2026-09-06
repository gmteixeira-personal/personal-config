## ADDED Requirements

### Requirement: Agent notifications are delivered by the machine's notification service

herdr SHALL hand its notifications to the machine's notification service rather than draw them itself, and the setting SHALL be declared in the tracked configuration file so it reaches every machine.

A notification about an agent is addressed to someone who is not watching. An agent that goes blocked while its pane is on another workspace, behind another window, or on a screen that is switched off is exactly the case the notification exists for, and a toast painted inside the herdr window is visible in none of them. Delivering through the notification service is what puts the message where the user is rather than where herdr is, and on a session that has a daemon it also means the notification is drawn like every other surface, with the palette and the timeout behaviour that `desktop-notifications` fixes.

The tracked configuration SHALL record what the value means and why it was chosen, not merely which values the setting accepts.

#### Scenario: A notification leaves herdr

- **WHEN** herdr raises a notification for an agent
- **THEN** it SHALL be sent to the machine's notification service
- **AND** it SHALL NOT be drawn as a toast inside the herdr window

#### Scenario: A notification arrives while herdr is not visible

- **WHEN** an agent's state changes to one herdr notifies about while the herdr window is not on screen
- **THEN** the notification SHALL be displayed by the notification service

#### Scenario: The setting is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its toast section SHALL select the machine's notification service as the delivery

#### Scenario: The configuration explains the value

- **WHEN** the comment above that setting is read
- **THEN** it SHALL state what the selected value does
- **AND** it SHALL state why an in-app toast was not kept
- **AND** it SHALL NOT describe the value the setting holds in terms of values it does not hold

### Requirement: The delivery setting carries no platform test

One value SHALL serve every machine. The tracked configuration SHALL NOT branch on which operating system, distribution or desktop it is being read on, and SHALL NOT be split into per-machine copies to express the difference between them.

herdr offers nothing to branch with — no include directive, no local override file, no per-host section — and the one escape it does offer replaces the whole file rather than a line of it. Two near-identical copies of a hundred-line file differing in one word is a synchronisation cost paid on every later change to any other setting in it. The setting avoids the branch by naming an intent rather than a mechanism: it asks for the machine's notification service, and each machine answers with whatever it has.

#### Scenario: The configuration holds one delivery value

- **WHEN** the tracked herdr configuration file is read
- **THEN** it SHALL declare the delivery once
- **AND** that value SHALL NOT be conditional on the machine

#### Scenario: No second configuration file is tracked

- **WHEN** the tracked files under herdr's configuration directory are listed
- **THEN** there SHALL be exactly one herdr configuration file among them
- **AND** no machine SHALL require the configuration path to be overridden to get its notifications delivered

### Requirement: A machine without a notification service supplies one

Where a machine has nothing owning the notification bus name, that machine SHALL supply the notification command on its `PATH`, outside this repository. The difference between machines SHALL be resolved by the machine, not by the tracked configuration.

This is the arrangement the rest of these dotfiles already use for a tool present on one machine and absent on another: the shell configuration asks whether the tool is there rather than which system it is on, and the editor configuration asks whether a provider was found rather than testing for the platform. A machine that cannot display a notification is a machine missing a capability, and the place to add a capability is the machine.

The cost of not doing so SHALL be understood as silence rather than an error: a delivery with no service behind it discards the notification the way `desktop-notifications` describes, leaving the sending program's failure on a stream nobody reads and nothing at all on screen.

#### Scenario: A machine with a daemon needs nothing added

- **WHEN** the session runs a notification daemon that owns the bus name
- **THEN** herdr's notifications SHALL be displayed with no further installation

#### Scenario: A machine without a daemon supplies the command

- **WHEN** herdr runs on a machine whose system has no notification daemon of its own
- **THEN** that machine SHALL provide the notification command on `PATH`
- **AND** the command SHALL raise a notification through whatever that system does have
- **AND** the tracked configuration SHALL be unchanged by its presence or absence

### Requirement: The delivery setting survives a restore and a reload

The setting SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine delivers through the service

- **WHEN** this repository is checked out into a fresh home directory and herdr starts on a machine whose notification service is present
- **THEN** an agent notification SHALL be displayed by that service with no further setup

#### Scenario: The setting applies without restarting

- **WHEN** the setting is changed and herdr is asked to reload its configuration
- **THEN** the next notification in the running server SHALL be delivered the new way
- **AND** open sessions SHALL survive the reload

### Requirement: The notification sound is unaffected

Changing where a notification is drawn SHALL NOT change whether one is sounded, nor which events herdr considers worth a notification. The sound setting SHALL keep the value it has.

#### Scenario: The sound still plays

- **WHEN** herdr raises a notification with sound enabled
- **THEN** the sound SHALL play as it did before this change

#### Scenario: The same events notify

- **WHEN** the agent states that raised a notification before this change occur
- **THEN** a notification SHALL be raised for each of them
- **AND** no state that did not notify before SHALL begin to notify
