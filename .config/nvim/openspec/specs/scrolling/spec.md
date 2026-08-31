# scrolling Specification

## Purpose

Defines where the cursor sits vertically inside a Neovim window as the buffer scrolls, so that the amount of context visible above and below the cursor is predictable rather than depending on how the cursor arrived at its line.

## Requirements

### Requirement: The cursor stays vertically centered

Neovim SHALL keep the cursor line at the vertical middle of its window whenever the buffer is long enough for the window to scroll. The window SHALL scroll to preserve that position rather than letting the cursor travel toward an edge. This SHALL apply to every window and every buffer, not to a configured subset.

#### Scenario: A vertical motion recenters the view

- **WHEN** the cursor moves down or up by any number of lines in a buffer longer than the window, away from the first and last screenful
- **THEN** the cursor line SHALL be rendered at the middle row of the window
- **AND** roughly equal numbers of buffer lines SHALL be visible above and below it

#### Scenario: A jump lands centered

- **WHEN** the cursor arrives at a line by a jump rather than a stepwise motion — a search match, a line number, or a jump to a definition
- **THEN** the cursor line SHALL be rendered at the middle row of the window
- **AND** no explicit recentering command SHALL be needed afterwards

#### Scenario: A fresh window is centered

- **WHEN** a new window or split is opened on a buffer longer than the window
- **THEN** the cursor line in that window SHALL be centered as well

### Requirement: Buffer ends are exempt

Within the first and last screenful of a buffer, and in any buffer shorter than the window, the view SHALL NOT be padded to force centering. The cursor SHALL move normally against the top or bottom of the buffer, and lines that do not exist SHALL NOT be scrolled into view.

#### Scenario: The top of a buffer

- **WHEN** the cursor is on the first line of a buffer
- **THEN** the first line SHALL be the first row shown
- **AND** the cursor SHALL NOT be centered by scrolling blank space above it

#### Scenario: The end of a buffer

- **WHEN** the cursor is on the last line of a long buffer
- **THEN** the cursor SHALL be at or near the bottom of the window
- **AND** the view SHALL NOT scroll past the last line to center it

#### Scenario: A buffer shorter than the window

- **WHEN** a buffer with fewer lines than the window is open
- **THEN** the whole buffer SHALL remain visible
- **AND** the cursor SHALL sit on its own line wherever that line falls

### Requirement: The setting survives a restore

The centering behavior SHALL come from the tracked Neovim configuration in this repository, so a machine checked out fresh SHALL have it without any manual step. It SHALL NOT depend on a plugin or on a per-session command.

#### Scenario: A restored machine centers the cursor

- **WHEN** this repository is checked out into a fresh home directory and Neovim starts
- **THEN** the cursor SHALL be centered as described above
- **AND** no plugin SHALL be required for it

### Requirement: Manual top and bottom placement is superseded

The commands that park the cursor line at the top or bottom of the window SHALL NOT hold that placement, because the centering requirement re-applies immediately. This is an accepted consequence of the requirement above, not a defect.

#### Scenario: An explicit top placement is undone

- **WHEN** `zt` is issued away from the ends of a long buffer
- **THEN** the cursor line SHALL end up centered rather than at the top row
