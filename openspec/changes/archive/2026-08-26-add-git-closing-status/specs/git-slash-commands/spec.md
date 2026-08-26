## ADDED Requirements

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

## MODIFIED Requirements

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
