## RENAMED Requirements

- FROM: `### Requirement: The file manager's status bar states its own foregrounds`
- TO: `### Requirement: Every coloured element of the file manager's chrome states its own foregrounds`

## MODIFIED Requirements

### Requirement: Every coloured element of the file manager's chrome states its own foregrounds

Every element of the file manager's chrome that states a background SHALL also state a foreground, rather than leaving the foreground to whatever the terminal's default happens to be. Chrome here means the tab bar and the status bar: the framing the file manager draws around the file list, as against the file list itself.

An element that paints a background and not a foreground is not inheriting a considered value; it is inheriting the colour chosen for ordinary text on the terminal's ordinary background, applied over a background nothing compared it against. The two settings live in different files, are made by different people for different reasons, and neither is wrong on its own — which is why the result is unreadable rather than merely ugly, and why no amount of care in either file alone prevents it.

The rule was already stated as "every element that states a background" rather than by naming the elements that were wrong, on the grounds that the fault is structural. That was borne out: the requirement was written about the status bar, and the tab bar turned out to ship the identical pair of values — a background with no foreground at 1.14:1, and a stated pair at 2.12:1 — and to be excluded only by where the sentence stopped. The scope is widened here so that the next element of the chrome to be looked at is covered before it is looked at, rather than after.

#### Scenario: A badge with a background has a foreground

- **WHEN** the file manager's theme is inspected for an element that states a background colour
- **THEN** that element SHALL also state a foreground colour

#### Scenario: The tab bar is inspected on the same terms

- **WHEN** the file manager's theme is inspected for the colours of the active and the inactive tab
- **THEN** each SHALL state both a foreground and a background

#### Scenario: Text is not the terminal's default

- **WHEN** text is drawn on a coloured background anywhere in the chrome
- **THEN** its colour SHALL NOT be the terminal's default foreground

## ADDED Requirements

### Requirement: Text in the file manager's chrome is readable against the background it is drawn on

Text drawn on a coloured background in the file manager's chrome SHALL reach a contrast ratio of at least 4.5:1 against that background.

This is a raised floor. It previously read "measurably more readable than what the program's shipped theme produces", because the shipped values were 1.14:1 and 2.12:1 against a 4.5:1 threshold and stating any value at all was most of the work. The allowance that went with it — a chosen colour MAY fall below the threshold provided the configuration records the measured ratio — is withdrawn, because the case it was written for is gone. It covered white text on the mode badge at 2.65:1, and the dark value the same comment named as the better number reaches 7.08:1 on the same background. Nothing in the configuration now needs the allowance, and leaving it in place would license copying a below-threshold value into each new element instead of copying the one that passes.

The measured ratio SHALL still be recorded beside each colour chosen for legibility, along with the ratio it replaced. Withdrawing the allowance removes the reason a ratio might be uncomfortable to write down; it does not remove the reason to write it down, which is that the next person to touch the value cannot otherwise tell a measured choice from a guess.

#### Scenario: A chosen colour meets the threshold

- **WHEN** the contrast ratio is measured between text in the chrome and the background it is drawn on
- **THEN** it SHALL be at least 4.5:1

#### Scenario: The measured ratio is recorded

- **WHEN** the theme is read around a colour chosen for legibility
- **THEN** it SHALL record the contrast ratio the choice produces
- **AND** it SHALL record the ratio it replaced


### Requirement: The tab bar and the status bar are coloured from the same values

The colours of the tab bar SHALL be the colours of the status bar: the active tab SHALL be drawn in the same foreground and background as the mode badge, and the inactive tab in the same foreground and background as the pale chip beside it.

They frame the same window, one along the top and one along the bottom, and they are the only two coloured things in it. Chosen independently they would drift — the same blue in two shades, or the same badge in two foregrounds — and the drift would be visible in a way neither value is wrong enough to explain. Chosen together they read as one piece of chrome, which is what a user reports when they ask for the top to look like the bottom.

The program makes this easy to get wrong rather than hard: it ships the tab bar and the status bar with the same two values, so they start matched and only a partial fix separates them. That is exactly what happened — the status bar was fixed for legibility and the tab bar was left shipped — and the requirement exists so that the next legibility fix to either one is made to both.

The consequence SHALL be accepted rather than worked around: the active tab's foreground is shared with the mode badge and with the position badge at the right end, so a change to that colour is a change to three elements at once, and there is no supported way to change one of them alone.

#### Scenario: The active tab matches the mode badge

- **WHEN** the theme's active tab and its mode badge are compared
- **THEN** they SHALL state the same foreground colour
- **AND** they SHALL state the same background colour

#### Scenario: The inactive tab matches the pale chip

- **WHEN** the theme's inactive tab and the chip beside the mode badge are compared
- **THEN** they SHALL state the same foreground colour
- **AND** they SHALL state the same background colour

#### Scenario: The sharing is recorded

- **WHEN** the theme is read around the tab colours
- **THEN** it SHALL record that those values are the status bar's restated
- **AND** it SHALL record that changing the shared foreground changes the tab bar and the status bar together

## REMOVED Requirements

### Requirement: Status bar text is readable against the background it is drawn on

**Reason**: Replaced by "Text in the file manager's chrome is readable against the background it is drawn on", which covers the tab bar as well as the status bar and raises the floor from "measurably better than shipped" to 4.5:1.

**Migration**: None for the configuration, which already satisfies the stricter requirement. The scenario "A value below the threshold is marked as such" is deliberately not carried over: it licensed a chosen colour below 4.5:1 provided the ratio was recorded, and the one value that relied on it — white on the mode badge at 2.65:1 — is now #11111b at 7.08:1. The companion scenario "The measured ratio is recorded" is carried over unchanged.
