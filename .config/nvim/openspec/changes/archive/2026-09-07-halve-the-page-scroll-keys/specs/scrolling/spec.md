## ADDED Requirements

### Requirement: `<C-d>` and `<C-u>` move half a window, everywhere in the buffer

`<C-d>` SHALL move the cursor down by half the height of its window and `<C-u>` SHALL move it up by the same amount. The distance SHALL be measured in screen rows, so a wrapped line counts as the rows it occupies rather than as one line, and SHALL be half of the window the cursor is in, so a window that is split, resized or maximized yields a correspondingly smaller or larger half.

The distance SHALL NOT depend on where the view sits in the buffer. Within the first screenful, where the view cannot scroll further up, `<C-d>` SHALL still move the cursor half a window and not a whole one; within the last screenful `<C-u>` SHALL do the same. The two keys SHALL be mirror images of each other from any position: pressing one and then the other SHALL return the cursor to the line it started on, wherever the ends of the buffer allow both moves.

Both keys SHALL work in normal mode and in visual mode, where they extend the selection by that distance.

Neither key SHALL scroll the window itself. The view SHALL follow the cursor through the centring requirement above and by no other means, so the amount of text that passes under the cursor is whatever centring implies for that position.

#### Scenario: Half a window down from the first line

- **WHEN** the cursor is on the first line of a buffer longer than the window
- **AND** the user presses `<C-d>`
- **THEN** the cursor SHALL move down by half the window's height in screen rows
- **AND** it SHALL NOT move down by a whole window

#### Scenario: Half a window down from a centered position

- **WHEN** the cursor is centered in a long buffer, away from both ends
- **AND** the user presses `<C-d>`
- **THEN** the cursor SHALL move down by half the window's height in screen rows
- **AND** it SHALL remain on the middle row, the text having scrolled by the same amount

#### Scenario: The two keys undo each other

- **WHEN** the cursor is anywhere in a buffer with at least half a window above it and half a window below it
- **AND** the user presses `<C-d>` and then `<C-u>`
- **THEN** the cursor SHALL be back on the line it started on

#### Scenario: Half a window up from within the first screenful

- **WHEN** the cursor is a few lines below the first line of a buffer, closer to it than half a window
- **AND** the user presses `<C-u>`
- **THEN** the cursor SHALL land on the first line of the buffer
- **AND** nothing SHALL be reported as an error

#### Scenario: Half a window down from within the last screenful

- **WHEN** the cursor is a few lines above the last line of a long buffer, closer to it than half a window
- **AND** the user presses `<C-d>`
- **THEN** the cursor SHALL land on the last line of the buffer
- **AND** the view SHALL NOT scroll past it

#### Scenario: Half a window up from within the last screenful

- **WHEN** the cursor is on the last line of a long buffer
- **AND** the user presses `<C-u>`
- **THEN** the cursor SHALL move up by half the window's height in screen rows
- **AND** it SHALL NOT move up by a whole window

#### Scenario: A wrapped line counts as the rows it occupies

- **WHEN** the buffer contains lines long enough to wrap across several screen rows
- **AND** the user presses `<C-d>`
- **THEN** the cursor SHALL move down half a window measured in screen rows
- **AND** it SHALL NOT move half a window measured in buffer lines

#### Scenario: A resized window changes the distance

- **WHEN** the window is made shorter or taller
- **AND** the user presses `<C-d>`
- **THEN** the cursor SHALL move by half of the window's new height

#### Scenario: Extending a visual selection

- **WHEN** a visual selection is active
- **AND** the user presses `<C-d>`
- **THEN** the selection SHALL extend down by half a window
- **AND** the selection SHALL remain active

#### Scenario: A count multiplies the distance

- **WHEN** the user types a count before `<C-d>` or `<C-u>`
- **THEN** the cursor SHALL move that many half-windows in the key's direction

#### Scenario: A buffer shorter than the window

- **WHEN** a buffer with fewer lines than the window is open
- **AND** the user presses `<C-d>` or `<C-u>`
- **THEN** the cursor SHALL move within the buffer, stopping at its last or first line
- **AND** no blank space SHALL be scrolled into view

### Requirement: The page keys move a whole window, everywhere in the buffer

`<C-f>` and `<PageDown>` SHALL move the cursor down by the full height of its window, and `<C-b>` and `<PageUp>` SHALL move it up by the same amount. The distance SHALL be measured in screen rows, so a wrapped line counts as the rows it occupies rather than as one line, and SHALL be the height of the window the cursor is in, so a window that is split, resized or maximized yields a correspondingly smaller or larger page.

A page SHALL be the window's whole height and SHALL NOT be reduced to leave rows of the previous screen visible. In a window of 39 rows a press SHALL move 39 lines.

The four keys SHALL be one behaviour under two names: `<C-f>` SHALL move exactly as far as `<PageDown>`, and `<C-b>` exactly as far as `<PageUp>`.

The distance SHALL NOT depend on where the view sits in the buffer. Within the first screenful, where the view cannot scroll further up, a downward press SHALL still move the cursor one window and not two; within the last screenful an upward press SHALL do the same. Each key SHALL be the mirror of its opposite from any position: `<C-b>` SHALL move exactly as far as `<C-f>` in the other direction and `<PageUp>` exactly as far as `<PageDown>`, so pressing one and then its opposite SHALL return the cursor to the line it started on, wherever the ends of the buffer allow both moves.

Both directions SHALL work in normal mode and in visual mode, where they extend the selection by that distance, and a count SHALL multiply the distance.

None of the four SHALL scroll the window itself. The view SHALL follow the cursor through the centring requirement above and by no other means.

`<C-f>` and `<C-b>` SHALL keep their existing first duty of scrolling an open hover or signature float; they SHALL move the cursor by a page only when no such float is open.

#### Scenario: A page down from the first line

- **WHEN** the cursor is on the first line of a buffer longer than the window
- **AND** the user presses `<C-f>`
- **THEN** the cursor SHALL move down by the window's height in screen rows
- **AND** it SHALL NOT move down by two windows

#### Scenario: A page is the whole window

- **WHEN** the window is 39 rows tall and the buffer holds lines that do not wrap
- **AND** the user presses `<PageDown>` away from both ends of the buffer
- **THEN** the cursor SHALL move 39 lines
- **AND** no line visible before the press SHALL still be visible after it

#### Scenario: The two directions undo each other

- **WHEN** the cursor is anywhere in a buffer with at least a window above it and a window below it
- **AND** the user presses `<C-f>` and then `<C-b>`
- **THEN** the cursor SHALL be back on the line it started on
- **AND** the same SHALL hold for `<PageDown>` followed by `<PageUp>`

#### Scenario: The chord and the named key agree

- **WHEN** the cursor is on a given line
- **AND** the user presses `<C-f>` from it, and then returns to that line and presses `<PageDown>`
- **THEN** both presses SHALL land on the same line
- **AND** the same SHALL hold for `<C-b>` and `<PageUp>`

#### Scenario: A page up from within the last screenful

- **WHEN** the cursor is on the last line of a long buffer
- **AND** the user presses `<C-b>`
- **THEN** the cursor SHALL move up by the window's height in screen rows
- **AND** it SHALL NOT move up by two windows

#### Scenario: A page down from within the last screenful

- **WHEN** the cursor is closer to the last line of a long buffer than a whole window
- **AND** the user presses `<PageDown>`
- **THEN** the cursor SHALL land on the last line of the buffer
- **AND** the view SHALL NOT scroll past it

#### Scenario: A page up from within the first screenful

- **WHEN** the cursor is closer to the first line of a buffer than a whole window
- **AND** the user presses `<PageUp>`
- **THEN** the cursor SHALL land on the first line of the buffer
- **AND** nothing SHALL be reported as an error

#### Scenario: A wrapped line counts as the rows it occupies

- **WHEN** the buffer contains lines long enough to wrap across several screen rows
- **AND** the user presses `<C-f>`
- **THEN** the cursor SHALL move down a window measured in screen rows
- **AND** it SHALL NOT move down a window measured in buffer lines

#### Scenario: A resized window changes the page

- **WHEN** the window is made shorter or taller
- **AND** the user presses `<PageDown>`
- **THEN** the cursor SHALL move by the window's new height

#### Scenario: Extending a visual selection

- **WHEN** a visual selection is active
- **AND** the user presses `<C-f>`
- **THEN** the selection SHALL extend down by a window
- **AND** the selection SHALL remain active

#### Scenario: A count multiplies the distance

- **WHEN** the user types a count before any of the four keys
- **THEN** the cursor SHALL move that many windows in the key's direction

#### Scenario: A buffer shorter than the window

- **WHEN** a buffer with fewer lines than the window is open
- **AND** the user presses `<C-f>` or `<C-b>`
- **THEN** the cursor SHALL move within the buffer, stopping at its last or first line
- **AND** no blank space SHALL be scrolled into view

#### Scenario: An open documentation float takes the key first

- **WHEN** a hover or signature float is open
- **AND** the user presses `<C-f>`
- **THEN** the float SHALL scroll
- **AND** the cursor SHALL NOT move by a page
