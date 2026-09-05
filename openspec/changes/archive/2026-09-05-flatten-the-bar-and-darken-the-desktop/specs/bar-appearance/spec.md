## Purpose

Defines what the session's bar draws and what it costs — that it presents its contents as text over the desktop rather than as a panel of its own, that removing its fills does not remove the states those fills reported, and that the repository decides how the bar looks without deciding which modules it shows.

## ADDED Requirements

### Requirement: The bar draws no surface of its own

The bar SHALL render with a transparent background and no border, so that what appears at the edge of the screen is its contents and not a panel behind them.

The bar is not a container the session needs; it is a line of readings. A slab behind it is a second visual element competing with the windows below for the same edge, and it is the element carrying no information.

#### Scenario: Nothing is drawn behind the bar's contents

- **WHEN** the bar is displayed over the desktop
- **THEN** the desktop SHALL be visible through it
- **AND** no border or rule SHALL be drawn along its edge

### Requirement: Modules carry no fill

No module SHALL draw a background of its own, and module text SHALL be white at rest. Modules SHALL be separated by spacing rather than by contrasting fills.

The stock stylesheet gives each module a saturated block, which makes the bar read as a row of unrelated tiles whose colours mean nothing to anyone who has not memorised them. Spacing separates just as well and asserts nothing.

#### Scenario: Modules are told apart without fills

- **WHEN** the bar is displayed with several modules present
- **THEN** no module SHALL have a background distinct from the bar
- **AND** adjacent modules SHALL be separated by space

### Requirement: State survives the removal of the fills

Where a module's background previously reported a state, that state SHALL be reported by the colour of the module's own text instead, and SHALL remain distinguishable from the resting appearance.

This is the cost of the requirement above, and it has to be paid rather than accepted. The fills were not decoration alone: a critical battery, a disconnected network, an over-temperature reading and a muted output were each announced by their background and by nothing else. Removing the fills without moving the signal would make the bar quieter by making it lie.

#### Scenario: A state is visible without a fill

- **WHEN** a module enters a state its background previously reported
- **THEN** that module's text SHALL change colour
- **AND** the change SHALL be distinguishable from the module's resting appearance

#### Scenario: An idle inhibitor that is holding the screen awake is visible

- **WHEN** the bar's idle inhibitor is active
- **THEN** it SHALL be distinguishable from its inactive state on the bar itself

### Requirement: The bar stays legible against a background it does not control

The bar's text SHALL remain readable where the surface behind it is lighter than the text, and the session SHALL declare the colour drawn behind windows rather than leave it at a compositor default.

Transparency moves the bar's contrast out of the bar. Once nothing is drawn behind the text, legibility is a property of whatever is behind the bar, and a configuration that does not choose that colour has not finished making the bar transparent — it has only stopped deciding.

#### Scenario: Text over a light surface

- **WHEN** the bar is displayed over a surface lighter than its text
- **THEN** its text SHALL remain readable

### Requirement: The bar occupies no more height than its contents need

The bar SHALL reserve a height proportionate to the text it renders, rather than the stock configuration's default.

Every logical pixel the bar reserves is taken from every window on the output for the whole session. The stock bar reserves more than twice its text height, which is a permanent cost paid for empty space.

#### Scenario: The reserved height is close to the content height

- **WHEN** the bar's configured height is compared with its font size
- **THEN** the height SHALL NOT be more than roughly twice the font size

### Requirement: The repository declares the bar's appearance without owning its module list

Tracked configuration for the bar SHALL declare how it looks and how much space it takes, and SHALL obtain the set of modules it displays from the system configuration rather than restating it.

The module list is long, it belongs to a packaged file that updates, and none of it is a decision this repository has made. Copying it in to change two geometry keys would take ownership of every module default as a side effect, and the copy would silently stop tracking the packaged file the moment it changed.

#### Scenario: Geometry is overridden without copying the module list

- **WHEN** the tracked bar configuration is inspected
- **THEN** it SHALL include the system configuration rather than replace it
- **AND** it SHALL restate only the keys it intends to override

#### Scenario: The bar starts from the tracked files

- **WHEN** the bar is started
- **THEN** it SHALL report using the tracked configuration and the tracked stylesheet
- **AND** it SHALL report including the system configuration
