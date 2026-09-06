# desktop-notifications Specification

## Purpose

Defines that the session has a notification daemon at all — that something owns the bus name programs send notifications to, that it starts with the session rather than on demand, that it is drawn in the session's palette like every other surface, and that a message reporting a failure is not taken off the screen on a timer.

## Requirements

### Requirement: The session owns the notification bus name

The session SHALL run a notification daemon, so that `org.freedesktop.Notifications` has an owner whenever the session is running.

Without one, every notification sent by anything in the session is discarded. The discard is silent in the way that matters: the sending program's error goes to a standard error stream nobody is reading, the exit status is the only trace, and to the user the notification simply never appears — indistinguishable from a program that decided not to send one. This session ran without a daemon for its whole existence, and the absence was found only by testing a script that depended on it.

#### Scenario: The bus name has an owner

- **WHEN** the session is running and the bus is queried for the owner of the notification name
- **THEN** the name SHALL be owned

#### Scenario: A sent notification is displayed

- **WHEN** a program in the session sends a notification
- **THEN** it SHALL be displayed

### Requirement: The daemon starts with the session

The notification daemon SHALL be started by the session's own startup configuration, and that configuration SHALL record what fails in its absence.

A daemon started by hand is a daemon that is running until the next login. The failure it leaves behind announces itself nowhere, so nothing in the session would report that notifications had stopped working — which is the same condition this requirement exists to end.

#### Scenario: A fresh session has notifications

- **WHEN** the session is started
- **THEN** the notification daemon SHALL be running without any manual step

#### Scenario: The startup configuration explains the entry

- **WHEN** the session's tracked startup configuration is read
- **THEN** it SHALL state what fails when the daemon is not started

### Requirement: Notifications are drawn in the session's palette

The notification daemon's tracked configuration SHALL draw notifications in the palette the rest of the session uses, and SHALL record which palette that is and where this repository's other statements of it live.

A notification is a panel that appears over the session and leaves again, which is what the launcher is; it is matched to the launcher rather than to the bar, which is a fixed edge. The palette is held in several files in several formats with no shared definition any of them can read, so each file naming its source is the only thing that keeps the set checkable.

Sizes stated in different units do not match by looking alike. Where one surface states a size in pixels and another in points, the tracked configuration SHALL record the conversion rather than repeat the number.

#### Scenario: A notification matches the session

- **WHEN** a notification is displayed
- **THEN** its background, text and border SHALL be values from the session's palette

#### Scenario: A reader can trace the colours

- **WHEN** the daemon's tracked configuration is read
- **THEN** it SHALL name the palette
- **AND** it SHALL name other tracked files in this repository holding the same palette

### Requirement: A notification reporting a failure is not expired on a timer

The daemon SHALL be configured so that a notification sent at critical urgency remains on screen until it is dismissed, and SHALL make it visually distinct from an ordinary one.

An ordinary notification reports something that is also visible elsewhere a moment later, and expiring it costs nothing. A failure is the case where nothing else says so — the screen behind it looks exactly as it did before the attempt. A failure the user happened to look away from is a failure they never saw, and the state it describes is one they will act on wrongly.

#### Scenario: A critical notification waits

- **WHEN** a notification is sent at critical urgency
- **THEN** it SHALL remain displayed until dismissed

#### Scenario: A critical notification is distinguishable

- **WHEN** a critical notification is displayed beside an ordinary one
- **THEN** it SHALL differ visibly from it

#### Scenario: An ordinary notification does not accumulate

- **WHEN** a notification is sent at ordinary urgency and not dismissed
- **THEN** it SHALL be removed after a short interval
