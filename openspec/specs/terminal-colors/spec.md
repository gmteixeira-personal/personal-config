# terminal-colors Specification

## Purpose

Defines which colours the terminal and the programs running in it put on screen, and by what mechanism those colours are named, so that what appears is the colour this configuration chose rather than whichever entry the terminal's shipped palette happens to hold in that slot.

## Requirements

### Requirement: Colour is named by value, not by palette slot

Every colour this configuration chooses SHALL be emitted as a direct 24-bit value. A colour SHALL NOT be requested by palette index, because an index is a question the terminal answers from its own theme: the same configuration then renders differently under a terminal that ships a different palette, and the choice recorded here is not the choice displayed.

This SHALL hold for the colours of a directory listing, for shell syntax highlighting, and for the prompt.

The terminal's sixteen palette slots SHALL be left at whatever the terminal ships. Once no configured colour is requested by index, their values stop being load-bearing, and restating them would only create a second place to keep in step.

#### Scenario: A directory listing names its colours

- **WHEN** the environment variable carrying the listing's colours is inspected in an interactive shell
- **THEN** every colour in it SHALL be a direct 24-bit value
- **AND** no entry SHALL select a colour by palette index

#### Scenario: Syntax highlighting names its colours

- **WHEN** the shell's syntax-highlighting colour settings are inspected
- **THEN** each SHALL carry a 24-bit value
- **AND** none SHALL carry a colour name that resolves through the palette

#### Scenario: A different terminal palette changes nothing

- **WHEN** the terminal's palette slots are given different values
- **THEN** the listing, the highlighting and the prompt SHALL render in the same colours as before

### Requirement: The rendered colours are unchanged by how they are named

Moving a colour from a palette index to a direct value SHALL NOT change what is on screen. Each colour SHALL be given the value that the palette slot it replaces resolves to under the terminal this configuration runs.

Which files fall into which colour group MAY change where the grouping comes from the generator rather than from this configuration, but the set of colours in use SHALL NOT.

#### Scenario: A listing keeps its colours

- **WHEN** the same directory is listed before and after the change
- **THEN** directories, symbolic links, executables, archives and media SHALL each render in the colour they rendered before

#### Scenario: No colour is introduced or dropped

- **WHEN** the set of distinct colours the listing can produce is compared before and after
- **THEN** it SHALL hold the same values

### Requirement: Bold is weight, not a second way to say bright

Where a colour is meant to be the bright form, this configuration SHALL name the bright value outright. It SHALL NOT rely on the terminal promoting a bold attribute to a brighter colour, because terminals disagree on whether they do: some promote, and some — including the multiplexer this configuration runs — draw bold as weight and keep the colour, so the same escape sequence yields two different colours.

Bold SHALL remain available as a weight where weight is what is wanted.

#### Scenario: The same listing in a promoting and a non-promoting renderer

- **WHEN** the same directory is listed in a terminal that promotes bold to bright and in one that does not
- **THEN** the colours SHALL be identical in both

### Requirement: Plain text renders at an intensity this configuration chooses

The terminal's default foreground — the colour used when no colour is selected at all — SHALL be named by the tracked terminal configuration rather than inherited from whatever the terminal ships. The background SHALL likewise be whatever the tracked configuration states or, where it states nothing, deliberately the terminal's own.

Where the tracked configuration explains such a value, the explanation SHALL name the value actually in force in the terminal version installed, not one from an earlier release.

#### Scenario: Uncoloured text uses the configured foreground

- **WHEN** text is printed with no colour escape
- **THEN** it SHALL render in the foreground the tracked terminal configuration names

#### Scenario: The stated default is the real default

- **WHEN** a comment in the tracked terminal configuration names the terminal's own default for a value it overrides
- **THEN** that default SHALL be the one the installed terminal version uses

### Requirement: Colour settings live under the section heading the installed terminal expects

The tracked terminal configuration SHALL write its colour settings under the section heading the installed terminal version reads without complaint. A heading that the installed version still parses but reports as deprecated SHALL be treated as wrong, not as acceptable until it breaks: the terminal prints the notice on every window it opens, and the reader who sees it cannot tell whether the values under that heading took effect at all.

Opening a terminal SHALL therefore produce the shell and nothing before it. No deprecation notice, and no other diagnostic from the terminal itself, SHALL appear above the first prompt.

Where the terminal offers more than one colour section and selects between them by a setting, only the section that setting selects SHALL be written. The unselected section SHALL be left out for the same reason the sixteen palette slots are left out: nothing in this configuration switches between them, so a second section would be a second place to keep in step with no reader.

The heading SHALL carry a comment recording why it is spelled the way it is, naming the terminal version that introduced the spelling and the setting that decides which section applies. A suffixed heading implies a counterpart the reader will go looking for; the comment is what tells them there is deliberately none.

#### Scenario: A new terminal window prints no notice

- **WHEN** a terminal window is opened
- **THEN** the first line on screen SHALL be the shell's own output
- **AND** no deprecation notice from the terminal SHALL precede it

#### Scenario: The configuration passes the terminal's own check

- **WHEN** the terminal is asked to check the tracked configuration
- **THEN** it SHALL report the configuration valid
- **AND** it SHALL report no deprecated setting or section

#### Scenario: Only the selected colour section is written

- **WHEN** the tracked terminal configuration is inspected for colour sections
- **THEN** exactly one SHALL be present
- **AND** it SHALL be the one the terminal's colour-theme setting selects

#### Scenario: The heading explains its own spelling

- **WHEN** the colour section heading in the tracked terminal configuration is read
- **THEN** a comment SHALL name the terminal version that introduced that spelling
- **AND** it SHALL name the setting that decides which colour section applies

#### Scenario: The foreground still applies under the new heading

- **WHEN** text is printed with no colour escape after the heading is renamed
- **THEN** it SHALL render in the same foreground as before the rename

### Requirement: Colour depth is advertised without changing the terminal's identity

24-bit support SHALL be advertised through the environment alone. `TERM` SHALL keep the entry the terminal itself sets, and no terminfo entry SHALL be compiled into a per-user database to add a colour-depth capability to it.

`TERM` is interpreted on the far side of an `ssh` connection, where a substituted or locally extended entry may not exist; the environment variable is not, and a program that does not read it degrades to fewer colours rather than to a broken screen.

A program that reads colour depth from terminfo rather than from the environment SHALL therefore be left at the depth terminfo reports. This is accepted, and SHALL NOT be worked around by either of the means above.

#### Scenario: TERM is the terminal's own

- **WHEN** the terminal's tracked configuration and the shell startup files are inspected
- **THEN** neither SHALL assign `TERM`

#### Scenario: No local terminfo database is required

- **WHEN** the configuration is bootstrapped onto a machine
- **THEN** no step SHALL compile a terminfo entry
- **AND** colours SHALL be correct without one

### Requirement: The listing's colours survive the absence of what generates them

Where the colours of a directory listing are produced by a program that is not part of the base system, that program SHALL be optional. Its absence SHALL leave a coloured listing rather than an uncoloured one, and SHALL be silent: no message, no error, and a shell that starts normally.

#### Scenario: The generator is absent

- **WHEN** a shell starts on a machine where that program is not installed
- **THEN** the listing SHALL still be coloured
- **AND** the shell SHALL print nothing about it

#### Scenario: The generator is present

- **WHEN** a shell starts on a machine where it is installed
- **THEN** the listing's colours SHALL be the 24-bit values this configuration names

### Requirement: Both shells colour a listing the same way

The listing colours SHALL be the same whether the shell is the interactive one this configuration prefers or the one an `ssh` session, `sudo -s`, or anything invoking `$SHELL` lands in. Both read a tracked startup file, and the two SHALL agree on this as they already agree on the rest of the environment.

#### Scenario: The two shells agree

- **WHEN** the listing-colour environment variable is compared between the two shells on the same machine
- **THEN** the values SHALL be identical
