## Purpose

Gives the editor an understanding of the code in a buffer — its errors, its symbols, and their definitions and references — by consulting a language server for that filetype, so that navigation and refactoring operate on meaning rather than on text matching.

## Requirements

### Requirement: A language server attaches per filetype

Opening a file of a supported filetype SHALL start and attach a language server for that filetype. Attachment SHALL be lazy: no server SHALL be started at editor startup for a filetype not yet opened. Opening a file of an unsupported filetype SHALL attach nothing and SHALL raise no error.

Supported filetypes SHALL be: Lua; TypeScript and JavaScript, including their JSX/TSX variants; JSON; YAML; CSS; HTML; Tailwind-annotated markup; Python; shell scripts; and C#.

#### Scenario: Opening a supported file

- **WHEN** the user opens a Python file
- **THEN** a language server for Python attaches to that buffer
- **AND** its features become available in that buffer

#### Scenario: Servers do not start eagerly

- **WHEN** the editor starts and only a Lua file is opened
- **THEN** only the Lua server is running
- **AND** no server for any other filetype has been started

#### Scenario: Opening an unsupported file

- **WHEN** the user opens a file of a filetype with no configured server
- **THEN** no server attaches
- **AND** the buffer is fully editable
- **AND** no error is raised

#### Scenario: A server binary is missing

- **WHEN** a supported filetype is opened but its server binary is not installed
- **THEN** the buffer opens and is editable
- **AND** the absence is reported rather than failing silently or blocking the open

### Requirement: A server's workspace is a project that server belongs to

A language server SHALL be given a workspace root only when the directory it names is a project for that server's own technology, identified by a configuration file that technology defines. The presence of a version-control directory SHALL NOT by itself qualify a directory as a workspace root, because a directory can be a repository without being a project of any particular kind — the home directory in this environment is one.

When no qualifying root is found, the server SHALL NOT attach, and SHALL NOT fall back to the buffer's own directory.

This requirement governs where a server attaches. It does not narrow the filetypes a server supports: a filetype in which that technology's markup genuinely appears SHALL remain supported inside a qualifying project.

#### Scenario: A file inside a project of that technology

- **WHEN** the user opens a file of a supported filetype inside a directory tree carrying that technology's configuration file
- **THEN** the server attaches
- **AND** its features are available in that buffer

#### Scenario: A file inside a repository that is not such a project

- **WHEN** the user opens a file of a supported filetype inside a git repository that carries no configuration file for that technology
- **THEN** that server does not attach
- **AND** no error is raised
- **AND** the buffer is fully editable

#### Scenario: A file in the home directory

- **WHEN** the user opens a file of a supported filetype directly in the home directory, which is itself a git repository
- **THEN** no server takes the home directory as its workspace root
- **AND** no server walks the home directory tree or registers file watches over it
- **AND** the editor keeps redrawing and the cursor keeps responding to motions

#### Scenario: The configuration file is above the buffer

- **WHEN** the buffer is nested several directories below the one carrying the configuration file
- **THEN** the search proceeds upward from the buffer's own path
- **AND** the directory carrying that file becomes the workspace root

#### Scenario: Declining is not the same as rooting at the buffer

- **WHEN** no qualifying configuration file is found above the buffer
- **THEN** the server is not started at all
- **AND** the buffer's own directory is not used as a substitute root

### Requirement: Diagnostics are shown inline and in the sign column

Problems reported by an attached server SHALL be presented in the buffer as text at the end of the affected line and as an icon in the sign column, distinguished by severity. Diagnostics SHALL update as the buffer is edited.

#### Scenario: Introducing an error

- **WHEN** the user writes code the attached server reports as an error
- **THEN** the message appears at the end of that line
- **AND** an error-severity icon appears in that line's sign column

#### Scenario: Fixing an error

- **WHEN** the user corrects the code
- **THEN** the message and the sign-column icon are removed

#### Scenario: Severity is distinguishable

- **WHEN** a buffer contains both an error and a warning
- **THEN** their sign-column icons differ
- **AND** each is styled according to its severity

### Requirement: Built-in language mappings are preserved

The editor's built-in language-server mappings — rename, code action, references, implementation, hover and type definition — SHALL remain bound to their default keys and SHALL continue to work from those keys.

A mapping MAY be *added* on a second key that invokes the same action, but a default SHALL NOT be *replaced*, and no mapping SHALL be added that is a strict prefix of a default, because a prefix mapping puts every default beneath it behind a key-sequence timeout. In particular `gr` SHALL NOT be bound, as it prefixes `grn`, `gra`, `grr`, `gri` and `grt`.

#### Scenario: Renaming a symbol

- **WHEN** the cursor is on a symbol in a buffer with an attached server
- **AND** the user invokes the built-in rename mapping
- **THEN** the editor prompts for a new name and applies it to every reference the server reports

#### Scenario: Listing references

- **WHEN** the user invokes the built-in references mapping on a symbol
- **THEN** the locations that reference that symbol are listed

#### Scenario: Hovering

- **WHEN** the user invokes the built-in hover mapping on a symbol
- **THEN** the server's documentation for that symbol is displayed in a floating window

#### Scenario: A default is not delayed by an added alias

- **WHEN** the user presses a built-in `gr`-prefixed mapping such as the rename or references default
- **THEN** it executes as soon as the sequence is complete
- **AND** the editor does not wait to see whether a shorter mapping was intended

#### Scenario: An alias and its default both reach the same action

- **WHEN** an action is reachable from both its default key and an added alias
- **THEN** both invoke the same action with the same result
- **AND** neither is the only way to reach it

### Requirement: `gd` and `gD` navigate to definition and declaration

In a buffer with an attached server, `gd` SHALL jump to the definition of the symbol under the cursor and `gD` to its declaration. These SHALL be added because the editor provides no built-in language-server binding for them. In buffers with no server attached, they SHALL retain their built-in behavior.

#### Scenario: Jumping to a definition in another file

- **WHEN** the cursor is on a symbol defined in a different file
- **AND** the user presses `gd`
- **THEN** that file opens with the cursor on the definition
- **AND** the previous position is added to the jumplist so it can be returned to

#### Scenario: No definition available

- **WHEN** the user presses `gd` on a symbol the server cannot resolve
- **THEN** the cursor does not move
- **AND** the user is told no definition was found

#### Scenario: No server attached

- **WHEN** the user presses `gd` in a buffer with no attached language server
- **THEN** the editor's built-in `gd` behavior applies

### Requirement: Frequently used language-server actions have short aliases

In a buffer with an attached server, the following SHALL be reachable from these keys in addition to their built-in defaults:

- `<leader>cr` — rename the symbol under the cursor.
- `<leader>ca` — list and apply the code actions available at the cursor.
- `gi` — jump to the implementation of the symbol under the cursor.
- `K` — display the server's documentation for the symbol under the cursor.

These SHALL be buffer-local and SHALL be established only when a server attaches, so that a buffer with no server keeps whatever the key does by default. Notably `gi` SHALL retain its built-in jump-to-last-insert-position behaviour in every buffer with no server attached.

#### Scenario: Renaming from the alias

- **WHEN** the cursor is on a symbol in a buffer with an attached server and the user presses `<leader>cr`
- **THEN** the editor prompts for a new name
- **AND** applies it to every reference the server reports

#### Scenario: Applying a code action

- **WHEN** the cursor is on a line for which the server offers a fix and the user presses `<leader>ca`
- **THEN** the available actions are listed
- **AND** selecting one applies it to the buffer

#### Scenario: No code action available

- **WHEN** the user presses `<leader>ca` where the server offers nothing
- **THEN** the user is told there are no code actions
- **AND** the buffer is unchanged

#### Scenario: Jumping to an implementation

- **WHEN** the cursor is on an interface member and the user presses `gi`
- **THEN** the implementation is opened with the cursor on it
- **AND** the previous position is added to the jumplist

#### Scenario: `gi` outside an LSP buffer

- **WHEN** the user presses `gi` in a buffer with no attached language server
- **THEN** the cursor returns to the position of the last insertion and insert mode is entered

#### Scenario: Hovering from `K`

- **WHEN** the cursor is on a symbol in a buffer with an attached server and the user presses `K`
- **THEN** the server's documentation for that symbol appears in a floating window
- **AND** the window is dismissed by any cursor movement

### Requirement: `[d` and `]d` move between diagnostics

In a buffer with an attached server, `]d` SHALL move the cursor to the next diagnostic in the buffer and `[d` to the previous one. Movement SHALL wrap from the last diagnostic to the first and from the first to the last, so that repeated presses cycle through every problem in the buffer.

#### Scenario: Stepping forward through problems

- **WHEN** a buffer contains two or more diagnostics and the cursor is above the first
- **AND** the user presses `]d`
- **THEN** the cursor moves to the first diagnostic
- **WHEN** the user presses `]d` again
- **THEN** the cursor moves to the second

#### Scenario: Stepping backward

- **WHEN** the cursor is below a diagnostic and the user presses `[d`
- **THEN** the cursor moves to that diagnostic

#### Scenario: Wrapping at the end

- **WHEN** the cursor is on the last diagnostic in the buffer and the user presses `]d`
- **THEN** the cursor moves to the first diagnostic in the buffer

#### Scenario: A buffer with no diagnostics

- **WHEN** the buffer has no diagnostics and the user presses `]d` or `[d`
- **THEN** the cursor does not move
- **AND** no error is raised

### Requirement: Servers are told what the editor can do

Every attached server SHALL be informed of the editor's full client capabilities, including those contributed by the completion engine, so that servers do not withhold features the editor is able to render.

#### Scenario: Completion capabilities reach every server

- **WHEN** any supported filetype is opened
- **THEN** the attached server receives the completion engine's advertised capabilities
- **AND** this holds for every server without being configured per server

### Requirement: Language servers do not own formatting

Formatting SHALL be requested only through the formatting capability. No language-server-specific format keymap or format-on-save hook SHALL be defined here. A server's formatting SHALL be reachable only as the fallback described in `formatting`.

#### Scenario: No competing format path

- **WHEN** a contributor searches the configuration for a formatting keymap
- **THEN** exactly one exists, defined by the formatting capability
- **AND** none is defined alongside the language-server configuration

### Requirement: Hover and signature documentation is rendered as formatted markdown

Documentation a server returns for hover and for signature help SHALL be rendered as formatted markdown rather than as the raw text of the response: headings, emphasis, and inline code SHALL be styled, and a fenced code block SHALL be highlighted as the language the fence names. Where the server names no language, the code block SHALL be highlighted as the filetype of the buffer the request came from.

Documentation longer than the float SHALL be scrollable without the float closing, and the keys that scroll it SHALL be usable from the buffer, so that reading long documentation does not require moving focus into the float first. Pressing them when no such float is open SHALL leave their built-in page-scrolling behaviour intact.

Rendering SHALL be presentation only: the text displayed SHALL be the documentation the server sent, and no request, key, or buffer state changes because of how it is drawn. `K` SHALL remain bound as `language-servers` already requires, and the float SHALL still be dismissed by cursor movement.

#### Scenario: A code block in hover documentation

- **WHEN** the user presses `K` on a symbol whose documentation contains a fenced code block
- **THEN** the block is displayed with syntax highlighting for the language the fence names
- **AND** the surrounding prose is rendered with its markdown styling applied

#### Scenario: Scrolling long documentation

- **WHEN** the documentation is longer than the float can show
- **AND** the user presses the float-scroll key
- **THEN** the float scrolls
- **AND** it stays open
- **AND** the cursor has not left the buffer

#### Scenario: The scroll keys outside a float

- **WHEN** no documentation float is open and the user presses the same key
- **THEN** the buffer scrolls by a page as it always has

#### Scenario: Dismissal is unchanged

- **WHEN** a documentation float is open and the user moves the cursor
- **THEN** the float is dismissed
- **AND** the text it covered is redrawn intact

#### Scenario: No server attached

- **WHEN** the user presses `K` in a buffer with no attached server
- **THEN** the built-in behaviour of `K` applies
- **AND** no float is drawn by this capability

### Requirement: Server progress is reported while it runs

Progress a server reports while it works — indexing a workspace, loading a project, restoring a package cache — SHALL be shown to the user while it is in progress, identifying the server it came from, and SHALL be removed once that work completes. Progress SHALL NOT be silently discarded, so that a server that has attached but is not yet answering requests is distinguishable from one that has failed.

Progress SHALL NOT block the editor, take focus, or move the cursor; the buffer SHALL remain editable throughout.

#### Scenario: A workspace being indexed

- **WHEN** a server attaches and begins indexing the workspace
- **THEN** the user is shown that the work is in progress
- **AND** the message names the server reporting it

#### Scenario: Progress completes

- **WHEN** the server reports the work finished
- **THEN** the progress display is removed
- **AND** nothing is left on screen for it

#### Scenario: Editing during progress

- **WHEN** the user types while a server is reporting progress
- **THEN** every keystroke is inserted into the buffer
- **AND** the cursor stays where the user put it

#### Scenario: A server that reports no progress

- **WHEN** a server attaches without reporting progress
- **THEN** nothing is displayed for it
- **AND** no error is raised
