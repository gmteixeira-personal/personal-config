## ADDED Requirements

### Requirement: A query is matched against an entry's keywords

The launcher SHALL match what is typed against the keywords a desktop entry declares, in addition to the fields it matches by default. The set of fields matched SHALL be stated in the launcher's tracked configuration rather than left to the launcher's default.

The launcher's default field list is `filename,name,generic`, which reads an entry's `Keywords=` line and then ignores it. Every entry this repository ships already carries one written on the opposite assumption — `wifi.desktop` offers `ssid` and `wireless`, `calculator.desktop` offers `arithmetic` — and none of those words has ever matched anything. The failure is invisible from either end: the entry looks correct, the launcher returns no match, and nothing reports that a field was skipped.

It matters most for an entry named after an action rather than after a program. A user reaches for whichever word their previous system used — shut down, power off, halt — and only one of those can be the entry's name. A launcher answering to that one word looks like a launcher missing the entry, not like one matching narrowly.

#### Scenario: A keyword finds its entry

- **WHEN** a word declared in an entry's `Keywords=` line is typed into the launcher
- **THEN** that entry SHALL be among the matches

#### Scenario: The field list is not left to the default

- **WHEN** the launcher's tracked configuration is inspected
- **THEN** it SHALL name the entry fields a query is matched against
- **AND** that list SHALL include keywords

#### Scenario: The default fields keep working

- **WHEN** an entry's name, generic name, or desktop file name is typed into the launcher
- **THEN** that entry SHALL still be among the matches
