## Purpose

Defines a `/git:*` slash-command suite carried in the personal Claude Code configuration, covering the everyday git verbs — init, fetch, commit, push, pull, switch, squash, append, merge, mergeinto, cleanup — with consistent rules for what gets staged, how commit messages are written, when an upstream is created, and when the assistant must stop and ask instead of rewriting or resolving on its own.

## Requirements

### Requirement: Command namespace

The suite SHALL be invoked as `/git:<command>` and SHALL be available in any git repository, not only the home configuration repository. The suite SHALL consist of exactly `init`, `fetch`, `status`, `commit`, `push`, `pull`, `switch`, `squash`, `append`, `merge`, `mergeinto`, and `cleanup`.

#### Scenario: Invocation form

- **WHEN** the user types `/git:init`, `/git:fetch`, `/git:status`, `/git:commit`, `/git:push`, `/git:pull`, `/git:switch`, `/git:squash`, `/git:append`, `/git:merge`, `/git:mergeinto`, or `/git:cleanup`
- **THEN** the corresponding command SHALL run

#### Scenario: Available outside the home repository

- **WHEN** a `/git:*` command runs with a working directory inside an unrelated git repository
- **THEN** it SHALL operate on that repository
- **AND** it SHALL NOT assume the home repository's layout, branch names, or remote

#### Scenario: Not in a repository

- **WHEN** a `/git:*` command other than `/git:init` runs where `git rev-parse --show-toplevel` fails
- **THEN** the command SHALL stop and report that the working directory is not a git repository
- **AND** it SHALL NOT create a repository
- **AND** it SHALL suggest `/git:init`

### Requirement: Repository conventions are honored

A command SHALL obey the conventions of the repository it runs in rather than imposing its own. It SHALL NOT bypass repository hooks and SHALL NOT weaken a repository's staging discipline.

#### Scenario: Commit and push hooks are never bypassed

- **WHEN** any command commits or pushes
- **THEN** it SHALL NOT pass `--no-verify` or otherwise disable hooks
- **AND** a hook rejection SHALL be reported verbatim with the command stopping

#### Scenario: Deny-by-default repository staging

- **WHEN** a command stages content in a repository whose tracked specification requires explicit staging, such as the home configuration repository
- **THEN** every path SHALL be staged by name
- **AND** `git add -A`, `git add .`, and `git add -u` SHALL NOT be used, including for `/git:push all`

#### Scenario: Ignored paths stay ignored

- **WHEN** a dirty path is matched by an ignore rule
- **THEN** it SHALL NOT be force-added
- **AND** it SHALL be reported as skipped when the user asked for all changes

### Requirement: Commit message generation

A command that creates or rewrites a commit message SHALL write the message from the actual staged content, in the style already used by the repository's recent history.

#### Scenario: Style inferred from history

- **WHEN** a commit message is written
- **THEN** the repository's recent commit subjects SHALL be inspected to determine the prevailing style
- **AND** the message SHALL follow that style, using conventional-commit prefixes only where the history already uses them

#### Scenario: Message describes the change

- **WHEN** a commit message is written
- **THEN** the subject SHALL name what changed rather than restating file names
- **AND** a body SHALL be added when the change is not self-evident from the subject

#### Scenario: No attribution footers unless the repository uses them

- **WHEN** a commit message is written
- **THEN** it SHALL NOT add a co-author or tool-attribution trailer unless the repository's own configuration or recent history uses one

### Requirement: Init creates a repository and registers its remote

`/git:init [REPO]` SHALL initialize a git repository in the working directory. When `REPO` is given as an HTTP(S) or SSH URL, it SHALL be registered as the `origin` remote.

#### Scenario: Repository created without a remote

- **WHEN** `/git:init` runs with no argument in a directory that is not inside a git repository
- **THEN** a repository SHALL be initialized there
- **AND** no remote SHALL be configured
- **AND** the report SHALL name the repository path and the initial branch

#### Scenario: Remote registered from the argument

- **WHEN** `/git:init` runs with an HTTP(S) or SSH URL
- **THEN** the repository SHALL be initialized
- **AND** that URL SHALL be registered as the remote named `origin`
- **AND** `git remote get-url origin` SHALL print the given URL

#### Scenario: Argument is not a repository URL

- **WHEN** the argument is neither an HTTP(S) URL nor an SSH remote specifier
- **THEN** the command SHALL stop and report that the argument is not a usable remote URL
- **AND** it SHALL NOT initialize a repository

#### Scenario: Already inside a repository

- **WHEN** `/git:init` runs where the working directory is already inside a git repository
- **THEN** the command SHALL NOT reinitialize it
- **AND** it SHALL report the existing repository root
- **AND** if a `REPO` argument was given and no `origin` exists, it SHALL offer to add `origin` to the existing repository

#### Scenario: Origin already exists with a different URL

- **WHEN** a `REPO` argument is given and an `origin` remote already exists pointing elsewhere
- **THEN** the command SHALL stop and report both URLs
- **AND** it SHALL NOT overwrite the existing remote without confirmation

#### Scenario: Initialization does not commit or push

- **WHEN** `/git:init` completes
- **THEN** no commit SHALL be created, no path SHALL be staged, and nothing SHALL be pushed
- **AND** the report SHALL mention `/git:push` as the way to publish the first commit

#### Scenario: Remote is not contacted

- **WHEN** a `REPO` argument is registered
- **THEN** the command SHALL NOT require the remote to be reachable
- **AND** an unreachable or not-yet-created remote SHALL NOT fail the initialization

### Requirement: Fetch updates remote-tracking refs from origin

`/git:fetch` SHALL fetch from the `origin` remote and report what changed, without altering the working tree or the current branch.

#### Scenario: Fetch from origin

- **WHEN** `/git:fetch` runs in a repository with an `origin` remote
- **THEN** `origin` SHALL be fetched
- **AND** the working tree, the index, and the checked-out branch SHALL be unchanged

#### Scenario: Report what moved

- **WHEN** the fetch brings in new commits, new branches, or deleted branches
- **THEN** the report SHALL summarize them, including whether the current branch is now behind its upstream
- **AND** it SHALL mention `/git:pull` when the current branch is behind

#### Scenario: Nothing new

- **WHEN** the fetch brings nothing in
- **THEN** the command SHALL report that everything is already up to date

#### Scenario: No origin remote

- **WHEN** the repository has no remote named `origin`
- **THEN** the command SHALL stop and report that
- **AND** if other remotes exist it SHALL name them

#### Scenario: Fetch fails

- **WHEN** the fetch fails, such as on an unreachable host or refused authentication
- **THEN** the command SHALL report the failure with the decisive line of git's output
- **AND** it SHALL NOT retry with different credentials or a different remote

### Requirement: Status shows the working tree as an annotated tree

`/git:status` SHALL render the repository's uncommitted changes as a directory tree with one icon per entry, and SHALL NOT modify the repository or contact a remote.

#### Scenario: Read-only

- **WHEN** `/git:status` runs
- **THEN** it SHALL NOT stage, commit, fetch, pull, or push
- **AND** the working tree, the index, and the checked-out branch SHALL be unchanged when it finishes

#### Scenario: Changes rendered as a tree

- **WHEN** the repository has uncommitted changes
- **THEN** the changed paths SHALL be rendered as a nested directory tree rather than a flat path list
- **AND** each directory entry SHALL end in `/`
- **AND** a directory SHALL show only the children that actually changed

#### Scenario: Untracked directories are expanded

- **WHEN** an untracked directory contains changed files
- **THEN** its files SHALL be listed individually rather than collapsed to a single directory entry

#### Scenario: Large untracked directory is capped

- **WHEN** a single untracked directory holds more than 20 files
- **THEN** the directory SHALL be shown as one entry with the file count instead of its contents
- **AND** the report SHALL say that the listing was collapsed

#### Scenario: State named by one emoji

- **WHEN** an entry is rendered
- **THEN** its state SHALL be determined by its porcelain index and working-tree columns, distinguishing at least untracked, added, modified, deleted, renamed, copied, type-changed, and conflicted
- **AND** the state SHALL be shown as a single emoji, with no word beside it
- **AND** directories SHALL carry a directory emoji distinct from every file emoji
- **AND** no emoji SHALL encode the file's type or extension

#### Scenario: Emoji are width-stable

- **WHEN** an emoji is chosen for any state
- **THEN** it SHALL occupy two columns in the target terminal, since the tree is aligned on that grid
- **AND** a codepoint carrying no variation selector SHALL be preferred, as it satisfies this without being checked
- **AND** a codepoint carrying a trailing `U+FE0F` SHALL be verified by eye before use, as its width varies by terminal
- **AND** Nerd Font glyphs SHALL NOT be used, as Claude Code does not render them

#### Scenario: Fields are aligned in fixed columns

- **WHEN** the tree is printed
- **THEN** the marker, session, and state fields SHALL occupy fixed widths at the start of every entry line
- **AND** the tree indentation SHALL follow them, so that names form the tree while the left edge forms a status column

#### Scenario: Colour comes from the fenced block

- **WHEN** the status is printed
- **THEN** the legend, tree, and status line SHALL be emitted inside a single ```diff fenced block
- **AND** ANSI escape sequences SHALL NOT be emitted
- **AND** each line's colour SHALL be selected by its first non-space character

#### Scenario: Colour encodes staged-ness

- **WHEN** an entry's change is staged
- **THEN** its line SHALL begin with `+` so that it renders green
- **AND** an unstaged or untracked entry SHALL begin with neither `+` nor `-`
- **AND** a conflicted entry SHALL begin with `-` so that it renders red
- **AND** `@@ … @@` SHALL NOT be used anywhere in the output, so no line renders grey
- **AND** staged SHALL be named `✅` wherever it is named in words, without occupying a column in the tree

#### Scenario: Legend covers what is shown

- **WHEN** the tree is printed
- **THEN** a legend SHALL give the meaning of every state that appears in that tree
- **AND** it SHALL say what the green colour means
- **AND** it SHALL be omitted only when the tree is empty, since it is the only place the emoji mapping is written

#### Scenario: Legend first, status line last

- **WHEN** the block is printed
- **THEN** the legend SHALL be its first line and the status line its last, with the tree between them

#### Scenario: Conflicts are surfaced first

- **WHEN** any path is conflicted
- **THEN** the conflict count SHALL appear directly under the legend, above the tree

#### Scenario: Clean tree

- **WHEN** there are no uncommitted changes
- **THEN** the command SHALL print the status line alone, with no tree and no legend
- **AND** it SHALL NOT add a sentence stating that the tree is clean, since the zero counts already state it

#### Scenario: Nothing is said that the block already shows

- **WHEN** the block has been printed
- **THEN** no prose SHALL restate the branch, its ahead/behind relation, any count, or any path shown in it
- **AND** no next command SHALL be suggested, since the status line already carries the reason for it
- **AND** the only permitted line outside the block SHALL be the notice that session ownership could not be determined

#### Scenario: Branch state in the status line

- **WHEN** the status is printed
- **THEN** a status line SHALL name the current branch and its ahead/behind relation to its upstream, or state that there is no upstream
- **AND** a detached HEAD SHALL be reported as such rather than as a branch
- **AND** the status line SHALL carry staged, unstaged, untracked, and conflicted counts, each always printed even when zero
- **AND** it SHALL carry the added and removed line totals summed across both numstats, written in the same emoji-plus-number shape as the counts beside them, so the whole line uses one notation
- **AND** their unit and their tracked-only scope SHALL be stated in the legend
- **AND** it SHALL NOT count lines in untracked files, which are represented by the untracked file count instead
- **AND** it SHALL be plain, taking the default colour, as SHALL the legend

#### Scenario: Ignored paths stay out

- **WHEN** a path is matched by an ignore rule
- **THEN** it SHALL NOT appear in the tree

#### Scenario: Changes from outside this session are marked

- **WHEN** a dirty path was not created or modified by the present conversation
- **THEN** its entry SHALL carry a session marker distinguishing it from the paths this session touched
- **AND** the marker SHALL occupy the same column on every entry so that marked entries align

#### Scenario: Session ownership cannot be determined

- **WHEN** the session edit record is unavailable or untrustworthy
- **THEN** the session column SHALL be left blank on every entry
- **AND** the command SHALL say once beneath the tree that ownership could not be determined
- **AND** it SHALL NOT ask the user which paths belong to the session
- **AND** it SHALL still print the tree

### Requirement: Commit records work without publishing it

`/git:commit [all]` SHALL stage and commit using the same scope rule as `/git:push`, and SHALL NOT push.

#### Scenario: Session scope by default

- **WHEN** `/git:commit` runs with no argument
- **THEN** only the paths touched in the present session, intersected with the dirty set, SHALL be staged and committed
- **AND** unrelated dirty paths SHALL be left uncommitted and reported

#### Scenario: All argument

- **WHEN** `/git:commit all` runs
- **THEN** every dirty non-ignored path SHALL be staged and committed, whether or not the session touched it

#### Scenario: Nothing is pushed

- **WHEN** `/git:commit` creates a commit
- **THEN** nothing SHALL be pushed, no upstream SHALL be created, and the remote SHALL NOT be contacted
- **AND** the report SHALL mention `/git:push` as the way to publish the commit

#### Scenario: Nothing to commit

- **WHEN** no path qualifies under the chosen scope
- **THEN** no commit SHALL be created, including no empty commit
- **AND** the command SHALL say so, mentioning `/git:push all` or `/git:commit all` when unrelated dirty paths exist

#### Scenario: Local-only by design

- **WHEN** the repository has no remote at all
- **THEN** `/git:commit` SHALL behave exactly as it does with one, since it never needs a remote

#### Scenario: Detached HEAD is allowed

- **WHEN** `/git:commit` runs while HEAD is detached
- **THEN** the commit SHALL still be created, since committing does not require a branch
- **AND** the report SHALL warn that the commit is not on any branch and name its hash

### Requirement: Push stages the session's own work by default

`/git:push` with no argument SHALL stage only the paths that were created or modified during the present session, intersected with the paths that are actually dirty at the time it runs.

#### Scenario: Session paths only

- **WHEN** `/git:push` runs with no argument and the working tree holds both session-touched and unrelated dirty paths
- **THEN** only the session-touched paths SHALL be staged and committed
- **AND** the unrelated dirty paths SHALL remain uncommitted and SHALL be listed in the report as left behind

#### Scenario: Session path is no longer dirty

- **WHEN** a path touched during the session has since been reverted or already committed
- **THEN** it SHALL NOT be staged
- **AND** its absence SHALL NOT be treated as an error

#### Scenario: No session paths to push

- **WHEN** `/git:push` runs with no argument and no session-touched path is dirty
- **THEN** the command SHALL report that there is nothing from this session to commit
- **AND** it SHALL NOT create an empty commit
- **AND** if unrelated dirty paths exist it SHALL say so and mention `/git:push all`

#### Scenario: Ambiguous session scope

- **WHEN** the set of session-touched paths cannot be determined with confidence
- **THEN** the command SHALL present the dirty paths and ask which to include before staging anything

### Requirement: Push all stages every dirty path

`/git:push all` SHALL stage every dirty path in the repository — modified, deleted, and untracked-but-not-ignored — regardless of whether the session touched it.

#### Scenario: Every dirty path is included

- **WHEN** `/git:push all` runs
- **THEN** modified, deleted, and untracked non-ignored paths SHALL all be staged
- **AND** the report SHALL list what was committed

#### Scenario: Nothing to commit

- **WHEN** `/git:push all` runs with a clean working tree and unpushed local commits
- **THEN** no commit SHALL be created
- **AND** the existing commits SHALL still be pushed

#### Scenario: Clean tree and nothing unpushed

- **WHEN** `/git:push all` runs with a clean tree and no unpushed commits
- **THEN** the command SHALL report that the branch is already up to date and do nothing

### Requirement: Push publishes the current branch

`/git:push` SHALL push the current branch to its upstream, creating the upstream on the remote when the branch has none.

#### Scenario: Upstream already set

- **WHEN** the current branch has an upstream
- **THEN** the commit SHALL be pushed to that upstream
- **AND** the report SHALL name the branch, the remote, and the new commit

#### Scenario: Upstream created on first push

- **WHEN** the current branch has no upstream and the repository has exactly one remote
- **THEN** the branch SHALL be pushed to that remote with upstream tracking established

#### Scenario: Several remotes and no upstream

- **WHEN** the current branch has no upstream and the repository has more than one remote
- **THEN** the command SHALL ask which remote to publish to before pushing

#### Scenario: No remote at all

- **WHEN** the repository has no remote configured
- **THEN** the commit SHALL still be created
- **AND** the command SHALL report that the commit is local only because no remote exists

#### Scenario: Push rejected as non-fast-forward

- **WHEN** the push is rejected because the upstream has commits the local branch lacks
- **THEN** the command SHALL stop and report the rejection
- **AND** it SHALL NOT force-push
- **AND** it SHALL suggest `/git:pull` as the next step

#### Scenario: Detached HEAD

- **WHEN** `/git:push` runs while HEAD is detached
- **THEN** the command SHALL stop and report that there is no branch to push
- **AND** it SHALL suggest `/git:switch BRANCH`

### Requirement: Pull updates the current branch from its remote

`/git:pull` SHALL bring the current branch up to date with its matching remote branch.

#### Scenario: Fast-forward pull

- **WHEN** `/git:pull` runs and the remote branch is ahead with no local divergence
- **THEN** the local branch SHALL be updated
- **AND** the report SHALL summarize what arrived

#### Scenario: Already up to date

- **WHEN** the local branch already matches its upstream
- **THEN** the command SHALL report that there is nothing to pull

#### Scenario: No upstream configured

- **WHEN** the current branch has no upstream
- **THEN** the command SHALL check whether a same-named branch exists on the remote
- **AND** if it does, the command SHALL ask before setting it as the upstream and pulling
- **AND** if it does not, the command SHALL report that there is nothing to pull from

#### Scenario: Dirty working tree

- **WHEN** `/git:pull` runs with uncommitted changes that the pull would touch
- **THEN** the command SHALL stop before changing the working tree
- **AND** it SHALL report which paths block the pull

#### Scenario: Pull conflicts

- **WHEN** the pull produces conflicts
- **THEN** the command SHALL stop, name the conflicted paths, and leave the repository in the conflicted state for the user to resolve
- **AND** it SHALL NOT resolve conflicts on its own

### Requirement: Switch reaches a branch wherever it exists

`/git:switch BRANCH` SHALL end with `BRANCH` checked out, whether it already exists locally, exists only on a remote, or does not exist at all.

#### Scenario: Local branch exists

- **WHEN** `BRANCH` exists locally
- **THEN** it SHALL be checked out

#### Scenario: Branch exists only on the remote

- **WHEN** `BRANCH` does not exist locally
- **THEN** the command SHALL fetch before deciding
- **AND** if a remote branch of that name exists, a local branch tracking it SHALL be created and checked out

#### Scenario: Branch exists nowhere

- **WHEN** `BRANCH` exists neither locally nor on any remote after fetching
- **THEN** a new branch SHALL be created from the current HEAD and checked out
- **AND** the report SHALL state that the branch is new and not yet published

#### Scenario: Same name on several remotes

- **WHEN** `BRANCH` exists on more than one remote and not locally
- **THEN** the command SHALL ask which remote to track before creating the local branch

#### Scenario: Uncommitted changes block the switch

- **WHEN** switching would overwrite uncommitted changes
- **THEN** the command SHALL stop and report the blocking paths
- **AND** it SHALL NOT discard or stash them without being asked

#### Scenario: Already on the branch

- **WHEN** `BRANCH` is already the current branch
- **THEN** the command SHALL report that and do nothing

#### Scenario: Missing argument

- **WHEN** `/git:switch` runs with no branch name
- **THEN** the command SHALL ask for one rather than guessing

### Requirement: Squash collapses recent commits

`/git:squash N` SHALL combine the last `N` commits on the current branch into a single commit whose message covers their combined content.

#### Scenario: Explicit count

- **WHEN** `/git:squash 3` runs and the branch has at least three eligible commits
- **THEN** those three commits SHALL become one
- **AND** the resulting tree SHALL be identical to the tree before the squash

#### Scenario: Regenerated message

- **WHEN** commits are squashed
- **THEN** the new message SHALL be written from the combined change rather than concatenating the old subjects
- **AND** it SHALL follow the repository's prevailing message style

#### Scenario: Judgement-based count

- **WHEN** `/git:squash *` runs
- **THEN** the recent history SHALL be examined for the boundary where the current line of work began
- **AND** the commits belonging to that work SHALL be squashed so the branch carries roughly one commit per feature
- **AND** the chosen count and the reason for it SHALL be reported before the squash is applied

#### Scenario: Judgement finds no clear boundary

- **WHEN** `/git:squash *` cannot identify a boundary with confidence
- **THEN** the command SHALL propose a count and ask for confirmation rather than guessing

#### Scenario: N exceeds available history

- **WHEN** `N` is larger than the number of commits on the branch, or reaches past its merge-base with the upstream default branch
- **THEN** the command SHALL stop and report the limit rather than rewriting shared history

#### Scenario: Merge commit in range

- **WHEN** the range to be squashed contains a merge commit
- **THEN** the command SHALL stop and report that the range is not safely squashable

#### Scenario: Dirty tree

- **WHEN** `/git:squash` runs with uncommitted changes present
- **THEN** the command SHALL stop and report them
- **AND** it SHALL suggest `/git:append` or `/git:push` first

### Requirement: Append folds work into the last commit

`/git:append` SHALL add the current working-tree changes to the most recent commit and update its message to describe the combined content.

#### Scenario: Changes folded in

- **WHEN** `/git:append` runs with dirty session-relevant paths
- **THEN** those changes SHALL become part of the last commit
- **AND** no new commit SHALL be created

#### Scenario: Message updated

- **WHEN** the appended content makes the existing subject inaccurate or incomplete
- **THEN** the message SHALL be rewritten to cover the combined change
- **AND** if the existing message already covers it, the message SHALL be left unchanged

#### Scenario: Staging scope matches push

- **WHEN** `/git:append` decides what to include
- **THEN** it SHALL use the same session-scoped selection rule as `/git:push` with no argument

#### Scenario: Nothing to append

- **WHEN** `/git:append` runs with a clean working tree
- **THEN** the command SHALL report that there is nothing to append and leave the commit untouched

#### Scenario: No commit to append to

- **WHEN** the current branch has no commits, or HEAD is a merge commit
- **THEN** the command SHALL stop and report why the amend is unsafe

### Requirement: Rewriting published history requires confirmation

`/git:squash` and `/git:append` SHALL detect when a commit they would rewrite already exists on a remote, and SHALL obtain explicit confirmation before rewriting it and before any force-push.

#### Scenario: Target commits are unpushed

- **WHEN** every commit in the rewrite range is absent from every remote-tracking ref
- **THEN** the rewrite SHALL proceed without asking

#### Scenario: Target commits are already published

- **WHEN** any commit in the rewrite range is reachable from a remote-tracking ref
- **THEN** the command SHALL stop, name the published commits, and ask for confirmation before rewriting
- **AND** it SHALL NOT rewrite or force-push without an explicit yes

#### Scenario: Force-push uses a lease

- **WHEN** a confirmed rewrite is pushed
- **THEN** the push SHALL use a lease against the known remote state so a concurrent remote update aborts it rather than being overwritten

### Requirement: Merge brings a branch into the current one

`/git:merge BRANCH` SHALL merge `BRANCH` into the current branch and end on the current branch.

#### Scenario: Clean merge

- **WHEN** `BRANCH` merges cleanly
- **THEN** the merge SHALL be committed
- **AND** the current branch SHALL remain checked out
- **AND** the report SHALL name both branches and the result

#### Scenario: Source branch is remote-only

- **WHEN** `BRANCH` does not exist locally
- **THEN** the command SHALL fetch and use the remote branch of that name
- **AND** if no such branch exists anywhere, it SHALL stop and report that

#### Scenario: Conflicts stop the command

- **WHEN** the merge conflicts
- **THEN** the command SHALL stop, name the conflicted paths, and leave the merge in progress for the user to resolve
- **AND** it SHALL NOT abort the merge and SHALL NOT resolve conflicts on its own

#### Scenario: Dirty tree blocks the merge

- **WHEN** `/git:merge` runs with uncommitted changes
- **THEN** the command SHALL stop and report them before starting the merge

#### Scenario: Nothing to merge

- **WHEN** `BRANCH` is already an ancestor of the current branch
- **THEN** the command SHALL report that and make no commit

### Requirement: Mergeinto pushes the current branch into another

`/git:mergeinto BRANCH` SHALL merge the current branch into `BRANCH` and SHALL leave `BRANCH` checked out when it succeeds.

#### Scenario: Ends on the target branch

- **WHEN** the merge into `BRANCH` succeeds
- **THEN** `BRANCH` SHALL be the checked-out branch afterwards
- **AND** the report SHALL name the source branch, the target branch, and the result

#### Scenario: Target reached wherever it lives

- **WHEN** `BRANCH` exists only on a remote
- **THEN** it SHALL be obtained by the same rule `/git:switch` uses before the merge

#### Scenario: Target updated before merging

- **WHEN** `BRANCH` has an upstream that is ahead of the local copy
- **THEN** `BRANCH` SHALL be brought up to date before the merge
- **AND** if that update cannot be done cleanly the command SHALL stop and report why

#### Scenario: Conflicts leave the user on the target branch

- **WHEN** the merge conflicts
- **THEN** the command SHALL stop with the conflicted merge in progress on `BRANCH`
- **AND** it SHALL name the conflicted paths
- **AND** it SHALL NOT return to the original branch, since that would discard the in-progress merge

#### Scenario: Dirty tree blocks the switch

- **WHEN** uncommitted changes would prevent switching to `BRANCH`
- **THEN** the command SHALL stop before switching and report the blocking paths

#### Scenario: Result is not pushed unless asked

- **WHEN** the merge into `BRANCH` succeeds
- **THEN** the merge commit SHALL NOT be pushed by this command
- **AND** the report SHALL mention `/git:push` as the way to publish it

### Requirement: Cleanup removes branches that are no longer needed

`/git:cleanup` SHALL identify local and remote branches whose work has already landed, present them for approval, and delete only what the user approves.

#### Scenario: Candidates are proposed before anything is deleted

- **WHEN** `/git:cleanup` runs
- **THEN** it SHALL fetch and prune stale remote-tracking refs first
- **AND** it SHALL present the candidate branches grouped by the reason each qualifies
- **AND** no branch SHALL be deleted before the user approves

#### Scenario: Merged into the default branch

- **WHEN** a local branch's tip is contained in the repository's default branch
- **THEN** it SHALL be offered as a candidate
- **AND** the reason SHALL be reported as merged

#### Scenario: Upstream is gone

- **WHEN** a local branch tracked an upstream that no longer exists after pruning
- **THEN** it SHALL be offered as a candidate under a separate, weaker reason than merged
- **AND** the report SHALL note that a squash-merged or rebase-merged branch appears this way, as does one whose remote branch was deleted by mistake

#### Scenario: Protected branches are never candidates

- **WHEN** the candidate list is built
- **THEN** the current branch and the repository's default branch SHALL be excluded
- **AND** they SHALL NOT be offered even when they satisfy a reason

#### Scenario: Partial approval

- **WHEN** the user approves only some of the proposed branches
- **THEN** only those SHALL be deleted
- **AND** the rest SHALL be left untouched and reported as kept

#### Scenario: Unmerged work is never force-deleted

- **WHEN** a local branch is deleted
- **THEN** the deletion SHALL use git's safe delete, which refuses a branch holding unmerged commits
- **AND** a refusal SHALL be reported rather than retried with a force delete

#### Scenario: Remote deletion is approved separately

- **WHEN** the candidate list includes branches on the remote
- **THEN** deleting them SHALL require its own explicit approval, distinct from approving the local deletions
- **AND** the repository's default branch on the remote SHALL never be offered

#### Scenario: Nothing to clean

- **WHEN** no branch qualifies
- **THEN** the command SHALL report that there is nothing to clean and delete nothing

#### Scenario: Working tree is untouched

- **WHEN** `/git:cleanup` completes
- **THEN** the checked-out branch, the working tree, and the index SHALL be unchanged

### Requirement: A state-changing command ends with the status block

A command that changes what the status block displays — the working tree, the index, `HEAD`, or the remote-tracking refs the branch is measured against — SHALL end a successful run by rendering that block. The commands that do so SHALL be `init`, `fetch`, `commit`, `push`, `pull`, `switch`, `squash`, `append`, `merge`, `mergeinto`, and `cleanup`. `/git:status` itself already renders it, and `/git:conventions` changes nothing and SHALL NOT render it.

#### Scenario: Block closes a successful run

- **WHEN** any of those commands completes its work
- **THEN** it SHALL render the status block as the last thing it prints
- **AND** the block SHALL come after the command's own report, not before it and not in place of it

#### Scenario: Fetch renders it too

- **WHEN** `/git:fetch` completes
- **THEN** it SHALL render the block, since moving the remote-tracking refs changes the ahead and behind counts the status line carries

#### Scenario: A stopped run prints no block

- **WHEN** a command stops on a failed precondition, a git failure, or a rejected hook
- **THEN** it SHALL print its stop report and SHALL NOT render the block
- **AND** it SHALL NOT run further git commands to build one

#### Scenario: A command that asks first prints no block yet

- **WHEN** a command pauses for confirmation before acting
- **THEN** it SHALL render the block only after the confirmed action completes, not while waiting

#### Scenario: The block stays read-only

- **WHEN** the closing block is built
- **THEN** it SHALL be assembled from the same read-only commands `/git:status` uses
- **AND** building it SHALL NOT stage, unstage, or otherwise change the repository

### Requirement: The render contract is defined once

The description of how the status block is rendered — the legend, the tree, the fixed entry-line fields, the colour rules, and the status line — SHALL live in one place that both `/git:status` and every closing block follow. It SHALL NOT be restated per command.

#### Scenario: Single source

- **WHEN** the command files are inspected
- **THEN** exactly one of them SHALL carry the render contract
- **AND** every other command that prints the block SHALL point at it rather than describing the format again

#### Scenario: Identical output

- **WHEN** the same repository state is printed by `/git:status` and by a closing block
- **THEN** the two blocks SHALL be identical

#### Scenario: A change to the contract reaches every command

- **WHEN** the render contract is edited
- **THEN** no per-command file SHALL need editing for the change to take effect

### Requirement: Each command declares the model it runs on

Every command in the suite SHALL name its model explicitly in its frontmatter, chosen by how much judgment the command exercises and how costly a mistake would be. No command SHALL be left to inherit the session's model.

#### Scenario: Every command names a model

- **WHEN** the frontmatter of each command file is inspected
- **THEN** each SHALL carry a `model` field

#### Scenario: Text-only command runs on the fast tier

- **WHEN** a command neither touches the repository nor renders the status block — `/git:conventions`, which only prints the shared rules
- **THEN** it SHALL run on the fastest available model

#### Scenario: Bounded operations run on the middle tier

- **WHEN** the command performs a bounded, reversible operation, writes a commit message, or renders the status block — `init`, `fetch`, `status`, `commit`, `push`, `pull`, `switch`, and `merge`
- **THEN** it SHALL run on the middle model tier

#### Scenario: History rewriting and ref deletion run on the top tier

- **WHEN** the command can rewrite published history, force-push, or delete branches — `squash`, `append`, `mergeinto`, and `cleanup`
- **THEN** it SHALL run on the most capable model

#### Scenario: Cost is never traded for safety

- **WHEN** a command's tier is chosen
- **THEN** the deciding question SHALL be what a wrong answer costs, not what the command costs to run
- **AND** a command that can lose committed work SHALL NOT be moved down a tier

### Requirement: Every command reports what it did

Each command SHALL end with a short report of the actions it performed and the resulting repository state, and SHALL surface git's own error output when it stops. On a successful run, a command that changed the repository SHALL follow that report with the rendered status block.

#### Scenario: Successful run

- **WHEN** a command completes its work
- **THEN** it SHALL report the branch, the operation performed, and any new or rewritten commit
- **AND** it SHALL state anything it deliberately left untouched
- **AND** it SHALL then render the status block, if it is one of the commands that changes what the block shows

#### Scenario: Stopped run

- **WHEN** a command stops on a precondition or a git failure
- **THEN** it SHALL report why it stopped, quote the decisive line of git's output, and name the next step
- **AND** the repository SHALL be left in the state git put it in, without hidden cleanup

#### Scenario: The report does not restate the block

- **WHEN** a command prints both a report and the status block
- **THEN** the report SHALL name what the command did — the operation, the commit, the paths, what was left out
- **AND** it SHALL NOT restate the counts, the branch position, or the file list that the block already shows
