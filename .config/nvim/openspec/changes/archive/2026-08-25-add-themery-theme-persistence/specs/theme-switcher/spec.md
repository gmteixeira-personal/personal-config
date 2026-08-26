## Purpose

Lets the user browse every installed colorscheme, judge each one against real code before committing to it, and have the accepted choice survive into every later session without editing the configuration.

## ADDED Requirements

### Requirement: One mapping opens the theme switcher

Pressing `<leader>ft` in normal mode SHALL open the theme switcher. Typing SHALL narrow the list by matching against colorscheme names, and the list SHALL update as each further character is typed.

The mapping SHALL be declared in the theme switcher's own plugin file, and `<leader>f` SHALL remain unbound as a mapping in its own right, so that no `<leader>f`-prefixed mapping waits on a key-sequence timeout. Deleting that plugin file SHALL remove the mapping with it, leaving no reference to the switcher anywhere else in the configuration.

#### Scenario: Opening the switcher

- **WHEN** the user presses `<leader>ft` in normal mode
- **THEN** a list of the available colorschemes opens

#### Scenario: Narrowing by name

- **WHEN** the user opens the switcher and types a fragment of a colorscheme's name
- **THEN** the list narrows to colorschemes whose names match that fragment

#### Scenario: The find prefix still does not stall

- **WHEN** the user presses `<leader>f`
- **THEN** nothing is executed and no action is deferred pending a timeout
- **AND** the editor waits for the next key of the sequence

### Requirement: The list is discovered, never enumerated

The colorschemes offered SHALL be determined by inspecting what is installed, not by a list maintained in the configuration. Installing a theme SHALL therefore make it selectable with no further edit, and uninstalling one SHALL remove it from the list with no further edit.

Discovery SHALL cover colorschemes whose plugin has not been loaded in this session. A theme installed but never loaded SHALL be offered exactly like a loaded one, and it SHALL NOT be necessary to load a theme eagerly in order for it to appear.

Every variant a theme provides SHALL be offered as its own entry, rather than only the theme's default variant.

#### Scenario: Adding a theme adds an entry

- **WHEN** a contributor installs a further colorscheme and restarts Neovim
- **AND** the user opens the theme switcher
- **THEN** that colorscheme's variants appear in the list
- **AND** no list of theme names was edited anywhere in the configuration

#### Scenario: An unloaded theme is still offered

- **WHEN** a colorscheme is installed but its plugin has not been loaded in this session
- **AND** the user opens the theme switcher
- **THEN** that colorscheme appears in the list

#### Scenario: Selecting an unloaded theme just works

- **WHEN** the user selects a colorscheme whose plugin has not yet loaded
- **THEN** it is loaded and applied
- **AND** no error is raised and no further action is required

#### Scenario: Variants are individually selectable

- **WHEN** an installed theme provides several variants
- **THEN** each variant appears as its own entry

### Requirement: The editor's bundled colorschemes are excluded

Colorschemes that ship with Neovim itself SHALL NOT appear in the theme switcher, so the list holds only the colorschemes this configuration installs. Which names count as bundled SHALL be determined from the running Neovim's own runtime files rather than from a list written into the configuration, so that the exclusion stays correct when Neovim adds or removes a bundled colorscheme.

Excluding a bundled colorscheme from the list SHALL NOT make it unavailable: it remains applicable by Neovim's own `:colorscheme` command.

#### Scenario: Only installed themes are listed

- **WHEN** the user opens the theme switcher
- **THEN** every entry belongs to a colorscheme installed by this configuration
- **AND** none of Neovim's bundled colorschemes is listed

#### Scenario: The exclusion tracks the running Neovim

- **WHEN** the running Neovim's set of bundled colorschemes differs from the set on another machine or another version
- **THEN** the entries excluded are those bundled by the Neovim actually running
- **AND** no edit to the configuration is needed to keep the exclusion correct

#### Scenario: A bundled colorscheme is still reachable

- **WHEN** the user applies a bundled colorscheme with `:colorscheme`
- **THEN** it is applied normally

### Requirement: The list previews live

Whenever the selection moves to a different entry, that colorscheme SHALL be applied to the visible buffer immediately, so a theme is judged against real code rather than against a name.

Dismissing the switcher without accepting an entry SHALL restore the colorscheme that was active before it opened, and SHALL leave nothing persisted.

#### Scenario: Stepping through themes

- **WHEN** a file is open and the user opens the switcher and moves the selection down the list
- **THEN** the buffer repaints in the highlighted colorscheme as each entry becomes selected
- **AND** the buffer's contents and the cursor position are unchanged

#### Scenario: Backing out restores the previous theme

- **WHEN** the user has previewed one or more colorschemes and then dismisses the switcher
- **THEN** the colorscheme active before it opened is active again
- **AND** the persisted selection is unchanged

### Requirement: An accepted theme persists across restarts

Accepting an entry SHALL leave that colorscheme active for the session AND record it, so that every later Neovim session starts in it. Recording SHALL require no action from the user beyond accepting the entry, and SHALL NOT require restarting Neovim to take effect.

Accepting a further theme later SHALL replace the recorded one rather than accumulate. Changing the colorscheme by any means other than accepting an entry in the switcher — Neovim's own `:colorscheme` command, for example — SHALL NOT change what is recorded.

#### Scenario: A choice survives a restart

- **WHEN** the user accepts a colorscheme in the switcher and then restarts Neovim
- **THEN** the new session starts in that colorscheme

#### Scenario: Accepting again replaces the choice

- **WHEN** the user accepts one colorscheme, then later accepts a different one, then restarts Neovim
- **THEN** the new session starts in the second colorscheme

#### Scenario: Applying a theme by command does not persist it

- **WHEN** the user applies a colorscheme with `:colorscheme` and then restarts Neovim
- **THEN** the new session starts in the last colorscheme accepted in the switcher, not the one applied by command

### Requirement: The recorded choice is machine-local and untracked

The recorded selection SHALL be held in a file that version control ignores, so that accepting a theme never leaves the configuration's working tree modified and a theme choice is never carried between machines by a clone or a pull.

The configuration SHALL work with that file absent. Where it does not exist — a fresh clone, or a working tree that has been cleaned — startup SHALL proceed with the default colorscheme named by `colorscheme` and no error SHALL be raised.

#### Scenario: Switching leaves the working tree clean

- **WHEN** the user accepts a colorscheme in the switcher
- **AND** the configuration's version control status is inspected
- **THEN** no tracked file is reported as modified

#### Scenario: A clone carries no theme choice

- **WHEN** the configuration is cloned to a machine that has never run it
- **AND** Neovim is started
- **THEN** the default colorscheme is applied
- **AND** no error is raised about the missing selection

#### Scenario: Pulling does not overwrite a local choice

- **WHEN** the user has accepted a colorscheme
- **AND** later pulls changes into the configuration
- **THEN** the accepted colorscheme is still what the next session starts in
- **AND** the pull reported no conflict over it
