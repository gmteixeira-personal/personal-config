## ADDED Requirements

### Requirement: noctalia is retired

noctalia SHALL NOT be part of this configuration. No configuration for it SHALL be tracked, no allowlist entry SHALL name a path belonging to it, the compositor's configuration SHALL NOT start it or address it from any binding, and on a machine this repository is deployed to no configuration or state directory belonging to it SHALL remain.

It is retired because it brings far more of a desktop than this session wants, and for no other reason: the project is actively maintained, its niri backend worked, and the bar, launcher, lock screen and clipboard panel all did what they claimed. Retiring it gives up the clipboard history and nothing else, and this requirement is a record of a preference rather than a judgement on the software.

Its removal has a failure mode the other retired tools do not. noctalia themes other programs by writing into their configuration directories, so its output is not confined to its own paths: on this machine it had authored files under `.config/gtk-3.0/`, `.config/gtk-4.0/`, `.config/kdeglobals`, `.config/kitty/`, `.config/btop/themes/`, `.config/foot/themes/` and `.config/niri/`, including directories for two programs that are not installed here. All of it is untracked, so no checkout restores it and no `git status` reports it. Those files SHALL be absent, and the two tracked configuration files that included them SHALL no longer do so.

#### Scenario: No noctalia configuration is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** no path under `.config/noctalia/` SHALL appear
- **AND** a search of the tracked file contents SHALL find no occurrence of `noctalia`, excluding archived OpenSpec changes, which are a historical record, and this requirement itself, which has to name what it retires

#### Scenario: The allowlist no longer names it

- **WHEN** the root ignore file is inspected
- **THEN** no allowlist entry SHALL name `.config/noctalia/settings.toml` or any other path under that directory
- **AND** `git check-ignore -v .config/noctalia/settings.toml` SHALL report a deny-by-default rule rather than an allowlist exception

#### Scenario: The compositor neither starts it nor addresses it

- **WHEN** `.config/niri/config.kdl` is inspected
- **THEN** no `spawn-at-startup` entry SHALL name it
- **AND** no binding SHALL spawn it or send it a message
- **AND** no `include` SHALL name a file it wrote

#### Scenario: No tracked file includes a theme it wrote

- **WHEN** the tracked configuration files for other programs are inspected
- **THEN** none SHALL include or import a file named after it
- **AND** `.config/foot/foot.ini` in particular SHALL carry no `include=` line naming it

#### Scenario: The files it wrote for other programs are gone

- **WHEN** a machine running this configuration is inspected
- **THEN** `.config/gtk-3.0/`, `.config/gtk-4.0/`, `.config/kdeglobals`, `.config/kitty/`, `.config/btop/`, `.config/foot/themes/` and `.config/niri/noctalia.kdl` SHALL each be absent, except where a later change creates one of them for its own reasons
- **AND** no surviving file among them SHALL name it

#### Scenario: No leftover state on the machine

- **WHEN** a machine running this configuration is inspected
- **THEN** `.config/noctalia/` and `.local/state/noctalia/` SHALL each be absent
- **AND** a search of the home directory SHALL find no file belonging to the tool, excluding assets that an unrelated third-party package ships inside its own installation directory

#### Scenario: Re-adding it is a deliberate act

- **WHEN** someone wants noctalia back
- **THEN** it SHALL require a new allowlist entry and a change that supersedes this requirement, not merely reinstalling the package and letting it write its files again
- **AND** that change SHALL account for the files it writes outside its own directories
