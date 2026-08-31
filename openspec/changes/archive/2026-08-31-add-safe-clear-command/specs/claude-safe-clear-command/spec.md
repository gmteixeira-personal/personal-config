## Purpose

Defines `/safe-clear`, a command that lands the session's work at a point where clearing the context loses only the conversation, and then hands off: what state the work is in, what to type to resume it in an empty context, and how to decline the clear and carry on instead.

## ADDED Requirements

### Requirement: Invocation

The command SHALL be invoked as `/safe-clear`, at the top level of the command namespace rather than within a suite, and SHALL be available in any session regardless of the working directory or of whether it is a git repository.

The command SHALL accept an optional argument naming the boundary to stop at, such as a task number, a file, or a condition like "after the tests pass". With no argument the command SHALL choose the nearest safe point itself.

#### Scenario: Invocation form

- **WHEN** the user types `/safe-clear`
- **THEN** the command SHALL run
- **AND** it SHALL NOT require a git repository or any particular project layout

#### Scenario: Caller names the boundary

- **WHEN** the user types `/safe-clear` with an argument naming where to stop
- **THEN** that boundary SHALL be the safe point the command works toward, provided it satisfies the safe-point conditions

#### Scenario: No argument

- **WHEN** the user types `/safe-clear` with no argument
- **THEN** the command SHALL choose the nearest point satisfying the safe-point conditions
- **AND** it SHALL NOT ask the user where to stop

### Requirement: What counts as a safe point

A safe point SHALL be a state in which discarding the conversation loses nothing else. All of the following SHALL hold:

- no file touched in the session is left half-edited — each one parses and reads as deliberate;
- no background command, agent, or task is still in flight whose result only the current context can interpret;
- nothing in the conversation is pending, including a question awaiting the user and a confirmation half-given;
- the next step can be stated in a sentence or two.

#### Scenario: Half-applied edit is not a safe point

- **WHEN** a rename has been applied to some but not all of its call sites, or a function has been opened and not closed, or an import has been added for a call not yet written
- **THEN** the command SHALL NOT treat the current state as a safe point

#### Scenario: Work still in flight is not a safe point

- **WHEN** a background command or agent started in the session has not finished
- **THEN** the command SHALL NOT treat the current state as a safe point
- **AND** waiting for that work to finish SHALL be a permitted way to reach one

#### Scenario: Already at a safe point

- **WHEN** the command runs and every safe-point condition already holds
- **THEN** it SHALL print the handoff block immediately
- **AND** it SHALL make no edit and run no command in order to do so

### Requirement: Reaching the safe point

The command SHALL be permitted to act in order to reach a safe point: finishing the unit of work in progress, backing out of one whose completion would be substantial further work, or waiting on work already started. Where it backs out rather than finishing, it SHALL say so in the handoff.

The command SHALL NOT start work that was not already in progress, and SHALL NOT perform unrelated cleanups.

#### Scenario: Finishing the in-flight unit

- **WHEN** a small amount of work would bring a half-finished edit to a coherent state
- **THEN** the command SHALL do that work
- **AND** it SHALL NOT treat the extra tool calls as a reason to stop unsafely

#### Scenario: Backing out instead of finishing

- **WHEN** finishing the in-flight unit would be substantial further work
- **THEN** the command SHALL revert it rather than complete it
- **AND** the handoff SHALL state that it was reverted and what it was

#### Scenario: No new work

- **WHEN** the command is choosing what to do to reach the safe point
- **THEN** it SHALL NOT begin the next task, add improvements, or perform cleanups it merely noticed

### Requirement: Nothing is published to reach a safe point

The command SHALL NOT commit, push, or otherwise publish anything as a means of reaching a safe point. Uncommitted work in the tree SHALL NOT by itself prevent a safe point, since clearing the context does not alter the working tree.

#### Scenario: Dirty tree is left dirty

- **WHEN** the safe point is reached with modified files in the working tree
- **THEN** the command SHALL leave them uncommitted
- **AND** it SHALL NOT offer the commit as a precondition of clearing

#### Scenario: Committing only on a separate request

- **WHEN** the user has separately asked for a commit
- **THEN** that commit SHALL be governed by the request that asked for it, not by this command

### Requirement: The context is never cleared by the command

The command SHALL NOT clear the context itself. Clearing SHALL remain an action the user takes.

#### Scenario: Command stops after the handoff

- **WHEN** the handoff block has been printed
- **THEN** the command SHALL stop
- **AND** the context SHALL still hold the conversation until the user clears it

### Requirement: The handoff block

On reaching a safe point the command SHALL print a block that states the safe point is reached, gives the line to type after clearing, and names `continue` as the alternative to clearing. The block SHALL be the whole output: no preamble, no session recap, no closing offer or follow-up question.

#### Scenario: Block contents

- **WHEN** the handoff block is printed
- **THEN** it SHALL state that a safe point for clearing the context has been reached
- **AND** it SHALL present the resume line as copyable text
- **AND** it SHALL state that typing `continue` resumes the work without clearing

#### Scenario: Nothing else is printed

- **WHEN** the command completes successfully
- **THEN** its output SHALL consist of the handoff block alone
- **AND** it SHALL NOT summarize the session, restate the work done, or ask a question

### Requirement: The resume line stands alone

The resume line SHALL be usable as the first message of an empty context. It SHALL name what a reader with no prior conversation needs — the repository path, file, change, or command, and the next action — and SHALL NOT rely on any referent that exists only in the conversation being discarded. It SHALL be one or two sentences. Where an existing slash command expresses the next step, the resume line SHALL start with it.

#### Scenario: No dangling reference

- **WHEN** the resume line is written
- **THEN** it SHALL NOT contain a phrase such as "continue what we discussed", nor a pronoun whose referent is only in the cleared conversation

#### Scenario: Existing command preferred

- **WHEN** the next step is one an existing slash command performs
- **THEN** the resume line SHALL begin with that command and its argument

### Requirement: Handoff state prefers durable artifacts

The command SHALL prefer state already on disk over prose in the handoff: a change's task list with its completed items ticked, a failing test, the working tree itself. It SHALL bring that state up to date before printing the block, and the resume line SHALL point at it.

A written handoff note SHALL be produced only where the state does not fit in the resume line. Such a note SHALL be stored outside the tracked tree, at a path that survives the clear, and the resume line SHALL name that path.

#### Scenario: Existing artifact carries the state

- **WHEN** the work is tracked by a task list or an equivalent on-disk artifact
- **THEN** that artifact SHALL be updated to reflect what is done
- **AND** no separate handoff note SHALL be written

#### Scenario: Handoff note is written

- **WHEN** the state genuinely does not fit in the resume line
- **THEN** a handoff note SHALL be written to a per-machine location that persists across the clear
- **AND** that location SHALL NOT be tracked by the repository
- **AND** the resume line SHALL name the note's path

### Requirement: A safe point that cannot be reached

Where the work is genuinely mid-flight and reaching a safe point would be substantial work, the command SHALL report that in one line, name what is unfinished, and print no handoff block.

#### Scenario: Mid-flight report

- **WHEN** no safe point can be reached
- **THEN** the command SHALL say so in one line and name the unfinished work
- **AND** it SHALL NOT print the handoff block
- **AND** it SHALL NOT suggest that clearing is safe
