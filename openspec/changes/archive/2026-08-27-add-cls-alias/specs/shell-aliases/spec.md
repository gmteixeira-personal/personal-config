## Purpose

Defines the command shorthands an interactive shell in this configuration answers to: which names are bound, what each resolves to, and the rules a shorthand follows so that it stays a convenience at the prompt without changing what any script sees.

## ADDED Requirements

### Requirement: An alias is an interactive convenience only

A shorthand defined by this configuration SHALL be available at an interactive prompt and SHALL have no effect on a non-interactive shell. A script that runs under this configuration SHALL behave exactly as it would with no shorthand defined, so that a name bound for typing convenience never becomes something a script depends on.

#### Scenario: Available at the prompt

- **WHEN** an interactive shell has read this configuration
- **THEN** each shorthand this configuration defines SHALL resolve to its target command

#### Scenario: Absent from a script

- **WHEN** a script or tool runner starts a non-interactive shell under this configuration
- **THEN** no shorthand defined here SHALL be in effect
- **AND** a name that is only a shorthand SHALL fail as an unknown command rather than silently resolving

### Requirement: A shorthand does not shadow an existing command

A shorthand SHALL NOT be bound to a name that already resolves to an executable on `PATH` or to a shell builtin, unless the intent is explicitly to change that command's default behavior. The names bound as pure shorthands SHALL be names the shell would otherwise report as not found, so that adding one cannot change the meaning of a command already in use.

#### Scenario: The name was previously unbound

- **WHEN** a shorthand is defined for a name that resolved to nothing before
- **THEN** the only new behavior SHALL be that the name now runs its target

#### Scenario: A real command keeps its meaning

- **WHEN** a command that exists on `PATH` is invoked by its own name
- **THEN** it SHALL run the executable, not a shorthand that happens to be spelled the same

### Requirement: `cls` clears the screen

An interactive shell SHALL accept `cls` as a name for clearing the terminal, producing the same result as the `clear` command. The name is carried over from shells where it is the standard spelling, so that the reflex of typing it does not end in an error.

#### Scenario: Clearing by the alternate name

- **WHEN** `cls` is entered at an interactive prompt
- **THEN** the terminal SHALL be cleared exactly as `clear` clears it

#### Scenario: The original name still works

- **WHEN** `clear` is entered at an interactive prompt
- **THEN** it SHALL clear the terminal as before, unchanged by the presence of `cls`

#### Scenario: Not defined for scripts

- **WHEN** a script invokes `cls`
- **THEN** the shell SHALL report it as an unknown command, since the shorthand is interactive-only
