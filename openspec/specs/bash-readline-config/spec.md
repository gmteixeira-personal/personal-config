## Purpose

Defines how the interactive bash command line is edited: vi key bindings instead of the emacs default, a cursor shape that reveals which editing mode is active, and a user-level readline file that layers on the system-wide one rather than replacing it.

## Requirements

### Requirement: Vi editing mode is the default

Every interactive bash session SHALL start with readline in vi editing mode, without the user running any command. The setting SHALL live in the user readline initialization file, which readline reads on its own; no `.bashrc` line SHALL be required to load it.

#### Scenario: Vi mode is active in a new shell

- **WHEN** a new interactive bash session starts
- **THEN** `bind -V` SHALL report the editing mode as vi

#### Scenario: No shell startup file loads it

- **WHEN** `.bashrc`, `.profile`, and `.bash_logout` are inspected
- **THEN** none SHALL contain a `bind -f` call or an `editing-mode` setting for this purpose

#### Scenario: Vi motions operate on the command line

- **WHEN** the user presses Escape and then a vi motion or operator such as `b`, `w`, `dd`, or `ciw`
- **THEN** the command line SHALL be edited accordingly rather than the keys being inserted as text

### Requirement: Cursor shape reports the editing mode

The terminal cursor SHALL indicate the active readline mode: the terminal's own configured cursor shape while in normal (command) mode, and a blinking beam while in insert mode. Normal mode SHALL be signalled by resetting the cursor to that configured shape rather than by naming a shape, so the indicator follows whatever the terminal profile sets — an empty box in this environment. The indicator SHALL be emitted as cursor-shape escape sequences only, contributing no visible characters to the prompt.

#### Scenario: Normal mode shows the terminal's own cursor shape

- **WHEN** the user presses Escape at the prompt
- **THEN** the cursor SHALL be reset to the shape configured by the terminal profile
- **AND** with that profile set to an empty box, the cursor SHALL be drawn as an empty box

#### Scenario: Insert mode shows a beam cursor

- **WHEN** the user enters insert mode, including at the start of a fresh prompt
- **THEN** the cursor SHALL be drawn as a blinking beam

#### Scenario: Indicator occupies no prompt columns

- **WHEN** the mode strings are configured
- **THEN** each SHALL wrap its escape sequence in the readline non-printing markers
- **AND** the prompt SHALL keep its existing text, alignment, and line-wrapping behaviour

#### Scenario: A fresh prompt starts in insert mode

- **WHEN** a command finishes and the next prompt is drawn
- **THEN** readline SHALL be in insert mode
- **AND** the cursor SHALL show the insert-mode shape, since readline does not begin a line in normal mode

### Requirement: The cursor is handed back to the terminal before a command runs

Readline repaints the cursor only when the editing mode changes, so the shape showing when the line is accepted — always the insert-mode shape, since a prompt begins in insert mode — is the shape the command inherits. The shell SHALL therefore reset the cursor to the terminal's configured shape after the command line is read and before the command is executed, so that a program which sets no cursor of its own runs with the terminal's shape rather than with the shell's mode indicator.

The reset SHALL restore the shape the terminal profile specifies rather than naming a shape, consistent with how normal mode is signalled. It SHALL apply to every command rather than being configured per program, and it SHALL contribute no visible characters.

#### Scenario: A program that sets no cursor of its own

- **WHEN** the user runs a full-screen program that never emits a cursor-shape sequence
- **THEN** that program SHALL display the terminal's configured cursor shape
- **AND** SHALL NOT display the insert-mode beam

#### Scenario: A program that manages its own cursor

- **WHEN** the user runs a program that sets its own cursor shape
- **THEN** that program's own shape SHALL apply, having been set after the reset

#### Scenario: The mode indicator survives

- **WHEN** the command finishes and the next prompt is drawn
- **THEN** readline SHALL be in insert mode and the cursor SHALL show the beam
- **AND** pressing Escape SHALL still return the cursor to the terminal's configured shape

#### Scenario: The reset is not per program

- **WHEN** the shell configuration is inspected
- **THEN** the reset SHALL be configured once for all commands
- **AND** no alias or wrapper SHALL exist that resets the cursor for one named program

#### Scenario: The prompt is unchanged

- **WHEN** the reset is in effect
- **THEN** the prompt SHALL keep its existing text, alignment, and line-wrapping behaviour
- **AND** an empty command line SHALL produce no reset, since no command runs

### Requirement: System-wide readline defaults are preserved

Because readline reads the user initialization file instead of the system-wide one when both exist, the user file SHALL include the system-wide file so its defaults remain in effect.

#### Scenario: System file is included

- **WHEN** the user readline initialization file is inspected
- **THEN** it SHALL include `/etc/inputrc`
- **AND** the include SHALL precede the settings that are meant to override it

#### Scenario: System defaults survive

- **WHEN** an interactive bash session starts with the user file in place
- **THEN** the key bindings and settings defined by the system-wide file SHALL still apply, except where a later setting in the user file deliberately overrides them

### Requirement: Readline configuration is tracked

The user readline initialization file SHALL be tracked by the home repository, alongside the other shell configuration files, so it is carried to every environment.

#### Scenario: File is trackable

- **WHEN** the root ignore file is inspected
- **THEN** it SHALL carry an explicit allowlist entry for `/.inputrc`
- **AND** `git check-ignore -v .inputrc` SHALL attribute the path to that allowlist entry
- **AND** `git status` SHALL list the file rather than ignoring it

#### Scenario: File is committed

- **WHEN** `git ls-files` runs after the change is implemented
- **THEN** `.inputrc` SHALL appear

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
