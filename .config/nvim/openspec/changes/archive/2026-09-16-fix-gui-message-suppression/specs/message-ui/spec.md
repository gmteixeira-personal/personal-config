## MODIFIED Requirements

### Requirement: A self-diagnosis this capability raises about its host is not shown where the claim is demonstrably false

Where the component providing this capability reports that it cannot work under the graphical front end this session runs, and that report is contradicted by what the editor itself reports about that front end, the report SHALL NOT be put in front of the user. The check that produces it SHALL keep running, and its findings SHALL remain reachable through the editor's own health report.

This is narrower than it may read, and deliberately so. It covers one thing: a claim this capability makes about its own environment, which the environment can be asked about directly and answers the other way. It does not cover an error raised by anything else, and it does not cover this capability failing to load — the requirement that a startup error still reaches the user stands untouched, because that requirement is about the editor reporting its own failures, not about this capability diagnosing its host.

The suppression SHALL be scoped to the front end where the claim is known to be wrong. Under a front end that genuinely drives the command line or the message area itself, this capability really is broken, and it SHALL still be able to say so.

The suppression SHALL NOT be taken to work because a message-routing filter matches the report. This capability's component raises its own health reports by calling the notification backend directly rather than through the editor's notify function, so such a report never reaches the routing layer and no filter offered there can act on it. Whether the suppression works SHALL be established at the surface the user sees.

The configuration SHALL record the evidence that the claim is false, so that the suppression can be re-examined rather than inherited: what the editor reports about the front end's extension flags, what the health report answers, and that the report is raised once per session because the component de-duplicates by message text rather than because the condition it names has passed.

#### Scenario: The false report is not shown

- **WHEN** the editor is started under the graphical front end this session runs
- **AND** the component providing this capability raises its "cannot work under this GUI" report
- **THEN** no notification of that report SHALL be shown

#### Scenario: The suppression is verified where the user would see it

- **WHEN** the suppression is checked
- **THEN** it SHALL be checked against the notifications the backend actually holds after a start under that front end
- **AND** a filter matching the report's text SHALL NOT be accepted as evidence on its own

#### Scenario: The finding is still reachable

- **WHEN** the editor's health report for this capability is run under that front end
- **THEN** it SHALL still report what the check found

#### Scenario: Another front end is not covered

- **WHEN** the same report would be raised outside that front end
- **THEN** it SHALL be shown as it was before

#### Scenario: Unrelated errors are unaffected

- **WHEN** this capability raises any other error
- **THEN** it SHALL be shown as it was before

#### Scenario: The evidence is recorded

- **WHEN** the configuration carrying the suppression is read
- **THEN** it SHALL state what was measured
- **AND** it SHALL state that the check itself is not disabled

## ADDED Requirements

### Requirement: The command line keeps its zero rows under a front end that writes the option back

Where the graphical front end this session runs restores the command-line height it read at startup, and that restoration lands after this capability has set the height to zero, the configuration SHALL set it back.

This capability's first requirement is that the command line is a floating input rather than the bottom screen row, and the zero height is what frees that row. A front end that writes the height back does not merely differ cosmetically from the terminal: it reinstates the row the requirement exists to remove, and the row is empty, because the input it would hold is drawn in the float. Below the status line it reads as the window being wrongly sized rather than as an option being wrong.

The correction SHALL be driven by the option changing rather than by a delay chosen to land after the front end's startup, and SHALL survive the front end writing the value more than once. It SHALL stop watching the option once startup is over, so that a later deliberate change to the command-line height is left alone.

#### Scenario: The row is not left behind

- **WHEN** the editor has started under that front end and has settled
- **THEN** the command-line height SHALL be zero
- **AND** no empty row SHALL be drawn between the status line and the bottom of the window beyond the window's own leftover

#### Scenario: More than one write is survived

- **WHEN** the front end writes the command-line height back more than once during startup
- **THEN** the height SHALL still be zero afterwards

#### Scenario: A later change is left alone

- **WHEN** the command-line height is set deliberately after startup is over
- **THEN** it SHALL keep the value it was given

#### Scenario: The terminal is unaffected

- **WHEN** the editor is started in a terminal
- **THEN** the correction SHALL do nothing
- **AND** the command-line height SHALL be what it was before
