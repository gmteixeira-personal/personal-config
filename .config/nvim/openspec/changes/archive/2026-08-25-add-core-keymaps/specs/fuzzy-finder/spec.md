## ADDED Requirements

### Requirement: `<leader>g` opens pickers over git

The user SHALL be able to fuzzy-find over the state of the repository containing the current working directory, from a two-key sequence beginning `<leader>g`, covering:

- **Tracked files** — the files git knows about, as distinct from every file on disk, so that ignored and untracked files are excluded.
- **Working-tree status** — the files that differ from the index or the last commit, with selection opening the file.
- **Commit log** — the repository's commits, with selection showing that commit's diff.
- **Branches** — the repository's branches, with selection checking one out.

`<leader>g` SHALL NOT itself be bound as a mapping, so that no sequence under it waits out a key-sequence timeout. These mappings SHALL be declared in the fuzzy finder's own plugin file.

#### Scenario: Finding a tracked file

- **WHEN** the working directory is a git repository containing both tracked and ignored files
- **AND** the user opens the tracked-files picker and types a fragment
- **THEN** the list narrows to tracked files matching that fragment
- **AND** no ignored or untracked file appears in the list

#### Scenario: Reviewing what has changed

- **WHEN** several files differ from the index
- **AND** the user opens the status picker
- **THEN** those files are listed
- **AND** selecting one opens it in the window the picker was invoked from

#### Scenario: Browsing the log

- **WHEN** the user opens the commit picker and selects a commit
- **THEN** that commit's changes are displayed

#### Scenario: Switching branch

- **WHEN** the repository has more than one branch
- **AND** the user opens the branch picker and selects one
- **THEN** that branch is checked out

#### Scenario: Outside a git repository

- **WHEN** the working directory is not inside a git repository
- **AND** the user opens any of these pickers
- **THEN** the user is told the directory is not a git repository
- **AND** no error trace is shown and the editor remains usable

#### Scenario: No mapping stalls on the git prefix

- **WHEN** the user presses `<leader>g`
- **THEN** nothing is executed and no action is deferred pending a timeout
- **AND** the editor waits for the next key of the sequence

### Requirement: `<Esc>` closes an open picker

Pressing `<Esc>` while a picker's prompt has focus SHALL close the picker immediately and return to the buffer it was invoked from, rather than leaving the picker open in its own normal mode. The buffer, cursor position and window layout SHALL be exactly as they were before the picker opened.

#### Scenario: Dismissing a picker mid-query

- **WHEN** a picker is open and the user has typed part of a query
- **AND** the user presses `<Esc>`
- **THEN** the picker closes
- **AND** the buffer and cursor position are exactly as they were before it opened

#### Scenario: One press is enough

- **WHEN** a picker is open with its prompt focused and the user presses `<Esc>` once
- **THEN** the picker is closed
- **AND** no second key is needed to leave it

#### Scenario: Every picker behaves the same way

- **WHEN** any of this capability's pickers is open
- **THEN** `<Esc>` closes it
- **AND** the behaviour does not differ between pickers

### Requirement: `<C-j>` and `<C-k>` move through picker results

While a picker's prompt has focus, `<C-j>` SHALL move the selection to the next result and `<C-k>` to the previous one, without leaving the prompt or interrupting the query being typed. The keys SHALL work alongside, not instead of, whatever result-navigation keys the picker already provides.

These mappings SHALL apply only within a picker prompt. In every other buffer `<C-j>` and `<C-k>` SHALL retain the window-navigation behaviour specified by `editor-keymaps`.

#### Scenario: Stepping down the result list

- **WHEN** a picker is open with several results and the first is selected
- **AND** the user presses `<C-j>`
- **THEN** the second result becomes selected
- **AND** the prompt still has focus and the typed query is unchanged

#### Scenario: Stepping back up

- **WHEN** a result below the first is selected and the user presses `<C-k>`
- **THEN** the previous result becomes selected

#### Scenario: Navigating then refining the query

- **WHEN** the user has moved the selection with `<C-j>` and then types another character
- **THEN** the query is extended by that character
- **AND** the result list narrows accordingly

#### Scenario: Opening the navigated-to result

- **WHEN** the user has moved the selection with `<C-j>` or `<C-k>` and accepts the selection
- **THEN** the result that was selected is the one opened

#### Scenario: Window navigation is unaffected outside a picker

- **WHEN** no picker is open and the user presses `<C-j>` in a normal buffer
- **THEN** focus moves to the window below, per `editor-keymaps`
