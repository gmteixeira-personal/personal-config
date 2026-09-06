## MODIFIED Requirements

### Requirement: Plain text renders at an intensity this configuration chooses

The terminal's default foreground — the colour used when no colour is selected at all — SHALL be named by the tracked terminal configuration rather than inherited from whatever the terminal ships. The default background SHALL likewise be named there. Leaving either to the terminal's own default is not a choice this configuration made: it is whichever value the package happens to ship, and it changes under the reader when the package does.

The background SHALL be a value from the palette the rest of the graphical session uses, so that the terminal window and the surfaces around it — the desktop, the lock screen, the bar and the launcher — are drawn from one set of colours rather than from that set plus whatever the terminal shipped.

Where the tracked configuration names a palette value, it SHALL record which palette the value belongs to and where this repository's copy of that palette lives. The palette is restated in several files in several formats with no definition they can share, so a value whose origin is not written down cannot be checked against the others.

Where the tracked configuration explains such a value, the explanation SHALL name the value actually in force in the terminal version installed, not one from an earlier release.

Naming a background SHALL NOT reintroduce colour by palette index: the sixteen palette slots stay unwritten, as the requirement on naming colour by value already provides.

#### Scenario: Uncoloured text uses the configured foreground

- **WHEN** text is printed with no colour escape
- **THEN** it SHALL render in the foreground the tracked terminal configuration names

#### Scenario: The background is named rather than inherited

- **WHEN** the tracked terminal configuration is inspected for a default background
- **THEN** it SHALL name one
- **AND** that value SHALL NOT be the terminal's own shipped default

#### Scenario: The background belongs to the session's palette

- **WHEN** the terminal's background value is compared with the values the compositor, the lock screen and the launcher configurations use for their surfaces
- **THEN** it SHALL be drawn from the same palette as those

#### Scenario: The palette's origin is recorded

- **WHEN** the tracked terminal configuration's colour section is read
- **THEN** a comment SHALL name the palette the background comes from
- **AND** it SHALL name the tracked file holding this repository's copy of that palette

#### Scenario: The stated default is the real default

- **WHEN** a comment in the tracked terminal configuration names the terminal's own default for a value it overrides
- **THEN** that default SHALL be the one the installed terminal version uses

#### Scenario: Plain text stays legible against the named background

- **WHEN** the configured foreground and the configured background are compared
- **THEN** their contrast ratio SHALL be at least 7:1
