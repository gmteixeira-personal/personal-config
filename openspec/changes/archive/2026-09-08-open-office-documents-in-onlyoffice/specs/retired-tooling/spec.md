## ADDED Requirements

### Requirement: LibreOffice is retired

LibreOffice SHALL NOT be part of this configuration. No configuration for it SHALL be tracked, no allowlist entry SHALL name a path belonging to it, no tracked mapping SHALL name one of its desktop entries, and on a machine this repository is deployed to none of its packages SHALL be installed and no configuration, state or cache directory belonging to it SHALL remain.

It is retired because the session's office suite is OnlyOffice, and running two office suites means two answers for every document type in a mapping whose whole purpose is to record one. `.config/mimeapps.list` names `onlyoffice-desktopeditors.desktop` for the office document types, and the `default-applications` specification requires each type to appear exactly once.

This retirement is not like the others recorded here, and the difference SHALL be stated wherever it is documented rather than left to be rediscovered. lazygit, zoxide, noctalia and alacritty were each a duplicate of something the session already had, so removing them cost no capability. LibreOffice was not a duplicate. It carried import filters and two components that OnlyOffice does not replace, and the formats they answered for have no handler after this change: the drawing and vector formats other than `.odg` and the Visio types — Publisher, CorelDRAW, EMF and WMF among them — the formula formats, and the legacy word processor and spreadsheet formats including WordPerfect, AbiWord, Lotus 1-2-3, StarOffice, dBASE, Gnumeric, Parquet and the ODF master document types.

Keeping one component was considered and is not available. `libreoffice-core` is 288 MB of the suite's 378 MB and every component requires it, so retaining Draw or Math for the formats OnlyOffice does not open means retaining the engine that made the duplicate answers a problem.

The loss is narrower than the component list suggests and SHALL be described in those terms. OnlyOffice declares `application/vnd.oasis.opendocument.graphics` and the Visio drawing, stencil and template types, so Draw's native format and the Visio family still open; what left with LibreOffice is the import filters around them.

#### Scenario: No LibreOffice configuration is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** no path under `.config/libreoffice/` SHALL appear
- **AND** no tracked file SHALL configure it, start it, or name a path belonging to it
- **AND** prose that names it as a tool this configuration no longer uses SHALL NOT violate this, where the naming is a record of the retirement rather than a configuration of the tool

#### Scenario: No tracked mapping names its desktop entries

- **WHEN** `.config/mimeapps.list` is inspected
- **THEN** no line SHALL name `libreoffice-writer.desktop`, `libreoffice-calc.desktop`, `libreoffice-impress.desktop`, `libreoffice-draw.desktop`, `libreoffice-math.desktop` or `libreoffice-startcenter.desktop`
- **AND** `grep -c libreoffice ~/.config/mimeapps.list` SHALL report 0

#### Scenario: The packages are not installed

- **WHEN** the system package manager is queried for LibreOffice
- **THEN** it SHALL report no `libreoffice-*` package as installed
- **AND** `libreoffice` and `soffice` SHALL NOT resolve to an executable on `PATH`

#### Scenario: No leftover state on the machine

- **WHEN** a machine running this configuration is inspected
- **THEN** `.config/libreoffice/` and `.cache/libreoffice/` SHALL each be absent
- **AND** `/usr/lib64/libreoffice/` SHALL be absent
- **AND** no `libreoffice-*.desktop` file SHALL remain under `/usr/share/applications/`

#### Scenario: The documentation records that it must stay absent

- **WHEN** the repository's tracked required-software documentation is read
- **THEN** LibreOffice SHALL be named among the tools that must not be installed
- **AND** the entry SHALL state that OnlyOffice serves its purpose instead
- **AND** the entry SHALL state which formats lost their handler with it, rather than describing the swap as a replacement in kind

#### Scenario: Re-adding it is a deliberate act

- **WHEN** someone wants LibreOffice back, whether as a full suite or as a single component for the formats OnlyOffice does not open
- **THEN** it SHALL require a change that supersedes this requirement, not merely reinstalling a package
- **AND** that change SHALL settle which suite answers for each office document type, so the mapping keeps exactly one answer per type
