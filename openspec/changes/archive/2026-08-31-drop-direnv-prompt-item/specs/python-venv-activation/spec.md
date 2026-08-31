## ADDED Requirements

### Requirement: The active environment is reported once in the prompt

While an environment is active, the prompt SHALL say so, and SHALL name the environment and the interpreter version it provides. While none is active, the prompt SHALL carry no indicator of one.

The prompt SHALL report it in one place. Where two prompt items would both stand for the same active environment — one naming it and one merely marking that the machinery which activated it is engaged — only the item that names it SHALL be drawn. A mark that is present exactly when a named item is present tells the reader nothing the named item has not already said, and costs them a glyph to recognise.

This governs what the prompt draws, not what is active. An environment SHALL be activated, and deactivated, exactly as the requirements above specify, whether or not any prompt item reports it.

#### Scenario: Inside a project that declares an environment

- **WHEN** the prompt is drawn with the working directory inside a project whose environment is active
- **THEN** it SHALL show one item naming the environment and the interpreter version
- **AND** it SHALL show no second item standing for the same environment

#### Scenario: Outside any such project

- **WHEN** the prompt is drawn with no environment active
- **THEN** it SHALL show no item reporting one

#### Scenario: Reporting is not activation

- **WHEN** a project that declares an approved environment is entered
- **THEN** `VIRTUAL_ENV` SHALL name that environment regardless of which prompt items are configured
