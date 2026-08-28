# shell-completions Specification

## Purpose

Defines how an interactive shell in this configuration picks up command completions that tools install into the per-user completion directory, on machines that have that directory but not necessarily the `bash-completion` loader that would otherwise discover its contents.

## Requirements

### Requirement: Completion scripts in the per-user directory are loaded

An interactive shell SHALL load every completion script installed under the per-user completion directory, so that a tool which installed its completions there is completable without any further step. Loading SHALL NOT depend on the `bash-completion` package being installed, because that loader is absent on machines that nonetheless have the directory.

Where the loader is present, loading these scripts eagerly SHALL remain harmless: it defines the same completion functions the loader would have defined on demand.

#### Scenario: An installed completion works

- **WHEN** an interactive shell starts on a machine with a completion script in the per-user completion directory
- **THEN** completion for that command SHALL be active in the new shell
- **AND** no command SHALL have to be run first to enable it

#### Scenario: No completion loader installed

- **WHEN** the machine has the per-user completion directory but no `bash-completion` loader
- **THEN** the scripts in that directory SHALL still be loaded

### Requirement: The completion directory is named relative to the home directory

The per-user completion directory SHALL be named through `$HOME` rather than as a literal absolute path. This configuration is carried to environments whose home directory has a different name, and a hardcoded path fails its own existence test there and loads nothing, silently.

Where a tool's installer writes a literal path into a tracked configuration file, that path SHALL be rewritten to the `$HOME` form.

#### Scenario: A different home directory

- **WHEN** an interactive shell starts in an environment whose home directory is not the one the completions were installed under
- **THEN** the completion directory of that environment SHALL be the one consulted

#### Scenario: No literal home path is tracked

- **WHEN** the shell configuration is inspected for the completion directory it names
- **THEN** that name SHALL be written in terms of `$HOME`

### Requirement: An absent or empty completion directory is not an error

Where the per-user completion directory does not exist, or exists with nothing in it, the shell SHALL start normally and report nothing. Only regular files SHALL be sourced, so that a subdirectory left there by another tool does not produce an error.

#### Scenario: Directory absent

- **WHEN** an interactive shell starts on a machine with no per-user completion directory
- **THEN** the shell SHALL start with no error or warning about it

#### Scenario: Directory empty

- **WHEN** the directory exists but contains no files
- **THEN** the shell SHALL start with no error or warning, and nothing SHALL be sourced

#### Scenario: A non-file entry is skipped

- **WHEN** the directory contains an entry that is not a regular file
- **THEN** that entry SHALL NOT be sourced
- **AND** the remaining entries SHALL still be loaded

### Requirement: Completions are not loaded for non-interactive shells

Completion scripts SHALL be loaded only by interactive shells. A script or tool runner SHALL NOT pay the cost of sourcing them, since completion has no effect where there is no prompt.

#### Scenario: A non-interactive shell loads nothing

- **WHEN** a non-interactive shell sources the shell configuration
- **THEN** no completion script SHALL have been sourced
