## ADDED Requirements

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
