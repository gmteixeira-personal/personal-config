# terminal-font Specification

## Purpose

Defines the font the terminal renders with and the glyph coverage two tracked configurations depend on, which faces of that font are installed and which are deliberately left out, and where the requirement is announced — because the font files fall under the ignore policy's denial of `.local/`, so no checkout can carry them and documentation is the only thing a rebuild has to go on.

## Requirements

### Requirement: The terminal names a font that carries Nerd Font glyphs

The terminal's tracked configuration SHALL name its font family explicitly, and that family SHALL resolve to a face carrying the Nerd Font glyph ranges. Naming no font is not acceptable here: the resolved default is whatever fontconfig prefers on the machine, which is a decision made by the distribution rather than by this repository, and on this one it produced a face with none of the glyphs.

The coverage, not the family name, is what is required. A font can carry the name of a patched family and still be the unpatched upstream — the distribution package `jetbrains-mono-fonts` is exactly that, and installing it satisfies a search for "JetBrains Mono" while leaving every icon a replacement box. The requirement is therefore stated against what the font renders, not against what it is called.

Two tracked configurations depend on this and neither can compensate for its absence. The prompt draws its segment icons from the Nerd Font ranges, and Neovim loads `mini.icons` eagerly as its single icon provider, so the file explorer, the picker and the status line all draw from them too. Their failure is silent and total: every icon becomes a box, and nothing reports why.

#### Scenario: The configuration names the family

- **WHEN** the terminal's tracked configuration is inspected
- **THEN** it SHALL name a font family explicitly
- **AND** it SHALL NOT leave the family to a system default

#### Scenario: The named family resolves to patched glyphs

- **WHEN** the named family is queried for a glyph in the Nerd Font ranges, such as U+E0B0 or U+F011C
- **THEN** fontconfig SHALL resolve it to a face that contains that glyph
- **AND** that face SHALL be one of the installed patched files

#### Scenario: The unpatched distribution package is not a substitute

- **WHEN** a machine has the distribution's unpatched JetBrains Mono package and not the patched release
- **THEN** the requirement SHALL be considered unmet
- **AND** the glyph query above SHALL fail to resolve to a face containing the glyph

### Requirement: Only the monospaced faces are installed, per-user

The font SHALL be installed under the user's own font directory rather than system-wide, and only the monospaced faces of the patched release SHALL be present.

Per-user is what the rest of this configuration already does for anything not carried by a system package — the Neovim toolchain, the multiplexer, the OpenSpec CLI — and it keeps the install reproducible by a user with no root on the machine.

The patched release ships six families: a base family whose icon glyphs are double-width, a `Propo` family with proportional spacing, a monospaced family whose icons occupy a single cell, and a no-ligature variant of each. Only the monospaced one is correct in a terminal; the other two width behaviours misalign the cell grid, and the no-ligature variants are unused. Installing all six costs four times the disk for faces nothing selects, and leaves three families that a later configuration could name by mistake and get a subtly broken grid from.

#### Scenario: The install is per-user

- **WHEN** the font files are located
- **THEN** they SHALL be under the user's own font directory
- **AND** no part of the install SHALL require root

#### Scenario: Only the monospaced family is present

- **WHEN** fontconfig is asked which families of the patched font are available
- **THEN** it SHALL report the monospaced family
- **AND** it SHALL NOT report the base family, the proportional family, or any no-ligature variant

#### Scenario: The files are not tracked

- **WHEN** the repository is inspected
- **THEN** no font file SHALL appear in `git ls-files`
- **AND** the install directory SHALL be ignored by the existing deny-by-default policy without a new entry

### Requirement: The font requirement is announced in tracked documentation

The repository's tracked required-software documentation SHALL name the font family, the release it comes from, where it is installed, and that the distribution's package of the same name is not a substitute.

This is the whole reproduction procedure. The files are ignored, so a checkout carries nothing; the terminal's configuration names a family and says nothing about where to get it; and the failure that follows from skipping it is silent and looks like a broken editor rather than a missing font. Documentation that named no font would leave a reader with a requirement they cannot act on, which is the state this requirement exists to end.

#### Scenario: A reader can act on the entry

- **WHEN** the required-software documentation is read on a machine with no Nerd Font installed
- **THEN** it SHALL name the specific font family the terminal configuration names
- **AND** it SHALL name where the patched release is obtained
- **AND** it SHALL state that the distribution package of the same name does not carry the glyphs

#### Scenario: The entry describes where the font lives

- **WHEN** the required-software documentation is read
- **THEN** it SHALL state that the font is installed onto the machine
- **AND** it SHALL NOT describe the font as something the terminal emulator supplies

#### Scenario: What breaks without it is named

- **WHEN** the required-software documentation is read
- **THEN** it SHALL name what renders incorrectly when the font is absent
