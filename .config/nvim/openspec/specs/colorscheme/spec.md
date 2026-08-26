## Purpose

Sets the editor's visual theme and guarantees it is applied early enough in startup that the user never sees an unstyled frame.
## Requirements
### Requirement: The theme is applied before the first frame is drawn

The colorscheme SHALL load during startup ahead of other plugins, not lazily on an event. The user SHALL NOT see default Vim colors followed by a visible repaint into the theme.

#### Scenario: Opening a file directly from the shell

- **WHEN** the user runs `nvim <file>` in a terminal
- **THEN** the first painted frame already uses the startup colorscheme's colors

#### Scenario: A later-loading plugin is themed too

- **WHEN** a plugin whose window opens after startup is opened
- **THEN** its window uses the startup colorscheme's highlight colors, including icon highlight groups

### Requirement: True color is enabled

The configuration SHALL enable 24-bit color, since the theme's palette cannot be represented in a 256-color terminal palette.

#### Scenario: Colors render as specified

- **WHEN** Neovim runs in a terminal that supports 24-bit color
- **THEN** theme colors render at their exact palette values rather than being approximated

### Requirement: Kanagawa wave is the default colorscheme

The kanagawa theme SHALL be installed, and its `wave` dark variant SHALL be the colorscheme applied at startup where no other has been chosen. No other variant of it is applied by default.

Kanagawa `wave` is a default, not a colorscheme fixed for the lifetime of the configuration: once the user has chosen another installed colorscheme, that one starts instead, per the persistence requirement in `theme-switcher`. The default applies on a machine where nothing has been chosen yet, and wherever the recorded choice is absent.

No installed colorscheme SHALL apply itself at startup. Applying the startup colorscheme — whether the default or a recorded choice — SHALL be done in exactly one place, so that which theme wins is determined by the configuration rather than by plugin load order. Every theme plugin SHALL therefore be a bare install that sets no colorscheme of its own.

Changing the default SHALL be an edit in that one place, naming a different installed colorscheme, without any theme having to be uninstalled and without editing any theme's own plugin file.

#### Scenario: Theme is active after startup

- **WHEN** Neovim has finished starting on a machine where no colorscheme has been chosen
- **THEN** the active colorscheme is kanagawa
- **AND** the background is the dark `wave` variant, not a light variant

#### Scenario: No theme claims startup for itself

- **WHEN** a contributor opens any installed theme's plugin file
- **THEN** it neither loads eagerly nor applies a colorscheme
- **AND** exactly one file in the configuration applies the startup colorscheme

#### Scenario: Changing the default

- **WHEN** a contributor changes the default named in that one place to a different installed colorscheme
- **AND** no choice has been recorded on that machine
- **THEN** the next session starts in the new default
- **AND** the theme it was changed from remains installed and selectable

#### Scenario: A recorded choice outranks the default

- **WHEN** the user has chosen a colorscheme other than the default
- **AND** Neovim is restarted
- **THEN** the session starts in the chosen colorscheme, not kanagawa `wave`

### Requirement: Further colorschemes are installed without being applied

Colorschemes beyond the default SHALL be installable so that they are available to switch to, without any of them being applied at startup and without their presence delaying it. Such a colorscheme SHALL be fetched and kept on disk, and SHALL load only when it is first previewed or applied.

Not being loaded SHALL NOT make a colorscheme unavailable: an installed colorscheme SHALL be applicable whether or not it has been loaded yet, and applying one that has not been loaded SHALL load it and apply it in one action, with no separate step required of the user. How such a colorscheme is offered for selection is specified by `theme-switcher`.

#### Scenario: Startup is unaffected by the extra themes

- **WHEN** Neovim starts with several colorschemes installed
- **THEN** the first painted frame uses the startup colorscheme
- **AND** no other installed colorscheme has been loaded

#### Scenario: Applying an unloaded theme just works

- **WHEN** a colorscheme whose plugin has not yet loaded is applied
- **THEN** it is loaded and applied
- **AND** no error is raised and no further action is required

