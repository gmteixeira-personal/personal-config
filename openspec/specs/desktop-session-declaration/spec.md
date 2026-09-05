# desktop-session-declaration Specification

## Purpose

Defines what this repository must record for the graphical session to be rebuilt on another machine — which software the session needs, where a tool's settings are declared when its own state directory is untrackable, and how a declaration that a machine-local layer can shadow is kept honest — so that a checkout reproduces the session rather than a desktop missing its bar, its launcher and its theme.

## Requirements

### Requirement: The session's software is named in tracked documentation

Every program the graphical session depends on SHALL appear in the repository's tracked required-software documentation, including the compositor, the terminal, the desktop shell, and any helper the compositor needs for compatibility with other window systems.

Configuration for a program is not a substitute for naming it. A tracked configuration file for an absent program produces a session that starts and is missing a piece, which is the failure mode this documentation exists to prevent.

#### Scenario: A reader can tell what the session needs

- **WHEN** the tracked documentation is read on a machine with none of the session installed
- **THEN** every program the session depends on SHALL be named
- **AND** each SHALL state what breaks or is lost in its absence

#### Scenario: A tracked configuration implies a named program

- **WHEN** the repository tracks a configuration file for a program
- **THEN** that program SHALL appear in the required-software documentation

### Requirement: Settings in an untrackable state directory are declared in the tool's own config layer

Where a tool keeps its settings in a directory the ignore policy denylists, and the tool also reads a configuration directory that the policy permits, the settings SHALL be declared in that configuration directory rather than left only in state.

Declaring them in the tool's own layer means a fresh machine applies them by reading its configuration normally, with no copy step, no restore command, and nothing to remember. A declaration parked somewhere neutral would need a documented procedure that is itself a thing to get wrong.

#### Scenario: A fresh machine applies the declaration

- **WHEN** the tool starts on a machine that has the declaration and no state directory of its own
- **THEN** the declared settings SHALL take effect

#### Scenario: State stays out of the repository

- **WHEN** the repository is inspected
- **THEN** the tool's state directory SHALL NOT be tracked
- **AND** only the declaration SHALL be

### Requirement: A shadowed declaration is refreshed from what it shadows

Where the tool's state layer overrides its configuration layer for keys present in both, the declaration SHALL be refreshed from the effective settings whenever those settings are changed through the tool's own interface, and the documentation SHALL say so.

The two layers disagreeing is not hypothetical: on the machine where the settings are edited, the state layer wins every overlapping key, so the declaration can drift arbitrarily far while that machine keeps working perfectly. The drift is only ever discovered on the next machine, which is the worst possible place to discover it.

#### Scenario: Settings changed through the interface

- **WHEN** the tool's settings are changed through its own user interface
- **THEN** the declaration SHALL be refreshed from the resulting effective configuration

#### Scenario: The precedence is documented

- **WHEN** the documentation for the declaration is read
- **THEN** it SHALL state that the machine-local state layer overrides the declaration
- **AND** it SHALL name how to regenerate the declaration

### Requirement: The declaration is portable

The declaration SHALL NOT contain absolute paths naming the home directory of the machine it was exported from, nor any credential, token or identifier that is personal to a machine or account.

An exported configuration is a machine's own state written out, so it carries whatever that machine happened to have. A home path in it resolves to nothing on the next machine and fails silently, which is the same class of failure the ignore policy's rule against machine-absolute paths already guards against elsewhere.

#### Scenario: No home path is carried

- **WHEN** the declaration is inspected for absolute paths under a home directory
- **THEN** none SHALL be found

#### Scenario: No credential is carried

- **WHEN** the declaration is inspected
- **THEN** it SHALL contain no token, key or account identifier

### Requirement: The rebuild procedure is written down and ordered

The tracked documentation SHALL describe how to rebuild the session from a checkout, in an order that works, naming what must be installed before the configuration means anything and how the session is started.

Ordering is the substance of the procedure rather than a presentational detail: the compositor's configuration names programs that must exist before it is loaded, and the session's user units require the compositor to have been started in the way that activates them.

#### Scenario: The procedure is followable on a fresh machine

- **WHEN** the rebuild procedure is followed on a machine with only the checkout
- **THEN** it SHALL name the software to install before the tracked configuration is used
- **AND** it SHALL name how the session is started

#### Scenario: The procedure covers the shell's settings

- **WHEN** the rebuild procedure is read
- **THEN** it SHALL account for the desktop shell's declared settings without requiring the reader to find them
