## ADDED Requirements

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
