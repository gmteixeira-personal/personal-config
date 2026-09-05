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

### Requirement: A tool without usable upstream completions is completable anyway

Where an installed command-line tool offers no usable completions in the interactive shell — neither built into the shell nor derivable from its manual page — completions for it SHALL be provided by this configuration.

A tool is treated as lacking completions only when its *option* form completes nothing. Testing the bare command name is not a valid check: with no completions defined the shell falls back to filename completion, which returns entries and so looks like success.

#### Scenario: An otherwise uncompletable tool completes its options

- **WHEN** completion is requested for an option prefix of such a tool
- **THEN** the tool's options SHALL be offered
- **AND** the result SHALL NOT be filename fallback

#### Scenario: Coverage is judged on the option form

- **WHEN** a tool is assessed for whether it needs completions
- **THEN** the assessment SHALL use an option prefix rather than the bare command name

### Requirement: A tool's own generator is preferred over a written completion

Where a tool can generate completions for the interactive shell itself, that generated output SHALL be used rather than a completion written by hand.

A generated completion tracks the tool's own command surface and is regenerated when the tool is upgraded; a hand-written one silently describes an older version. Hand-writing is reserved for tools that offer no generator and whose manual page cannot be parsed into completions — for example a page that documents options only in prose, or that documents a configuration file format rather than a command line.

#### Scenario: A tool that can generate them

- **WHEN** an installed tool offers a completion generator for the interactive shell
- **THEN** the completion in use SHALL be that tool's generated output

#### Scenario: A tool that cannot

- **WHEN** a tool offers no generator and its manual page yields no options
- **THEN** a written completion SHALL provide its options
- **AND** that completion SHALL record why it was written by hand

### Requirement: A hand-written completion is tracked, a generated one is not

A completion written by hand SHALL be tracked by this repository. A completion generated by its own tool, and one harvested in bulk from the machine's manual pages, SHALL NOT be tracked.

The per-user completion directory is otherwise machine-local, because the tools that install completions there rewrite them on every reinstall and upgrade; a tracked copy would go stale against the tool that owns it. A hand-written completion is the exception that rule did not anticipate: nothing regenerates it, so leaving it untracked loses it. It SHALL therefore be named individually in the allowlist rather than by re-including the directory, so the directory keeps its machine-local default.

#### Scenario: A hand-written completion survives

- **WHEN** `git ls-files` is inspected
- **THEN** each completion written by hand SHALL appear

#### Scenario: A generated completion is left to its tool

- **WHEN** the completion directory is checked against the repository
- **THEN** a completion produced by a tool's own generator SHALL NOT be tracked
- **AND** neither SHALL the manual-page-derived set, which is rebuildable by a single command

#### Scenario: The directory stays machine-local

- **WHEN** the allowlist is inspected for the completion directory
- **THEN** it SHALL name individual files rather than re-including the directory
