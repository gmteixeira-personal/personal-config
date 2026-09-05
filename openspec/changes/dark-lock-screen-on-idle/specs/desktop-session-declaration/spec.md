## MODIFIED Requirements

### Requirement: The session's software is named in tracked documentation

Every program the graphical session depends on SHALL appear in the repository's tracked required-software documentation, including the compositor, the terminal, the bar, the launcher, the lock screen, the idle daemon that drives it, and any helper the compositor needs for compatibility with other window systems.

Configuration for a program is not a substitute for naming it. A tracked configuration file for an absent program produces a session that starts and is missing a piece, which is the failure mode this documentation exists to prevent. The reverse matters just as much here: the bar, the launcher and the idle daemon have no tracked configuration at all, because each runs on its built-in defaults or on arguments the compositor gives it, so the documentation is the only place their absence is ever announced.

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
