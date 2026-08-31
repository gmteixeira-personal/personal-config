# nvim-markdown-rendering Specification

## Purpose

Defines how Neovim displays a markdown buffer: which markup is drawn as formatted text instead of shown as characters, which text stays raw so the document remains editable in place, and where the syntax highlighting inside fenced code blocks comes from.

## Requirements

### Requirement: Markdown markup is drawn as formatted text

A markdown buffer SHALL be displayed as a formatted document rather than as its source characters. Headings, list markers, task checkboxes, tables, block quotes, callouts, and fenced code blocks SHALL each be given a visual treatment that distinguishes them from surrounding prose. The underlying file SHALL NOT be modified to achieve this — rendering is a display concern only, and the bytes on disk SHALL be unchanged by opening, viewing, or closing the buffer.

#### Scenario: Headings are distinguishable by level

- **WHEN** a markdown buffer containing headings of more than one level is displayed
- **THEN** each heading SHALL be visually distinct from body text
- **AND** headings of different levels SHALL be distinguishable from each other
- **AND** the leading hash characters SHALL NOT be shown as literal text

#### Scenario: A table is aligned

- **WHEN** a markdown buffer containing a pipe table is displayed
- **THEN** the table's columns SHALL be drawn aligned to a common width
- **AND** its borders SHALL be drawn as connected lines rather than as pipe and hyphen characters

#### Scenario: Task list state is legible at a glance

- **WHEN** a markdown buffer containing both a checked and an unchecked task list item is displayed
- **THEN** each item SHALL carry a mark indicating its state
- **AND** the two states SHALL be distinguishable from each other without reading the bracket characters

#### Scenario: A fenced code block is set apart from prose

- **WHEN** a markdown buffer containing a fenced code block is displayed
- **THEN** the block SHALL be visually separated from the prose around it
- **AND** the fence's declared language SHALL be indicated

#### Scenario: The file on disk is untouched

- **WHEN** a markdown file is opened, viewed, and closed without an edit being made
- **THEN** its contents on disk SHALL be byte-identical to before
- **AND** no write SHALL have occurred

### Requirement: The cursor's own line shows raw markup

The line the cursor is on SHALL show its markdown source rather than its rendered form, so that markup can be read and edited exactly as written. Moving the cursor onto a line SHALL reveal that line's source, and moving off it SHALL restore the rendered form. This SHALL apply in every mode, so a rendered document is never read-only in practice.

#### Scenario: Moving onto a line reveals its source

- **WHEN** the cursor moves onto a rendered line — a heading, a table row, a task item, or a link
- **THEN** that line SHALL be redrawn as its raw markdown source
- **AND** the surrounding lines SHALL stay rendered

#### Scenario: Moving away restores the rendering

- **WHEN** the cursor leaves a line whose source was revealed
- **THEN** that line SHALL return to its rendered form

#### Scenario: Markup can be edited in place

- **WHEN** the user edits markup on the cursor's line — changing a heading level, or toggling a checkbox character
- **THEN** the characters being edited SHALL be visible throughout the edit
- **AND** the rendered form SHALL reflect the edit once the cursor leaves the line

### Requirement: Fenced code is highlighted as its declared language

Code inside a fenced block SHALL be syntax-highlighted according to the language named on the fence, using Neovim's treesitter highlighting and the injection queries that ship with it. The legacy regular-expression syntax rules SHALL NOT be what colors a markdown buffer, because they do not use those injections.

#### Scenario: Treesitter highlighting is active on a markdown buffer

- **WHEN** a markdown buffer is open
- **THEN** a treesitter highlighter SHALL be attached to it
- **AND** it SHALL NOT be left to the legacy syntax rules

#### Scenario: A code fence is colored by its language

- **WHEN** a fenced block declares a language whose parser is available
- **THEN** the code inside it SHALL be highlighted using that language's rules
- **AND** the highlighting SHALL differ from that of the prose around the block

#### Scenario: An unavailable language degrades quietly

- **WHEN** a fenced block declares a language with no parser installed
- **THEN** the block SHALL still be rendered as a code block
- **AND** no error SHALL be reported to the user

### Requirement: Only markdown buffers are affected

Rendering SHALL apply to markdown buffers and to no other filetype. A session that never opens a markdown file SHALL be unaffected — no rendering work SHALL be performed and no start-up cost SHALL be paid for this capability.

#### Scenario: Another filetype is untouched

- **WHEN** a buffer of any other filetype is open
- **THEN** its text SHALL be displayed exactly as before this capability existed
- **AND** no concealment or virtual text from markdown rendering SHALL appear in it

#### Scenario: A session without markdown pays nothing

- **WHEN** Neovim starts and no markdown buffer is opened
- **THEN** the rendering support SHALL NOT be loaded
- **AND** start-up time SHALL be unchanged

### Requirement: The capability runs on what Neovim bundles

This capability SHALL work using only the treesitter engine, parsers, and queries distributed with Neovim itself. It SHALL NOT require installing an additional treesitter parser, a parser-management plugin, an external command-line program, or a compilation or build step at install time.

#### Scenario: A fresh install needs no extra component

- **WHEN** the configuration is installed on a machine that has only Neovim and the plugin manager
- **THEN** markdown rendering SHALL work without any further installation
- **AND** no parser SHALL need to be compiled or downloaded separately

#### Scenario: No external program is invoked

- **WHEN** a markdown buffer is rendered
- **THEN** no external process SHALL be spawned to produce the rendering

### Requirement: The configuration is tracked

The configuration enabling this capability SHALL live in the tracked Neovim configuration in this repository, so a machine checked out fresh SHALL render markdown without any manual step. The plugin version SHALL be pinned in the tracked lock file, so a fresh checkout resolves the same version.

#### Scenario: A restored machine renders markdown

- **WHEN** this repository is checked out into a fresh home directory and Neovim starts
- **THEN** opening a markdown file SHALL render it as described above
- **AND** no manual configuration step SHALL be needed

#### Scenario: The version is pinned

- **WHEN** the tracked lock file is inspected after the change is implemented
- **THEN** it SHALL carry an entry pinning the rendering plugin to a specific revision
