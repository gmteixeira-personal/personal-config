## Purpose

Sets the editor's visual theme and guarantees it is applied early enough in startup that the user never sees an unstyled frame.

## ADDED Requirements

### Requirement: Rose Pine dark is the active colorscheme

The rose-pine theme SHALL be installed and active, using its `main` dark variant. Neither of the other variants is applied by default.

#### Scenario: Theme is active after startup

- **WHEN** Neovim has finished starting
- **THEN** the active colorscheme is rose-pine
- **AND** the background is the dark `main` variant, not the light variant

### Requirement: The theme is applied before the first frame is drawn

The colorscheme SHALL load during startup ahead of other plugins, not lazily on an event. The user SHALL NOT see default Vim colors followed by a visible repaint into the theme.

#### Scenario: Opening a file directly from the shell

- **WHEN** the user runs `nvim <file>` in a terminal
- **THEN** the first painted frame already uses rose-pine colors

#### Scenario: A later-loading plugin is themed too

- **WHEN** a plugin whose window opens after startup is opened
- **THEN** its window uses rose-pine highlight colors, including icon highlight groups

### Requirement: True color is enabled

The configuration SHALL enable 24-bit color, since the theme's palette cannot be represented in a 256-color terminal palette.

#### Scenario: Colors render as specified

- **WHEN** Neovim runs in a terminal that supports 24-bit color
- **THEN** theme colors render at their exact palette values rather than being approximated
