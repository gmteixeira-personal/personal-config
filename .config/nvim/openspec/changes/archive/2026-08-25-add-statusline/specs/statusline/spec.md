## Purpose

Gives the editor a status line that answers, without the user asking, what mode they are in, which file they are looking at and whether it has unsaved changes, which branch they are on, what the language server thinks of the file, where the cursor sits in it, and whether a macro is being recorded — repainted to match whichever colorscheme is in force.

## ADDED Requirements

### Requirement: The status line reports the editor's state rather than the file's name alone

The editor's status line SHALL be replaced by one that reports, for the focused window:

- the editing mode in force
- the checked-out git branch, and a summary of the working tree's changes, where the file is inside a repository
- the number of diagnostics against the buffer, counted separately by severity
- the file's name, with a distinct indicator when the buffer has unsaved changes and a distinct indicator when it cannot be written
- the file's type
- the cursor's position, and its progress through the file

Where a given piece of information does not apply — no repository, no diagnostics, no filetype — it SHALL be omitted rather than shown empty or as a placeholder, and no error SHALL be raised.

The precise ordering, separators, and symbols are the status line component's own and are NOT fixed by this capability.

#### Scenario: Mode is named

- **WHEN** the user is in normal mode
- **THEN** the status line names the mode

#### Scenario: Mode changes are reflected

- **WHEN** the user presses `i` and then `<Esc>`
- **THEN** the status line names insert mode and then normal mode again

#### Scenario: A file in a repository

- **WHEN** the user opens a file tracked in a git repository
- **THEN** the status line shows the checked-out branch's name

#### Scenario: A file outside a repository

- **WHEN** the user opens a file that is not inside a git repository
- **THEN** no branch is shown
- **AND** no error is raised

#### Scenario: A file with diagnostics

- **WHEN** the focused buffer has diagnostics of more than one severity
- **THEN** the status line shows a count for each severity

#### Scenario: A file with no diagnostics

- **WHEN** nothing reports diagnostics against the focused buffer
- **THEN** no diagnostic counts are shown

#### Scenario: An edited file

- **WHEN** the user types into a buffer without writing it
- **THEN** an unsaved-changes indicator appears

#### Scenario: Writing the file

- **WHEN** the user writes the buffer
- **THEN** the unsaved-changes indicator disappears

#### Scenario: A read-only file

- **WHEN** the user opens a file that cannot be written
- **THEN** a read-only indicator is shown

#### Scenario: Position in the file

- **WHEN** the user moves the cursor to another line
- **THEN** the status line reports the new position

### Requirement: A macro recording in progress is visible

While a macro is being recorded, the status line SHALL show that a recording is in progress, and SHALL name the register it is being recorded into. When recording stops, that indication SHALL disappear.

This is what satisfies the `message-ui` requirement that a recording remain visible to the user. The messages the editor emits about its mode are routed away from the floating views that capability installs, so the status line is where they SHALL surface instead.

#### Scenario: Starting a recording

- **WHEN** the user presses `q` followed by a register name in normal mode
- **THEN** the status line shows that a recording is in progress
- **AND** it names that register

#### Scenario: Stopping a recording

- **WHEN** the user presses `q` again to end the recording
- **THEN** the indication is no longer shown

#### Scenario: A recording is not silent

- **WHEN** the user begins recording a macro
- **THEN** the editor gives some visible sign of it
- **AND** the user does not have to run a command to discover that recording is active

### Requirement: The status line follows the active colorscheme

The status line's colours SHALL be those of the colorscheme in force. When the user changes colorscheme, the status line SHALL repaint in the new one, with no restart, no command, and no further action.

This SHALL hold for every installed colorscheme and for every variant of one, including two variants of the same theme, which SHALL be distinguishable from each other. It SHALL also hold for a colorscheme installed later that ships no status line palette of its own: in that case the colours SHALL be derived from the colorscheme's own highlights rather than falling back to a fixed palette unrelated to it.

The colours SHALL be correct in the first frame drawn at startup, not applied after a visible repaint.

#### Scenario: Switching theme

- **WHEN** the user accepts a different colorscheme in the theme switcher
- **THEN** the status line repaints in that colorscheme's colours
- **AND** no restart or further command is needed

#### Scenario: Switching between variants of one theme

- **WHEN** the user switches from one variant of a theme to another variant of the same theme
- **THEN** the status line's colours change to the second variant's

#### Scenario: A theme with no status line palette

- **WHEN** the user selects a colorscheme that ships no palette for the status line
- **THEN** the status line is coloured from that colorscheme's own highlights
- **AND** it is not left in the colours of the previous theme or of an unrelated default

#### Scenario: The first frame is themed

- **WHEN** the editor starts
- **THEN** the status line is drawn in the startup colorscheme's colours
- **AND** the user does not see it repaint from other colours

#### Scenario: A theme chosen in an earlier session

- **WHEN** the editor starts on a machine where a colorscheme was accepted previously
- **THEN** the status line is drawn in that colorscheme's colours

### Requirement: The capability is configured no further than it needs to be

Beyond making a recording visible, this capability SHALL take the status line component's own defaults rather than restating them. It SHALL NOT fix the sections' contents or ordering, the separators, or the icon set, so that upstream's changes to those arrive with an update instead of being pinned here.

It SHALL NOT change how many status lines the editor draws: each window SHALL keep its own, exactly as before this capability existed.

#### Scenario: Windows keep their own status lines

- **WHEN** the user splits the window
- **THEN** each split carries its own status line

#### Scenario: Defaults are not restated

- **WHEN** a contributor reads this capability's configuration
- **THEN** the only presentation choice it makes is the recording indicator
- **AND** the sections, separators, and icons are the component's defaults

### Requirement: The capability adds no icon provider and is declared in its own file

Everything this capability needs SHALL be declared in a single file under `lua/plugins/`, and SHALL NOT appear in the general keymaps or options modules. Deleting that file SHALL remove the status line entirely, returning the editor to the one it draws by default.

The capability SHALL take its icons from the icon provider this configuration already installs. It SHALL NOT install a second one.

#### Scenario: Locating the configuration

- **WHEN** a contributor looks for where the status line is defined
- **THEN** it is declared in one file under `lua/plugins/`

#### Scenario: Removing the capability

- **WHEN** that plugin file is deleted and the editor is restarted
- **THEN** the editor's default status line is drawn again
- **AND** no other behaviour changes

#### Scenario: One icon provider

- **WHEN** the configuration's installed plugins are listed
- **THEN** only the existing icon provider is present
- **AND** no second one was added for the status line
