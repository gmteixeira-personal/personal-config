## MODIFIED Requirements

### Requirement: An office document opened from outside a shell opens in the session's office suite

Opening a file of an office document type through the desktop's open mechanism SHALL start the session's office suite with that document loaded, in a window on screen.

The types covered SHALL be the types the installed office suite's desktop entries declare support for, less any type already answered by another handler this mapping names. Both the OpenDocument types and the Microsoft Office types SHALL be covered, and each SHALL open as its own kind of document — a word processor document for prose, a spreadsheet for cells, a presentation for slides.

How the suite divides itself into entries SHALL NOT change what this mapping names. A suite that ships one entry per component is named by those entries; a suite that ships a single entry and selects the editor from the opened file's type is named by that one entry. What the mapping records either way is that the type reaches the suite and arrives in the right kind of editor.

Unmapped is not a neutral state here. With no handler named, opening one of these files produces no window, no error and no journal line, so there is nothing at the point of use to read and nothing to distinguish an absent mapping from a broken application.

#### Scenario: The office suite opens the document

- **WHEN** a file of a covered office document type is opened through the desktop's open mechanism
- **THEN** the session's office suite SHALL open showing that document

#### Scenario: Microsoft Office formats open as their own kind of document

- **WHEN** a `.docx`, `.xlsx` or `.pptx` file is opened through the desktop's open mechanism
- **THEN** it SHALL open as a word processor document, a spreadsheet or a presentation respectively

#### Scenario: OpenDocument formats open the same way

- **WHEN** an `.odt`, `.ods` or `.odp` file is opened through the desktop's open mechanism
- **THEN** it SHALL open as a word processor document, a spreadsheet or a presentation respectively

#### Scenario: The same handler answers from every caller

- **WHEN** the same office document is opened from the file chooser, from the terminal file manager and through `xdg-open`
- **THEN** each SHALL open it in the session's office suite

#### Scenario: The suite needs no terminal

- **WHEN** the desktop entries this mapping names for the office suite are inspected
- **THEN** each SHALL declare that it does not need a terminal
- **AND** this session SHALL NOT write a replacement entry for any of them

### Requirement: A type the office suite shares with an already mapped handler keeps that handler

Where a type this mapping already names a handler for is also declared by the office suite, the existing handler SHALL remain the default for it, and the type SHALL NOT appear twice in the mapping.

The office suite's entries claim far more than office documents: plain text, comma- and tab-separated values, PDF and e-book formats among them. Those already have an answer chosen for a reason — text belongs in the session's editor, PDF and e-books in the document viewer — and a suite that can also open them is not a reason to move them. A type listed under two handlers is worse still: the mapping stops recording a decision and starts recording whichever line the resolver reads last.

Two spellings of one format count as one type here. Where the suite declares a type that `/usr/share/mime/aliases` gives as the canonical name of a type another handler already answers for — or as an alias of it — that is the same format arriving under a second name, and it SHALL stay with the handler that already has it rather than appearing again under the suite.

#### Scenario: Text stays in the editor

- **WHEN** a plain text, CSV or tab-separated file is opened through the desktop's open mechanism
- **THEN** it SHALL open in the session's editor
- **AND** it SHALL NOT open in the office suite

#### Scenario: PDF stays in the document viewer

- **WHEN** a PDF file is opened through the desktop's open mechanism
- **THEN** it SHALL open in the session's document viewer
- **AND** it SHALL NOT open in the office suite

#### Scenario: An alias of a mapped type stays with that type's handler

- **WHEN** the office suite declares a type that is an alias of, or the canonical name of, a type another handler in this mapping already answers for
- **THEN** that format SHALL remain with the handler that already answers for it
- **AND** the mapping SHALL NOT gain a second line naming the suite for it

#### Scenario: Each type has one line

- **WHEN** the tracked mapping is read
- **THEN** each type SHALL appear exactly once

#### Scenario: A type nothing else answers for goes to the suite

- **WHEN** the office suite declares a type that no other handler in this mapping names
- **THEN** that type SHALL be mapped to the office suite

## ADDED Requirements

### Requirement: A format no installed handler declares is left unmapped

Where no desktop entry installed on the machine declares a type, this mapping SHALL NOT name a handler for it. A line naming an entry that is absent, or naming an installed entry for a type that entry does not declare, SHALL be removed rather than left in place or pointed at the nearest similar application.

The mapping is a record of decisions that can be checked. A line naming a `.desktop` file that no package installs records nothing — it resolves to the same silence as no line at all, while reading as though the format is handled. Pointing such a type at whichever installed suite looks closest is worse: the launch then fails inside an application that was never built to open the format, and the failure surfaces as that application's error rather than as an absent mapping.

Changing which office suite is installed can therefore remove formats from the mapping. A suite with fewer import filters than the one it replaces leaves the formats only the old suite declared with no handler, and that is the honest state to record.

#### Scenario: An entry that is no longer installed is not named

- **WHEN** the tracked mapping is read
- **THEN** every desktop entry it names SHALL be present on the machine

#### Scenario: A type no installed entry declares has no line

- **WHEN** the tracked mapping names a handler for a type
- **THEN** that handler's desktop entry SHALL declare that type, or another type that `/usr/share/mime/aliases` resolves to the same format

#### Scenario: A format the suite does not open is not sent to it anyway

- **WHEN** an office document format is declared by no installed desktop entry
- **THEN** the mapping SHALL NOT name the office suite for it
- **AND** opening such a file SHALL be understood to start nothing
