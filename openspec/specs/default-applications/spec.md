# default-applications Specification

## Purpose
Defines which application the session opens a file in when the file is opened from outside a shell — from the file manager, from a browser download, or through `xdg-open` — so that the answer is a tracked decision rather than whatever the last program to claim a type left behind, and defines what a desktop entry must do to be launchable at all in a session whose terminal no launcher knows how to find.

## Requirements

### Requirement: A text file opened from outside a shell opens in the session's editor

Opening a file of a text type through the desktop's open mechanism SHALL start the session's editor with that file loaded, in a window on screen.

The types covered SHALL be every type the shared MIME database files under the `text` media type, except any type the browser answers for, together with the source-code types the database files under `application/` rather than under `text/`.

The media type is not a reliable guide to what is text. The database files Rust under `text/rust` and Go under `text/x-go`, Ruby under `application/x-ruby` and Python under `text/x-python` — the placements record how each type was registered, not what kind of file it is. Selecting by prefix therefore leaves gaps that look arbitrary at the point of use, where one source file opens and the next does nothing.

#### Scenario: The editor opens the file

- **WHEN** a file of a covered text type is opened through the desktop's open mechanism
- **THEN** a window SHALL appear with the session's editor running in it
- **AND** the editor SHALL have that file loaded

#### Scenario: The same handler answers from every caller

- **WHEN** the same file is opened from the file manager, from a browser download, and through `xdg-open`
- **THEN** each SHALL open it in the session's editor

#### Scenario: A source file opens whichever media type its type is filed under

- **WHEN** source files whose types are filed under `text/`, under `text/x-` and under `application/` are each opened
- **THEN** each SHALL open in the session's editor

#### Scenario: The browser keeps the type it answers for

- **WHEN** an HTML file is opened
- **THEN** it SHALL open in the web browser and SHALL NOT open in the editor

### Requirement: Both MIME types a Markdown file resolves to are mapped

A Markdown file SHALL open in the session's editor whichever of the two MIME types the calling program resolves it to.

A `.md` file does not have one answer. Resolution by filename glob gives `text/markdown`, and resolution by content inspection gives `text/plain`, because a Markdown file is plain text and its magic says so. Callers differ in which they use — GIO globs, `file(1)` inspects — so the file opens or fails depending on which program was asked, and a mapping for only one of them looks correct in testing and fails in use. Mapping both is what makes the behaviour independent of the caller.

#### Scenario: Markdown resolved by glob

- **WHEN** a caller resolves a `.md` file to `text/markdown`
- **THEN** the default application for that type SHALL be the session's editor

#### Scenario: Markdown resolved by content

- **WHEN** a caller resolves a `.md` file to `text/plain`
- **THEN** the default application for that type SHALL be the session's editor

### Requirement: An image file opened from outside a shell opens in the session's image viewer

Opening a file of an image type through the desktop's open mechanism SHALL start the session's image viewer with that image shown.

The types covered SHALL be the image types the installed viewer declares support for. Naming a type the viewer does not handle would route a file to a program that cannot display it, which is worse than the browser it replaces.

#### Scenario: The viewer opens the image

- **WHEN** a file of a covered image type is opened through the desktop's open mechanism
- **THEN** the session's image viewer SHALL open showing that image

#### Scenario: Every image type reaches the same viewer

- **WHEN** files of different covered image types are each opened
- **THEN** each SHALL open in the session's image viewer
- **AND** none SHALL open in the web browser

#### Scenario: The viewer needs no terminal

- **WHEN** the image viewer's desktop entry is inspected
- **THEN** it SHALL declare that it does not need a terminal
- **AND** this session SHALL NOT write a replacement entry for it

### Requirement: A document file opened from outside a shell opens in the session's document viewer

Opening a file of a document type through the desktop's open mechanism SHALL start the session's document viewer with that document shown.

The types covered SHALL be the types the installed document viewer declares support for, less any type already answered by the image viewer. Where two installed viewers both claim a type, exactly one SHALL be named as its default, so the type has one answer rather than one per program that happened to claim it.

#### Scenario: The viewer opens the document

- **WHEN** a file of a covered document type is opened through the desktop's open mechanism
- **THEN** the session's document viewer SHALL open showing that document
- **AND** it SHALL NOT open in the web browser

#### Scenario: A type both viewers claim goes to one of them

- **WHEN** a type is declared by both the image viewer and the document viewer
- **THEN** exactly one of them SHALL be named as the default for that type
- **AND** the choice SHALL be recorded in the tracked mapping rather than left to resolution order

#### Scenario: The viewer needs no terminal

- **WHEN** the document viewer's desktop entry is inspected
- **THEN** it SHALL declare that it does not need a terminal
- **AND** this session SHALL NOT write a replacement entry for it

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
### Requirement: The editor's desktop entry opens its own terminal

The desktop entry named as the default for these types SHALL declare that it does not need a terminal, and SHALL open the session's terminal itself as part of its own command.

The packaged entry does the opposite: it declares `Terminal=true` and leaves the choice of terminal to whatever launches it. The library that launches desktop entries for the file manager, the browser and `xdg-open` picks a terminal from a fixed list — `xdg-terminal-exec`, `gnome-terminal`, `konsole`, `ptyxis`, `tilix` — and this session installs none of them. Unlike the application launcher, which has a setting for this and is given `footclient`, that library has no setting to name a terminal. The failure is silent in both directions: the entry is valid, the mechanism reports success, and no window appears and nothing is logged where the user would look.

An entry that opens its own terminal removes the question. Nothing that launches it has to know what terminal this session runs.

#### Scenario: The entry does not ask to be given a terminal

- **WHEN** the tracked desktop entry is inspected
- **THEN** it SHALL declare `Terminal=false`

#### Scenario: The entry names the session's terminal

- **WHEN** the tracked desktop entry's command is inspected
- **THEN** it SHALL open the same terminal the compositor's terminal key opens
- **AND** it SHALL pass the file it was given to the editor running in that terminal

#### Scenario: Launching does not depend on a terminal the session lacks

- **WHEN** the entry is launched by a program that has no configured terminal
- **THEN** the editor SHALL open

### Requirement: The packaged entry is left in place

The desktop entry this change adds SHALL be a new entry beside the packaged one, and SHALL NOT replace or shadow it.

Shadowing the packaged entry means restating its full type list and its metadata in this repository, where a package update would no longer reach them. A separate entry inherits nothing to go stale.

#### Scenario: The packaged entry still resolves

- **WHEN** the installed desktop entries are listed
- **THEN** the packaged editor entry SHALL still be present and unmodified

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
