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
