## REMOVED Requirements

### Requirement: The editor's desktop entry opens its own terminal

**Reason**: The entry named as the default for text types no longer opens a terminal at all. It is the editor's own window, so "opens its own terminal" is no longer a property the named default can have, and restating it as a requirement of a fall-through entry would leave the primary case uncovered.

**Migration**: Split in two. `The entry named for text needs no terminal from its caller` below carries what the requirement was for — that no program launching the entry has to know which terminal this session runs — stated over both shapes of entry rather than over one. `A text handler the machine lacks falls through to one it has` carries the terminal-opening obligation, which now applies to the tracked fall-through entry and to nothing else.

## ADDED Requirements

### Requirement: The entry named for text needs no terminal from its caller

The desktop entry named as the default for these types SHALL declare that it does not need a terminal, and SHALL NOT leave the choice of one to the program that launches it.

The caller has no terminal to give. A file opened from the file manager, from a browser download or through `xdg-open` is opened from a graphical session by a program that is not a shell, so the editor that answers SHALL be one that draws its own window — the same editor the session names as its graphical text editor, rather than the terminal spelling of it.

The packaged entry does the opposite: it declares `Terminal=true` and leaves the choice of terminal to whatever launches it. The library that launches desktop entries for the file manager, the browser and `xdg-open` picks a terminal from a fixed list — `xdg-terminal-exec`, `gnome-terminal`, `konsole`, `ptyxis`, `tilix` — and this session installs none of them. Unlike the application launcher, which has a setting for this and is given `footclient`, that library has no setting to name a terminal. The failure is silent in both directions: the entry is valid, the mechanism reports success, and no window appears and nothing is logged where the user would look.

Two shapes of entry escape that, and this requirement covers whichever is named: one that draws its own window has no terminal to find, and one that opens a terminal itself does not have to be told which. Nothing that launches either has to know what terminal this session runs.

#### Scenario: The entry does not ask to be given a terminal

- **WHEN** the entry named as the default for these types is inspected
- **THEN** it SHALL declare `Terminal=false`

#### Scenario: The editor appears in a window it drew itself

- **WHEN** a file of a covered text type is opened through the desktop's open mechanism
- **THEN** the editor SHALL appear in a window of its own
- **AND** no terminal emulator SHALL be started to hold it

#### Scenario: Launching does not depend on a terminal the session lacks

- **WHEN** the entry is launched by a program that has no configured terminal
- **THEN** the editor SHALL open

### Requirement: A text handler the machine lacks falls through to one it has

The entry named as the default for text types SHALL name its executable in the field a launcher tests before offering an entry, and this repository SHALL keep a tracked terminal-based entry for the same editor as what these types resolve to when that test fails.

The graphical editor is a cargo build rather than a packaged program, so a checkout can land on a machine that does not have it. A default naming an entry whose program is absent would resolve to the same silence the unmapped case produces — no window, no error, nothing logged — and it would do so on exactly the machine least able to diagnose it, a fresh checkout. The executable test is what turns that into a fall-through instead: the launching library skips such an entry and goes on to the applications registered for the type.

The terminal-based entry is what is then found, so it SHALL remain tracked and SHALL keep opening the session's terminal itself, for the reason that applied while it was the default.

#### Scenario: The default entry names its executable

- **WHEN** the entry named as the default for text types is inspected
- **THEN** it SHALL name the editor's executable in the field a launcher tests before offering the entry

#### Scenario: A machine without the graphical editor still opens the file

- **WHEN** the graphical editor is not installed and a file of a covered text type is opened
- **THEN** the named default SHALL be skipped
- **AND** the file SHALL open in the tracked terminal-based entry instead

#### Scenario: The fallback entry stays tracked and still supplies its own terminal

- **WHEN** the terminal-based entry is inspected
- **THEN** it SHALL be a tracked file in this repository
- **AND** it SHALL open the same terminal the compositor's terminal key opens
- **AND** it SHALL pass the file it was given to the editor running in that terminal


## MODIFIED Requirements

### Requirement: The default mapping is tracked, not left to the machine

The file recording these default applications SHALL be tracked in the repository, and every desktop entry it names that this repository writes SHALL be tracked with it. An entry a package ships SHALL NOT be copied into the repository to satisfy this.

The mapping file is written by tools as a side effect of ordinary use — a browser or a file manager offering to become the default rewrites it in place. Untracked, the session's defaults are whatever the last such prompt left behind, and a clone onto another machine gets none of them. A packaged entry is not subject to that: it arrives with its package, and a tracked copy would only go stale against it.

That rewriting is not confined to the lines it changes. A program that claims a type rewrites the whole file from its own parse of it, which drops every comment the file carried. The tracked copy is therefore the only record of why each type is mapped where it is, and restoring it SHALL be treated as part of recovering from such a rewrite rather than as separate tidying.

#### Scenario: The mapping and the entries this repository writes are tracked

- **WHEN** the repository's tracked paths are listed
- **THEN** the default-applications mapping file SHALL be among them
- **AND** every desktop entry it names that this repository wrote SHALL be among them

#### Scenario: A packaged entry is named but not copied

- **WHEN** the mapping names a desktop entry that a package ships
- **THEN** the repository SHALL NOT contain a copy of that entry

#### Scenario: A rewrite by another program is recovered from the tracked copy

- **WHEN** the mapping file on the machine has been rewritten in place by a program that claimed a type
- **THEN** the commentary SHALL be restored from the tracked copy
- **AND** any association that rewrite added SHALL be carried forward or removed as a decision, not left as whatever the rewrite produced

#### Scenario: The requirement is discoverable

- **WHEN** the tracked required-software documentation is read
- **THEN** it SHALL state which applications text files, image files, document files and office documents open in through this mapping
- **AND** it SHALL state that a text file opened from outside a shell opens in the editor's own window rather than in a terminal
- **AND** it SHALL state that the terminal-based entry is what these types fall through to where the graphical editor is absent, and that it exists because the launching library cannot be told which terminal to use
- **AND** it SHALL state that without the office suite installed these documents have no handler at all, and open with no window and no error
