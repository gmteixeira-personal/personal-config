## ADDED Requirements

### Requirement: Hover and signature documentation is rendered as formatted markdown

Documentation a server returns for hover and for signature help SHALL be rendered as formatted markdown rather than as the raw text of the response: headings, emphasis, and inline code SHALL be styled, and a fenced code block SHALL be highlighted as the language the fence names. Where the server names no language, the code block SHALL be highlighted as the filetype of the buffer the request came from.

Documentation longer than the float SHALL be scrollable without the float closing, and the keys that scroll it SHALL be usable from the buffer, so that reading long documentation does not require moving focus into the float first. Pressing them when no such float is open SHALL leave their built-in page-scrolling behaviour intact.

Rendering SHALL be presentation only: the text displayed SHALL be the documentation the server sent, and no request, key, or buffer state changes because of how it is drawn. `K` SHALL remain bound as `language-servers` already requires, and the float SHALL still be dismissed by cursor movement.

#### Scenario: A code block in hover documentation

- **WHEN** the user presses `K` on a symbol whose documentation contains a fenced code block
- **THEN** the block is displayed with syntax highlighting for the language the fence names
- **AND** the surrounding prose is rendered with its markdown styling applied

#### Scenario: Scrolling long documentation

- **WHEN** the documentation is longer than the float can show
- **AND** the user presses the float-scroll key
- **THEN** the float scrolls
- **AND** it stays open
- **AND** the cursor has not left the buffer

#### Scenario: The scroll keys outside a float

- **WHEN** no documentation float is open and the user presses the same key
- **THEN** the buffer scrolls by a page as it always has

#### Scenario: Dismissal is unchanged

- **WHEN** a documentation float is open and the user moves the cursor
- **THEN** the float is dismissed
- **AND** the text it covered is redrawn intact

#### Scenario: No server attached

- **WHEN** the user presses `K` in a buffer with no attached server
- **THEN** the built-in behaviour of `K` applies
- **AND** no float is drawn by this capability

### Requirement: Server progress is reported while it runs

Progress a server reports while it works — indexing a workspace, loading a project, restoring a package cache — SHALL be shown to the user while it is in progress, identifying the server it came from, and SHALL be removed once that work completes. Progress SHALL NOT be silently discarded, so that a server that has attached but is not yet answering requests is distinguishable from one that has failed.

Progress SHALL NOT block the editor, take focus, or move the cursor; the buffer SHALL remain editable throughout.

#### Scenario: A workspace being indexed

- **WHEN** a server attaches and begins indexing the workspace
- **THEN** the user is shown that the work is in progress
- **AND** the message names the server reporting it

#### Scenario: Progress completes

- **WHEN** the server reports the work finished
- **THEN** the progress display is removed
- **AND** nothing is left on screen for it

#### Scenario: Editing during progress

- **WHEN** the user types while a server is reporting progress
- **THEN** every keystroke is inserted into the buffer
- **AND** the cursor stays where the user put it

#### Scenario: A server that reports no progress

- **WHEN** a server attaches without reporting progress
- **THEN** nothing is displayed for it
- **AND** no error is raised
