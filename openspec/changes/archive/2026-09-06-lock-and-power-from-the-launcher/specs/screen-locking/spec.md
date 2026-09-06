## MODIFIED Requirements

### Requirement: The session locks on demand

The session SHALL offer at least two routes that lock the screen immediately: a compositor binding, and an entry in the session's own launcher. The label the compositor shows for its binding SHALL name the program that locks it.

Neither route SHALL ask for confirmation. A lock screen is dismissed by the password the user was about to type anyway, so an accidental lock costs one password and nothing else — while a confirmation in front of it slows down the action whose whole value is being instant, and the two power entries beside it in the launcher are confirmed precisely because they are not like this one.

A chord is the faster route and the launcher entry is the discoverable one. `Super+Alt+L` cannot be used before it is known, and the overlay that lists it is itself behind a chord; a launcher entry is found by typing a prefix of the word "lock", which needs nothing to be known in advance.

#### Scenario: The binding locks the session

- **WHEN** the on-demand lock binding is pressed
- **THEN** the lock screen SHALL appear
- **AND** the session SHALL remain locked until a correct password is accepted

#### Scenario: The binding names what it runs

- **WHEN** the compositor configuration is inspected for the lock binding
- **THEN** its hotkey-overlay title SHALL name swaylock

#### Scenario: The launcher locks the session

- **WHEN** the launcher is opened, a prefix of "lock" is typed, and the lock entry is chosen
- **THEN** the lock screen SHALL appear
- **AND** it SHALL appear without a confirmation having been presented first

#### Scenario: Both routes present the same screen

- **WHEN** the session is locked from the compositor binding and then, on another occasion, from the launcher entry
- **THEN** the screen presented SHALL be the same in both cases
- **AND** its appearance SHALL come from the tracked swaylock configuration rather than from arguments given at either call site
