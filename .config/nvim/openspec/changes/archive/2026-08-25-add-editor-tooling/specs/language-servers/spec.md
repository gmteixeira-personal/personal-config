## Purpose

Gives the editor an understanding of the code in a buffer — its errors, its symbols, and their definitions and references — by consulting a language server for that filetype, so that navigation and refactoring operate on meaning rather than on text matching.

## ADDED Requirements

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

The editor's built-in language-server mappings — rename, code action, references, implementation, and hover — SHALL remain bound to their default keys and SHALL NOT be rebound to alternatives.

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
