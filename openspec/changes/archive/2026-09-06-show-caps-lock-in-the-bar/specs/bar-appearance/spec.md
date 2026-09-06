## ADDED Requirements

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
