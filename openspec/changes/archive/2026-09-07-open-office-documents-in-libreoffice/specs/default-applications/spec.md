## ADDED Requirements

### Requirement: An office document opened from outside a shell opens in the session's office suite

Opening a file of an office document type through the desktop's open mechanism SHALL start the session's office suite with that document loaded, in a window on screen.

The types covered SHALL be the types the installed office suite's components declare support for, less any type already answered by another handler this mapping names. Both the OpenDocument types and the Microsoft Office types SHALL be covered, and each SHALL open in the component that declares it — a word processor document in the word processor, a spreadsheet in the spreadsheet program, a presentation in the presentation program.

Unmapped is not a neutral state here. With no handler named, opening one of these files produces no window, no error and no journal line, so there is nothing at the point of use to read and nothing to distinguish an absent mapping from a broken application.

#### Scenario: The office suite opens the document

- **WHEN** a file of a covered office document type is opened through the desktop's open mechanism
- **THEN** the session's office suite SHALL open showing that document

#### Scenario: Microsoft Office formats open as their own kind of document

- **WHEN** a `.docx`, `.xlsx` or `.pptx` file is opened through the desktop's open mechanism
- **THEN** it SHALL open in the office suite component for word processing, spreadsheets or presentations respectively

#### Scenario: OpenDocument formats open the same way

- **WHEN** an `.odt`, `.ods` or `.odp` file is opened through the desktop's open mechanism
- **THEN** it SHALL open in the office suite component for word processing, spreadsheets or presentations respectively

#### Scenario: The same handler answers from every caller

- **WHEN** the same office document is opened from the file chooser, from the terminal file manager and through `xdg-open`
- **THEN** each SHALL open it in the session's office suite

#### Scenario: The suite needs no terminal

- **WHEN** the office suite's desktop entries are inspected
- **THEN** each SHALL declare that it does not need a terminal
- **AND** this session SHALL NOT write a replacement entry for any of them

### Requirement: A type the office suite shares with an already mapped handler keeps that handler

Where a type this mapping already names a handler for is also declared by the office suite, the existing handler SHALL remain the default for it, and the type SHALL NOT appear twice in the mapping.

The office suite's entries claim far more than office documents: plain text, comma- and tab-separated values, PDF, and several image types. Those already have an answer chosen for a reason — text belongs in the session's editor, PDF in the document viewer, images in the image viewer — and a suite that can also open them is not a reason to move them. A type listed under two handlers is worse still: the mapping stops recording a decision and starts recording whichever line the resolver reads last.

#### Scenario: Text stays in the editor

- **WHEN** a plain text, CSV or tab-separated file is opened through the desktop's open mechanism
- **THEN** it SHALL open in the session's editor
- **AND** it SHALL NOT open in the office suite

#### Scenario: PDF stays in the document viewer

- **WHEN** a PDF file is opened through the desktop's open mechanism
- **THEN** it SHALL open in the session's document viewer
- **AND** it SHALL NOT open in the office suite

#### Scenario: Each type has one line

- **WHEN** the tracked mapping is read
- **THEN** each type SHALL appear exactly once

#### Scenario: A type nothing else answers for goes to the suite

- **WHEN** the office suite declares a type that no other handler in this mapping names
- **THEN** that type SHALL be mapped to the office suite

## MODIFIED Requirements

### Requirement: The default mapping is tracked, not left to the machine

The file recording these default applications SHALL be tracked in the repository, and every desktop entry it names that this repository writes SHALL be tracked with it. An entry a package ships SHALL NOT be copied into the repository to satisfy this.

The mapping file is written by tools as a side effect of ordinary use — a browser or a file manager offering to become the default rewrites it in place. Untracked, the session's defaults are whatever the last such prompt left behind, and a clone onto another machine gets none of them. A packaged entry is not subject to that: it arrives with its package, and a tracked copy would only go stale against it.

#### Scenario: The mapping and the entries this repository writes are tracked

- **WHEN** the repository's tracked paths are listed
- **THEN** the default-applications mapping file SHALL be among them
- **AND** every desktop entry it names that this repository wrote SHALL be among them

#### Scenario: A packaged entry is named but not copied

- **WHEN** the mapping names a desktop entry that a package ships
- **THEN** the repository SHALL NOT contain a copy of that entry

#### Scenario: The requirement is discoverable

- **WHEN** the tracked required-software documentation is read
- **THEN** it SHALL state which applications text files, image files, document files and office documents open in through this mapping
- **AND** it SHALL state that the editor's entry exists because the launching library cannot be told which terminal to use
- **AND** it SHALL state that without the office suite installed these documents have no handler at all, and open with no window and no error
