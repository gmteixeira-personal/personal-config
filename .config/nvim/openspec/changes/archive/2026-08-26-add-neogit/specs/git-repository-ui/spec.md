## Purpose

Gives the user a view of the whole repository — every file that differs from the index or the last commit, in one place — and makes the operations that act on the repository rather than on a single buffer (committing, branching, fetching, pulling, pushing, rebasing, stashing, reading the log) reachable from inside the editor.

## ADDED Requirements

### Requirement: A repository status view opens from the git prefix

The user SHALL be able to open, from a two-key sequence beginning `<leader>g`, a view of the git repository containing the current working directory. That view SHALL show the state of the whole repository rather than of one buffer, listing at least:

- the files with **unstaged** changes,
- the files with **staged** changes,
- the files that are **untracked**,
- the current **branch** and its relationship to its upstream.

The view SHALL reflect the repository as it is at the moment it is opened, and SHALL update to reflect changes made through it without the user reopening it.

`<leader>g` SHALL NOT itself be bound as a mapping, so that no sequence under it waits out a key-sequence timeout.

#### Scenario: Opening the view over a dirty repository

- **WHEN** the working directory is a git repository with modified, staged and untracked files
- **AND** the user opens the status view
- **THEN** the modified files are listed as unstaged
- **AND** the staged files are listed as staged
- **AND** the untracked files are listed as untracked
- **AND** the current branch is shown

#### Scenario: Opening the view over a clean repository

- **WHEN** the working directory is a git repository with nothing to commit
- **AND** the user opens the status view
- **THEN** the view opens and reports that there is nothing to stage or commit
- **AND** no error is raised

#### Scenario: The view follows what is done through it

- **WHEN** the status view is open and the user stages a listed file through it
- **THEN** that file moves from the unstaged list to the staged list in the same view
- **AND** the user does not have to close and reopen the view to see it

#### Scenario: No mapping stalls on the git prefix

- **WHEN** the user presses `<leader>g`
- **THEN** nothing is executed and no action is deferred pending a timeout
- **AND** the editor waits for the next key of the sequence

### Requirement: The window arrangement is chosen at the moment of opening

Opening the status view SHALL be available in four distinct arrangements, each on its own mapping, so that the user picks how the view is placed at the moment they ask for it rather than from a fixed setting:

- `<leader>gg` — the arrangement is chosen **automatically** from the space available.
- `<leader>gr` — the view **replaces** the current window's contents, using the whole of that window.
- `<leader>gv` — the view opens in a new **vertical** split.
- `<leader>gh` — the view opens in a new **horizontal** split.

All four SHALL open the same view, differing only in placement. Closing the view SHALL leave the user with the window layout and the buffer they had before opening it.

#### Scenario: Letting the editor choose

- **WHEN** the user presses `<leader>gg`
- **THEN** the status view opens in an arrangement chosen from the space available
- **AND** the view shown is the same one the other three mappings open

#### Scenario: Replacing the current window

- **WHEN** the user is editing a file and presses `<leader>gr`
- **THEN** the status view occupies the window that file was in
- **AND** no new window is created
- **AND** closing the view returns that window to the file

#### Scenario: Opening beside the current window

- **WHEN** the user presses `<leader>gv`
- **THEN** a new vertical split is created for the status view
- **AND** the window the user came from remains open showing its buffer

#### Scenario: Opening above or below the current window

- **WHEN** the user presses `<leader>gh`
- **THEN** a new horizontal split is created for the status view
- **AND** the window the user came from remains open showing its buffer

#### Scenario: Layout is restored on close

- **WHEN** the user has a split layout, opens the status view in any arrangement, and then closes it
- **THEN** the layout and buffers they had before opening it are restored

### Requirement: Changes are staged and committed from the view

From the status view the user SHALL be able to, without leaving it:

- **Stage** and **unstage** a listed file, a block of changed lines within it, or everything at once.
- **Discard** a listed change.
- **Inspect** the change a listed entry represents before acting on it.
- **Commit** what is staged, composing the message in the editor, and **amend** the previous commit.

Staging performed here SHALL act on the same git index as the buffer-local hunk operations, so that work staged by either route is visible to the other.

#### Scenario: Staging one file of several

- **WHEN** three files are listed as unstaged and the user stages one of them
- **THEN** that file moves to the staged list
- **AND** the other two remain unstaged

#### Scenario: Staging part of a file

- **WHEN** a listed file contains two separate blocks of changed lines
- **AND** the user stages one block
- **THEN** only that block's lines are added to the index
- **AND** the rest of the file remains listed as unstaged

#### Scenario: Unstaging

- **WHEN** a file is listed as staged and the user unstages it
- **THEN** it moves back to the unstaged list
- **AND** its changes are not lost

#### Scenario: Inspecting before acting

- **WHEN** the user expands a listed entry
- **THEN** the change that entry represents is displayed
- **AND** nothing is staged, discarded or committed by displaying it

#### Scenario: Committing

- **WHEN** at least one change is staged and the user starts a commit
- **THEN** a buffer opens for the commit message
- **AND** writing and closing it creates the commit
- **AND** abandoning it without a message leaves the staged changes staged and creates no commit

#### Scenario: Amending

- **WHEN** the repository has at least one commit and the user amends it
- **THEN** the previous commit's message is offered for editing
- **AND** anything currently staged is folded into that commit

#### Scenario: Staging is shared with the buffer indicators

- **WHEN** a file is open in a buffer with changed lines marked in the sign column
- **AND** the user stages that file from the status view
- **THEN** the buffer's indicators update to show those lines as staged rather than unstaged

### Requirement: Repository operations are reachable from the view

From the status view the user SHALL be able to reach the operations that act on the repository as a whole, at least:

- **Branches** — switching to another branch and creating a new one.
- **Remotes** — fetching, pulling and pushing.
- **Rebase** and **merge**.
- **Stash** — storing the current work and restoring it.
- **Log** — reading the repository's history.

Where an operation needs a target — a branch, a remote, a commit — the user SHALL be offered the available choices rather than having to type the name from memory.

#### Scenario: Switching branch

- **WHEN** the repository has more than one branch and the user starts a branch switch from the view
- **THEN** the repository's branches are offered as choices
- **AND** selecting one checks it out
- **AND** the view updates to show the newly checked-out branch

#### Scenario: Pushing

- **WHEN** the current branch has commits its upstream does not
- **AND** the user pushes from the view
- **THEN** those commits are sent to the upstream
- **AND** the view updates to show the branch level with its upstream

#### Scenario: Stashing

- **WHEN** the working tree has uncommitted changes and the user stashes from the view
- **THEN** the working tree is returned to its committed state
- **AND** the stashed work is listed as recoverable from the view

#### Scenario: Reading the log

- **WHEN** the user opens the log from the view
- **THEN** the repository's commits are listed
- **AND** selecting one shows that commit's changes

#### Scenario: An operation that git refuses

- **WHEN** the user starts an operation git cannot complete, such as pulling with a conflicting local change
- **THEN** the failure is reported to the user with git's own message
- **AND** the editor remains usable and the view remains open

### Requirement: The view's own keys are discoverable from inside it

The status view SHALL respond to keys of its own that exist only while it is focused, and it SHALL provide a way — from inside the view, without consulting documentation — to list those keys with what each one does.

Those keys SHALL exist only in that view: they SHALL NOT change the meaning of any key in an ordinary editing buffer.

#### Scenario: Listing the view's keys

- **WHEN** the status view is focused and the user asks it for help
- **THEN** the keys the view responds to are listed with a description of each

#### Scenario: The keys are confined to the view

- **WHEN** the user leaves the status view for an ordinary buffer
- **THEN** the keys the view responded to have their ordinary meaning again

#### Scenario: Closing the view

- **WHEN** the status view is focused and the user closes it
- **THEN** the view is dismissed
- **AND** any operation left half-composed, such as an unwritten commit message, is abandoned rather than applied

### Requirement: Opening outside a git repository offers to create one

Where the working directory is not inside a git repository, opening the status view SHALL offer to initialize a repository there. That offer SHALL default to declining, so that a mapping pressed by accident and dismissed creates nothing. Declining SHALL tell the user the directory is not a git repository and leave the editor exactly as it was.

#### Scenario: Not a repository, declining

- **WHEN** the working directory is not inside a git repository
- **AND** the user presses any of the four opening mappings
- **THEN** the user is asked whether to initialize a repository in that directory
- **AND** dismissing the question without choosing declines it
- **AND** the user is told the directory is not a git repository
- **AND** no window is opened or replaced and the current buffer is unchanged
- **AND** no error trace is shown and the editor remains usable

#### Scenario: Not a repository, accepting

- **WHEN** the user is asked whether to initialize a repository and accepts
- **THEN** a git repository is created in that directory
- **AND** the status view opens over it in the arrangement the mapping named
