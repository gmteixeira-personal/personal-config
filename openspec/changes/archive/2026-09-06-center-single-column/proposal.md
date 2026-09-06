## Why

A workspace holding one window puts it against the left edge of the output, with the rest of the screen empty to its right. That is a consequence of the scrolling layout's rule that columns start at the left and grow rightwards, not a decision anyone made about where a lone window should sit: with nothing to scroll to, the left edge is an arbitrary place to pin the only thing on screen, and it drags the eye off-centre for the common case of reading or typing in a single window.

## What Changes

- The compositor centres the single column on a workspace that has exactly one column, instead of aligning it to the left edge.
- The setting is stated in the layout block of the compositor configuration, alongside the gaps and the column widths it interacts with, and records why it is set and how it relates to `center-focused-column`.
- No change to behaviour once a second column exists: the workspace scrolls as it does today.

## Capabilities

### New Capabilities
- `window-placement`: where the compositor places tiled columns on a workspace, as distinct from what it draws around them — starting with the position of a lone column and its relationship to the focus-centring rule.

### Modified Capabilities
<!-- None. `window-appearance` covers decoration and spacing, not placement. -->

## Impact

- `.config/niri/config.kdl`, `layout` block — one added setting plus its comment.
- Interacts with the existing `center-focused-column "never"` and `default-column-width { proportion 0.5; }` settings in the same block; neither changes value.
- Takes effect on config reload; no restart of the compositor or of any client is required.
