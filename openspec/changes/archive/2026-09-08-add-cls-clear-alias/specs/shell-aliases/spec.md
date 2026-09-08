## MODIFIED Requirements

### Requirement: An alias is an interactive convenience only

A shorthand defined by this configuration SHALL be available at an interactive prompt and SHALL have no effect on a non-interactive shell. A script that runs under this configuration SHALL behave exactly as it would with no shorthand defined, so that a name bound for typing convenience never becomes something a script depends on.

A shorthand SHALL be defined in every interactive shell this configuration configures, not in whichever of them the shorthand was first written for. A name that answers in one shell and reports itself as unknown in another is worse than a name that was never bound, because the reflex it exists to serve is trained by the shell that answers and then fails in the shell that does not.

#### Scenario: Available at the prompt

- **WHEN** an interactive shell has read this configuration
- **THEN** each shorthand this configuration defines SHALL resolve to its target command

#### Scenario: The same shorthands in every configured shell

- **WHEN** a shorthand is defined for one of the interactive shells this configuration covers
- **THEN** it SHALL be defined for the others as well, resolving to the same target command in each

#### Scenario: Absent from a script

- **WHEN** a script or tool runner starts a non-interactive shell under this configuration
- **THEN** no shorthand defined here SHALL be in effect
- **AND** a name that is only a shorthand SHALL fail as an unknown command rather than silently resolving

### Requirement: `cls` clears the screen

An interactive shell SHALL accept `cls` as a name for clearing the terminal, producing the same result as the `clear` command. The name is carried over from shells where it is the standard spelling, so that the reflex of typing it does not end in an error.

This SHALL hold in bash and in fish alike. The reflex is trained on the name, not on the shell it is typed into, so a binding present in only one of them leaves the error it exists to remove.

#### Scenario: Clearing by the alternate name

- **WHEN** `cls` is entered at an interactive prompt
- **THEN** the terminal SHALL be cleared exactly as `clear` clears it

#### Scenario: Clearing from either shell

- **WHEN** `cls` is entered at an interactive bash prompt, and again at an interactive fish prompt
- **THEN** the terminal SHALL be cleared in both cases

#### Scenario: The original name still works

- **WHEN** `clear` is entered at an interactive prompt
- **THEN** it SHALL clear the terminal as before, unchanged by the presence of `cls`

#### Scenario: Not defined for scripts

- **WHEN** a script invokes `cls`
- **THEN** the shell SHALL report it as an unknown command, since the shorthand is interactive-only
