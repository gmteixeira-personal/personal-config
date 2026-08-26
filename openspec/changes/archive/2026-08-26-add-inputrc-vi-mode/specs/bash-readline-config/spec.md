## Purpose

Defines how the interactive bash command line is edited: vi key bindings instead of the emacs default, a cursor shape that reveals which editing mode is active, and a user-level readline file that layers on the system-wide one rather than replacing it.

## ADDED Requirements

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
