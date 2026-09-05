## ADDED Requirements

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
