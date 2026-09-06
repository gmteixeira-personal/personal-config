## Purpose

Defines which application the session opens a file in when the file is opened from outside a shell — from the file manager, from a browser download, or through `xdg-open` — so that the answer is a tracked decision rather than whatever the last program to claim a type left behind, and defines what a desktop entry must do to be launchable at all in a session whose terminal no launcher knows how to find.

## ADDED Requirements

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
- **THEN** it SHALL state which applications text files, image files and document files open in through this mapping
- **AND** it SHALL state that the editor's entry exists because the launching library cannot be told which terminal to use
