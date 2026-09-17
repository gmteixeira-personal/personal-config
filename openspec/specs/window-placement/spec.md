# window-placement Specification

## Purpose

Defines where the compositor puts a window on a workspace — where it places tiled columns, and which windows it does not tile at all — as distinct from what it draws around them, so that the positions the scrolling layout arrives at by default are stated as decisions where the session disagrees with them.

## Requirements

### Requirement: A workspace holding one column centres it

Where a workspace holds exactly one column, the compositor SHALL place that column in the horizontal centre of the output rather than against an edge.

A scrolling layout places columns from the left edge rightwards because that is the direction the workspace scrolls in. That rule decides the position of the second column and every column after it, and it also decides the position of the first — which is a side effect, not a choice: with nothing to scroll to, the left edge is an arbitrary place to pin the only thing on screen, and the empty half of the output sits to one side of the window rather than around it.

The rule counts columns, not windows. A single column holding several windows stacked in it is still one column and SHALL be centred; two columns SHALL NOT be, however few windows they hold between them.

#### Scenario: One window on a workspace

- **WHEN** a workspace holds a single window in a single column
- **THEN** that column SHALL be centred horizontally on the output

#### Scenario: A single column of stacked windows

- **WHEN** a workspace holds one column containing more than one window
- **THEN** that column SHALL be centred horizontally on the output

#### Scenario: A second column opens

- **WHEN** a second column is opened on a workspace whose one column was centred
- **THEN** the workspace SHALL revert to the layout's ordinary placement
- **AND** the centring SHALL NOT be applied to either column on account of this requirement

#### Scenario: The last of two columns closes

- **WHEN** a workspace is left with exactly one column after the other closes
- **THEN** the remaining column SHALL be centred horizontally on the output

### Requirement: The centring is stated in the compositor configuration

The compositor configuration SHALL state the single-column centring rather than leave it to the compositor's default, and SHALL record why it is set.

The compositor's default is to align the lone column to the left edge, so the behaviour this capability requires exists only while the configuration asks for it. A reader finding the setting unexplained cannot tell it apart from a setting copied out of an example file, which is the same reason every other value the layout block sets carries its own note.

#### Scenario: The setting is present

- **WHEN** the compositor configuration's layout settings are inspected
- **THEN** they SHALL state that a single column is centred

#### Scenario: The reason is recorded

- **WHEN** the configuration is read around that setting
- **THEN** it SHALL record why the session sets it rather than accepting the default

### Requirement: Focusing a column that does not fit beside the last one centres it

Where focus moves to a column that cannot be shown on the output together with the column that held focus before it, the compositor SHALL place the newly focused column in the horizontal centre of the output. Where the two columns do fit together on the output, the compositor SHALL NOT move the view on account of the focus change.

A scrolling layout brings an off-screen column into view by scrolling the least amount that reaches it, which leaves that column against whichever edge of the output it was scrolled in from. The column so placed is the one that has just been focused — the one about to be read or typed into — and an edge is the worst place on the output to read a column: it is against the bezel, and the rest of the workspace is stacked on one side of it rather than distributed around it.

The condition is what limits the rule to the case that needs it. When the newly focused column does not fit beside the previous one the view has to move regardless, so centring costs no motion that was not already going to happen; it only chooses where the scroll stops. When the two do fit, the column is already on screen and already readable, and moving the view would be motion with nothing to show for it. Centring every focused column unconditionally would do exactly that, and SHALL NOT be what this requirement asks for.

Like every other rule in this capability, this counts columns and not windows. A column holding several stacked windows is one column, and whether it fits beside the previously focused column is decided by that column's width.

#### Scenario: Focus moves to a column that does not fit alongside

- **WHEN** focus moves to a column that cannot be shown on the output together with the previously focused column
- **THEN** the newly focused column SHALL be centred horizontally on the output

#### Scenario: Focus moves between two columns already on screen together

- **WHEN** focus moves between two columns that fit on the output together
- **THEN** the view SHALL NOT move
- **AND** neither column SHALL be centred on account of the focus change

#### Scenario: A wide column takes focus

- **WHEN** focus moves to a column wide enough that it and the previously focused column cannot share the output
- **THEN** that column SHALL be centred horizontally on the output
- **AND** the number of windows stacked in either column SHALL NOT affect this

#### Scenario: Focus returns to the column it came from

- **WHEN** focus moves to a column that is centred under this requirement and then returns to the column it came from
- **THEN** the column it returns to SHALL be centred if it and the column just left cannot share the output

### Requirement: The focus-centring rule is stated in the compositor configuration

The compositor configuration SHALL state the focus-centring rule rather than leave it to the compositor's default, and SHALL record why that value is chosen over the two it is chosen against.

The compositor's default leaves a newly focused column against the edge it was scrolled to, so the behaviour the requirement above describes exists only while the configuration asks for it. The setting takes one of three values and the two rejected ones are the reason the note is needed: a reader who finds only the chosen value cannot tell a weighed decision from a value copied out of an example file, and the difference between centring on overflow and centring always is not visible in the value's name.

#### Scenario: The setting is present

- **WHEN** the compositor configuration's layout settings are inspected
- **THEN** they SHALL state that a focused column is centred when it does not fit beside the previously focused one

#### Scenario: The rejected values are recorded

- **WHEN** the configuration is read around that setting
- **THEN** it SHALL record why the session centres on overflow rather than leaving the column at the edge
- **AND** it SHALL record why it does not centre every focused column

### Requirement: The single-column rule is independent of the focus-centring rule

Documentation SHALL record that the single-column centring is separate from the rule that decides when focusing a column centres it, and that the two are set independently.

The two settings sit next to each other in the same layout block, both describe centring, and neither name says which case it covers. The focus rule decides where a column lands when focus moves to it, which is a question a workspace only has once it holds more than one column; the single-column rule decides where the sole column sits, where focus has nowhere to move. Because a lone column has no previously focused column to be measured against, no value of the focus rule decides its position, and the single-column rule is the only thing that does.

The two therefore never decide the same case, and setting one says nothing about the other. They are not alternatives and SHALL NOT be recorded as such, whatever value the focus rule presently holds.

#### Scenario: A reader distinguishes the two settings

- **WHEN** the configuration is read around the single-column centring
- **THEN** it SHALL state that the setting applies only to a workspace holding one column
- **AND** it SHALL state that the focus-centring setting is a separate decision covering the case where a workspace holds more than one

#### Scenario: The single-column behaviour does not follow the focus rule

- **WHEN** a workspace holds exactly one column
- **THEN** that column SHALL be centred by the single-column rule
- **AND** the value of the focus-centring setting SHALL NOT change where it is placed

### Requirement: A window opened only to carry a drag is floated rather than tiled

Where a window exists only for the length of a drag-and-drop gesture, the compositor SHALL open it floating.

A scrolling tiling layout has no cheap place to put a window. Opening one as a column moves every other column on the workspace aside to make room, and closing it moves them all back — motion that is the right answer for a window being opened to work in, and the wrong answer for one that will be gone in the seconds it takes to drag a file out of it. The user is at that moment aiming a pointer at the window they mean to drop into, and the layout has just moved it.

Floating also puts the window above the tiled ones rather than beside them, which is what a drag needs: the source and the target have to be visible at the same time, and a tiled source is one that may have scrolled the target off the output.

#### Scenario: The drag window opens floating

- **WHEN** a window is opened to carry a drag
- **THEN** the compositor SHALL open it floating

#### Scenario: The workspace is not rearranged

- **WHEN** a drag window opens on a workspace holding tiled columns
- **THEN** those columns SHALL NOT be moved to make room for it

#### Scenario: The target stays visible

- **WHEN** a drag window is open over a workspace
- **THEN** it SHALL be drawn above the tiled windows rather than displacing one

### Requirement: The floating rule is stated in the compositor configuration, and says how it identifies the window

The compositor configuration SHALL state the floating rule, SHALL record why the window is floated, and SHALL record how the rule identifies it — including that the identifier it matches on is not the window's full application identifier.

The compositor tiles by default, so this behaviour exists only while the configuration asks for it. The match itself needs its own note because it is not a literal: the rule matches a fragment of the application identifier rather than the whole of it, and a reader who assumes the value is the identifier will not be able to reconcile it with what the window actually reports. Recording the full identifier beside the fragment is what lets the rule be checked without running the program.

#### Scenario: The rule is present

- **WHEN** the compositor configuration's window rules are inspected
- **THEN** one SHALL float the drag window

#### Scenario: The reason is recorded

- **WHEN** the configuration is read around that rule
- **THEN** it SHALL record why the window is floated rather than tiled

#### Scenario: The match is explained

- **WHEN** the configuration is read around that rule
- **THEN** it SHALL record the window's full application identifier
- **AND** it SHALL state that the value matched against it is a fragment rather than the whole
