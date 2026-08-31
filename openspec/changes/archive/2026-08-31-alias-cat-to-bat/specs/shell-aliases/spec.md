## MODIFIED Requirements

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

## ADDED Requirements

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
