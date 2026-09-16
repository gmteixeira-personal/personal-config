## ADDED Requirements

### Requirement: The command line and the messages are taken under a front end that claims them only while it starts

Where the graphical front end this session runs attaches its UI declaring that it externalises the command line or the messages, and then stops declaring it, this capability SHALL take those widgets once the declaration is withdrawn.

The component decides which widgets to take by reading the front end's declaration once, as it attaches, and a widget it sees claimed is a widget it does not take for the rest of the session. The front end's declaration stands for roughly the first tenth of a second and is gone afterwards, which is inside the window where that single read happens. The outcome is not a degraded command line but the editor's built-in one: the floating input never appears, the bottom screen row comes back, and nothing reports it, because from the component's point of view it did as it was told.

Re-taking SHALL be driven by the declaration actually being withdrawn rather than by a delay chosen to outlast the front end's startup, SHALL stop once it has been withdrawn, and SHALL give up rather than wait indefinitely if it never is. Giving up SHALL leave the capability as it was found.

#### Scenario: The floating command line appears under the front end

- **WHEN** the editor has started under that front end and `:` is pressed
- **THEN** the command line SHALL be drawn as a floating input
- **AND** it SHALL NOT be drawn on the bottom screen row

#### Scenario: The widgets are actually held

- **WHEN** the capability is inspected after startup under that front end
- **THEN** it SHALL report that it holds the command-line and message widgets
- **AND** what it reports SHALL match what it reports in a terminal

#### Scenario: A front end that keeps the claim is left alone

- **WHEN** the front end does not withdraw its declaration
- **THEN** the capability SHALL stop trying
- **AND** it SHALL be left in the state the front end's declaration produced

#### Scenario: The terminal is unaffected

- **WHEN** the editor is started in a terminal
- **THEN** the capability SHALL take the same widgets it took before
- **AND** nothing SHALL be re-taken

### Requirement: A self-diagnosis is silenced only after the condition it names has been corrected

Where the component providing this capability reports that it cannot work under the front end this session runs, that report SHALL NOT be silenced on the grounds that a later reading of the same state disagrees with it. It MAY be silenced only once the configuration corrects the condition the report names, and only because the report is then describing a state that no longer holds.

The distinction is the whole requirement. A report raised inside a window and a reading taken after that window has closed are not the same measurement, and the second is not evidence about the first. Treating it as evidence is what turned a correct report into a suppressed one and left the capability inert under the front end with nothing saying so.

The silencing SHALL be scoped to the front end where the correction is applied, and SHALL NOT be reachable without it: whatever carries the correction and whatever carries the silencing SHALL be read as one thing, and the configuration SHALL state that the second is not a substitute for the first.

The check that produces the report SHALL keep running, and its findings SHALL remain reachable through the editor's health report. The silencing SHALL be established against the notifications the notification backend actually holds after a start under that front end; a message-routing filter matching the report's text SHALL NOT be accepted as evidence, because the component raises these reports by calling the backend directly and they never reach the routing layer.

#### Scenario: The condition is corrected first

- **WHEN** the configuration silencing the report is read
- **THEN** it SHALL name the correction that makes the report stale
- **AND** it SHALL state that the silencing does not stand without it

#### Scenario: The report is not shown once corrected

- **WHEN** the editor is started under that front end
- **THEN** no notification of the report SHALL be shown
- **AND** the capability SHALL hold the widgets the report said it could not

#### Scenario: Verified at the surface the user sees

- **WHEN** the silencing is checked
- **THEN** it SHALL be checked against the notifications the backend holds after a start under that front end
- **AND** a filter matching the report's text SHALL NOT be accepted as evidence on its own

#### Scenario: The check still runs

- **WHEN** the editor's health report for this capability is run under that front end
- **THEN** it SHALL still report what the check found

#### Scenario: Unrelated errors are unaffected

- **WHEN** this capability raises any other error
- **THEN** it SHALL be shown as it was before

## REMOVED Requirements

### Requirement: A self-diagnosis this capability raises about its host is not shown where the claim is demonstrably false

**Reason**: The claim was not false. It was raised inside the window where the front end declares it externalises the command line and the messages, and it described the capability's real state: the widgets were not taken and were never taken again. The requirement was built on readings taken after that window closed, which say the opposite and are not evidence about it, so it licensed silencing a correct report and left the fault in place.

**Migration**: Replaced by "A self-diagnosis is silenced only after the condition it names has been corrected", which keeps the scoping, the health-report reachability and the verification-at-the-backend clauses and adds the one that was missing: the condition is corrected first, by "The command line and the messages are taken under a front end that claims them only while it starts".
