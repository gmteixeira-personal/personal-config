## Purpose

Defines what an interactive fish prints before its first prompt: no greeting, silenced by the tracked configuration rather than by state a machine happens to hold, and without suppressing anything else the shell has to say.

## Requirements

### Requirement: An interactive shell prints no greeting

An interactive fish SHALL print no greeting before its first prompt. The first thing it writes SHALL be the prompt itself.

This SHALL hold for every interactive shell, not only the first of a session or the first after login: a new terminal window, a new tab, a split, a shell reached by handing an interactive bash session over to fish, and a fish started from inside another shell SHALL each print no greeting.

#### Scenario: A new interactive shell

- **WHEN** an interactive fish starts
- **THEN** it SHALL print no greeting text
- **AND** the first output it writes SHALL be its prompt

#### Scenario: Reached by handover from bash

- **WHEN** an interactive bash session hands itself over to fish
- **THEN** the resulting shell SHALL print no greeting

#### Scenario: A shell started inside another shell

- **WHEN** a fish is started from within an existing interactive shell, or an existing one replaces itself to re-read its configuration
- **THEN** that shell SHALL print no greeting

### Requirement: The greeting is silenced by the tracked configuration

The absence of the greeting SHALL come from a file this repository tracks, so that a shell assembled from a clone behaves the same as this one. It SHALL NOT depend on a value recorded in machine-local state, such as the file where fish records universal variables.

Where machine-local state does hold a greeting, the tracked configuration SHALL be what takes effect, and the greeting SHALL still be absent.

#### Scenario: A fresh clone is silent too

- **WHEN** the repository is cloned onto a machine that has never had this configuration
- **THEN** an interactive fish there SHALL print no greeting
- **AND** no command SHALL have to be run on that machine to make it so

#### Scenario: Nothing is recorded on the machine

- **WHEN** the configuration is in place and the file where fish records universal variables is inspected
- **THEN** it SHALL record nothing about the greeting

#### Scenario: A greeting left behind on the machine

- **WHEN** machine-local state records a greeting from earlier configuration
- **THEN** the tracked configuration SHALL override it
- **AND** the shell SHALL still print no greeting

### Requirement: Nothing but the greeting is silenced

Silencing the greeting SHALL suppress only the greeting. Anything else a shell would print at start-up — a warning, an error, output from another part of this configuration — SHALL still appear, and the documentation the greeting pointed at SHALL remain reachable by asking for it.

A non-interactive fish SHALL be unaffected: it SHALL behave and output exactly as it did before, since it never had a greeting to lose.

#### Scenario: A start-up warning still shows

- **WHEN** something in the configuration writes a warning or an error while an interactive shell starts
- **THEN** that message SHALL be printed

#### Scenario: A private shell still says it is private

- **WHEN** an interactive fish starts with history persistence turned off
- **THEN** it SHALL still report that history will not be persisted

#### Scenario: The help the greeting advertised

- **WHEN** the user asks the shell for its help
- **THEN** the help SHALL be shown as before

#### Scenario: A non-interactive shell is unchanged

- **WHEN** a script or tool runner starts a non-interactive fish
- **THEN** its output SHALL be exactly what the command produces
- **AND** the shell SHALL start with no error about the greeting configuration
