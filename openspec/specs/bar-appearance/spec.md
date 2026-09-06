# bar-appearance Specification

## Purpose

Defines what the session's bar draws and what it costs — that it presents its contents as text over the desktop rather than as a panel of its own, that removing its fills does not remove the states those fills reported, and that the repository decides how the bar looks without deciding which modules it shows.

## Requirements

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

### Requirement: The repository declares the bar's appearance and names the modules it shows

Tracked configuration for the bar SHALL declare how it looks and how much space it takes, and SHALL name the modules it displays. It SHALL obtain each module's own options from the system configuration by including that file rather than copying it, and SHALL restate only the keys it intends to override.

The module list and the module options are two different things, and only one of them is the repository's business. The packaged list is written for a different compositor: most of its entries cannot start under this session's compositor, and a module that cannot start is still one the bar builds and polls to render nothing. Inheriting that list means shipping a bar whose contents are decided by a file that does not know what is running. Naming the list is the only way to be rid of those entries.

The options are the opposite case. They are long, they belong to a packaged file that updates, and none of them is a decision made here. Copying them in to change a format string would take ownership of every default as a side effect, and the copy would silently stop tracking the packaged file the moment it changed.

#### Scenario: Module options are overridden without copying them

- **WHEN** the tracked bar configuration is inspected
- **THEN** it SHALL include the system configuration rather than replace it
- **AND** it SHALL restate only the module option keys it intends to override

#### Scenario: The module list names what the session can run

- **WHEN** the tracked bar configuration's module lists are inspected
- **THEN** every module named SHALL be one this session's compositor can drive
- **AND** no module SHALL be present that cannot start under it

#### Scenario: The bar starts from the tracked files

- **WHEN** the bar is started
- **THEN** it SHALL report using the tracked configuration and the tracked stylesheet
- **AND** it SHALL report including the system configuration

### Requirement: A module earns its place by being acted on

The bar SHALL carry a module only where the reading it presents is one the user acts on from the bar, or one whose change the user needs to notice without looking. A module presenting a figure that moves continuously and prompts no action SHALL NOT be carried.

The bar is read passively, all day, and every module on it is a standing claim on attention. A percentage that changes every second trains the reader to stop looking, which costs the modules beside it their glanceability too. Load is the clearest case: when it matters, the question is which process, and the bar cannot answer that — the tools that can are one keystroke away. Removing such a module is not hiding information; it is declining to present information in the one place where it cannot be followed up.

This is not a rule against numbers. A battery percentage prompts an action and is worth carrying; a volume level is one the user changes from the bar itself. The test is whether the reading leads anywhere.

#### Scenario: A continuously moving figure with no action is absent

- **WHEN** the bar is displayed
- **THEN** no module SHALL present a continuously varying utilisation figure that the bar offers no way to act on

#### Scenario: A reading that prompts an action is kept

- **WHEN** the bar is displayed on a machine running on battery
- **THEN** the battery reading SHALL be present

#### Scenario: Removing a module removes its whole footprint

- **WHEN** a module is removed from the bar
- **THEN** it SHALL be absent from the tracked module list
- **AND** the tracked configuration SHALL carry no options for it
- **AND** the tracked stylesheet SHALL carry no rules naming it

### Requirement: The active keyboard layout is shown on the bar

Where more than one keyboard layout is configured, the bar SHALL show which one is active.

The layout can change without the user meaning it to: the switch key is a frequently used binding with one modifier added, so a slipped modifier changes it and nothing else announces the change. The first symptom is a character arriving wrong, and the cause is not obvious from the symptom. This is the second kind of module this specification admits — not one acted on from the bar, but one whose change has to be noticed without being looked for.

The reading SHALL name the layout as the keyboard configuration names it, not as the compositor describes it, so that what is on the bar and what is in the tracked configuration are the same word.

The active layout SHALL be distinguishable at a glance rather than only by reading the label, and SHALL follow the rule that state is carried by the colour of the module's own text rather than by a fill.

#### Scenario: The layout is shown

- **WHEN** the bar is displayed with more than one layout configured
- **THEN** it SHALL show the active layout

#### Scenario: The reading follows a switch

- **WHEN** the layout is switched
- **THEN** the bar SHALL show the layout switched to, without the bar being restarted

#### Scenario: The name matches the configuration

- **WHEN** the label is compared with the layout names in the tracked keyboard configuration
- **THEN** it SHALL use the same names

#### Scenario: Layouts are told apart without reading

- **WHEN** each configured layout is active in turn
- **THEN** the module's text colour SHALL differ between them
- **AND** neither SHALL be indicated by a fill

### Requirement: The Caps Lock state is shown on the bar

The bar SHALL show that Caps Lock is on. It SHALL show nothing while the lock is off, and the widget SHALL take no space in that state.

This is the second module admitted on the ground that its change must be noticed without being looked for. Caps Lock is a mode with no other announcement here: the key that carried it is a Control modifier, so the keyboard's own indicator LED sits beside a key that no longer means anything, and the lock itself is on a chord. The first symptom is a line of capitals that has already been typed.

An indicator that is present in both states would be a permanent claim on attention reporting "normal" nearly all of the time, which is what trains a reader to stop looking at the modules beside it. Absence is the resting state and the appearance of the module is the whole signal.

The state SHALL be carried by the colour of the module's own text rather than by a fill, and that colour SHALL be distinguishable from the one the layout indicator uses for the same kind of report, so that two modules a short distance apart do not say "the keyboard is in a mode" in the same way.

#### Scenario: The lock is on

- **WHEN** Caps Lock is on
- **THEN** the bar SHALL show an indicator that it is on

#### Scenario: The lock is off

- **WHEN** Caps Lock is off
- **THEN** the bar SHALL show no indicator for it
- **AND** the module SHALL occupy no width

#### Scenario: The reading follows the lock

- **WHEN** the lock is toggled
- **THEN** the bar SHALL follow the change without the bar being restarted

#### Scenario: The state is a colour, not a fill

- **WHEN** the indicator is shown
- **THEN** the state SHALL be carried by the module's text colour
- **AND** it SHALL NOT be indicated by a fill
- **AND** that colour SHALL differ from the colours the layout indicator uses

#### Scenario: However the lock was toggled

- **WHEN** the lock is changed by any means the machine offers, rather than only by the chord this configuration binds
- **THEN** the bar SHALL show the resulting state

### Requirement: A module reporting a radio opens that radio's controls

Where the bar carries a module reporting the state of a radio, clicking that module SHALL open the session's interface for managing that radio. The click SHALL perform that action alone.

This is the debt left by the requirement that a module earns its place by being acted on. That requirement names the bar itself as where the acting happens, and the network module was carried in breach of it — a reading with nothing behind it, because the packaged configuration it inherits from defines no click at all. The Bluetooth module had a click, but one that opened a terminal REPL: a way out of the bar rather than a way to act on it.

A module whose click both runs a command and toggles its own label is the failure mode to avoid here, and it is the default rather than an unlikely mistake: the bar's own implementation fires an alternate-format toggle and the configured command on the same button. The label then reads differently depending on how many times it has been clicked, which makes a glanceable module unreadable in exactly the situation it is being used.

#### Scenario: The Bluetooth module opens Bluetooth management

- **WHEN** the bar's Bluetooth module is clicked
- **THEN** the session's Bluetooth management interface SHALL open

#### Scenario: The network module opens wireless management

- **WHEN** the bar's network module is clicked
- **THEN** the session's wireless management interface SHALL open

#### Scenario: The click does not also change the label

- **WHEN** a module reporting a radio is clicked
- **THEN** the text that module displays SHALL be unchanged by the click

### Requirement: A module's reading is sourced without widening the user's privileges

Presenting a reading on the bar SHALL NOT require the user to join a group, a udev rule to be installed, or any other standing grant beyond what a graphical session already has. Where a reading is available from more than one source, the source requiring no such grant SHALL be preferred, even where it is the less direct one.

A bar is a display. The cost of a display should be bounded by what it draws, and a group joined to feed one module is not scoped to that module: it is granted to every process the user runs, for every device of that class, for as long as the account exists. Reading keyboard state is the sharp case — the interface that reports which locks are set is the same one that reports every keystroke.

Where the preferred source is less direct, the configuration SHALL record which source was declined and why, so that a later reader does not "simplify" the module onto the direct one and quietly take the grant with it.

#### Scenario: No group is joined for a module

- **WHEN** the user's group membership is inspected
- **THEN** no group SHALL have been joined in order to present a reading on the bar

#### Scenario: The declined source is recorded

- **WHEN** a module takes its reading from an indirect source because the direct one demands a standing grant
- **THEN** the configuration SHALL record the source that was declined and what it would have cost

#### Scenario: A module needing a grant is not added

- **WHEN** a reading is available only through an interface requiring a standing grant
- **THEN** the module SHALL NOT be added on that basis alone
