# terminal-emulator Specification

## Purpose

Defines which terminal the graphical session opens, the server/client model it runs under and what that model implies for when its configuration is read, and the shell it starts, so that a terminal window is cheap to open and starts the shell actually in use rather than the one the password database happens to name.

## Requirements

### Requirement: The session's terminal is foot in client/server form

The compositor binding that opens a terminal SHALL spawn a foot *client*, not a standalone foot. The label the compositor shows for that binding SHALL name the terminal it actually opens, so the hotkey overlay cannot advertise a terminal that was replaced.

A standalone terminal pays process and font-loading startup per window; a client attaches to an already-running server and pays it once per session.

#### Scenario: The terminal binding opens a client

- **WHEN** the compositor configuration is inspected for the binding that opens a terminal
- **THEN** it SHALL spawn `footclient`
- **AND** its hotkey-overlay title SHALL name foot

#### Scenario: No stale terminal is named

- **WHEN** the compositor configuration is searched for the terminal it previously opened
- **THEN** no binding SHALL name it

### Requirement: A terminal server runs for the graphical session

A foot server SHALL be available for the whole graphical session, started through the packaged systemd user units rather than by the compositor, and SHALL listen on a socket under the runtime directory.

Both the socket unit and the service unit SHALL be enabled. The socket alone would start the server lazily; the service alone would leave a client that runs before the server is ready with nothing to connect to. Enabling both means a client is served whether it arrives before or after the server.

#### Scenario: The units are enabled

- **WHEN** the enabled state of the foot server socket and service units is queried
- **THEN** both SHALL report enabled

#### Scenario: The server is reachable

- **WHEN** the graphical session is running
- **THEN** the foot socket SHALL exist in the runtime directory
- **AND** a foot client SHALL open a window without the server having been started by hand

### Requirement: New terminal windows start fish

The shell that foot starts in a new window SHALL be fish, and SHALL be named explicitly in foot's configuration rather than inherited from the environment.

The server is started by systemd, so it inherits the shell recorded in the password database — bash — and not the shell running interactively. Leaving this implicit gives every window the wrong shell while the interactive session looks correct.

#### Scenario: A window starts fish

- **WHEN** a new terminal window is opened
- **THEN** the shell running in it SHALL be fish

#### Scenario: The shell does not depend on the login shell

- **WHEN** foot's configuration is inspected
- **THEN** it SHALL name the fish binary explicitly
- **AND** that SHALL hold whether or not the password database names fish

### Requirement: The configuration is tracked and records its own reload rule

foot's configuration file SHALL be tracked by this repository.

In server mode the file is read once, when the server starts; new windows inherit that reading and do not re-read it. The file SHALL state this and name the command that applies an edit, because the failure it causes otherwise is silent — an edit appears to do nothing, and opening another window does not help.

#### Scenario: The configuration is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** foot's configuration file SHALL appear

#### Scenario: The reload rule is discoverable from the file

- **WHEN** foot's configuration file is read
- **THEN** it SHALL state that the server reads it only at startup
- **AND** it SHALL name the command that restarts the server
