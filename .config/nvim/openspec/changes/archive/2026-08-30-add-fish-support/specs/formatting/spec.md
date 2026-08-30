## MODIFIED Requirements

### Requirement: Formatter selection is per filetype with a defined fallback chain

Each filetype SHALL resolve to an ordered list of formatters. Resolution SHALL proceed as follows, in order:

1. A dedicated external formatter configured for that filetype, trying each entry in its list until one is available.
2. Failing that, formatting provided by an attached language server.
3. Failing that, no formatting — the buffer is left untouched, without error.

The following filetypes SHALL have external formatters configured: Lua; JavaScript, TypeScript, and their JSX/TSX variants; JSON; YAML; CSS; HTML; Markdown; Python; shell scripts; and fish. C# SHALL rely on language-server formatting.

#### Scenario: A filetype with an external formatter

- **WHEN** a Lua buffer is formatted
- **THEN** the configured Lua formatter produces the result
- **AND** no language server is asked to format it

#### Scenario: A fish buffer is formatted by its external formatter

- **WHEN** a fish buffer is formatted, whether on write or on demand
- **AND** a fish language server capable of formatting is attached to it
- **THEN** the external fish formatter produces the result
- **AND** the language server is not asked to format it

#### Scenario: Falling back to the language server

- **WHEN** a C# buffer is formatted
- **AND** a language server that supports formatting is attached
- **THEN** the language server produces the result

#### Scenario: Falling back within a filetype's formatter list

- **WHEN** a filetype lists two external formatters in order
- **AND** the first is not installed on the system
- **THEN** the second is used
- **AND** no error is raised about the missing first

#### Scenario: A filetype with no formatter at all

- **WHEN** a buffer whose filetype has no configured formatter and no attached formatting-capable server is written
- **THEN** the contents are unchanged
- **AND** the write completes with no error
