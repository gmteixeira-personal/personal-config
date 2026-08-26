## ADDED Requirements

### Requirement: The cursor is handed back to the terminal before a command runs

Readline repaints the cursor only when the editing mode changes, so the shape showing when the line is accepted — always the insert-mode shape, since a prompt begins in insert mode — is the shape the command inherits. The shell SHALL therefore reset the cursor to the terminal's configured shape after the command line is read and before the command is executed, so that a program which sets no cursor of its own runs with the terminal's shape rather than with the shell's mode indicator.

The reset SHALL restore the shape the terminal profile specifies rather than naming a shape, consistent with how normal mode is signalled. It SHALL apply to every command rather than being configured per program, and it SHALL contribute no visible characters.

#### Scenario: A program that sets no cursor of its own

- **WHEN** the user runs a full-screen program that never emits a cursor-shape sequence
- **THEN** that program SHALL display the terminal's configured cursor shape
- **AND** SHALL NOT display the insert-mode beam

#### Scenario: A program that manages its own cursor

- **WHEN** the user runs a program that sets its own cursor shape
- **THEN** that program's own shape SHALL apply, having been set after the reset

#### Scenario: The mode indicator survives

- **WHEN** the command finishes and the next prompt is drawn
- **THEN** readline SHALL be in insert mode and the cursor SHALL show the beam
- **AND** pressing Escape SHALL still return the cursor to the terminal's configured shape

#### Scenario: The reset is not per program

- **WHEN** the shell configuration is inspected
- **THEN** the reset SHALL be configured once for all commands
- **AND** no alias or wrapper SHALL exist that resets the cursor for one named program

#### Scenario: The prompt is unchanged

- **WHEN** the reset is in effect
- **THEN** the prompt SHALL keep its existing text, alignment, and line-wrapping behaviour
- **AND** an empty command line SHALL produce no reset, since no command runs
