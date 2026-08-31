## ADDED Requirements

### Requirement: Activation is silent unless something needs attention

Activating an environment, keeping it active while the working directory moves within its tree, and restoring the previous environment on leaving SHALL each produce no output. A shell that is doing what it is supposed to do SHALL say nothing about it.

This is a rule about the success path only. It SHALL NOT suppress any report this capability already requires: a declaration that has not been approved on this machine, and a declaration naming an environment that is not present, SHALL each still be reported in full, naming the path concerned and, where an action is needed, the command that takes it. Silence SHALL be the absence of routine reporting, not the loss of a diagnostic.

The distinction SHALL be drawn by what the message is, not by which shell is running or which directory it is in. Both interactive shells this configuration supports SHALL be silent on the same events and loud on the same ones.

#### Scenario: Entering a working project says nothing

- **WHEN** the working directory becomes a directory whose approved declaration names an environment that exists
- **THEN** the environment SHALL be active
- **AND** no output SHALL be produced

#### Scenario: Moving within and leaving say nothing

- **WHEN** the working directory moves to a descendant of such a directory, and then out of its tree entirely
- **THEN** the environment SHALL remain active and then be restored as the requirements above specify
- **AND** no output SHALL be produced by either move

#### Scenario: An unapproved declaration is still reported

- **WHEN** the working directory becomes a directory holding a declaration that has not been approved on this machine
- **THEN** the report SHALL still be printed, naming the declaration and the command that approves it

#### Scenario: A missing environment is still reported

- **WHEN** a directory's approved declaration names an environment that does not exist on disk
- **THEN** the single-line report naming the missing path SHALL still be printed

#### Scenario: Both shells are quiet on the same events

- **WHEN** the same working project is entered from an interactive bash and from an interactive fish
- **THEN** neither SHALL produce output
- **AND** an unapproved declaration entered from either SHALL be reported by both
