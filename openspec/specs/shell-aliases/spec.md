# shell-aliases Specification

## Purpose

Defines the command shorthands an interactive shell in this configuration answers to: which names are bound, what each resolves to, and the rules a shorthand follows so that it stays a convenience at the prompt without changing what any script sees.

## Requirements

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

### Requirement: A shorthand does not shadow an existing command

A shorthand SHALL NOT be bound to a name that already resolves to an executable on `PATH` or to a shell builtin, unless the intent is explicitly to change that command's default behavior. The names bound as pure shorthands SHALL be names the shell would otherwise report as not found, so that adding one cannot change the meaning of a command already in use.

Where the intent *is* to change a command's default behavior, the binding SHALL be a deliberate, recorded decision rather than an incidental collision, and SHALL owe two things. It SHALL be guarded on the replacement being present, so that on a machine without it the original command keeps working with no message and no error. And the original SHALL stay reachable by the shell's own means of bypassing a shorthand, so that a caller who wants the real command can always have it.

#### Scenario: The name was previously unbound

- **WHEN** a shorthand is defined for a name that resolved to nothing before
- **THEN** the only new behavior SHALL be that the name now runs its target

#### Scenario: A real command keeps its meaning

- **WHEN** a command that exists on `PATH` is invoked by its own name, and no deliberate override of that name is defined
- **THEN** it SHALL run the executable, not a shorthand that happens to be spelled the same

#### Scenario: A deliberate override is guarded

- **WHEN** a name is deliberately bound to a replacement for the command it already names, on a machine where that replacement is not installed
- **THEN** the name SHALL run the original command
- **AND** nothing SHALL be printed about the replacement's absence

#### Scenario: The overridden command stays reachable

- **WHEN** a deliberate override is in effect and the caller invokes the name through the shell's mechanism for bypassing a shorthand
- **THEN** the original executable SHALL run

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

### Requirement: `cat` shows highlighted output

At an interactive prompt on a machine where `bat` is installed, `cat` SHALL print a file with syntax highlighting rather than as plain text. This is a deliberate override of `cat` under the rule above, taken because reading a file at the prompt is what the name is reached for and highlighting is what that reading wants.

Where `bat` is not installed, `cat` SHALL be the original `cat`, unchanged and unannounced.

#### Scenario: Reading a source file

- **WHEN** `cat` is given a source file at an interactive prompt on a machine with `bat` installed
- **THEN** the file's contents SHALL be printed with syntax highlighting

#### Scenario: Without bat installed

- **WHEN** an interactive shell starts on a machine where `bat` is absent
- **THEN** `cat` SHALL run the original executable
- **AND** the shell SHALL print nothing about `bat`

#### Scenario: Reaching the original

- **WHEN** the caller invokes `cat` through the shell's shorthand-bypassing mechanism
- **THEN** the original `cat` SHALL run

#### Scenario: Not defined for scripts

- **WHEN** a script invokes `cat`
- **THEN** the original `cat` SHALL run, since the override is interactive-only
