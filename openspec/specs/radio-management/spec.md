# radio-management Specification

## Purpose

Defines what the session can do with its two radios and how — that the Bluetooth adapter and the wireless network are both managed from the session's own launcher rather than from a terminal or a settings panel nobody installed, that a menu never offers an action the current state would reject, that a network passphrase never becomes a process argument, and that a failure is always reported even when the thing that normally reports it is absent.

## Requirements

### Requirement: Both radios are managed from the session's launcher

The session SHALL provide, for the Bluetooth adapter and for wireless networking, an interface reached from the session's own launcher that covers the ordinary operations on that radio without a terminal.

For Bluetooth those operations are: listing known and discovered devices with their current state, scanning, pairing, trusting, connecting, disconnecting, removing a device, and turning the adapter on and off. For wireless they are: listing access points in range with their signal and security, joining a network the session has not seen before, reconnecting to a saved one, disconnecting, forgetting a saved profile, joining a network that does not broadcast its name, and turning the radio on and off.

Neither radio had such an interface. The session installs no Bluetooth manager and no settings panel, so pairing meant driving a REPL in a terminal window. Wireless was worse than awkward: NetworkManager obtains a passphrase by calling a secret agent on the session bus, no agent runs here, and so joining an unknown network could not be done from the session at all.

#### Scenario: Bluetooth devices are managed without a terminal

- **WHEN** the Bluetooth interface is opened from the launcher
- **THEN** it SHALL list the adapter's known and discovered devices
- **AND** it SHALL offer connecting, disconnecting, pairing, trusting and removing a device
- **AND** no terminal window SHALL be required

#### Scenario: A new wireless network is joined without a terminal

- **WHEN** the wireless interface is opened from the launcher and an access point with no saved profile is chosen
- **THEN** the session SHALL prompt for the passphrase itself
- **AND** the network SHALL be joined without a terminal window

#### Scenario: A saved network reconnects without a prompt

- **WHEN** an access point whose profile the session has already saved is chosen
- **THEN** it SHALL be connected without prompting for the passphrase again

### Requirement: A network passphrase never becomes a process argument

The session SHALL NOT pass a wireless passphrase as an argument to any command. A passphrase collected from the user SHALL reach the network configuration by a means that does not place it on a command line.

A process's arguments are readable by every other process of the same user through `/proc`, for as long as the process runs — and a connect runs for several seconds. That is a wider audience than the passphrase's resting place, which is a root-owned file readable by nobody else. Handing it over as an argument would widen the exposure for the convenience of one shorter command.

Masking the input as it is typed is not this requirement and does not satisfy it. Masking addresses somebody reading the screen; this addresses somebody reading the process table.

#### Scenario: The passphrase is absent from the process table

- **WHEN** a wireless network is joined through the session's interface
- **THEN** no process started to perform the join SHALL carry the passphrase in its arguments

#### Scenario: The passphrase is not shown as it is typed

- **WHEN** the session prompts for a passphrase
- **THEN** the characters typed SHALL NOT be rendered legibly on screen

### Requirement: A menu offers only the actions the current state allows

Each interface SHALL derive the actions it offers from the present state of the device or network concerned, and SHALL NOT offer an action that the state would cause to fail.

A fixed list of verbs where some are rejected on selection teaches the reader that what is on screen is not to be relied on. The reader then has to know the underlying tool's rules to use a menu whose purpose was to spare them exactly that.

#### Scenario: A connected device is not offered connection

- **WHEN** a device that is currently connected is chosen
- **THEN** the actions offered SHALL include disconnecting
- **AND** they SHALL NOT include connecting

#### Scenario: An unpaired device is not offered trust

- **WHEN** a device that has not been paired is chosen
- **THEN** the actions offered SHALL include pairing
- **AND** they SHALL NOT include trusting or untrusting

#### Scenario: A network with no saved profile is not offered forgetting

- **WHEN** an access point for which no profile is saved is chosen
- **THEN** the actions offered SHALL NOT include forgetting it

### Requirement: A selection is not recovered by parsing its label

Where an interface presents a list and acts on the chosen entry, it SHALL identify that entry by its position in the list rather than by parsing the text displayed for it.

Device names and network names are attacker-free but not format-free: they contain spaces, dashes, slashes, brackets and colons, and the tools that report them escape a colon inside a value rather than omitting it. Any scheme that renders an identifier into the label and parses it back is a quoting problem waiting for the first device whose name contains the separator — and the failure is a wrong device acted on, not an error.

#### Scenario: A name containing separators still resolves

- **WHEN** a device or network whose name contains a colon, a dash, a slash or a bracket is chosen from a list
- **THEN** the action SHALL be applied to that device or network and no other

#### Scenario: Typing something that matches nothing is not a selection

- **WHEN** text matching no entry is typed into a list and accepted
- **THEN** no action SHALL be taken

### Requirement: A failed join leaves nothing saved

Where joining a network requires creating a saved profile, a join that fails SHALL leave no profile behind.

A profile carrying a wrong passphrase does not fail once. It fails on every later autoconnect, silently, and its presence is what stops the interface offering to ask for the passphrase again — so the one visible route to correcting the mistake is closed by the mistake.

#### Scenario: A wrong passphrase saves nothing

- **WHEN** a network is joined with an incorrect passphrase and the connection fails
- **THEN** no saved profile for that network SHALL remain
- **AND** choosing that network again SHALL prompt for the passphrase

### Requirement: A failure is reported whether or not a notification daemon is running

Every action offered SHALL report its failure to the user. Where the report is delivered by a notification daemon, the interface SHALL detect the absence of one and report through its own interface instead.

Success needs no message of its own: the list is redrawn immediately afterwards and carries the new state. Failure is the opposite case, because the redrawn list looks the same whether the action failed or was never attempted — an unchanged screen is not a report. An interface whose only channel is a daemon that may not exist has no way to distinguish those, and this session ran for its whole life without such a daemon.

#### Scenario: A failure with no daemon running is still reported

- **WHEN** an action fails and no notification daemon owns the session bus name
- **THEN** the failure SHALL be reported through the interface the user is already looking at

#### Scenario: A long-running operation shows that it is running

- **WHEN** an operation that blocks for several seconds is started, such as scanning for devices
- **THEN** the session SHALL show that it is in progress
- **AND** the user SHALL be able to end the wait before it completes
