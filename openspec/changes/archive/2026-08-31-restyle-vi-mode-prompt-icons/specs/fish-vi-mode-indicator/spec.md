## Purpose

Defines what the prompt shows to say which vi editing mode the command line is in: that every mode is told apart at a glance, which glyph stands for which mode, and that the assignment travels with the repository rather than living in state a machine happens to hold.

## ADDED Requirements

### Requirement: The prompt says which vi editing mode the command line is in

An interactive shell using vi key bindings SHALL show, at the prompt, which editing mode the command line is currently in. That indication SHALL be present at every prompt, not only after a mode change, and SHALL update as soon as the mode changes rather than at the next command.

Every mode fish can put the command line in SHALL be indicated. A mode SHALL NOT leave the indicator blank.

#### Scenario: Leaving insert mode

- **WHEN** the command line is in insert mode and the user leaves it for normal mode
- **THEN** the indicator SHALL change on the spot
- **AND** it SHALL show what normal mode shows, not what insert mode showed

#### Scenario: The mode is visible without changing it

- **WHEN** a prompt is drawn and no key has yet been pressed at it
- **THEN** the indicator SHALL already show the mode the command line is in

#### Scenario: No mode is unmarked

- **WHEN** the command line is put into any of the modes vi key bindings provide
- **THEN** the indicator SHALL show a glyph
- **AND** the prompt SHALL NOT be drawn with the indicator missing

### Requirement: Each mode has its own glyph

The indicator SHALL use a distinct glyph per mode, so that the mode can be read from the glyph alone without waiting for a change to compare against. No two modes SHALL share a glyph. The assignment SHALL be:

| Mode | Glyph |
| --- | --- |
| insert | `❯` (U+276F) |
| normal | `◆` (U+25C6) |
| replace | `▶` (U+25B6) |
| visual | `▚` (U+259A) |

Replacing a single character and replacing until told to stop are one mode for this purpose: both SHALL show the replace glyph, because both consume the next keystrokes as replacement text and the distinction between them does not change what the next key does to the line.

The glyphs SHALL be drawable by a terminal font without a Nerd Font or other patched font: an unpatched font on another machine SHALL show the indicator rather than a missing-glyph box.

#### Scenario: Reading the mode from the glyph

- **WHEN** the shell is in one of the four modes
- **THEN** the glyph shown SHALL be the one this requirement assigns to that mode
- **AND** it SHALL NOT be the glyph assigned to any other mode

#### Scenario: Both kinds of replace

- **WHEN** the user starts replacing a single character, and separately starts replacing until told to stop
- **THEN** both SHALL show the replace glyph

#### Scenario: A machine without a patched font

- **WHEN** the configuration is used in a terminal whose font is not a Nerd Font
- **THEN** each of the four glyphs SHALL render as its intended shape
- **AND** none SHALL render as a missing-glyph box

### Requirement: The indicator is the prompt character

The mode SHALL be shown by the character that ends the prompt — the one immediately before where typed input appears — rather than by a separate badge elsewhere on the line. Reading the mode and finding the cursor SHALL therefore be the same glance.

The prompt SHALL NOT carry a second, independent mode indicator alongside it. Where the prompt framework offers one, it SHALL be left undrawn rather than configured to agree.

#### Scenario: Where the mode is shown

- **WHEN** a prompt is drawn in any vi mode
- **THEN** the mode glyph SHALL be the last visible character of the prompt
- **AND** nothing but separating whitespace SHALL stand between it and where typed input begins

#### Scenario: Only one indicator

- **WHEN** the prompt is drawn
- **THEN** exactly one element of it SHALL report the vi mode

### Requirement: Changing the mode does not hide the last command's outcome

The prompt character reports two things at once: the vi mode by its shape, and whether the last command succeeded by its colour. The mode glyphs SHALL NOT interfere with the second. Whichever mode the shell is in, a failed command SHALL still be distinguishable from a successful one at the prompt that follows it.

#### Scenario: A failure in normal mode

- **WHEN** a command fails and the prompt that follows is drawn in normal mode
- **THEN** the prompt character SHALL show the normal-mode glyph
- **AND** it SHALL still be marked as following a failure

#### Scenario: Success and failure differ in every mode

- **WHEN** a prompt is drawn after a successful command, and again after a failed one, in the same mode
- **THEN** the two SHALL be distinguishable from each other

### Requirement: The assignment is carried by the repository

The mode-to-glyph assignment SHALL come from a file this repository tracks, so that a shell assembled from a clone indicates modes the same way this one does. It SHALL NOT depend on a value recorded in machine-local state, such as the file where fish records universal variables.

Where machine-local state holds a different assignment, the tracked one SHALL be what takes effect. Reconfiguring the prompt on one machine SHALL NOT silently revert the shared assignment for the others: the tracked file SHALL be what a reconfiguration is captured into.

#### Scenario: A fresh clone indicates modes the same way

- **WHEN** the repository is cloned onto a machine that has never had this configuration
- **THEN** an interactive shell there SHALL show the same glyph for each mode as this one does
- **AND** no command SHALL have to be run on that machine to make it so

#### Scenario: A stale assignment left on the machine

- **WHEN** machine-local state records glyphs from an earlier configuration
- **THEN** the tracked assignment SHALL override it
- **AND** the prompt SHALL show the tracked glyphs

#### Scenario: Reconfiguring the prompt

- **WHEN** the prompt is reconfigured on one machine and the result is captured into the repository
- **THEN** the captured file SHALL hold the assignment then in effect
- **AND** committing it SHALL carry that assignment to the other machines
