## MODIFIED Requirements

### Requirement: A language server attaches per filetype

Opening a file of a supported filetype SHALL start and attach a language server for that filetype. Attachment SHALL be lazy: no server SHALL be started at editor startup for a filetype not yet opened. Opening a file of an unsupported filetype SHALL attach nothing and SHALL raise no error.

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
