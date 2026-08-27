## ADDED Requirements

### Requirement: The screen can be cleared from either vi mode

`Ctrl-L` SHALL clear the screen and redraw the prompt in both of readline's vi keymaps, so the keystroke behaves the same whether the line is being typed or a vi motion is being used. The binding SHALL be declared for each keymap in the user readline initialization file rather than left to whichever keymap the defaults happen to cover, and rather than being applied by a `bind` call from a shell startup file.

Any text already typed SHALL survive the redraw.

#### Scenario: Cleared while typing

- **WHEN** the user presses `Ctrl-L` at a prompt in insert mode
- **THEN** the screen SHALL be cleared
- **AND** the prompt SHALL be redrawn at the top with the partially typed line intact

#### Scenario: Cleared in command mode

- **WHEN** the user presses Escape and then `Ctrl-L`
- **THEN** the screen SHALL be cleared and the prompt redrawn
- **AND** readline SHALL remain in command mode

#### Scenario: Both keymaps are declared

- **WHEN** the user readline initialization file is inspected
- **THEN** it SHALL bind `Ctrl-L` to `clear-screen` under both the vi command keymap and the vi insert keymap

#### Scenario: Declared in the readline file, not the shell

- **WHEN** `.bashrc`, `.profile`, and `.bash_logout` are inspected
- **THEN** none SHALL contain a `bind` call establishing this binding
