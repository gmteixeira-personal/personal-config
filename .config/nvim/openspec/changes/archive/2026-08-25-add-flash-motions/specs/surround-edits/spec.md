## MODIFIED Requirements

### Requirement: The commands do not displace an existing mapping

The commands SHALL be reachable without taking any key sequence that has a meaning in stock Neovim or in this configuration. In particular they SHALL NOT claim bare `s` or bare `S` in normal or operator-pending mode, nor `r` or `R` in operator-pending mode, all of which belong to the jump-motions capability; and SHALL NOT use the `<leader>b`, `<leader>c`, `<leader>f`, `<leader>g`, `<leader>h`, `<leader>m`, `<leader>q`, or `<leader>w` prefixes, nor the `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>`, `<C-n>`, `<C-s>`, `<C-Up>`/`<C-Down>`, `<S-Left>`/`<S-Right>`, or `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` mappings this configuration already defines. The single exception is visual-mode `S`, which the visual add command shadows by design and which the jump-motions capability leaves alone for that reason.

#### Scenario: Bare `s` is not a surround command

- **WHEN** the user presses `s` in normal mode
- **THEN** the jump-motions capability's jump starts
- **AND** no surround command is invoked and no surround command waits on the key

#### Scenario: The existing mappings survive

- **WHEN** the user presses any mapping this configuration defined before this change
- **THEN** it does what it did before
- **AND** no surround command intercepts it

#### Scenario: An operator followed by a non-surround key

- **WHEN** the user presses an operator whose two-key surround form exists, followed by an ordinary motion
- **THEN** the operator applies to that motion with no wait
- **AND** no surround command runs

#### Scenario: The surround commands still resolve

- **WHEN** the user presses `ys`, `ds`, or `cs` followed by their usual arguments
- **THEN** the surround edit is made
- **AND** the `s` in the sequence does not start a jump
