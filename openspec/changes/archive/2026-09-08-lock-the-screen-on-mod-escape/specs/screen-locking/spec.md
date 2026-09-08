## MODIFIED Requirements

### Requirement: The session locks on demand

The session SHALL offer at least two routes that lock the screen immediately: a compositor binding, and an entry in the session's own launcher. The label the compositor shows for its binding SHALL name the program that locks it.

Where the compositor offers more than one chord for the lock, every one of them SHALL reach the same lock through the same tracked configuration, and each SHALL carry the same label naming the program that locks it. A second chord that presents a different screen, or that the overlay describes differently, is a second action wearing the first one's name.

A chord SHALL count as a lock route only once it has been confirmed to lock the machine it is configured on. A chord something takes before the compositor receives it is not a route, and nothing in the configuration says which chords those are: the file parses, the compositor validates it and reloads it, and the chord then does nothing at all — no spawn, no lock, and no line in the journal to read afterwards. Pressing it is the only test there is.

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

#### Scenario: A chord is confirmed by pressing it

- **WHEN** a chord is bound to locking the session
- **THEN** it SHALL be pressed on the machine and observed to lock before it is counted as one of the on-demand routes
- **AND** a validating configuration and a reloaded compositor SHALL NOT be taken as that confirmation

#### Scenario: An unreachable chord is replaced rather than kept

- **WHEN** a bound lock chord is pressed and the session does not lock
- **THEN** the binding SHALL be replaced by a chord that does lock
- **AND** the session SHALL keep at least two working on-demand routes throughout

#### Scenario: The launcher locks the session

- **WHEN** the launcher is opened, a prefix of "lock" is typed, and the lock entry is chosen
- **THEN** the lock screen SHALL appear
- **AND** it SHALL appear without a confirmation having been presented first

#### Scenario: Both routes present the same screen

- **WHEN** the session is locked from the compositor binding and then, on another occasion, from the launcher entry
- **THEN** the screen presented SHALL be the same in both cases
- **AND** its appearance SHALL come from the tracked swaylock configuration rather than from arguments given at either call site
