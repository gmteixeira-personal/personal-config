## ADDED Requirements

### Requirement: The candidate list is driven by a fixed set of keys

While the candidate list is open, `<Tab>` SHALL accept the selected candidate, `<C-j>` SHALL move the selection down and `<C-k>` SHALL move it up. `<C-j>` and `<C-k>` SHALL be the same down/up pair the fuzzy finder's prompt uses for its result list, so one idiom moves through every list this configuration puts on screen.

These keys SHALL be additions. The keys already accepting (`<C-y>`), dismissing (`<C-e>`), opening (`<C-space>`) and moving through (`<C-n>`/`<C-p>`) the list SHALL keep working unchanged.

Accepting SHALL remain explicit: `<Tab>` is a second accept key, and no candidate SHALL be inserted by the list merely appearing or narrowing.

#### Scenario: Accepting with `<Tab>`

- **WHEN** the candidate list is open with a candidate selected and the user presses `<Tab>`
- **THEN** the typed prefix is replaced by the full candidate text
- **AND** the list closes
- **AND** insert mode continues at the end of the inserted text

#### Scenario: Moving through the list

- **WHEN** the candidate list is open and the user presses `<C-j>`
- **THEN** the selection moves to the next candidate
- **AND** pressing `<C-k>` moves it back to the previous one
- **AND** no text is inserted by either press

#### Scenario: The pre-existing keys still work

- **WHEN** the candidate list is open
- **THEN** `<C-y>` still accepts, `<C-e>` still dismisses, and `<C-n>`/`<C-p>` still move the selection

### Requirement: Each list key keeps its ordinary meaning when no list is open

`<Tab>`, `<C-j>` and `<C-k>` SHALL only take on their list meaning while the candidate list is open. With no list open, each SHALL fall through to what it otherwise does, so binding them to the list costs the user no key they already had.

`<Tab>` SHALL fall through to jumping to the next snippet placeholder when the cursor is inside an expanded snippet, and to inserting indentation otherwise. `<C-k>` SHALL fall through to toggling the signature window, and to its stock insert-mode meaning when there is no signature to show. `<C-j>` SHALL fall through to its stock insert-mode meaning.

The normal-mode window-focus mappings on `<C-j>` and `<C-k>` SHALL be unaffected, since the list bindings exist only in insert mode.

#### Scenario: `<Tab>` with no list open

- **WHEN** no candidate list is open, the cursor is not inside a snippet, and the user presses `<Tab>`
- **THEN** indentation is inserted as it would be without any completion plugin

#### Scenario: `<Tab>` inside a snippet

- **WHEN** a snippet has been expanded, its placeholder is active, no candidate list is open, and the user presses `<Tab>`
- **THEN** the cursor jumps to the next placeholder

#### Scenario: `<C-k>` with no list open

- **WHEN** no candidate list is open and the user presses `<C-k>` inside a call the language server can describe
- **THEN** the signature window is toggled
- **AND** no candidate is selected or inserted

#### Scenario: Moving between windows

- **WHEN** the user presses `<C-j>` or `<C-k>` in normal mode
- **THEN** focus moves to the window below or above, as it did before this change
