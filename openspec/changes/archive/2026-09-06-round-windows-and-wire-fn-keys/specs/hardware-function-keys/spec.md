## Purpose

Defines what the laptop's function row does to the session — which key acts on the backlight and which on the microphone — and how a binding for a key printed on the hardware is written so that it matches what the keyboard actually sends rather than what the legend implies.

## ADDED Requirements

### Requirement: The brightness keys change the backlight

The keys carrying brightness legends SHALL raise and lower the internal panel's backlight, in steps small enough that the range is reachable by repeated presses and large enough that one press is visible.

A step SHALL be expressed as a proportion of the panel's maximum rather than as a raw value. The maximum is a property of the panel and differs between machines by orders of magnitude; a raw step that is one notch on one panel is the entire range on another.

The keys SHALL work while the session is locked. Brightness is the one control a user needs before authenticating — a screen too dark or too bright to read is a screen the password cannot be typed into.

#### Scenario: Raising and lowering

- **WHEN** the key carrying the brightness-up legend is pressed
- **THEN** the internal panel SHALL become brighter
- **AND** the key carrying the brightness-down legend SHALL make it darker

#### Scenario: The step is proportional

- **WHEN** the configuration for the brightness keys is inspected
- **THEN** the step SHALL be a proportion of the panel's maximum brightness
- **AND** it SHALL NOT be a raw value read off this machine's panel

#### Scenario: The lock screen

- **WHEN** the session is locked and a brightness key is pressed
- **THEN** the backlight SHALL change

### Requirement: The backlight never reaches full darkness by key repeat

Lowering the brightness by repeated key presses SHALL stop above zero.

Zero is a black screen, and the key that undoes it is on a keyboard that is now unlit and unreadable. The floor is not a safety margin for the hardware; it is the difference between a dim screen and a machine that appears to have crashed.

#### Scenario: Holding the key down

- **WHEN** the brightness-down key is pressed enough times to pass the bottom of the range
- **THEN** the panel SHALL remain lit
- **AND** the brightness-up key SHALL still be able to raise it

### Requirement: A binding names the keysym the keyboard sends

A binding for a key printed on this laptop SHALL name the keysym that key actually produces on this machine's compiled keymap, and the configuration SHALL record what the key sends where that differs from what its legend suggests.

A legend is not a keysym. A key stamped with a microphone may send `KEY_F15`, whose keycode is claimed by the model's symbol set and named for something unrelated to audio; a binding written from the legend then matches nothing. The failure is silent in both directions — the compositor reports no unmatched key, and the binding that was supposed to catch it is present, plausible and inert.

Where a keysym's name bears no relation to the key's function, the configuration SHALL state the chain from key to keysym, so that a reader does not delete the binding as a mistake or a later edit does not "correct" it back to the name the legend implies.

#### Scenario: The binding matches the key

- **WHEN** a key printed with a function this session provides is pressed
- **THEN** the action SHALL run

#### Scenario: A surprising name is explained

- **WHEN** a binding names a keysym unrelated to the function of the key it serves
- **THEN** the configuration SHALL record which key sends it and why that name is the correct one

#### Scenario: Bindings for the conventional names are kept

- **WHEN** a key is bound by the unconventional keysym it really sends
- **THEN** any existing binding for the conventional keysym for that function SHALL remain
- **AND** it SHALL keep serving whichever key does send it

### Requirement: The mute keys act on the stream their legend names

A key legended for the microphone SHALL mute and unmute the capture stream, and a key legended for the speakers SHALL mute and unmute the playback stream. Neither SHALL act on the other.

The two are separate states, drawn separately in the bar and wanted at different moments — a muted microphone during a call is not a muted speaker, and a key that conflated them would silence the one the user could still hear was working.

#### Scenario: The microphone key

- **WHEN** the key legended for the microphone is pressed
- **THEN** the capture stream SHALL toggle between muted and unmuted
- **AND** the playback stream SHALL be unaffected

#### Scenario: The speaker key

- **WHEN** the key legended for the speakers is pressed
- **THEN** the playback stream SHALL toggle between muted and unmuted
- **AND** the capture stream SHALL be unaffected

#### Scenario: The bar shows which is muted

- **WHEN** either stream is muted from its key
- **THEN** the bar SHALL indicate that stream as muted
- **AND** the other stream's indicator SHALL be unchanged

### Requirement: A function key's action adds no package and no privilege

The action bound to a function key SHALL be reachable with what a systemd graphical session already provides. It SHALL NOT require a package installed outside this repository, and SHALL NOT require the user to join a group or a udev rule to be installed in order to work.

A binding that spawns a program the machine does not carry fails exactly as a wrong keysym does: nothing happens and nothing is reported. Depending on a package also moves part of the configuration outside the repository, where a fresh machine reproduces the file but not the behaviour.

Privileged access is the same argument one level down. Where an interface exists that grants the seat's own session what it needs, that interface SHALL be preferred over widening the user's group membership, which grants every process the user runs the same access permanently and for every device of that class.

#### Scenario: A fresh machine

- **WHEN** this repository is checked out onto a machine with no packages installed beyond the session itself
- **THEN** the function keys SHALL work

#### Scenario: No group membership

- **WHEN** the user's group membership is inspected
- **THEN** no group SHALL have been added for the sake of a function key

#### Scenario: A missing program is not the mechanism

- **WHEN** the configuration for a function key is inspected
- **THEN** it SHALL NOT depend on a program that this repository neither ships nor installs
