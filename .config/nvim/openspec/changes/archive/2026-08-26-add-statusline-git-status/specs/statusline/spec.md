## ADDED Requirements

### Requirement: The status line summarizes the repository's uncommitted work and unpushed commits

The status line SHALL report, for the repository containing the focused buffer, a summary of work that has not yet been committed and commits that have not yet been pushed. The summary SHALL consist of up to four segments, each a symbol immediately followed by a count:

| Segment | Counts |
| --- | --- |
| `+N` | files in the working tree that git is not tracking |
| `●N` | files whose working-tree content differs from the index |
| `◆N` | files whose indexed content differs from the commit at the head of the branch |
| `↑N` | commits on the checked-out branch that are not on its upstream branch |

Every count SHALL be a count of **files**, except `↑`, which counts commits. A count of changed lines or of hunks SHALL NOT be substituted for a count of files.

The summary SHALL describe the **whole repository**, not the focused buffer. It SHALL be reported whether or not the focused buffer is itself one of the files counted, and whether or not the focused buffer has been modified.

**Each segment SHALL be omitted entirely when its count is zero**, independently of the other three. A segment SHALL NOT be rendered as a symbol with a zero beside it, and SHALL NOT be rendered as a symbol alone. Where every count is zero the summary SHALL render as nothing at all and SHALL occupy no width on the line, so that a clean, fully pushed repository is reported by silence.

A file may be counted in more than one segment: a file with staged changes and further unstaged edits on top of them SHALL be counted in both `●` and `◆`. A file with unresolved merge conflicts SHALL be counted in `●`.

`↑` SHALL be omitted where the checked-out branch has no upstream branch configured, since there is then no answer to how many commits are pending, rather than an answer of zero.

The symbols, their order, and the fact that the summary carries no surrounding brackets are fixed by this requirement. Where the summary sits on the line relative to the other components is NOT fixed by this requirement.

#### Scenario: Work of every kind outstanding

- **WHEN** the repository has two untracked files, five files with unstaged changes, three files with staged changes, and one commit not on the upstream
- **THEN** the status line shows `+2`, `●5`, `◆3` and `↑1`

#### Scenario: A clean, fully pushed repository

- **WHEN** the working tree matches the head commit exactly, nothing is untracked, and the branch is level with its upstream
- **THEN** the summary shows nothing
- **AND** it occupies no width on the status line
- **AND** no symbol is drawn with a zero beside it

#### Scenario: Only one kind of work outstanding

- **WHEN** the repository has two untracked files and nothing else outstanding
- **THEN** the summary shows `+2` and nothing else
- **AND** no `●`, `◆` or `↑` is drawn

#### Scenario: Counts are files, not lines

- **WHEN** one file has forty changed lines in six separate blocks and no other file is changed
- **THEN** the unstaged segment reads `●1`

#### Scenario: The summary is repository-wide, not buffer-local

- **WHEN** four files in the repository have unstaged changes
- **AND** the focused buffer is a fifth file that is unmodified
- **THEN** the unstaged segment reads `●4`

#### Scenario: A file both staged and further edited

- **WHEN** a file's changes are staged and the file is then edited again without staging
- **THEN** that file is counted in both the staged and the unstaged segments

#### Scenario: A conflicted file

- **WHEN** a merge leaves a file with unresolved conflicts
- **THEN** that file is counted in the unstaged segment

#### Scenario: A branch with no upstream

- **WHEN** the checked-out branch has no upstream branch configured
- **THEN** no `↑` segment is shown
- **AND** the other segments are shown as usual
- **AND** no error is raised

#### Scenario: A branch level with its upstream

- **WHEN** the checked-out branch has an upstream and no commits the upstream lacks
- **THEN** no `↑` segment is shown

### Requirement: The summary tracks the repository as it changes, without being asked

The summary SHALL be brought up to date after any action that changes what it reports, with no command, keypress or manual refresh from the user. In particular it SHALL be updated after:

- a buffer is written
- changes are staged, unstaged or reset from within the editor, whether hunk by hunk from the buffer or file by file from the repository view
- a commit, push, pull or fetch completes from within the editor
- the editor regains focus, so that work done in another terminal is picked up
- the focused buffer changes to one in a different repository, or the working directory changes

Gathering the summary SHALL NOT block the editor: the status line SHALL continue to redraw, and the user to type, while the counts are being determined. A repository large enough that counting is slow SHALL show the previous counts, or nothing, until the new ones arrive — never a frozen editor.

The summary SHALL NOT be gathered so often that it costs noticeably: a burst of events in quick succession SHALL result in the counts being gathered once, not once per event.

#### Scenario: Staging from the buffer

- **WHEN** the user stages a hunk from within a buffer
- **THEN** the staged segment's count rises and the unstaged segment's falls, if that was the file's only unstaged hunk
- **AND** the user does nothing further to make it happen

#### Scenario: Committing from the repository view

- **WHEN** the user writes a commit from the repository view
- **THEN** the staged segment clears
- **AND** the unpushed segment's count rises by one

#### Scenario: Pushing

- **WHEN** the user pushes the branch from within the editor
- **THEN** the unpushed segment clears

#### Scenario: Work done outside the editor

- **WHEN** the user commits in another terminal and returns to the editor
- **THEN** the summary reflects the commit

#### Scenario: Writing a file

- **WHEN** the user writes a buffer that had no unstaged changes on disk before
- **THEN** the unstaged segment's count rises

#### Scenario: A slow repository does not stall the editor

- **WHEN** the repository is large enough that counting takes a noticeable time
- **THEN** the editor stays responsive to typing and redraws throughout
- **AND** the summary updates once the counts are available

#### Scenario: A burst of events

- **WHEN** several events that would each trigger a refresh occur within a moment of one another
- **THEN** the counts are gathered once rather than once per event

### Requirement: The summary is absent, not broken, where there is nothing to summarize

Where the focused buffer is not inside a git repository, the summary SHALL show nothing and SHALL raise no error. Where no `git` executable is available, the summary SHALL likewise show nothing and SHALL raise no error, and every other part of the status line SHALL continue to work.

A failure to determine the counts SHALL never produce a message, a notification, or an error trace, and SHALL never leave a partial or stale-looking summary claiming to describe the current repository.

#### Scenario: A file outside a repository

- **WHEN** the user opens a file that is not inside a git repository
- **THEN** no summary is shown
- **AND** no error is raised

#### Scenario: Moving from a repository to a file outside one

- **WHEN** the user is looking at a file in a repository with work outstanding
- **AND** then focuses a buffer that is not inside a repository
- **THEN** the first repository's counts are no longer shown

#### Scenario: Two repositories in one session

- **WHEN** the user has files from two different repositories open
- **AND** focuses one and then the other
- **THEN** the summary describes the repository of whichever file is focused

#### Scenario: No git executable

- **WHEN** no `git` executable is on the path
- **THEN** no summary is shown
- **AND** no error, message or notification is raised
- **AND** the mode, filename, diagnostics and position are still shown

## MODIFIED Requirements

### Requirement: The status line reports the editor's state rather than the file's name alone

The editor's status line SHALL be replaced by one that reports, for the focused window:

- the editing mode in force
- the checked-out git branch, and a summary of the working tree's changes, where the file is inside a repository
- a summary of the repository's uncommitted work and unpushed commits, where the file is inside a repository
- the number of diagnostics against the buffer, counted separately by severity
- the file's name, with a distinct indicator when the buffer has unsaved changes and a distinct indicator when it cannot be written
- the file's type
- the cursor's position, and its progress through the file

The summary of the working tree's changes and the summary of the repository are distinct and SHALL both be reported. The first describes the focused buffer alone; the second describes the whole repository. They SHALL NOT be conflated, and one SHALL NOT be dropped in favour of the other.

Where a given piece of information does not apply — no repository, no diagnostics, no filetype, nothing uncommitted — it SHALL be omitted rather than shown empty or as a placeholder, and no error SHALL be raised.

The precise ordering, separators, and symbols are the status line component's own and are NOT fixed by this capability, except for the symbols of the repository summary, which are fixed by the requirement that defines it.

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

#### Scenario: Buffer changes and repository changes are both reported

- **WHEN** the focused buffer has changed lines
- **AND** other files in the repository also have changes
- **THEN** the status line reports the focused buffer's changed lines
- **AND** separately reports the repository's counts of changed files

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

### Requirement: The capability is configured no further than it needs to be

Beyond making a recording visible and reporting the repository's uncommitted work and unpushed commits, this capability SHALL take the status line component's own defaults rather than restating them. It SHALL NOT fix the separators or the icon set. Where naming a section is unavoidable in order to place one of those two additions, the defaults of that section SHALL be restated exactly as upstream ships them and SHALL NOT be reordered, dropped or substituted; no other section SHALL be named at all.

It SHALL NOT change how many status lines the editor draws: each window SHALL keep its own, exactly as before this capability existed.

#### Scenario: Windows keep their own status lines

- **WHEN** the user splits the window
- **THEN** each split carries its own status line

#### Scenario: Defaults are not restated

- **WHEN** a contributor reads this capability's configuration
- **THEN** the only presentation choices it makes are the recording indicator and the repository summary
- **AND** the separators and icons are the component's defaults
- **AND** every component in a named section other than those two is the one upstream places there

#### Scenario: Naming a section keeps its other contents

- **WHEN** a section is named in order to place one of the two additions
- **THEN** the components upstream places in that section are all still present
- **AND** they are in upstream's order
