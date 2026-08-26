## Purpose

Provides filetype, directory, and symbol icons to every plugin that displays them, from a single source, so that the same file shows the same glyph everywhere in the editor.

## ADDED Requirements

### Requirement: Exactly one icon provider is installed

The configuration SHALL install a single icon provider plugin. A second icon provider SHALL NOT be installed, whether directly or as another plugin's dependency.

#### Scenario: No duplicate provider is pulled in as a dependency

- **WHEN** the installed plugin list is inspected after a full install
- **THEN** exactly one icon-providing plugin is present

### Requirement: Plugins requesting the legacy icon provider are served transparently

Many plugins request icons through the `nvim-web-devicons` module interface. The configuration SHALL satisfy those requests from the single installed provider, so such a plugin renders icons without that plugin being installed and without patching the requesting plugin.

#### Scenario: A plugin that requires the legacy module gets icons

- **WHEN** a plugin calls `require("nvim-web-devicons")` and asks for a file's icon and highlight group
- **THEN** an icon and a highlight group are returned
- **AND** no error about a missing module is raised

#### Scenario: The shim is active before any plugin requests icons

- **WHEN** a plugin that requests icons loads at startup
- **THEN** the compatibility shim is already in place

### Requirement: Icons are available for the categories plugins use

The provider SHALL supply icons for files, directories, and filetypes at minimum, so that any plugin displaying those categories can render one.

#### Scenario: File icons reflect type

- **WHEN** icons are requested for two files of different types
- **THEN** each returns an icon appropriate to its type
- **AND** each returns a highlight group so the icon is colored by the active theme

#### Scenario: Unknown file type still renders

- **WHEN** an icon is requested for a file with no recognized extension or filetype
- **THEN** a fallback icon and highlight group are returned rather than an error or an empty string
