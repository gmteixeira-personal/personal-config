## Purpose

Defines how much space the session leaves between tiled windows and which decorations they carry, splitting what the compositor decides from what each client decides, so that the parts of a window's appearance that cannot be set from one place are at least written down in one.

## ADDED Requirements

### Requirement: Tiled windows meet without a gap

The compositor SHALL place adjacent tiled windows with no gap between them.

A gap is a floating-desktop affordance: it separates windows whose edges would otherwise be ambiguous because they overlap arbitrarily. In a tiling layout the edges are decided by the layout and are never ambiguous, so the gap costs screen area and returns nothing.

#### Scenario: Two tiled windows are adjacent

- **WHEN** two windows are tiled side by side
- **THEN** no space SHALL be left between them

### Requirement: A focus indicator survives the removal of gaps and borders

Where gaps are zero and window borders are off, the session SHALL still mark which window has focus, and that marker SHALL be the only thing consuming space between windows.

Removing gaps, borders and the focus ring together leaves adjacent windows visually continuous with nothing to say which one receives input. The focus ring is kept at the compositor's default rather than narrowed, because at zero gaps it is no longer competing with a gap for attention — it is the whole indication.

#### Scenario: The focused window is identifiable

- **WHEN** several windows are tiled with gaps at zero and borders off
- **THEN** the focused window SHALL be visually distinguishable from the others

### Requirement: Clients are asked to omit their own decorations

The compositor SHALL ask clients to omit client-side decorations, and a client this configuration tracks settings for SHALL be configured to prefer no decoration.

Both halves are needed and neither is binding. The compositor's request is a hint a client may refuse, and a client's preference is a hint the compositor may override. Setting only one leaves the outcome to whichever default happens to win.

#### Scenario: The compositor makes the request

- **WHEN** the compositor configuration is inspected
- **THEN** it SHALL ask clients to omit client-side decorations

#### Scenario: A tracked client states its preference

- **WHEN** the configuration of a client this repository tracks settings for is inspected
- **THEN** it SHALL state a preference for no decoration

#### Scenario: A client that refuses

- **WHEN** a client draws its own decorations regardless of the request
- **THEN** that SHALL be understood as the client's decision
- **AND** the configuration SHALL NOT be treated as broken on account of it

### Requirement: The decoration setting's restart dependency is recorded

Documentation SHALL record that the decoration request reaches clients through a Wayland global the compositor offers when it starts, and therefore that both the compositor and any client holding a long-lived connection must be restarted before a change takes effect.

Nothing reports this. The configuration reloads and validates, the option is plainly present, and decorations keep being drawn — the only evidence is a line in the client's log saying no decoration manager is available. A terminal run as a server is the sharpest case: it holds one connection for every window it opens, so windows opened long after the change still inherit the connection's original view.

#### Scenario: A reader learns why the setting appears inert

- **WHEN** the documentation for the decoration setting is read
- **THEN** it SHALL state that the compositor must be restarted for the change to reach clients
- **AND** it SHALL state that a client holding a long-lived connection must also be restarted

#### Scenario: The failure is silent

- **WHEN** the decoration setting is changed and nothing is restarted
- **THEN** the configuration SHALL still validate
- **AND** decorations SHALL continue to be drawn with no error reported by the compositor
