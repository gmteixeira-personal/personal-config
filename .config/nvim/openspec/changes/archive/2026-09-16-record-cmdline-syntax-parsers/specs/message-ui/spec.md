## ADDED Requirements

### Requirement: The command-line input is highlighted for the kind of input it is, and what that needs is written down

The floating command-line input SHALL be syntax-highlighted according to what is being entered: a search pattern as a regular expression, a shell command line as shell. Where the editor bundles neither the grammar nor its highlighting query for one of those languages, this capability SHALL NOT gain a parser-management plugin; the files SHALL be installed on the machine, outside this repository, and the configuration SHALL record what they are and how to produce them.

A compiled grammar is not a thing to track here, and a highlighting query belongs to a version of a grammar rather than to this configuration. That leaves the repository able to hold only the statement of what is required, which is precisely what was missing: the two languages were absent on the machine for as long as this capability existed, the editor's health report said so on every run, and the configuration said the opposite.

The record SHALL name both halves. A grammar on its own changes nothing — this capability asks for the language's highlighting query and gives up quietly when there is none — so naming only the grammar describes a state that still renders the input as plain text. It SHALL name the paths both halves are installed at, the command that produces the grammar, and where the query comes from.

The grammar SHALL be pinned to the revision the query is written against, and the record SHALL say why: a query matches a grammar's node names, and a newer grammar can rename a node and leave the query matching nothing, which fails as unhighlighted text rather than as an error.

Absence SHALL remain a degradation rather than a fault. On a machine without the files, the affected inputs SHALL render unhighlighted, every other part of this capability SHALL work, and the editor's health report SHALL be what says they are missing.

#### Scenario: A search pattern is highlighted

- **WHEN** a search is opened from the floating command line and a pattern is typed
- **THEN** the pattern SHALL be highlighted as a regular expression

#### Scenario: A shell command line is highlighted

- **WHEN** a shell command line is opened from the floating command line
- **THEN** what is typed SHALL be highlighted as shell

#### Scenario: No parser-management plugin is added

- **WHEN** the plugin list is inspected
- **THEN** it SHALL contain no plugin whose purpose is installing or updating grammars

#### Scenario: Both halves are recorded

- **WHEN** the configuration for this capability is read
- **THEN** it SHALL name the installed path of each grammar and of each highlighting query
- **AND** it SHALL state that a grammar without its query changes nothing

#### Scenario: The record is enough to rebuild from

- **WHEN** the same files have to be produced on another machine
- **THEN** the configuration SHALL name the source of each grammar and each query
- **AND** it SHALL give the command that builds a grammar

#### Scenario: The grammar is pinned to its query

- **WHEN** the recorded grammar revisions are read
- **THEN** each SHALL be the revision the corresponding query is written against
- **AND** the configuration SHALL state that an unpinned grammar can leave the query matching nothing

#### Scenario: A machine without them still works

- **WHEN** the editor starts where the grammars are not installed
- **THEN** the floating command line SHALL still open
- **AND** the affected inputs SHALL render unhighlighted
- **AND** no error SHALL be raised
