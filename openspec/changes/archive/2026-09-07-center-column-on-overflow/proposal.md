## Why

Moving focus to a column that is off-screen scrolls the workspace by the least amount that brings that column into view, so the column arrives pinned against the left or right edge of the output. The column that has just been focused is the one being read or typed into, and it is placed where a column is hardest to read: hard against a bezel, with the whole of the workspace's empty or occupied space piled on one side of it.

The compositor offers three answers to this and the session has so far taken the default, `never`, without weighing the other two. `always` recentres the view on every focus change, including changes between two columns that are already both on screen and both perfectly readable — motion with nothing to show for it. `on-overflow` centres only in the case that produces the problem: when the newly focused column cannot be shown alongside the one focused before it, so the view has to move anyway. That is the setting this change takes.

## What Changes

- The compositor centres a newly focused column when it does not fit on the output together with the previously focused column, instead of leaving it against the edge the scroll arrived at.
- Focus changes between columns that already fit together on screen do not move the view, exactly as before.
- The comment recorded beside the existing single-column centring is corrected. It presently states that the focus-centring setting stays at `never` and that the single-column rule does not alter it, which stops being true with this change; the two settings remain independent decisions and that is what the comment should say.

## Capabilities

### New Capabilities
<!-- None. Where the compositor places a column on focus is what `window-placement` already covers. -->

### Modified Capabilities
- `window-placement`: adds the requirement that focusing a column which does not fit beside the previously focused one centres it, and replaces the existing requirement that records the single-column rule as independent of focus centring — that one drew the independence from the focus setting's current value, which this change alters, so its replacement draws it from the cases the two settings decide instead.

## Impact

- `.config/niri/config.kdl`, `layout` block — one changed value, `center-focused-column`, from `"never"` to `"on-overflow"`, plus the comment above it and the tail of the `always-center-single-column` comment that refers to it.
- Interacts with `always-center-single-column` in the same block, which keeps its value and its behaviour: a workspace holding one column has no previously focused column to overflow against, so the two rules never decide the same case.
- No keybinding changes. `Mod+C` (`center-column`) still centres the focused column on demand, and remains the way to centre a column that this setting leaves where it is.
- Takes effect on config reload; no restart of the compositor or of any client is required.
