## MODIFIED Requirements

### Requirement: Windows are split and closed under a `<leader>s` prefix

The user SHALL be able to split the current window vertically, split it horizontally, close the focused window, and equalize all window sizes, each from a two-key sequence beginning `<leader>s`. `<leader>s` SHALL NOT be bound to any command of its own, so that pressing it executes nothing and the sequence under it completes on the next key without waiting out a key-sequence timeout. A component that only describes the mappings under a prefix — see `keymap-hints` — MAY attach itself to `<leader>s`, since it runs no command and delays no completion.

#### Scenario: Splitting vertically

- **WHEN** the user invokes the vertical split mapping
- **THEN** a second window showing the same buffer opens beside the current one

#### Scenario: Splitting horizontally

- **WHEN** the user invokes the horizontal split mapping
- **THEN** a second window showing the same buffer opens above or below the current one

#### Scenario: Closing a window

- **WHEN** two or more windows are open and the user invokes the close mapping
- **THEN** the focused window closes
- **AND** its buffer remains loaded

#### Scenario: Equalizing

- **WHEN** windows are of unequal size and the user invokes the equalize mapping
- **THEN** all windows in the tab page are given equal size

#### Scenario: No mapping stalls on the split prefix

- **WHEN** the user presses `<leader>s`
- **THEN** no split, close, or equalize command is executed and none is deferred pending a timeout
- **AND** the editor waits for the next key of the sequence

#### Scenario: Completing the sequence after the prefix

- **WHEN** the user presses `<leader>s` and then the key of one of these mappings
- **THEN** that mapping runs
- **AND** it is not delayed by anything attached to the prefix
