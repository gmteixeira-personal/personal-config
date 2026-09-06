## Purpose

Defines what the physical keys of this machine do before any application sees them: which key carries which modifier, where a displaced function goes when a key is taken from it, and how far down the stack the answer has to hold, so that the same keyboard behaves the same way in the graphical session and at a virtual console.

## ADDED Requirements

### Requirement: The Caps Lock key carries Control

The key in the Caps Lock position SHALL act as a Control modifier. It SHALL do so wherever a key is read on this machine, not only in the graphical session.

The key is on the home row under the left little finger and Control is pressed constantly — by the shell's key bindings, by the readline configuration, by the multiplexer's prefix, by every terminal program. Caps Lock toggles a mode that is wanted rarely. The exchange is between the best key on the board and one of the worst.

#### Scenario: Control in the graphical session

- **WHEN** the key in the Caps Lock position is held and another key is pressed, in a window of the graphical session
- **THEN** the application SHALL receive that key with a Control modifier

#### Scenario: Control at a virtual console

- **WHEN** the same is done at a virtual console
- **THEN** the console SHALL act as though Control were held

#### Scenario: Caps Lock is not toggled

- **WHEN** the key in the Caps Lock position is pressed and released alone
- **THEN** no lock SHALL be engaged and no indicator SHALL change

### Requirement: The displaced Caps Lock function stays reachable

Taking a key away SHALL NOT remove the function it carried. The Caps Lock function — locking the modifier that makes letters capital, and unlocking it again — SHALL remain available on `Shift+F12`.

The chord SHALL be one that nothing else in this configuration binds, so that the displaced function does not displace something in turn.

#### Scenario: The lock engages and releases

- **WHEN** `Shift+F12` is pressed once
- **THEN** letters typed afterwards SHALL be capital
- **AND** pressing it again SHALL return them to lower case

#### Scenario: Plain F12 is unchanged

- **WHEN** `F12` is pressed without Shift
- **THEN** the application SHALL receive `F12`

#### Scenario: The chord is not already taken

- **WHEN** the tracked configuration is searched for a binding on `Shift+F12`
- **THEN** no other binding SHALL claim it

### Requirement: The remap holds for every keyboard and every layout

The remap SHALL apply to every keyboard attached to the machine, and SHALL NOT depend on which keyboard layout is active.

Layout is a per-keyboard preference and the remap is not: a machine may carry one keyboard laid out for one language and another for a second, and both SHALL carry Control in the Caps Lock position. Where more than one layout is configured, the remap SHALL survive a switch between them.

#### Scenario: A second keyboard

- **WHEN** an additional keyboard is attached
- **THEN** its Caps Lock position SHALL carry Control, with no per-device configuration having been written for it

#### Scenario: A second layout

- **WHEN** more than one layout is configured and the active one is switched
- **THEN** the Caps Lock position SHALL still carry Control
- **AND** `Shift+F12` SHALL still lock and unlock

#### Scenario: The remap is not merely compiled but survives a live switch

- **WHEN** the layout is switched at runtime rather than only at the moment the keymap is built
- **THEN** the remap SHALL hold in the layout switched to, without the keymap being rebuilt

### Requirement: The remap reaches the virtual consoles

The remap SHALL apply at the virtual consoles as well as in the graphical session.

The console is where a broken graphical session is repaired, which is exactly the moment a keyboard that behaves differently costs the most. A remap that stops at the compositor is absent on the one occasion it is most needed.

The graphical session's X11 clients SHALL be covered by the graphical session's own configuration rather than by a second one, since they take their keymap from the compositor.

#### Scenario: A console outside the graphical session

- **WHEN** a virtual console other than the one running the graphical session is entered
- **THEN** the Caps Lock position SHALL carry Control
- **AND** `Shift+F12` SHALL lock and unlock

#### Scenario: X11 clients need no separate configuration

- **WHEN** an X11 client runs under the graphical session's X server
- **THEN** it SHALL see the same remap
- **AND** no X11-specific keyboard configuration SHALL exist in this repository

### Requirement: The remap adds no software to the machine

The remap SHALL be built from what the machine already carries — the compositor's own keyboard configuration and the console keymap tooling — and SHALL NOT introduce a package, a daemon, or a privileged process that reads input devices.

#### Scenario: No new dependency is required

- **WHEN** the tracked documentation's list of software the configuration expects is compared before and after
- **THEN** no entry SHALL have been added for the remap

#### Scenario: Nothing privileged runs continuously

- **WHEN** the running processes are inspected
- **THEN** no process introduced by this remap SHALL be running

### Requirement: Configuration outside the home directory is tracked as a copy

Where a part of the remap must live outside `$HOME` and therefore cannot be tracked in place, this repository SHALL carry a copy of that file and SHALL document the single step that installs it. The documentation SHALL say what is lost until that step is run, since a partially installed remap is worse than an absent one: the keyboard then behaves differently in two places.

#### Scenario: The copy is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** the file installed outside `$HOME` SHALL appear as a tracked copy

#### Scenario: The step is documented with its consequence

- **WHEN** the tracked bootstrap documentation is read
- **THEN** it SHALL name the command that installs that copy
- **AND** it SHALL say that until it is run the remap applies in the graphical session and not at the consoles

### Requirement: The configured layouts are switchable from the keyboard

Where more than one layout is configured, a key SHALL switch between them, and the active one SHALL be reportable so that something other than typing a character can tell which is live.

Exactly one mechanism SHALL do the switching. Both the compositor and the keymap can bind a layout-switch key, and a chord bound in both switches twice and lands back where it started — so where the compositor binds it, the keymap SHALL NOT.

The key SHALL be one that nothing else in this configuration binds.

#### Scenario: A key switches layout

- **WHEN** the switch key is pressed with two layouts configured
- **THEN** the other layout SHALL become active
- **AND** pressing it again SHALL return to the first

#### Scenario: The active layout can be read back

- **WHEN** the compositor is asked which layouts are configured
- **THEN** it SHALL list them
- **AND** it SHALL indicate which is active

#### Scenario: Switching is not doubled

- **WHEN** the keyboard options are inspected
- **THEN** no layout-switching option SHALL be among them, the compositor's own binding being the one mechanism

#### Scenario: The key is free

- **WHEN** the compositor configuration is searched for the switch key
- **THEN** no other binding SHALL claim it
