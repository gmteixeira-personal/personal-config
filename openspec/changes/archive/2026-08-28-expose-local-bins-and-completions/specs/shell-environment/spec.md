## ADDED Requirements

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
