## MODIFIED Requirements

### Requirement: Search is case-insensitive until the query says otherwise

A search query typed in all lower case SHALL match regardless of case. A query containing an upper-case character SHALL match case-sensitively. Matches SHALL be shown and the view moved to them as the query is typed.

Once a search is accepted, every match SHALL remain highlighted until the highlight is explicitly dismissed, so that the distribution of a term across the buffer stays visible while the user works with it. Dismissing the highlight is a mapping rather than an option, and is specified by `editor-keymaps`.

#### Scenario: Lower-case query

- **WHEN** the user searches for a term typed entirely in lower case
- **THEN** occurrences are matched irrespective of their case

#### Scenario: Query containing an upper-case character

- **WHEN** the user searches for a term containing at least one upper-case character
- **THEN** only occurrences matching that exact case are matched

#### Scenario: Feedback while typing

- **WHEN** the user is part-way through typing a search query
- **THEN** the first match is already shown and the view has moved to it
- **AND** the display updates as further characters are typed

#### Scenario: Highlight persists after the search

- **WHEN** the user accepts a search and returns to editing
- **THEN** every occurrence of the term remains highlighted
- **AND** the highlighting survives cursor movement and editing elsewhere in the buffer

#### Scenario: Highlight is dismissed deliberately

- **WHEN** matches are highlighted and the user dismisses the highlight
- **THEN** no matches remain highlighted
- **AND** the search pattern and search history are retained, so `n` and `N` still work

#### Scenario: Abandoning a search

- **WHEN** the user cancels a search part-way through typing
- **THEN** the cursor returns to where it was before the search began
