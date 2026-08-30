# fish-startup-files Specification

## Purpose

Defines where each kind of fish configuration lives and what may depend on what, so that a setting can be found from its category alone and so that no setting survives only because an unrelated one happened to run.

## Requirements

### Requirement: Startup configuration lives in topic-scoped snippets

Every setting fish applies at startup SHALL live in a file under `conf.d/` named for the kind of setting it holds, or — for a function — in `functions/`. No single file SHALL collect settings of more than one kind, and `config.fish` SHALL NOT exist.

The categories SHALL be: environment; key bindings; command shorthands; and functions. A setting that belongs to none of them SHALL be given a file of its own rather than added to the closest existing one.

#### Scenario: Locating a setting by its kind

- **WHEN** a maintainer needs to find or change a key binding
- **THEN** it is in the `conf.d/` file named for key bindings
- **AND** it is not in any other startup file

#### Scenario: No catch-all file

- **WHEN** the fish configuration directory is listed
- **THEN** `config.fish` is absent
- **AND** every startup file present is named for exactly one kind of setting

#### Scenario: A new kind of setting

- **WHEN** a setting is added that fits none of the named categories
- **THEN** it is placed in a new file named for what it is
- **AND** no existing file gains a second kind of setting

### Requirement: A snippet does not depend on another snippet having run

Each `conf.d/` snippet SHALL produce its effect regardless of the order the snippets are read in. A snippet SHALL NOT read a variable, function, or binding that another snippet defines, because fish reads them in filename order and that order carries no meaning.

A snippet MAY depend on what fish itself provides before any snippet runs, and on the environment the shell was started with.

#### Scenario: Reordering changes nothing

- **WHEN** the startup snippets are read in any order
- **THEN** the resulting shell is identical in its bindings, shorthands, functions, and exported environment

#### Scenario: A snippet needing another's output

- **WHEN** a setting genuinely requires a value another snippet computes
- **THEN** the two live in the same file
- **AND** no ordering prefix is added to the filenames to sequence them

### Requirement: Interactive-only configuration carries its own guard

A file holding configuration that is meaningful only at a prompt SHALL test for an interactive shell itself and stop when the shell is not interactive. It SHALL NOT rely on being nested inside a function, a binding, or another file's guard for that.

A non-interactive shell SHALL therefore end up with the environment such a configuration would give it and none of the prompt behaviour.

#### Scenario: A script sees no interactive setup

- **WHEN** a script or tool runner starts a non-interactive fish
- **THEN** no key binding, shorthand, or prompt setting from this configuration is in effect
- **AND** the shell starts with no error about it

#### Scenario: The guard is visible in the file that needs it

- **WHEN** a maintainer opens a file holding interactive-only configuration
- **THEN** the interactivity test is in that file
- **AND** removing an unrelated file does not remove the guard

#### Scenario: Environment is not gated behind interactivity

- **WHEN** a non-interactive fish reads the configuration
- **THEN** every environment variable and `PATH` entry the configuration sets is present

### Requirement: A function is defined by being named

A function this configuration provides SHALL live in its own file under `functions/`, named for the function, so that fish loads it when the name is first used. A function SHALL NOT be defined as a side effect of another function running.

`fish_user_key_bindings` is the exception fish itself defines: it SHALL hold the `bind` calls and nothing else.

#### Scenario: Calling a function that has not been used yet

- **WHEN** a shell starts and the user invokes one of the configuration's functions for the first time
- **THEN** the function runs
- **AND** it was not defined during startup

#### Scenario: Key bindings do not carry unrelated definitions

- **WHEN** `fish_user_key_bindings` is read
- **THEN** it contains only `bind` calls
- **AND** no function, shorthand, or variable is defined inside it

#### Scenario: Changing key bindings leaves the shorthands alone

- **WHEN** the key binding configuration is changed or removed
- **THEN** every shorthand and function this configuration provides is still available at the prompt

### Requirement: Every startup file is tracked

Each file this configuration places under `conf.d/` or `functions/` SHALL be tracked by the dotfiles repository, so that the shell on another machine is assembled from the same snippets. Files fish or another tool writes into that directory on its own SHALL remain untracked.

#### Scenario: A new snippet is tracked without further work

- **WHEN** a file is added under `conf.d/` or `functions/` by this configuration
- **THEN** the repository reports it as an untracked file to be committed
- **AND** no ignore rule has to be edited to make that so

#### Scenario: Generated files stay out

- **WHEN** a tool writes its own completions or fish records a universal variable
- **THEN** that file remains ignored
