## MODIFIED Requirements

### Requirement: The session's terminal is foot in client/server form

Every compositor binding that opens a terminal SHALL spawn a foot *client*, not a standalone foot. The label the compositor shows for each such binding SHALL name the terminal it actually opens, so the hotkey overlay cannot advertise a terminal that was replaced.

A standalone terminal pays process and font-loading startup per window; a client attaches to an already-running server and pays it once per session.

More than one binding may open a terminal, and the obligation attaches to each of them rather than to whichever was written first. A second binding added later is the likely place for a bare `foot` or a label naming a terminal this session no longer runs — it is written by hand, next to a line that already looks correct, and a standalone foot works well enough that nothing about the window says which of the two opened it.

#### Scenario: The terminal binding opens a client

- **WHEN** the compositor configuration is inspected for the binding that opens a terminal
- **THEN** it SHALL spawn `footclient`
- **AND** its hotkey-overlay title SHALL name foot

#### Scenario: Every terminal binding opens a client

- **WHEN** the configuration holds more than one binding that opens a terminal
- **THEN** each SHALL spawn `footclient`
- **AND** each SHALL carry a hotkey-overlay title naming foot

#### Scenario: No stale terminal is named

- **WHEN** the compositor configuration is searched for the terminal it previously opened
- **THEN** no binding SHALL name it

## ADDED Requirements

### Requirement: The terminal opens on the convention chord

The compositor SHALL open a terminal on `Mod+Return`. It SHALL also keep the letter chord that opened one before, so that both reach the same terminal.

`Mod+Return` is what i3 and sway ship as their default and what a user arriving from either types without thinking. This session's `Mod+T` came from the example configuration niri ships rather than from a decision, and an unbound chord in a compositor fails silently: no window opens, nothing is logged, and nothing indicates that the key was the problem rather than the terminal.

Keeping both chords costs one line. Replacing rather than adding would break the chord that works today in order to fix one that does not, and the session already answers to two chords for its launcher, so a program reachable by two keys is this configuration's existing habit rather than a new one.

#### Scenario: The convention chord opens a terminal

- **WHEN** `Mod+Return` is pressed in the graphical session
- **THEN** a terminal window SHALL open

#### Scenario: The previous chord still opens a terminal

- **WHEN** the letter chord that opened a terminal before this change is pressed
- **THEN** a terminal window SHALL open
- **AND** it SHALL be the same terminal the convention chord opens

#### Scenario: The overlay lists both

- **WHEN** the compositor's hotkey overlay is shown
- **THEN** both chords SHALL appear
- **AND** both SHALL be labelled with the terminal they open
