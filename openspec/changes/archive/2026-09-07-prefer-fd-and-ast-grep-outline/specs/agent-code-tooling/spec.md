## Purpose

Records which tools an agent working on this machine reaches for when it finds, reads, and rewrites code, and states where that instruction is written so that it reaches every project rather than one. An agent that is told nothing falls back to what it can assume exists — `find`, a regular expression, a whole-file read — and the tools installed here that answer those questions better go unused because nothing announces them.

## ADDED Requirements

### Requirement: Tool preferences are stated once, in the user-level instruction file

A preference about which tool an agent reaches for SHALL be written in the user-level Claude Code instruction file, `.claude/CLAUDE.md`, which is read at the start of every session in every project on this machine.

It SHALL NOT be restated in an individual project's instructions. A preference of this kind is a fact about the machine rather than about a repository: the tool is installed here or it is not, and a copy per project is a copy that goes stale in every project but the one edited.

The file SHALL be tracked in this repository, so that the preference travels with the configuration rather than existing only on the machine where it was typed.

A note there SHALL be a preference an agent applies, not a permission it asks for. It states which tool wins the ordinary case and which cases it does not win, and an agent that finds a case the note does not cover chooses for itself rather than stopping.

#### Scenario: The preference reaches a project this repository knows nothing about

- **WHEN** an agent starts in any directory on this machine, including a repository with no instruction file of its own
- **THEN** it SHALL have read the tooling notes from `.claude/CLAUDE.md`
- **AND** the notes SHALL apply there without that project declaring anything

#### Scenario: The note is not copied per project

- **WHEN** a tool preference that holds for every project is recorded
- **THEN** it SHALL be written in the user-level file
- **AND** it SHALL NOT be duplicated into a project's own instruction file

#### Scenario: The file is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** `.claude/CLAUDE.md` SHALL appear

#### Scenario: A note states both sides of the preference

- **WHEN** a tooling note is read
- **THEN** it SHALL name the case the tool wins
- **AND** it SHALL name the case that still belongs to the tool it displaces, so that the preference cannot be read as a claim that the displaced tool is never correct

### Requirement: fd locates files and directories in place of find

The instruction file SHALL state that `fd` is installed and that it, not `find`, is what an agent uses to locate a file or a directory.

The note SHALL state the behaviour a `find` habit gets wrong, because each difference is a silent wrong answer rather than an error:

- The pattern is a regular expression matched against the **file name**, not the whole path, and `-p` is what matches the full path.
- `-g` selects glob matching instead, for the cases where a glob is what is meant.
- A directory to search in is a second positional argument, after the pattern. `find`'s order — the path first — does not work, and a lone directory is read as a pattern and refused.
- Paths matched by a `.gitignore` rule, and `.git` itself, are skipped unless `-H -I` asks for them.

The note SHALL carry the forms an agent reaches for often enough to be worth not re-deriving: restriction by extension, restriction to files or to directories, and running a command against each match or against all of them at once.

The note SHALL name the cases that remain `find`'s — the predicates `fd` does not have, such as matching on modification time or permissions, and pruning logic complex enough that expressing it is the point.

#### Scenario: The preference is stated rather than the mere installation

- **WHEN** the note is read
- **THEN** it SHALL state that `fd` is preferred over `find` for locating a file or a directory
- **AND** naming the tool's presence alone SHALL NOT be sufficient

#### Scenario: The default scope is stated

- **WHEN** a reader asks whether a search covers ignored or hidden files
- **THEN** the note SHALL state that `.gitignore`d paths and `.git` are skipped by default
- **AND** it SHALL name the flags that include them

#### Scenario: The pattern's meaning is stated

- **WHEN** a reader writes a pattern
- **THEN** the note SHALL state that it is a regular expression against the file name by default
- **AND** it SHALL name the flag that switches to a glob and the flag that matches the whole path
- **AND** it SHALL state that a directory to search in follows the pattern rather than preceding it

#### Scenario: Every example is a command that runs

- **WHEN** an example in the note is copied and run
- **THEN** it SHALL be accepted by `fd` as written
- **AND** no example SHALL delete or modify a file, so that copying one costs nothing to find out

#### Scenario: find keeps what fd does not cover

- **WHEN** a search needs a predicate `fd` does not have
- **THEN** the note SHALL direct the reader back to `find`
- **AND** it SHALL name examples rather than leaving the boundary to be discovered

#### Scenario: Absence is tolerated

- **WHEN** an agent runs on a machine where `fd` is not installed
- **THEN** the work SHALL still complete through `find`
- **AND** nothing in the configuration SHALL fail because the preferred tool is missing

### Requirement: ast-grep performs syntax-aware search and rewrite

The instruction file SHALL state that `ast-grep` is installed and that it, not a per-file edit loop and not a regular expression over `sed` or `grep`, is what performs a multi-file syntax-aware search or rewrite: a rename, a change of call pattern, a reordering of arguments, an API migration.

The note SHALL carry the search form and the in-place rewrite form, the difference between a single-node capture and a multi-node capture, and how the language is selected.

The note SHALL state that matches are reviewed before they are applied, so that an in-place rewrite across a repository is a second command rather than the first one.

The note SHALL name the case that remains plain `grep`'s: a target that is not syntax — a comment, a string, a configuration file, a line of log output.

#### Scenario: A multi-file rewrite does not become an edit loop

- **WHEN** the same change has to be made across more than one file and the change is structural
- **THEN** the note SHALL direct the agent to `ast-grep`
- **AND** it SHALL name the per-file edit loop and the regular expression as the things it displaces

#### Scenario: Matches are reviewed before they are applied

- **WHEN** an in-place rewrite is described
- **THEN** the note SHALL state that the search runs first without the flag that writes
- **AND** the writing flag SHALL be named separately rather than shown only as part of one combined command

#### Scenario: grep keeps what is not syntax

- **WHEN** the target of a search is a comment, a string, a configuration file, or log output
- **THEN** the note SHALL direct the reader to plain `grep`

### Requirement: A large file is mapped before it is read whole

The instruction file SHALL state that `ast-grep outline` lists a file's symbols, imports, exports, and members, and that this is what an agent runs before reading a large file.

The note SHALL state what the mapping is for: reading the ranges that matter instead of the whole file. Without that, the command reads as one more way to search, and the reason it is worth a command of its own — that the alternative is pulling an entire file into context to find out where two functions are — is lost.

#### Scenario: The command is named with its purpose

- **WHEN** the note is read
- **THEN** it SHALL name `ast-grep outline` and what it lists
- **AND** it SHALL state that the mapping exists so that only the interesting ranges are read

#### Scenario: Mapping precedes a large read

- **WHEN** an agent needs a symbol in a file large enough that reading it whole is costly
- **THEN** the note SHALL direct it to map the file first
- **AND** reading the whole file SHALL NOT be the documented first move
