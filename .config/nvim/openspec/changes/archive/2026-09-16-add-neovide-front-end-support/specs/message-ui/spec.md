## ADDED Requirements

### Requirement: A self-diagnosis this capability raises about its host is not shown where the claim is demonstrably false

Where the component providing this capability reports that it cannot work under the graphical front end this session runs, and that report is contradicted by what the editor itself reports about that front end, the report SHALL NOT be put in front of the user. The check that produces it SHALL keep running, and its findings SHALL remain reachable through the editor's own health report.

This is narrower than it may read, and deliberately so. It covers one thing: a claim this capability makes about its own environment, which the environment can be asked about directly and answers the other way. It does not cover an error raised by anything else, and it does not cover this capability failing to load — the requirement that a startup error still reaches the user stands untouched, because that requirement is about the editor reporting its own failures, not about this capability diagnosing its host.

The suppression SHALL be scoped to the front end where the claim is known to be wrong. Under a front end that genuinely drives the command line or the message area itself, this capability really is broken, and it SHALL still be able to say so.

The configuration SHALL record the evidence that the claim is false, so that the suppression can be re-examined rather than inherited: what the editor reports about the front end's extension flags, what the health report answers, and the fact that the pair arrives once at startup rather than repeating on the check's own interval.

#### Scenario: The false report is not shown

- **WHEN** the editor is started under the graphical front end this session runs
- **AND** the component providing this capability raises its "cannot work under this GUI" report
- **THEN** no notification of that report SHALL be shown

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
