## ADDED Requirements

### Requirement: Windows are drawn with rounded corners

The compositor SHALL draw windows with a stated corner radius, and SHALL clip each window's own content to that radius.

The radius alone rounds what the compositor draws around a window. A client painting to its full rectangle still fills the corner it was given, so without clipping the result is a rounded frame with a square window inside it — visible wherever a window's own background differs from the surface behind it.

The radius SHALL be stated in the configuration rather than left to the compositor's default, for the same reason the focus marker's width is: a value that is never written down is one a reader assumes was never chosen, and one a compositor update is free to change.

#### Scenario: A tiled window's corners

- **WHEN** a window is displayed
- **THEN** its corners SHALL be rounded to the stated radius

#### Scenario: The client's own painting is clipped

- **WHEN** a window paints a background colour of its own to its full rectangle
- **THEN** the corner SHALL still be rounded
- **AND** no square edge of the client's background SHALL appear inside it

#### Scenario: The radius is stated

- **WHEN** the compositor configuration is inspected for the corner radius
- **THEN** it SHALL state a value

### Requirement: Windows cast a shadow, and the shadow follows the stated corners

The compositor SHALL draw a shadow around windows. The shadow SHALL follow the corner radius the configuration states rather than the window's bounding rectangle.

The compositor has no way to learn the corner radius of a window that rounds its own corners; absent a stated radius it must assume the window is square, and the shadow it draws then cuts across the inside of every rounded corner. There is a setting that hides those artifacts by drawing the shadow behind the window instead of around it, and it is the wrong fix here: stating the radius removes the cause, and the setting exists for the case where the radius cannot be known.

The two settings therefore depend on each other and SHALL be read together. Turning the shadow on while the radius is unstated produces artifacts; removing the radius later, with the shadow still on, reintroduces them.

#### Scenario: A window has a shadow

- **WHEN** a window is displayed above the surface behind it
- **THEN** a shadow SHALL be drawn around it

#### Scenario: The shadow respects the corner

- **WHEN** a window with rounded corners casts a shadow
- **THEN** the shadow SHALL follow the rounded corner
- **AND** no shadow SHALL be drawn inside the window's rounded corner

#### Scenario: The dependency is recorded

- **WHEN** the compositor configuration is read around the shadow settings
- **THEN** it SHALL record that the shadow's correctness depends on the stated corner radius
