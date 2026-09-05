## ADDED Requirements

### Requirement: The surface behind windows has a declared colour

The compositor SHALL be configured with the colour it draws where no window is present, rather than relying on its built-in default.

Every other part of this capability decides what the compositor draws around windows; the colour behind them was the one part left to whatever the compositor shipped. That was invisible while nothing depended on it. It stops being invisible once a transparent bar is read against it, because an undeclared colour is one that can change under a compositor update and take the bar's legibility with it. Declaring it also means the value is stated in the same file as the gaps and the borders, where a reader looking for what the session draws will already be.

#### Scenario: The colour is stated in the configuration

- **WHEN** the compositor configuration is inspected
- **THEN** it SHALL declare the colour drawn behind windows

#### Scenario: An empty workspace shows the declared colour

- **WHEN** a workspace with no windows is displayed
- **THEN** the colour shown SHALL be the one the configuration declares
