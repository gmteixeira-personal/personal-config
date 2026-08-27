## ADDED Requirements

### Requirement: 24-bit color is advertised only where the terminal supports it

An interactive shell SHALL declare 24-bit color support to the programs it runs, by exporting `COLORTERM`, when and only when it is running under a terminal known to render it. Where the terminal is unknown or known not to, the variable SHALL be left unset rather than given a value, because a program that believes a false claim emits escape sequences the terminal then draws as literal text.

An existing value SHALL be preserved. `TERM` SHALL NOT be changed to carry this information, since `TERM` is interpreted on the far side of an `ssh` connection where the terminfo entry it names may not exist.

#### Scenario: A known-capable terminal

- **WHEN** an interactive shell starts under a terminal identified as supporting 24-bit color
- **THEN** `COLORTERM` SHALL be exported with a value naming truecolor support

#### Scenario: An unidentified terminal

- **WHEN** an interactive shell starts with nothing in the environment identifying the terminal as 24-bit capable
- **THEN** `COLORTERM` SHALL be unset

#### Scenario: An existing declaration is left alone

- **WHEN** a shell starts with `COLORTERM` already set by something else
- **THEN** that value SHALL survive unchanged

#### Scenario: TERM is untouched

- **WHEN** the shell configuration is read
- **THEN** `TERM` SHALL keep the value the terminal gave it

#### Scenario: Non-interactive shells make no claim

- **WHEN** a script or tool runner starts a non-interactive shell
- **THEN** no color-depth declaration SHALL be added to its environment
