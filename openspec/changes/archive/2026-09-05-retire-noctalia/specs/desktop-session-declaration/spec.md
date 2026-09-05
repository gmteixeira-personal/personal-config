## MODIFIED Requirements

### Requirement: The session's software is named in tracked documentation

Every program the graphical session depends on SHALL appear in the repository's tracked required-software documentation, including the compositor, the terminal, the bar, the launcher, the lock screen, and any helper the compositor needs for compatibility with other window systems.

Configuration for a program is not a substitute for naming it. A tracked configuration file for an absent program produces a session that starts and is missing a piece, which is the failure mode this documentation exists to prevent. The reverse matters just as much here: the bar, the launcher and the lock screen have no tracked configuration at all, because each runs on its built-in defaults, so the documentation is the only place their absence is ever announced.

#### Scenario: A reader can tell what the session needs

- **WHEN** the tracked documentation is read on a machine with none of the session installed
- **THEN** every program the session depends on SHALL be named
- **AND** each SHALL state what breaks or is lost in its absence

#### Scenario: A tracked configuration implies a named program

- **WHEN** the repository tracks a configuration file for a program
- **THEN** that program SHALL appear in the required-software documentation

#### Scenario: A named program without tracked configuration

- **WHEN** the session depends on a program that has no tracked configuration file
- **THEN** it SHALL still be named in the required-software documentation
- **AND** the documentation SHALL state that it runs on its own defaults

## REMOVED Requirements

### Requirement: The rebuild procedure is written down and ordered

**Reason**: One of its scenarios required the rebuild procedure to account for the desktop shell's declared settings. There is no desktop shell and there are no declared settings, so the scenario cannot be satisfied by any procedure. The requirement is removed and re-added below rather than edited, because a MODIFIED delta replaces the whole block and would silently drop the scenario instead of recording why it went.

**Migration**: Replaced immediately below by "The rebuild procedure states what the checkout carries", which keeps the ordering obligation word for word and puts a different question in the shell scenario's place: which of the session's programs the checkout configures, and which run on their own defaults.

## ADDED Requirements

### Requirement: The rebuild procedure states what the checkout carries

The tracked documentation SHALL describe how to rebuild the session from a checkout, in an order that works, naming what must be installed before the configuration means anything and how the session is started. It SHALL also state which of the session's programs the checkout configures and which run on their own defaults.

Ordering is the substance of the procedure rather than a presentational detail: the compositor's configuration names programs that must exist before it is loaded, and the session's user units require the compositor to have been started in the way that activates them.

Saying what the checkout does not carry matters for the same reason as the order. Most of this session's programs have no tracked configuration at all, so a reader who assumes a checkout configures everything it names will go looking for files that were never written, and will read their absence as a broken clone rather than as the intended state.

#### Scenario: The procedure is followable on a fresh machine

- **WHEN** the rebuild procedure is followed on a machine with only the checkout
- **THEN** it SHALL name the software to install before the tracked configuration is used
- **AND** it SHALL name how the session is started

#### Scenario: The procedure states what the checkout does not carry

- **WHEN** the rebuild procedure is read
- **THEN** it SHALL say which of the session's programs the checkout configures
- **AND** it SHALL say which of them run on their own defaults, so nothing is looked for that does not exist
