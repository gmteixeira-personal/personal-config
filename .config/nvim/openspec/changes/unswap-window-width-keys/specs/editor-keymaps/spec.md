## MODIFIED Requirements

### Requirement: The focused window is resized with Alt and a home-row direction key

`<M-k>` and `<M-j>` SHALL increase and decrease the focused window's height. `<M-l>` and `<M-h>` SHALL increase and decrease its width. Each of the four keys SHALL grow the focused window toward the direction its letter names and shrink it away from that direction, so the horizontal pair reads the same way the vertical pair does. The four keys SHALL name the same four directions as the focus mappings, so that focusing and resizing differ only by which modifier is held. Each press SHALL change the size by a fixed increment, and holding or repeating the key SHALL continue to resize until the window reaches the limit the surrounding layout allows.

#### Scenario: Growing a window vertically

- **WHEN** two windows are stacked and the user presses `<M-k>` in the upper one
- **THEN** that window becomes taller
- **AND** the other window becomes correspondingly shorter

#### Scenario: Growing a window horizontally

- **WHEN** two windows sit side by side and the user presses `<M-l>` in the left one
- **THEN** that window becomes wider
- **AND** the other becomes correspondingly narrower

#### Scenario: Shrinking a window horizontally

- **WHEN** two windows sit side by side and the user presses `<M-h>` in the left one
- **THEN** that window becomes narrower
- **AND** the other becomes correspondingly wider

#### Scenario: Growing a window that sits on the right of the layout

- **WHEN** two windows sit side by side and the user presses `<M-l>` in the right one
- **THEN** that window becomes wider
- **AND** the other becomes correspondingly narrower
- **AND** the key grows the focused window regardless of which side of the layout it occupies

#### Scenario: The resize keys do not disturb an existing mapping

- **WHEN** a key that another part of the configuration already binds is pressed
- **THEN** it keeps the meaning that part gave it
- **AND** no resize mapping has replaced it

#### Scenario: Resizing when there is nothing to resize against

- **WHEN** only one window is open and the user presses any resize key
- **THEN** the window continues to fill the tab page
- **AND** no error is raised
