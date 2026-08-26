## Purpose

Offers candidate completions as the user types, drawn from the attached language server and from the surrounding context, so that symbols, paths, and snippets can be inserted without typing them in full or leaving the buffer to look them up.

## Requirements

### Requirement: Candidates appear automatically while typing

In insert mode, a candidate list SHALL appear as the user types, without an explicit trigger key, and SHALL narrow as further characters are typed. Dismissing the list SHALL leave the typed text exactly as entered.

#### Scenario: Typing an identifier prefix

- **WHEN** the user types the first characters of an identifier in insert mode
- **THEN** a list of matching candidates appears
- **AND** it narrows as more characters are typed

#### Scenario: Accepting a candidate

- **WHEN** a candidate is selected and the user accepts it
- **THEN** the typed prefix is replaced by the full candidate text
- **AND** insert mode continues at the end of the inserted text

#### Scenario: Dismissing the list

- **WHEN** the candidate list is open and the user dismisses it
- **THEN** the list closes
- **AND** the text typed so far is left exactly as it was
- **AND** insert mode continues

#### Scenario: No candidates

- **WHEN** nothing matches what the user has typed
- **THEN** no list is shown
- **AND** typing continues uninterrupted

### Requirement: Candidates come from multiple sources

The candidate list SHALL draw from the attached language server, from words present in open buffers, from filesystem paths, and from snippets. Sources SHALL be merged into a single list rather than presented separately.

#### Scenario: Language-server candidates

- **WHEN** the user types inside a buffer with an attached server
- **THEN** the server's candidates appear, carrying the kind and detail the server reports

#### Scenario: Path candidates

- **WHEN** the user types a filesystem path fragment
- **THEN** matching paths appear as candidates

#### Scenario: Candidates with no server attached

- **WHEN** the user types in a buffer with no attached language server
- **THEN** buffer-word, path, and snippet candidates still appear
- **AND** no error is raised about the missing server

### Requirement: Completion does not interfere with ordinary editing

The candidate list SHALL NOT change the meaning of a keystroke that is not a completion action. Text typed while the list is open SHALL be inserted normally, and no candidate SHALL be inserted without the user explicitly accepting it.

#### Scenario: Nothing is inserted implicitly

- **WHEN** the candidate list is open with an entry highlighted
- **AND** the user continues typing ordinary characters
- **THEN** exactly those characters are inserted
- **AND** the highlighted candidate is not inserted

#### Scenario: Leaving insert mode

- **WHEN** the candidate list is open and the user leaves insert mode
- **THEN** the list closes
- **AND** no candidate is inserted
