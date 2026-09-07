## ADDED Requirements

### Requirement: The file manager's status bar states its own foregrounds

Every element of the file manager's status bar that states a background SHALL also state a foreground, rather than leaving the foreground to whatever the terminal's default happens to be.

An element that paints a background and not a foreground is not inheriting a considered value; it is inheriting the colour chosen for ordinary text on the terminal's ordinary background, applied over a background nothing compared it against. The two settings live in different files, are made by different people for different reasons, and neither is wrong on its own — which is why the result is unreadable rather than merely ugly, and why no amount of care in either file alone prevents it.

The rule is stated as "every element that states a background" rather than by naming the two elements that are wrong today, because the fault is structural. An element that gains a background later gains this fault with it.

#### Scenario: A badge with a background has a foreground

- **WHEN** the file manager's theme is inspected for an element that states a background colour
- **THEN** that element SHALL also state a foreground colour

#### Scenario: Text is not the terminal's default

- **WHEN** text is drawn on a coloured background in the status bar
- **THEN** its colour SHALL NOT be the terminal's default foreground

### Requirement: Status bar text is readable against the background it is drawn on

Text in the file manager's status bar SHALL be readable against the background it sits on, and SHALL be measurably more readable than what the program's shipped theme produces in this session.

Readable is a floor rather than a target here. The starting point is 1.14:1 for the badges and 2.12:1 for the chips against a 4.5:1 threshold, so any stated value is an improvement and stating one is most of the work. Where a chosen value still falls below the threshold, the configuration SHALL record the measured ratio, so that a value which is better but not yet good is not mistaken for a value that was checked and passed.

#### Scenario: The measured ratio is recorded

- **WHEN** the theme is read around a colour chosen for legibility
- **THEN** it SHALL record the contrast ratio the choice produces
- **AND** it SHALL record the ratio it replaced

#### Scenario: A value below the threshold is marked as such

- **WHEN** a chosen colour produces a ratio below 4.5:1
- **THEN** the configuration SHALL state that it is below the threshold rather than presenting it as sufficient

### Requirement: Colours chosen here do not depend on the terminal's palette slots

Where this configuration chooses a colour for the file manager, it SHALL state a 24-bit value rather than name one of the terminal's sixteen palette slots.

The session's terminal configuration deliberately leaves those slots at the terminal's own defaults, on the recorded reasoning that nothing this session emits asks for one. A colour named by slot is therefore a colour this session has not chosen, and moving the slots later would move it without anyone intending to. A colour the configuration keeps on purpose — because it is the value already on screen and the change is not about it — MAY stay named by slot, and the configuration SHALL say that is why.

Repainting the slots is not an alternative route to this requirement. The unreadable text is unset rather than badly set, so it stays the terminal's default foreground whatever the slots become; the measured ratios against this session's own palette are 1.10:1 and 1.23:1, no better than the 1.14:1 being fixed.

#### Scenario: A chosen colour is a literal

- **WHEN** the theme is inspected for a colour this change selects
- **THEN** it SHALL be a 24-bit value

#### Scenario: A retained colour is explained

- **WHEN** the theme names a palette slot rather than a literal
- **THEN** the configuration SHALL record that the value is being kept rather than chosen

### Requirement: The row under the cursor is left alone

The file manager's highlighting of the row under the cursor SHALL NOT be changed by configuration that sets out to improve legibility elsewhere.

It is already the best-contrasted element in the window, at 7.08:1, so a change made in the name of readability would make it worse. It is also not addressable: the program styles that row by reversing the row's own colours rather than by a theme key, so the only lever is the colour every row of that file type is drawn in — which would repaint rows that are not under the cursor to fix one that is.

#### Scenario: The highlight is unchanged

- **WHEN** the file manager's theme is inspected after a legibility change
- **THEN** it SHALL contain no setting for the row under the cursor

#### Scenario: The reason is recorded

- **WHEN** the configuration is read
- **THEN** it SHALL record that the row under the cursor was considered and deliberately left alone
