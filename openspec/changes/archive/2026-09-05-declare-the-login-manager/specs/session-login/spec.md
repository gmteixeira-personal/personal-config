## Purpose

Defines how a booted machine reaches a running graphical session — what presents the login, what that login launches, and why every route in has to go through the compositor's session launcher — and what the documentation must carry given that the file deciding all of it sits outside the repository root and can never be tracked.

## ADDED Requirements

### Requirement: A greeter starts the session at boot

The machine SHALL reach its graphical session without anyone typing a command: a login manager SHALL run at boot, and the system's default target SHALL be the one that starts it.

Typing the compositor's name into a TTY is a working route and a poor contract. It is available only to someone who already knows the name, it leaves the machine sitting at a text console until they do, and it means the documented rebuild produces a different machine from the one being documented.

#### Scenario: The greeter runs without intervention

- **WHEN** the machine is booted
- **THEN** the login manager SHALL be running
- **AND** reaching the session SHALL NOT require a command typed at a console

#### Scenario: The greeter is enabled, not merely installed

- **WHEN** the login manager's unit is queried
- **THEN** it SHALL report enabled
- **AND** the system default target SHALL be the one that pulls it in

### Requirement: Every route into the session starts it as a session

Each route from the login to a running compositor SHALL invoke the compositor's session launcher rather than its bare binary — the greeter's default command, the session entry its picker offers, and the compositor's name typed at a shell prompt alike.

A bare compositor imports nothing into the systemd user manager, so `graphical-session.target` never activates and every unit wanting it stays inactive with no error reported anywhere. One route getting this wrong produces a session that is subtly broken in a way that depends on how the user happened to log in, which is worse than one that is broken every time.

#### Scenario: The greeter's default command

- **WHEN** the greeter configuration's default session command is inspected
- **THEN** it SHALL invoke the compositor's session launcher

#### Scenario: The session entry the picker lists

- **WHEN** the session entry the greeter offers is inspected
- **THEN** its exec line SHALL invoke the compositor's session launcher

#### Scenario: A session entered by any route activates the target

- **WHEN** the session has been entered by any of the available routes
- **THEN** `graphical-session.target` SHALL be active
- **AND** the user units wanting it SHALL be running

### Requirement: The greeter's configuration is documented because it cannot be tracked

The greeter's configuration file lies outside the repository root, so the repository SHALL NOT be expected to carry it, and the tracked documentation SHALL instead reproduce what that file must contain, name the unit to enable, and name the default target to set.

This is the one part of the session that no allowlist entry could ever reach: the repository root is `$HOME`, and the file is root-owned under `/etc`. Documentation is not a lesser substitute here, it is the only available mechanism — which makes its absence, rather than the file's absence, the actual defect.

#### Scenario: A fresh machine can be brought to the same state

- **WHEN** the rebuild procedure is followed on a machine with only the checkout
- **THEN** it SHALL give the content the greeter configuration must have
- **AND** it SHALL name the unit to enable and the default target to set

#### Scenario: The untracked path is declared as untracked

- **WHEN** the documentation of what the repository does not carry is read
- **THEN** the greeter's configuration path SHALL appear in it
- **AND** the reason SHALL be that it lies outside the repository root rather than that it was chosen against

### Requirement: The greeter and its greeter program are named as required software

The login manager and the greeter program it runs SHALL both appear in the required-software documentation, each stating what is lost in its absence.

The two fail differently and the difference matters to whoever is debugging: without the login manager the machine boots to a text console and the session must be started by hand, while without the greeter program the login manager runs and has nothing to present, which looks like a broken boot rather than a missing package.

#### Scenario: Both are named with their consequences

- **WHEN** the required-software documentation is read
- **THEN** both the login manager and the greeter program SHALL be named
- **AND** each SHALL state what is lost without it
