## MODIFIED Requirements

### Requirement: Hover and signature documentation is rendered as formatted markdown

Documentation a server returns for hover and for signature help SHALL be rendered as formatted markdown rather than as the raw text of the response: headings, emphasis, and inline code SHALL be styled, and a fenced code block SHALL be highlighted as the language the fence names. Where the server names no language, the code block SHALL be highlighted as the filetype of the buffer the request came from.

Documentation longer than the float SHALL be scrollable without the float closing, and the keys that scroll it SHALL be usable from the buffer, so that reading long documentation does not require moving focus into the float first. Pressing them when no such float is open SHALL scroll the buffer by a page as the `scrolling` capability defines a page, which is not the editor's built-in page scroll.

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
- **THEN** the buffer scrolls by one page
- **AND** the page is the whole window, as the `scrolling` capability requires

#### Scenario: Dismissal is unchanged

- **WHEN** a documentation float is open and the user moves the cursor
- **THEN** the float is dismissed
- **AND** the text it covered is redrawn intact

#### Scenario: No server attached

- **WHEN** the user presses `K` in a buffer with no attached server
- **THEN** the built-in behaviour of `K` applies
- **AND** no float is drawn by this capability
