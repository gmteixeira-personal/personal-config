# shell-environment Specification

## Purpose
Defines what a shell in this configuration exports about the machine it is running on: how `PATH` is assembled from installation locations that differ per machine, and when a tool-root variable is named at all, so that one tracked configuration can be carried to environments that install the same tools in different places.

## Requirements

### Requirement: PATH names only directories that exist

Every `PATH` entry for a per-machine installation location SHALL be added only if that directory exists at the time the shell configuration is read. A machine that obtains the same tool from elsewhere SHALL end up with no entry for the absent location, and SHALL report no error for it.

The entries themselves SHALL be kept rather than deleted. They record where each tool lives on the machines that install it that way, and this configuration is carried to all of them.

#### Scenario: An absent location contributes nothing

- **WHEN** a shell starts on a machine where a named installation directory does not exist
- **THEN** `PATH` SHALL contain no entry for it
- **AND** the shell SHALL start without an error or warning about it

#### Scenario: A present location is on PATH

- **WHEN** a shell starts on a machine where the directory does exist
- **THEN** `PATH` SHALL contain it

#### Scenario: Relative order is preserved

- **WHEN** several of the named directories exist on the same machine
- **THEN** their order in `PATH` SHALL be the order the configuration declares, so that a tool present in two of them resolves to the same one every time

### Requirement: PATH does not accumulate duplicates

Reading the shell configuration more than once SHALL NOT add a directory to `PATH` that is already there. This SHALL hold both when a file is re-sourced in a running shell and when one startup file adds a directory that another has already added.

#### Scenario: Re-sourcing is idempotent

- **WHEN** the shell configuration is sourced twice in the same shell
- **THEN** `PATH` SHALL be identical after the second pass to what it was after the first

#### Scenario: Login shell does not duplicate the interactive one

- **WHEN** a login shell reads both startup files and both name the same directory
- **THEN** that directory SHALL appear in `PATH` exactly once

### Requirement: A tool root is named only when that installation is present

An environment variable that names a tool's installation root SHALL be exported only when that installation is actually present, and SHALL be detected by the presence of the tool's own executable rather than by the presence of a directory that the tool may create for other reasons. Where the installation is absent, the variable SHALL be left unset so that a system-packaged copy of the tool locates its own root.

#### Scenario: Per-user SDK present

- **WHEN** a shell starts on a machine carrying a per-user .NET SDK, with its executable at `~/.dotnet/dotnet`
- **THEN** `DOTNET_ROOT` SHALL be exported naming that directory
- **AND** that directory and its tools directory SHALL be on `PATH`

#### Scenario: Only a system package present

- **WHEN** a shell starts on a machine whose only .NET SDK came from the system package manager
- **THEN** `DOTNET_ROOT` SHALL be unset
- **AND** `dotnet --version` SHALL report the system SDK's version

#### Scenario: A directory the tool created for its own bookkeeping is not evidence

- **WHEN** `~/.dotnet` exists but holds only first-use sentinels and caches, with no `dotnet` executable in it
- **THEN** `DOTNET_ROOT` SHALL NOT be exported

### Requirement: 24-bit color is advertised only where the terminal supports it

An interactive shell SHALL declare 24-bit color support to the programs it runs, by exporting `COLORTERM`, when and only when it is running under a terminal known to render it. Where the terminal is unknown or known not to, the variable SHALL be left unset rather than given a value, because a program that believes a false claim emits escape sequences the terminal then draws as literal text.

An existing value SHALL be preserved. `TERM` SHALL NOT be changed to carry this information, since `TERM` is interpreted on the far side of an `ssh` connection where the terminfo entry it names may not exist.

#### Scenario: A known-capable terminal

- **WHEN** an interactive shell starts under a terminal identified as supporting 24-bit color
- **THEN** `COLORTERM` SHALL be exported with a value naming truecolor support

#### Scenario: An unidentified terminal

- **WHEN** an interactive shell starts with nothing in the environment identifying the terminal as 24-bit capable
- **THEN** `COLORTERM` SHALL be unset

#### Scenario: An existing declaration is left alone

- **WHEN** a shell starts with `COLORTERM` already set by something else
- **THEN** that value SHALL survive unchanged

#### Scenario: TERM is untouched

- **WHEN** the shell configuration is read
- **THEN** `TERM` SHALL keep the value the terminal gave it

#### Scenario: Non-interactive shells make no claim

- **WHEN** a script or tool runner starts a non-interactive shell
- **THEN** no color-depth declaration SHALL be added to its environment

### Requirement: Per-machine tool locations are reached by non-interactive shells

Every `PATH` entry for a per-machine installation location SHALL be added by the shell configuration before it stops doing work for a non-interactive shell. A shell that reads the configuration without being interactive — a login shell running a single command, a remote command over `ssh`, a hook or tool runner that sources the file — SHALL end up with the same set of these entries that an interactive shell gets.

This SHALL hold for every such location the configuration names, not only for those whose tools are obviously wanted by scripts. The relative order of the entries SHALL be the same as in an interactive shell, so a tool present in two of them resolves to the same one either way.

Configuration that is only meaningful to a person at a prompt — prompt strings, history behaviour, key bindings, completions — SHALL remain after that point, and SHALL NOT be moved before it to accompany the `PATH` entries.

#### Scenario: A non-interactive shell resolves a per-user tool

- **WHEN** the shell configuration is sourced by a non-interactive shell on a machine where `~/.local/bin` and `~/.cargo/bin` exist
- **THEN** both directories SHALL be on `PATH`
- **AND** an executable installed in either SHALL be resolvable by name

#### Scenario: Interactive and non-interactive agree

- **WHEN** the entries for per-machine installation locations are compared between an interactive shell and a non-interactive shell that sourced the same configuration
- **THEN** the same directories SHALL be present, in the same relative order

#### Scenario: Interactive-only configuration stays interactive-only

- **WHEN** a non-interactive shell sources the configuration
- **THEN** no prompt, history, key binding, or completion setup SHALL have run

### Requirement: An editor is nominated for privileged file editing

The shell SHALL nominate an editor for `sudoedit` by exporting `SUDO_EDITOR`, and SHALL give it the absolute path of the editor as resolved on the machine the shell is running on rather than a bare command name. `SUDO_EDITOR` is read by `sudoedit` alone and takes precedence over `VISUAL` and `EDITOR`, so naming it states the choice unambiguously and removes any dependence on how `sudo` searches for a command name.

The variable SHALL be exported only where that editor is present, in keeping with the rule that a tool is named only when its executable is there. Where it is absent the variable SHALL be left unset, so that `sudoedit` falls through to `VISUAL`, then `EDITOR`, then the editor list in the system's own sudo configuration.

`EDITOR` and `VISUAL` SHALL keep the bare command name they carry. They are read by many programs, each resolving it against the `PATH` of the moment, and an absolute path there would pin those programs to the editor that existed when the shell started.

This SHALL hold for non-interactive shells as well as interactive ones, since the editor variables are already set before the configuration stops doing work for a non-interactive shell.

#### Scenario: The editor is present

- **WHEN** a shell starts on a machine where the configured editor's executable is resolvable
- **THEN** `SUDO_EDITOR` SHALL be exported
- **AND** its value SHALL be an absolute path to that executable

#### Scenario: A per-machine installation is found wherever it lives

- **WHEN** two machines install the same editor in different locations, one from a system package and one under a per-user directory that the shell configuration adds to `PATH`
- **THEN** each shell SHALL export the absolute path of the copy on its own machine
- **AND** neither location SHALL be named literally in the configuration

#### Scenario: The editor is absent

- **WHEN** a shell starts on a machine where no such executable is resolvable
- **THEN** `SUDO_EDITOR` SHALL be unset
- **AND** the shell SHALL start without an error or warning about it

#### Scenario: Privileged editing uses the invoking user's editor configuration

- **WHEN** a file owned by root is opened with `sudoedit`
- **THEN** the editor named by `SUDO_EDITOR` SHALL run
- **AND** it SHALL read the invoking user's own editor configuration, because `sudoedit` runs the editor with that user's permissions and environment

#### Scenario: The general-purpose editor variables are unchanged

- **WHEN** the shell configuration is read
- **THEN** `EDITOR` and `VISUAL` SHALL each carry the editor's command name, not a path

#### Scenario: A non-interactive shell nominates the same editor

- **WHEN** the shell configuration is sourced by a non-interactive shell
- **THEN** `SUDO_EDITOR` SHALL hold the same value an interactive shell on that machine would give it
