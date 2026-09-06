## 1. Compositor configuration

- [x] 1.1 Add `always-center-single-column` to the `layout` block of `.config/niri/config.kdl`, next to `center-focused-column`, and verify `niri validate` reports the config as valid
- [x] 1.2 Write the comment above the setting recording why the session sets it rather than accepting the left-aligned default, that it applies only to a workspace holding one column, and that `center-focused-column "never"` directly above is a separate decision this change leaves alone — verify by reading the block back and checking a reader can tell the two settings apart

## 2. Verification

- [x] 2.1 Reload the config and verify a workspace holding one window shows that window centred horizontally on the output
- [x] 2.2 Open a second window on that workspace and verify the layout returns to its ordinary left-to-right placement, then close it and verify the remaining window recentres
- [x] 2.3 Verify a single column holding two stacked windows is still centred, and that focus movement between columns on a multi-column workspace behaves as it did before the change
