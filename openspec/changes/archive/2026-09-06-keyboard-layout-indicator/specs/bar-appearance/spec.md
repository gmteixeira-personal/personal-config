## ADDED Requirements

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
