## Purpose

Defines what the Claude Code status line reports and the form each field takes, so that a line sharing its width with the prompt spends every character on a value rather than on a word naming the value that follows it.

## Requirements

### Requirement: A field is identified by its value, not by a label

A status line field whose value already identifies what it is SHALL be rendered as that value alone. No field SHALL carry a word, prefix, or key naming the field, where the set of values the field can take is enough to recognise it.

This applies to the caveman intensity, which SHALL render as its level alone — `LITE`, `OFF`, `FULL`, and the rest — and not as a name-and-value pair.

#### Scenario: The caveman badge at a named intensity

- **WHEN** the caveman style is at its `lite` intensity
- **THEN** the status line SHALL show `LITE`
- **AND** it SHALL NOT show the word `CAVEMAN` or a colon before the level

#### Scenario: The caveman badge when the style is off

- **WHEN** the caveman style is off, or no intensity has been recorded
- **THEN** the status line SHALL show `OFF`
- **AND** the badge SHALL be present rather than omitted, so its position on the line does not move between sessions

#### Scenario: A label that carries no information

- **WHEN** a field is added to the status line whose possible values name the field on sight
- **THEN** it is rendered as the value alone
- **AND** no label is added in front of it

### Requirement: The model badge names the family and the effort

The model field SHALL show the model's family name and its effort level, joined by a colon and nothing else. The family name is the model's display name up to the first space, so a version number, a context-window note, or any other qualifier SHALL NOT appear. The word `effort` SHALL NOT appear.

Where a field has no value, the separator that would have joined it SHALL NOT be rendered.

#### Scenario: A model with a version in its display name

- **WHEN** the session reports a display name of `Opus 5` and an effort level of `xhigh`
- **THEN** the status line SHALL show `Opus:xhigh`

#### Scenario: A model whose family is more than one word long

- **WHEN** the session reports a display name whose first word is the family — `Haiku 4.5`, `Sonnet 5`, `Fable 5`
- **THEN** the status line SHALL show that first word and the effort level, joined by a colon

#### Scenario: No effort level reported

- **WHEN** the session reports a display name but no effort level
- **THEN** the status line SHALL show the family name alone
- **AND** no trailing colon SHALL be left behind

#### Scenario: Fast mode is on

- **WHEN** the session reports fast mode
- **THEN** the fast-mode marker SHALL still be shown against the model
- **AND** the family name and effort SHALL be unchanged by it

### Requirement: The directory and branch are joined by a colon

Where the working directory is in a git repository, the status line SHALL show the directory name and the branch joined by a colon, with no space on either side and no word between them.

#### Scenario: A directory on a branch

- **WHEN** the working directory is `personal-config` and the checked-out branch is `main`
- **THEN** the status line SHALL open with `personal-config:main`
- **AND** the word `on` SHALL NOT appear

#### Scenario: A detached HEAD

- **WHEN** the working directory is in a repository with no branch checked out
- **THEN** the short commit hash SHALL take the branch's place after the colon

#### Scenario: Not a repository at all

- **WHEN** the working directory is not in a git repository
- **THEN** the status line SHALL show the directory name alone
- **AND** no colon SHALL be left behind
