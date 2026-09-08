## MODIFIED Requirements

### Requirement: The session locks on demand

The session SHALL offer at least two routes that lock the screen immediately: a compositor binding, and an entry in the session's own launcher. The label the compositor shows for its binding SHALL name the program that locks it.

Where the compositor offers more than one chord for the lock, every one of them SHALL reach the same lock through the same tracked configuration, and each SHALL carry the same label naming the program that locks it. A second chord that presents a different screen, or that the overlay describes differently, is a second action wearing the first one's name.

Neither route SHALL ask for confirmation. A lock screen is dismissed by the password the user was about to type anyway, so an accidental lock costs one password and nothing else — while a confirmation in front of it slows down the action whose whole value is being instant, and the two power entries beside it in the launcher are confirmed precisely because they are not like this one.

A chord is the faster route and the launcher entry is the discoverable one. `Super+Alt+L` cannot be used before it is known, and the overlay that lists it is itself behind a chord; a launcher entry is found by typing a prefix of the word "lock", which needs nothing to be known in advance.

#### Scenario: The binding locks the session

- **WHEN** the on-demand lock binding is pressed
- **THEN** the lock screen SHALL appear
- **AND** the session SHALL remain locked until a correct password is accepted

#### Scenario: The binding names what it runs

- **WHEN** the compositor configuration is inspected for the lock binding
- **THEN** its hotkey-overlay title SHALL name swaylock

#### Scenario: Every lock chord reaches the same lock

- **WHEN** the compositor binds more than one chord to locking the session
- **THEN** each of them SHALL present the same lock screen from the same tracked configuration
- **AND** each SHALL carry the same hotkey-overlay title

#### Scenario: The launcher locks the session

- **WHEN** the launcher is opened, a prefix of "lock" is typed, and the lock entry is chosen
- **THEN** the lock screen SHALL appear
- **AND** it SHALL appear without a confirmation having been presented first

#### Scenario: Both routes present the same screen

- **WHEN** the session is locked from the compositor binding and then, on another occasion, from the launcher entry
- **THEN** the screen presented SHALL be the same in both cases
- **AND** its appearance SHALL come from the tracked swaylock configuration rather than from arguments given at either call site

## ADDED Requirements

### Requirement: An application cannot suppress the lock chord

Every compositor chord that locks the session SHALL be processed by the compositor even while an application holds the keyboard-shortcuts inhibitor, so that no running program can take away the session's ability to lock itself.

The inhibitor exists for remote-desktop clients and software KVMs, which ask the compositor to stop handling its own bindings so the keys reach the far machine instead. That request is reasonable for the bindings that move windows around, and it is not reasonable for the lock: while such a client holds the keyboard, the compositor's lock chord does nothing, and the launcher — the documented second route — is itself opened by a suppressible chord, so the session cannot be locked at all until the inhibitor is released first. The moment this matters is exactly the moment the machine is showing someone else's session and is about to be left unattended.

The general escape hatch that releases the inhibitor SHALL remain, but locking SHALL NOT depend on finding it first.

#### Scenario: Locking works while an inhibitor is active

- **WHEN** an application holds the keyboard-shortcuts inhibitor and a lock chord is pressed
- **THEN** the compositor SHALL process the chord rather than forward it to the application
- **AND** the lock screen SHALL appear

#### Scenario: Locking needs no release of the inhibitor first

- **WHEN** the session is locked while an inhibitor is active
- **THEN** no other chord SHALL have had to be pressed beforehand to make the lock chord work

#### Scenario: The escape hatch is unaffected

- **WHEN** the compositor's bindings are inspected
- **THEN** a binding that toggles the keyboard-shortcuts inhibitor SHALL still be present
- **AND** it SHALL itself be exempt from inhibiting
