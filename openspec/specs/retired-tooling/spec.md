# retired-tooling Specification

## Purpose
Records the tools that were once part of this configuration and have since been withdrawn, and states what must be absent for each one, so that a retired tool cannot return quietly through a stale configuration file, a leftover allowlist entry, or a state directory nobody thought to remove.

## Requirements

### Requirement: lazygit is retired

lazygit SHALL NOT be part of this configuration. No configuration for it SHALL be tracked, no allowlist entry SHALL name a path under `.config/lazygit/`, and on a machine this repository is deployed to the package SHALL NOT be installed and no configuration, state, or cache directory belonging to it SHALL remain.

It is retired because it is no longer used here, and for no other reason: the project is actively maintained, and the git workflow it served is covered by the Neovim git plugins this configuration already loads and by the `/git:*` command suite. Retiring it removes a tool, not a capability, and this requirement is a record of a preference rather than a judgement on the software.

#### Scenario: No lazygit configuration is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** no path under `.config/lazygit/` SHALL appear

#### Scenario: The allowlist no longer names it

- **WHEN** the root ignore file is inspected
- **THEN** no allowlist entry SHALL name `.config/lazygit/config.yml` or any other path under that directory
- **AND** `git check-ignore -v .config/lazygit/config.yml` SHALL report a deny-by-default rule rather than an allowlist exception

#### Scenario: No leftover state on the machine

- **WHEN** a machine running this configuration is inspected
- **THEN** `.config/lazygit/`, `.local/state/lazygit/`, `.local/share/lazygit/`, and `.cache/lazygit/` SHALL each be absent
- **AND** a search of the home directory SHALL find no file belonging to the tool, excluding assets that an unrelated third-party package ships inside its own installation directory

#### Scenario: The package is not installed

- **WHEN** the system package manager is queried for lazygit
- **THEN** it SHALL report the package as not installed

#### Scenario: Re-adding it is a deliberate act

- **WHEN** someone wants lazygit back
- **THEN** it SHALL require a new allowlist entry and a change that supersedes this requirement, not merely creating the configuration file again

### Requirement: zoxide is retired

zoxide SHALL NOT be part of this configuration. No configuration for it SHALL be tracked, no shell startup file SHALL initialize it, no allowlist entry SHALL name a path belonging to it, and on a machine this repository is deployed to the package SHALL NOT be installed and no configuration, state, data, or cache directory belonging to it SHALL remain.

It is retired because it was not being used here, and for no other reason: the project is actively maintained, and plain `cd`, the shell's own directory history, and the `mkcd` function cover the navigation it served. Retiring it removes a tool, not a capability, and this requirement is a record of a preference rather than a judgement on the software.

Because zoxide works by installing a shell hook, its removal has a failure mode the other retired tools do not: a shell session started while zoxide was still present keeps the hook function resident in memory after the binary is gone, and prints an error on every directory change. That state belongs to the running session, not to the configuration, and a shell started fresh from this configuration SHALL be free of it.

#### Scenario: No zoxide configuration is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** no tracked path SHALL name zoxide
- **AND** a search of the tracked file contents SHALL find no occurrence of `zoxide`, excluding archived OpenSpec changes, which are a historical record

#### Scenario: No shell startup file initializes it

- **WHEN** the fish startup files under `.config/fish/conf.d/` and the bash startup files are inspected
- **THEN** none SHALL contain a `zoxide init` line or any other invocation of the `zoxide` command

#### Scenario: A fresh shell defines no zoxide hook

- **WHEN** a new fish shell is started from this configuration and a directory is entered
- **THEN** no `__zoxide_hook` or `__zoxide_pwd` function SHALL be defined
- **AND** no error naming zoxide SHALL be printed

#### Scenario: The allowlist no longer names it

- **WHEN** the root ignore file is inspected
- **THEN** no allowlist entry SHALL name a path under `.config/zoxide/` or any other path belonging to the tool

#### Scenario: No leftover state on the machine

- **WHEN** a machine running this configuration is inspected
- **THEN** `.config/zoxide/`, `.local/share/zoxide/`, `.local/state/zoxide/`, and `.cache/zoxide/` SHALL each be absent
- **AND** the database file the tool keeps its directory rankings in SHALL be absent
- **AND** a search of the home directory SHALL find no file belonging to the tool, excluding assets that an unrelated third-party package ships inside its own installation directory

#### Scenario: The package is not installed

- **WHEN** the system package manager is queried for zoxide
- **THEN** it SHALL report the package as not installed
- **AND** `zoxide` SHALL NOT resolve to an executable on `PATH`

#### Scenario: Re-adding it is a deliberate act

- **WHEN** someone wants zoxide back
- **THEN** it SHALL require a change that supersedes this requirement, not merely reinstalling the binary or restoring an init line

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

### Requirement: alacritty is retired

alacritty SHALL NOT be part of this configuration. No configuration for it SHALL be tracked, no allowlist entry SHALL name a path belonging to it, the compositor's configuration SHALL NOT start it or address it from any binding, and on a machine this repository is deployed to the package SHALL NOT be installed and no configuration, state or cache directory belonging to it SHALL remain.

It is retired because the session already has a terminal and never opened this one, and for no other reason: the project is actively maintained and alacritty worked. `.config/niri/config.kdl` binds `Mod+T` to `footclient`, the `terminal-emulator` specification names foot as the session's terminal in client/server form, and no tracked file has ever mentioned alacritty. Retiring it removes a duplicate, not a capability, and this requirement is a record of a preference rather than a judgement on the software.

Its removal has a failure mode the other retired tools do not, and it is the reason the retirement is worth recording rather than simply doing. alacritty's configuration was untracked, so it was never reproduced by a checkout and never reported by `git status` — the tool was invisible to every mechanism this repository uses to know what it configures. A second terminal in that state is not neutral: it needs the same font as the session terminal to render the prompt and the editor correctly, and any setting given to it would live only on the machine it was typed on. Leaving it installed means a terminal that is one keystroke away, looks broken when opened, and cannot be fixed in a way that survives a rebuild.

The configuration being retired carried one binding that has no equivalent elsewhere: `Shift+Return` sending `ESC` followed by carriage return. foot does not gain that binding here, so the sequence is not available in the session's terminal after this change.

#### Scenario: No alacritty configuration is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** no path under `.config/alacritty/` SHALL appear
- **AND** no tracked file SHALL configure it, start it, or name a path belonging to it
- **AND** prose that names it incidentally SHALL NOT violate this, where the naming is a statement about terminals in general rather than a configuration of this one — `.config/nvim/lua/config/keymaps.lua` lists it among the terminals that speak the kitty keyboard protocol, and that remains true and remains permitted

#### Scenario: The allowlist does not name it

- **WHEN** the root ignore file is inspected
- **THEN** no allowlist entry SHALL name `.config/alacritty/alacritty.toml` or any other path under that directory
- **AND** `git check-ignore -v .config/alacritty/alacritty.toml` SHALL report a deny-by-default rule rather than an allowlist exception

#### Scenario: The compositor neither starts it nor addresses it

- **WHEN** `.config/niri/config.kdl` is inspected
- **THEN** no `spawn-at-startup` entry SHALL name it
- **AND** no binding SHALL spawn it

#### Scenario: The package is not installed

- **WHEN** the system package manager is queried for alacritty
- **THEN** it SHALL report the package as not installed
- **AND** `alacritty` SHALL NOT resolve to an executable on `PATH`

#### Scenario: No leftover state on the machine

- **WHEN** a machine running this configuration is inspected
- **THEN** `.config/alacritty/`, `.local/share/alacritty/`, `.local/state/alacritty/` and `.cache/alacritty/` SHALL each be absent
- **AND** a search of the home directory SHALL find no file belonging to the tool, excluding assets that an unrelated third-party package ships inside its own installation directory

#### Scenario: The documentation records that it must stay absent

- **WHEN** the repository's tracked required-software documentation is read
- **THEN** alacritty SHALL be named among the tools that must not be installed
- **AND** the entry SHALL state what serves its purpose instead

#### Scenario: Re-adding it is a deliberate act

- **WHEN** someone wants alacritty back
- **THEN** it SHALL require a new allowlist entry and a change that supersedes this requirement, not merely reinstalling the package and letting it write its configuration again
- **AND** that change SHALL account for the font the terminal needs, so the second terminal does not return in the state this requirement removed it from
