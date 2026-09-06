# window-placement Specification

## Purpose

Defines where the compositor places tiled columns on a workspace — as distinct from what it draws around them — so that the positions the scrolling layout arrives at by default are stated as decisions where the session disagrees with them.

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

### Requirement: The single-column rule is recorded as independent of focus centring

Documentation SHALL record that the single-column centring is separate from the rule that decides when focusing a column centres it, and that the two are set independently.

The two settings sit next to each other in the same layout block, both describe centring, and neither name says which case it covers. The focus rule decides where a column lands when focus moves to it, which is a question a workspace only has once it holds more than one column; the single-column rule decides where the sole column sits, where focus has nowhere to move. Setting the focus rule to centre every focused column would also centre a lone one, which makes the two look like alternatives — they are not, and the session keeps the focus rule as it is.

#### Scenario: A reader distinguishes the two settings

- **WHEN** the configuration is read around the single-column centring
- **THEN** it SHALL state that the setting applies only to a workspace holding one column
- **AND** it SHALL state that the focus-centring setting is a separate decision that this change does not alter

#### Scenario: The focus-centring behaviour is unchanged

- **WHEN** focus moves between columns on a workspace holding more than one
- **THEN** the placement SHALL be whatever the focus-centring setting already produced before this change
