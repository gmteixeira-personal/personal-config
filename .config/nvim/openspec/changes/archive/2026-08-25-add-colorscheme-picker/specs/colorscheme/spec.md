## RENAMED Requirements

- FROM: `### Requirement: Rose Pine dark is the active colorscheme`
- TO: `### Requirement: Kanagawa wave is the startup colorscheme`

## MODIFIED Requirements

### Requirement: Kanagawa wave is the startup colorscheme

The kanagawa theme SHALL be installed, and its `wave` dark variant SHALL be the colorscheme applied at startup. No other variant of it is applied by default.

Kanagawa `wave` is the startup colorscheme specifically, not a colorscheme fixed for the lifetime of the session: the user MAY switch to another installed colorscheme while Neovim is running.

Exactly one installed colorscheme SHALL apply itself at startup. Where several colorschemes are installed, no more than one of them may be configured to load eagerly and set the colorscheme, so that which theme wins is determined by the configuration rather than by plugin load order.

Which colorscheme starts SHALL be changeable by moving the eager-load and startup-apply configuration from one installed theme to another, without any theme having to be uninstalled.

#### Scenario: Theme is active after startup

- **WHEN** Neovim has finished starting
- **THEN** the active colorscheme is kanagawa
- **AND** the background is the dark `wave` variant, not a light variant

#### Scenario: Only one theme claims startup

- **WHEN** a contributor looks for what sets the colorscheme at startup
- **THEN** exactly one installed colorscheme is configured to load eagerly and apply itself
- **AND** every other installed colorscheme leaves the startup colorscheme alone

#### Scenario: Changing which theme starts

- **WHEN** a contributor moves the eager-load and startup-apply configuration to a different installed theme
- **THEN** the next session starts in that theme
- **AND** the theme it was moved from remains installed and selectable

### Requirement: The theme is applied before the first frame is drawn

The colorscheme SHALL load during startup ahead of other plugins, not lazily on an event. The user SHALL NOT see default Vim colors followed by a visible repaint into the theme.

#### Scenario: Opening a file directly from the shell

- **WHEN** the user runs `nvim <file>` in a terminal
- **THEN** the first painted frame already uses the startup colorscheme's colors

#### Scenario: A later-loading plugin is themed too

- **WHEN** a plugin whose window opens after startup is opened
- **THEN** its window uses the startup colorscheme's highlight colors, including icon highlight groups

## ADDED Requirements

### Requirement: Further colorschemes are installed without being applied

Colorschemes beyond the startup one SHALL be installable so that they are available to switch to, without any of them being applied at startup and without their presence delaying it. Such a colorscheme SHALL be fetched and kept on disk, and SHALL load only when it is first previewed or selected.

Not being loaded SHALL NOT make a colorscheme invisible: an installed colorscheme SHALL be offered for selection whether or not it has been loaded yet, and selecting one that has not been loaded SHALL load it and apply it in one action, with no separate step required of the user.

The variants a theme provides SHALL each be selectable in their own right, rather than only the theme's default variant.

#### Scenario: Startup is unaffected by the extra themes

- **WHEN** Neovim starts with several colorschemes installed
- **THEN** the first painted frame uses the startup colorscheme
- **AND** no other installed colorscheme has been loaded

#### Scenario: An unloaded theme is still offered

- **WHEN** a colorscheme is installed but has not been loaded in this session
- **AND** the user opens the colorscheme picker
- **THEN** that colorscheme appears in the list

#### Scenario: Selecting an unloaded theme just works

- **WHEN** the user selects a colorscheme whose plugin has not yet loaded
- **THEN** it is loaded and applied
- **AND** no error is raised and no further action is required

#### Scenario: Variants are individually selectable

- **WHEN** an installed theme provides several variants
- **THEN** each variant appears as its own entry in the picker

### Requirement: A colorscheme chosen during a session is not persisted

Switching colorscheme while Neovim is running SHALL affect the running session only. The configuration SHALL NOT write the chosen colorscheme to disk, and no state file SHALL be created or updated by the switch.

Consequently, every Neovim session SHALL start in the configured startup colorscheme regardless of what was chosen in an earlier session. Changing which colorscheme a session starts in SHALL remain an edit to the configuration.

#### Scenario: A switch lasts only for the session

- **WHEN** the user switches to a colorscheme other than the startup one and then restarts Neovim
- **THEN** the new session starts in kanagawa `wave`

#### Scenario: Switching writes nothing

- **WHEN** the user switches colorscheme during a session
- **THEN** no file under the configuration or state directory is created or modified

#### Scenario: Concurrent sessions do not affect each other

- **WHEN** two Neovim instances are running and the user switches colorscheme in one
- **THEN** the other instance's colorscheme is unchanged
