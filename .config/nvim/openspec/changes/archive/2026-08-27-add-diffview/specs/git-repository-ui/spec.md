## MODIFIED Requirements

### Requirement: A repository status view opens from the git prefix

The user SHALL be able to open, from a two-key sequence beginning `<leader>g`, a view of the git repository containing the current working directory, and to dismiss it with the **same sequence**. The mapping SHALL have two states and no third: pressing it opens the view where none is open, and closes it where one is.

That view SHALL show the state of the whole repository rather than of one buffer, listing at least:

- the files with **unstaged** changes,
- the files with **staged** changes,
- the files that are **untracked**,
- the current **branch** and its relationship to its upstream.

The view SHALL reflect the repository as it is at the moment it is opened, and SHALL update to reflect changes made through it without the user reopening it.

This SHALL be reachable at `<leader>gg`. `<leader>g` SHALL NOT itself be bound as a mapping, so that no sequence under it waits out a key-sequence timeout.

Dismissing and reopening the view SHALL return the user to where they left off in it — the same position in the list, with the same sections expanded — rather than to the top.

#### Scenario: Opening the view over a dirty repository

- **WHEN** the working directory is a git repository with modified, staged and untracked files
- **AND** the user presses `<leader>gg`
- **THEN** the modified files are listed as unstaged
- **AND** the staged files are listed as staged
- **AND** the untracked files are listed as untracked
- **AND** the current branch is shown

#### Scenario: Opening the view over a clean repository

- **WHEN** the working directory is a git repository with nothing to commit
- **AND** the user opens the status view
- **THEN** the view opens and reports that there is nothing to stage or commit
- **AND** no error is raised

#### Scenario: Dismissing the view with the same key

- **WHEN** the status view is open and the user presses `<leader>gg`
- **THEN** the view closes
- **AND** the user is returned to the buffer they were editing

#### Scenario: Reopening returns to where the user left off

- **WHEN** the user has scrolled the status view and expanded one of its sections
- **AND** dismisses it and presses `<leader>gg` again
- **THEN** the view reopens at the position it was left at
- **AND** the section that was expanded is still expanded

#### Scenario: The view follows what is done through it

- **WHEN** the status view is open and the user stages a listed file through it
- **THEN** that file moves from the unstaged list to the staged list in the same view
- **AND** the user does not have to close and reopen the view to see it

#### Scenario: No mapping stalls on the git prefix

- **WHEN** the user presses `<leader>g`
- **THEN** nothing is executed and no action is deferred pending a timeout
- **AND** the editor waits for the next key of the sequence

## REMOVED Requirements

### Requirement: The window arrangement is chosen at the moment of opening

**Reason**: The four mappings that made placement a keystroke — `<leader>gg` automatic, `<leader>gr` replace, `<leader>gv` vertical split, `<leader>gh` horizontal split — cost four of the ten two-key sequences under `<leader>g` to express a choice that is reconsidered far less often than a diff is opened. Three of those keys now carry diff views, which are pressed constantly. The status buffer is a tall list and replacing the current window is the arrangement that suits it, so `<leader>gg` does that and does not ask.

**Migration**: `<leader>gg` opens the view in place of the current window, which is what `<leader>gr` did. Every other arrangement remains reachable by asking for it outright: `:Neogit kind=auto`, `:Neogit kind=vsplit`, `:Neogit kind=split`, `:Neogit kind=tab`.

## ADDED Requirements

### Requirement: A change listed in the status view opens in the dedicated diff view

From the status view the user SHALL be able to hand a listed change to the repository diff view, rather than only expanding it inline. This SHALL be available for at least:

- the entry under the cursor, whether that is a file or a whole section,
- an arbitrary **range between two revisions**, where the available revisions are offered as choices rather than typed from memory,
- a **single commit** selected from the log.

Expanding an entry in place SHALL continue to work as it does. The dedicated view is an additional way to read a change, not a replacement for the inline one.

#### Scenario: Opening the entry under the cursor

- **WHEN** the status view lists a changed file and the cursor is on it
- **AND** the user asks for it in the diff view
- **THEN** that file's difference opens in the dedicated view
- **AND** the status view is left as it was to return to

#### Scenario: Opening a range between revisions

- **WHEN** the user asks the status view for the difference between two revisions
- **THEN** the repository's branches, tags and the current commit are offered as choices
- **AND** selecting two of them opens every file differing between them in the dedicated view

#### Scenario: Expanding in place still works

- **WHEN** the user expands a listed entry in the status view
- **THEN** the change that entry represents is displayed inline as before
- **AND** nothing is staged, discarded or committed by displaying it

### Requirement: A conflicted file is staged by resolving it

Where the status view lists a file as conflicted, asking to stage it SHALL open that file in the three-way conflict view rather than refusing. Once every conflicting region has been resolved and the view is closed, the file SHALL be staged without the user asking a second time.

Where the file is closed still conflicted, it SHALL NOT be staged, and the status view SHALL continue to list it as conflicted.

#### Scenario: Staging a conflicted file resolves it first

- **WHEN** a merge has left a file conflicted and the status view lists it as such
- **AND** the user asks to stage it
- **THEN** the file opens in the three-way conflict view
- **AND** resolving every region and closing the view stages the file
- **AND** the status view lists it as staged

#### Scenario: Leaving a conflict unresolved

- **WHEN** the user opens a conflicted file from the status view and closes it with regions still unresolved
- **THEN** the file is not staged
- **AND** the status view still lists it as conflicted
- **AND** no error is raised
