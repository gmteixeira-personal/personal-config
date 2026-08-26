## Purpose

Keeps a working session — the open buffers, the window layout, and where each cursor sat — across closing and reopening the editor, so that returning to a project resumes it instead of rebuilding it, and so that reloading the configuration costs nothing.

## ADDED Requirements

### Requirement: The session is saved automatically when the editor exits

Leaving the editor SHALL write the current session to disk without the user asking. The session SHALL be stored outside every project directory, so that no repository the user opens acquires a session file and nothing needs to be added to a `.gitignore`.

A session SHALL be identified by the working directory it was saved from, and by nothing else. Two directories SHALL have two independent sessions; the same directory SHALL have one session regardless of which git branch is checked out.

#### Scenario: Quitting saves

- **WHEN** the user has files open in a split layout and quits the editor
- **THEN** the session for the current working directory is written to disk
- **AND** no file is created inside the working directory

#### Scenario: Two projects, two sessions

- **WHEN** the user works in one project, quits, then works in a second project and quits
- **THEN** each directory has its own saved session
- **AND** reopening either one restores that directory's layout, not the other's

#### Scenario: Branches share one session

- **WHEN** the user saves a session, checks out a different git branch, and reopens the editor in the same directory
- **THEN** the same session is restored

### Requirement: A saved session records buffers, layout and position

A saved session SHALL record the open buffers, the working directory, the window sizes and positions, the tab pages, the fold state, and the per-window local options, so that a restore reproduces the layout rather than merely reopening a list of files.

The setting that determines this SHALL live in `lua/config/options.lua`, because it governs the editor's own built-in session commands and takes effect with no plugin installed.

#### Scenario: The layout comes back

- **WHEN** the user quits with a vertical split, a horizontal split, and a second tab page open
- **AND** reopens the editor in that directory
- **THEN** the same splits and tab pages are present at the same sizes

#### Scenario: Position comes back

- **WHEN** a session is restored
- **THEN** each restored buffer's cursor is where it was left
- **AND** folds that were closed are still closed

#### Scenario: The setting is a general option

- **WHEN** a contributor looks for what a session records
- **THEN** it is set in `lua/config/options.lua`
- **AND** it is not set in any file under `lua/plugins/`

### Requirement: The session is restored automatically on a bare launch

Starting the editor in a directory with no file argument SHALL restore that directory's saved session, if one exists. Starting the editor with a file argument SHALL NOT restore, so that `nvim <file>` opens that file and nothing else.

A launch in a directory with no saved session SHALL open the ordinary empty start screen and SHALL NOT raise an error.

#### Scenario: Bare launch restores

- **WHEN** the user runs `nvim` with no arguments in a directory that has a saved session
- **THEN** the buffers, windows and cursor positions from that session are restored

#### Scenario: A named file wins

- **WHEN** the user runs `nvim file.txt` in a directory that has a saved session
- **THEN** `file.txt` is opened
- **AND** the saved session is not restored
- **AND** the saved session is left on disk intact

#### Scenario: No session yet

- **WHEN** the user runs `nvim` with no arguments in a directory that has never been saved
- **THEN** the empty start screen appears
- **AND** no error or warning is shown

#### Scenario: Piped or filtered input

- **WHEN** the editor is started reading from standard input rather than opening a directory's own files
- **THEN** no session is restored over that input

### Requirement: Directories where a session is meaningless are excluded

Saving and restoring SHALL both be suppressed in directories where a restored layout would be wrong or surprising: the user's home directory, the filesystem root, and the user's download directory. In a suppressed directory the editor SHALL start empty and SHALL leave no session behind on exit.

#### Scenario: Launching from home

- **WHEN** the user runs `nvim` with no arguments from the home directory
- **THEN** the empty start screen appears
- **AND** on exit no session is saved for the home directory

#### Scenario: A suppressed directory is not silently special

- **WHEN** the user explicitly saves a session from a suppressed directory
- **THEN** the editor reports that this directory is excluded rather than appearing to succeed

### Requirement: Sessions are searched, saved, restored and deleted under `<leader>q`

The session mappings SHALL live under the `<leader>q` prefix, beside the mappings that leave the editor. `<leader>q` SHALL remain unbound as a command in its own right, so that no mapping under it waits out `timeoutlen`. The prefix SHALL provide:

- `<leader>qs` — a search that lists every saved session and restores the selected one,
- `<leader>qW` — a save that writes the current session for the current directory immediately,
- `<leader>qr` — a restore that reloads the current directory's saved session, discarding the current layout,
- `<leader>qd` — a delete that removes the current directory's saved session.

Saving the session is `<leader>qW`, on the shifted key, because `<leader>qw` already writes every modified buffer and quits. The two SHALL stay distinct: neither SHALL do any part of the other's work. Pressing `<leader>qW` SHALL NOT end the editing session, and pressing `<leader>qw` SHALL NOT write a session file beyond whatever the automatic save on exit writes.

Every mapping SHALL carry a description, so each is listed by the key hints. The mappings SHALL be declared with the session plugin's own spec, not in the general keymaps module.

#### Scenario: Searching sessions

- **WHEN** the user presses `<leader>qs`
- **THEN** a fuzzy picker lists the saved sessions by the directory each was saved from
- **AND** selecting one restores it

#### Scenario: Saving by hand

- **WHEN** the user presses `<leader>qW` mid-work
- **THEN** the current session is written immediately
- **AND** the editor keeps working with the same buffers and layout
- **AND** the editor does not quit

#### Scenario: The shifted key is not the quit

- **WHEN** the user presses `<leader>qw`
- **THEN** every modified named buffer is written and the editing session ends, exactly as before this capability existed

#### Scenario: Restoring by hand

- **WHEN** the user has changed the layout and presses `<leader>qr`
- **THEN** the saved layout for this directory replaces the current one

#### Scenario: Deleting the current session

- **WHEN** the user presses `<leader>qd`
- **THEN** this directory's saved session is removed
- **AND** the next bare launch in this directory opens the empty start screen

#### Scenario: Restoring with nothing saved

- **WHEN** the user presses `<leader>qr` in a directory with no saved session
- **THEN** the editor reports that there is no session to restore
- **AND** the current buffers and layout are left untouched

#### Scenario: The prefix still runs nothing

- **WHEN** the user presses `<leader>q` and pauses
- **THEN** no command runs
- **AND** both the quit mappings and the session mappings are listed with their descriptions

### Requirement: A restored session does not resurrect unwanted windows

A restore SHALL reproduce the user's file windows. Windows belonging to transient user interface — a file explorer float, a picker, a completion or hint panel — SHALL NOT be recreated as empty or broken windows by a restore.

#### Scenario: The explorer is not restored as a stale window

- **WHEN** the user quits with a file explorer float open
- **AND** reopens the editor in that directory
- **THEN** the file windows are restored
- **AND** no empty or error-filled window stands in for the float

### Requirement: Everything the capability needs is declared in one plugin file

The plugin, its options, and its `<leader>q` session mappings SHALL all be declared in a single file under `lua/plugins/`, except the general session-contents option named above. Deleting that file SHALL remove automatic saving, automatic restoring, and the four session mappings, and SHALL leave every other mapping in the configuration working exactly as before.

#### Scenario: Removing the capability

- **WHEN** the plugin's file is deleted from `lua/plugins/` and the editor is restarted
- **THEN** no session is saved on exit and none is restored on launch
- **AND** `<leader>qs`, `<leader>qW`, `<leader>qr` and `<leader>qd` are no longer defined
- **AND** `<leader>qq` and `<leader>qw` still quit the editor as they did before
- **AND** every other mapping still works

#### Scenario: The editor's own session commands survive

- **WHEN** the plugin's file is deleted
- **THEN** the built-in `:mksession` still records buffers, layout and folds as configured
