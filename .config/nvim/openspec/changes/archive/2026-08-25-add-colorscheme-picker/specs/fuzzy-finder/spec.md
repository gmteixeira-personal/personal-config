## ADDED Requirements

### Requirement: `<leader>ft` previews and switches colorscheme

Pressing `<leader>ft` SHALL open a picker over the colorschemes available to the configuration — every variant of every installed theme, together with the editor's bundled colorschemes. A theme whose plugin has not been loaded yet SHALL be listed alongside the rest, per the availability requirement in `colorscheme`. Typing SHALL narrow the list by fuzzy-matching against colorscheme names.

The picker SHALL preview live: whenever the selection moves to a different entry, that colorscheme SHALL be applied to the visible buffer immediately, so a theme is judged against real code rather than a name alone.

Accepting an entry SHALL leave that colorscheme active. Dismissing the picker SHALL restore the colorscheme that was active before it opened, including the value of `background`. Neither outcome writes to disk; persistence across restarts is out of scope and is specified by `colorscheme`.

Like every mapping in this capability, `<leader>ft` SHALL be declared in the fuzzy finder's own plugin file, and `<leader>f` SHALL remain unbound as a mapping in its own right.

#### Scenario: Stepping through themes

- **WHEN** a file is open and the user presses `<leader>ft` and moves the selection down the list
- **THEN** the buffer repaints in the highlighted colorscheme as each entry becomes selected
- **AND** the buffer's contents and the cursor position are unchanged

#### Scenario: Previewing a theme that has not been loaded

- **WHEN** the selection moves to a colorscheme whose plugin has not yet loaded
- **THEN** that colorscheme is loaded and previewed like any other entry
- **AND** the user takes no additional step and sees no error

#### Scenario: Keeping a theme

- **WHEN** the user selects a colorscheme in the picker and accepts it
- **THEN** the picker closes
- **AND** that colorscheme remains active in the session

#### Scenario: Backing out restores the previous theme

- **WHEN** the user has previewed one or more colorschemes and then dismisses the picker with `<Esc>`
- **THEN** the picker closes
- **AND** the colorscheme active before the picker opened is active again

#### Scenario: Narrowing by name

- **WHEN** the user presses `<leader>ft` and types a fragment of a colorscheme's name
- **THEN** the list narrows to colorschemes whose names fuzzy-match that fragment

#### Scenario: The find prefix still does not stall

- **WHEN** the user presses `<leader>f`
- **THEN** nothing is executed and no action is deferred pending a timeout
- **AND** the editor waits for the next key of the sequence
