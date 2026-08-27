## Purpose

Shows every file that differs between the working tree and a revision, or between two revisions, in one view -- a list of the files on one side and the selected file's difference side by side on the other -- and provides the three-way view a merge conflict is resolved in.

## ADDED Requirements

### Requirement: The repository's whole difference is toggled from the git prefix

The user SHALL be able to open, from a two-key sequence beginning `<leader>g`, a view of everything that differs between the working tree and the last commit, and to dismiss that view with the **same sequence**. The mapping SHALL have two states and no third: pressing it opens the view where none is open, and closes the view where one is.

Whether the view's file panel is currently shown SHALL NOT affect this. Pressing the sequence with the panel hidden SHALL close the view, exactly as it does with the panel shown, and SHALL NOT open a second view.

That view SHALL show, at the same time:

- a **list of every file that differs**, whether its change is staged, unstaged or untracked, and
- the **difference of the selected file**, its two versions side by side and scroll-bound.

Selecting another file in the list SHALL show that file's difference in the same view, without the user reopening it.

This SHALL be reachable at `<leader>gm`. `<leader>g` SHALL NOT itself be bound as a mapping.

The view SHALL occupy its own tab page, so that opening it leaves the window layout the user was working in intact and closing it returns them to that layout.

#### Scenario: Opening over a repository with several changed files

- **WHEN** the working directory is a git repository with more than one file changed
- **AND** the user presses `<leader>gm`
- **THEN** a view opens listing every file that differs from the last commit
- **AND** the difference of one of them is shown with its two versions side by side
- **AND** the differing lines are highlighted in both

#### Scenario: Moving between files

- **WHEN** the view is open and the user selects a different file in the list
- **THEN** that file's difference replaces the one displayed
- **AND** the list remains visible with the new selection marked

#### Scenario: Staged and unstaged changes are both listed

- **WHEN** one file has staged changes, another has unstaged changes, and a third is untracked
- **AND** the user opens the view
- **THEN** all three are listed
- **AND** the list distinguishes which of them are staged

#### Scenario: Dismissing the view with the same key

- **WHEN** the view is open and the user presses `<leader>gm`
- **THEN** the view closes
- **AND** no second view is opened

#### Scenario: Toggling with the file panel hidden

- **WHEN** the view is open and the user has hidden its file panel
- **AND** the user presses `<leader>gm`
- **THEN** the view closes
- **AND** no second view is opened

#### Scenario: Toggling from a buffer opened out of the view

- **WHEN** the view is open and the user has jumped from it to a file, leaving the view behind them
- **AND** the user presses `<leader>gm`
- **THEN** the view closes
- **AND** no second view is opened

#### Scenario: The editing layout is left alone

- **WHEN** the user has a split layout open and presses `<leader>gm`
- **THEN** the view opens without disturbing that layout
- **AND** pressing `<leader>gm` again returns the user to it with the same buffers and cursor positions

#### Scenario: Opening over a clean repository

- **WHEN** the working directory is a git repository with nothing changed
- **AND** the user opens the view
- **THEN** the view opens with an empty file list
- **AND** no error is raised

#### Scenario: Opening outside a git repository

- **WHEN** the working directory is not inside a git repository
- **AND** the user presses `<leader>gm`
- **THEN** the user is told the directory is not a git repository
- **AND** no error trace is shown and the editor remains usable

### Requirement: One file's difference is toggled from the git prefix

The user SHALL be able to open the difference between the file in the current buffer and the last commit, from a two-key sequence beginning `<leader>g`, and to dismiss it with the same sequence. It SHALL be reachable at `<leader>gd` and SHALL behave as the repository diff's mapping does — two states, decided independently of whether a panel is shown.

The two versions SHALL be shown side by side, scroll-bound, with the differing lines highlighted in both.

The file panel SHALL NOT be shown for this view. It would list exactly one file, whose name is already on screen.

This and the repository-wide view SHALL be independent: neither mapping SHALL dismiss the other's view.

Where the current buffer has no file behind it, pressing the sequence SHALL report that and open nothing.

#### Scenario: Opening one file's difference

- **WHEN** the user has modified a file tracked by git
- **AND** presses `<leader>gd`
- **THEN** the file's difference from the last commit opens with the two versions side by side
- **AND** the differing lines are highlighted in both
- **AND** no file panel is shown

#### Scenario: Dismissing it with the same key

- **WHEN** the view is open and the user presses `<leader>gd`
- **THEN** the view closes
- **AND** no second view is opened

#### Scenario: The one-file and every-file views are independent

- **WHEN** one file's difference is open and the user presses `<leader>gm`
- **THEN** the one-file view is not closed
- **AND** the repository-wide view opens

#### Scenario: A buffer with no file behind it

- **WHEN** the current buffer has no file behind it
- **AND** the user presses `<leader>gd`
- **THEN** the user is told there is no file to diff
- **AND** no view is opened
- **AND** no error is raised

### Requirement: An open view can be refreshed

The user SHALL be able to ask an open view to re-read the repository, from a two-key sequence beginning `<leader>g`, for the case where the repository changed underneath it without the view noticing. This SHALL be reachable at `<leader>gr`.

This SHALL NOT be a toggle: it acts on a view that is already open and SHALL open nothing where none is.

#### Scenario: Refreshing after a change made outside the editor

- **WHEN** a view is open and the repository is changed by something outside the editor
- **AND** the user presses `<leader>gr`
- **THEN** the view re-reads the repository and shows the change

#### Scenario: Refreshing with no view open

- **WHEN** no view is open and the user presses `<leader>gr`
- **THEN** nothing is opened
- **AND** no error is raised

### Requirement: A file's history is toggled from the git prefix

The user SHALL be able to open, from a two-key sequence beginning `<leader>g`, the history of the file in the current buffer: the commits that touched it, and for the selected commit the difference that commit made to it. The same sequence SHALL dismiss that view.

This SHALL be reachable at `<leader>gh`, and SHALL behave as the repository diff's mapping does — two states, decided independently of whether the view's panel is shown.

The two SHALL be independent: the history mapping SHALL NOT dismiss the repository diff, and the repository diff's mapping SHALL NOT dismiss the history.

#### Scenario: Opening a file's history

- **WHEN** the user is editing a file with more than one commit behind it
- **AND** presses `<leader>gh`
- **THEN** a view opens listing the commits that touched that file
- **AND** selecting one shows the difference that commit made

#### Scenario: Dismissing the history with the same key

- **WHEN** the history view is open and the user presses `<leader>gh`
- **THEN** the view closes
- **AND** no second view is opened

#### Scenario: The two views do not dismiss each other

- **WHEN** the history view is open and the user presses `<leader>gm`
- **THEN** the history view is not closed
- **AND** the repository diff opens

### Requirement: A merge conflict is resolved from a three-way view

Where a file is conflicted, the user SHALL be able to open it in a view showing **both sides of the conflict and the working file** at once, and to take either side's version of a conflicted region into the working file from within that view.

Resolving every region SHALL leave the working file free of conflict markers, and the result SHALL be an ordinary edit of that file which the user can then stage.

#### Scenario: Resolving a conflicted file

- **WHEN** a merge has left a file with conflicting regions
- **AND** the user opens that file in the conflict view
- **THEN** the two conflicting versions and the working file are shown together
- **AND** the user can take either version of a region into the working file
- **AND** doing so for every region leaves the file with no conflict markers

#### Scenario: Moving between conflicting regions

- **WHEN** a conflicted file has more than one conflicting region
- **AND** the user asks for the next one
- **THEN** the cursor moves to it with all sides staying aligned

### Requirement: The view's own keys are discoverable from inside it

The view SHALL respond to keys of its own that exist only while it is focused, and it SHALL provide a way -- from inside the view, without consulting documentation -- to list those keys with what each one does.

Those keys SHALL exist only in that view: they SHALL NOT change the meaning of any key in an ordinary editing buffer.

#### Scenario: Listing the view's keys

- **WHEN** the view is focused and the user asks it for help
- **THEN** the keys the view responds to are listed with a description of each

#### Scenario: The keys are confined to the view

- **WHEN** the user leaves the view for an ordinary buffer
- **THEN** the keys the view responded to have their ordinary meaning again

### Requirement: Closing a view leaves the buffer list as it found it

A view loads a buffer for each file it shows, and reading several files in one SHALL NOT leave a buffer per file behind. When the last view closes, every buffer the views loaded SHALL be dropped from the buffer list.

Buffers the user already had open SHALL NOT be dropped, whatever a view did with them. A buffer with unsaved changes, or one displayed in a window, SHALL NOT be dropped either.

#### Scenario: Reading several files in a view

- **WHEN** the user opens a view and moves through several of its files
- **AND** then closes the view
- **THEN** none of those files remains in the buffer list
- **AND** cycling buffers does not reach them

#### Scenario: The user's own buffers are left alone

- **WHEN** the user has files open, including one left hidden
- **AND** opens a view that shows some of the same files, then closes it
- **THEN** the buffers the user opened are all still listed

#### Scenario: An edited file is kept

- **WHEN** a file the view loaded has been edited and not written
- **AND** the user closes the view
- **THEN** that buffer is still listed and its changes are intact

### Requirement: A view open at quit does not reach the saved session

Quitting with a view open SHALL save a session describing what the user was editing, and nothing the view brought in. Neither the view's own buffers nor the files it loaded to show a difference SHALL be restored on the next launch unless the user was editing them independently of it.

Where the user was editing nothing, quitting with a view open SHALL leave no session to restore.

#### Scenario: Quitting with a view open over files being edited

- **WHEN** the user is editing one or more files, opens a view, and quits
- **AND** they later launch the editor again in the same directory
- **THEN** the session restores the files they were editing
- **AND** no window is stood up for the view or for anything it loaded
- **AND** no error is raised

#### Scenario: Quitting with a view open and nothing being edited

- **WHEN** the user opens the editor with no file, opens a view, and quits
- **AND** they later launch the editor again in the same directory
- **THEN** nothing is restored
- **AND** the file the view was showing is not reopened
- **AND** no error is raised
