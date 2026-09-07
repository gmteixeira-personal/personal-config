## ADDED Requirements

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

## REMOVED Requirements

### Requirement: The single-column rule is recorded as independent of focus centring

**Reason**: The requirement drew the distinction between the two settings from the value the focus setting happened to hold — that it "stays at `never`", and that centring every focused column would make the two look like alternatives. This change sets that value to `"on-overflow"`, so the requirement's own reasoning no longer holds and its final scenario, which asserted the focus-centring behaviour is unchanged, is now false.

**Migration**: Replaced by "The single-column rule is independent of the focus-centring rule" above, which keeps the distinction and both of its still-true scenarios, but grounds them in the cases the two settings decide rather than in a value that can change: a lone column has no previously focused column to overflow against, so no value of the focus rule can decide its position.
