## ADDED Requirements

### Requirement: A buffer with several candidate workspaces is given one

Where a project describes itself more than once — several solution or workspace files above the same buffer, each a qualifying root under the requirement that a server's workspace is a project that server belongs to — the configuration SHALL resolve the ambiguity rather than leave the server unstarted. Declining to choose is not a neutral outcome: a server with no workspace does not attach, and a buffer with no attached server silently loses every feature the other requirements in this capability describe, including `gd`.

The candidate chosen SHALL be the widest: the one naming every project the others name. A narrower candidate can only take away navigation the wider one offers, because a symbol outside its set of projects is a symbol it cannot resolve.

Where no candidate is recognisable as the widest, the server SHALL leave the choice to the user and SHALL make the ambiguity visible rather than failing silently. It SHALL NOT attach without a workspace as a substitute for choosing.

#### Scenario: Several solutions describe the same project

- **WHEN** the user opens a file whose enclosing project is named by more than one solution file above it
- **THEN** a server attaches to that buffer
- **AND** its workspace is the solution naming every project the others name

#### Scenario: Navigating across a boundary a narrower candidate draws

- **WHEN** the cursor is on a symbol defined in a project that only the widest candidate names
- **AND** the user presses `gd`
- **THEN** that project's file opens with the cursor on the definition

#### Scenario: No candidate is recognisable as the widest

- **WHEN** the candidates above a buffer cannot be ranked by the configured rule
- **THEN** the user is told the target is ambiguous and how to select one
- **AND** no server attaches without a workspace
- **AND** the buffer is fully editable

#### Scenario: Ambiguity does not attach a rootless server

- **WHEN** a buffer's workspace cannot be determined
- **THEN** no server is attached to that buffer with no workspace
- **AND** no second server for that technology is left running beside a correctly rooted one

## MODIFIED Requirements

### Requirement: A language server attaches per filetype

Opening a file of a supported filetype SHALL start and attach a language server for that filetype. Attachment SHALL be lazy: no server SHALL be started at editor startup for a filetype not yet opened. Opening a file of an unsupported filetype SHALL attach nothing and SHALL raise no error.

Laziness is a property of the server process, not of the configuration that governs it. The configuration deciding which server serves a filetype and which workspace it is given SHALL be fully in effect before the first buffer of that filetype is resolved, so that the first such buffer of a session is served exactly as every later one is. A configuration that arrives too late to be consulted is a configuration that does not hold.

Supported filetypes SHALL be: Lua; TypeScript and JavaScript, including their JSX/TSX variants; JSON; YAML; CSS; HTML; Tailwind-annotated markup; Python; shell scripts; fish; C#; and Razor, covering both the `.razor` and `.cshtml` extensions.

fish is listed separately from shell scripts because it is not a POSIX shell: the server that serves `sh` and `bash` cannot parse it, and a distinct server covers it.

Exactly one server SHALL attach per buffer for a given technology. Where one server serves several filetypes, opening any of them SHALL NOT start a second instance of that server alongside the first.

#### Scenario: Opening a supported file

- **WHEN** the user opens a Python file
- **THEN** a language server for Python attaches to that buffer
- **AND** its features become available in that buffer

#### Scenario: Opening a fish file

- **WHEN** the user opens a `.fish` file inside a directory tree carrying a fish configuration
- **THEN** a language server for fish attaches to that buffer
- **AND** diagnostics, hover, and completion are available in that buffer
- **AND** the server serving `sh` and `bash` does not attach to it

#### Scenario: Opening a Razor file

- **WHEN** the user opens a `.razor` or `.cshtml` file inside a C# project
- **THEN** a language server attaches to that buffer
- **AND** the markup, the C# expressions, and the `@code` block are syntax highlighted rather than shown as undifferentiated plain text
- **AND** completion and diagnostics are available in that buffer

#### Scenario: Opening a Razor file outside a project

- **WHEN** the user opens a `.razor` or `.cshtml` file where no C# project can be found
- **THEN** no server attaches and no error is raised
- **AND** the markup, the razor comments, and the `@` expressions are still syntax highlighted

#### Scenario: One server instance per technology

- **WHEN** the user opens a C# file and then a Razor file in the same project
- **THEN** both buffers are served
- **AND** only one instance of that technology's server is running

#### Scenario: The first buffer of a session is served like every later one

- **WHEN** the user opens the first file of a supported filetype in a session
- **THEN** its workspace is resolved under the complete configuration for that server
- **AND** exactly one server for that technology attaches to it
- **AND** opening a second file of that filetype afterwards resolves to the same workspace

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
