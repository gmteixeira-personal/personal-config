## Purpose

Normalizes the formatting of a buffer's contents to a per-filetype standard, applied automatically when the buffer is written and on demand from a keymap, so that formatting is never something the user has to remember to do or argue about.

## Requirements

### Requirement: Buffers are formatted on write

When a buffer is written, its contents SHALL be formatted before the write reaches disk, so that the saved file and the buffer both hold formatted text. Formatting SHALL be bounded by a timeout; if a formatter does not complete within it, the write SHALL still succeed with the buffer's contents unmodified.

#### Scenario: Saving a misformatted file

- **WHEN** the user writes a buffer whose filetype has a configured formatter
- **AND** the buffer's contents do not match that formatter's output
- **THEN** the buffer contents are replaced with the formatted output
- **AND** the formatted contents are what is written to disk

#### Scenario: Saving an already-formatted file

- **WHEN** the user writes a buffer that is already correctly formatted
- **THEN** the contents are unchanged
- **AND** the cursor position is preserved

#### Scenario: A formatter that hangs

- **WHEN** a formatter does not return within the configured timeout
- **THEN** the write still completes
- **AND** the buffer is written with its unformatted contents
- **AND** the user is not left with a blocked or truncated buffer

#### Scenario: A formatter that fails

- **WHEN** a configured formatter exits with an error, for example on syntactically invalid input
- **THEN** the buffer contents are left unmodified
- **AND** the write completes
- **AND** the error is surfaced to the user rather than silently swallowed

### Requirement: `<leader>cf` formats on demand

Pressing `<leader>cf` in normal mode SHALL format the current buffer using the same formatter selection as the on-write path. `<leader>c` SHALL be a prefix only and SHALL NOT itself be bound.

#### Scenario: Formatting without saving

- **WHEN** the user presses `<leader>cf`
- **THEN** the buffer is formatted in place
- **AND** the buffer is not written to disk
- **AND** the change is a single undoable edit

#### Scenario: The format key does not collide with the find prefix

- **WHEN** the user presses `<leader>f`
- **THEN** no formatting occurs

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

### Requirement: Formatting has exactly one entry point

Formatting SHALL be requested through a single mechanism for both the on-write and on-demand paths. No separate language-server format keymap SHALL be defined, so that a filetype covered by both an external formatter and a formatting-capable server cannot produce two different results depending on which key was pressed.

#### Scenario: One key, one result

- **WHEN** a filetype has both an external formatter and an attached formatting-capable language server
- **THEN** formatting on write and formatting via `<leader>cf` both use the external formatter
- **AND** there is no other keymap that formats using the language server instead
