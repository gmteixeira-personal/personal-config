## Context

See proposal.md — Why. The layout block of `.config/niri/config.kdl` already sets `gaps`, `background-color`, `center-focused-column "never"`, `always-center-single-column`, the preset column widths and `default-column-width { proportion 0.5; }`. The default width matters to how often the new rule fires: at half the output width two adjacent columns fit together exactly, so focus moving between neighbours does not overflow and does not move the view, while any column at a wider preset does overflow against its neighbour and is centred.

`center-focused-column` is the compositor's own setting for this decision and takes one of three values, so the change is one value plus the comments around it. `niri validate` accepts `"on-overflow"` on the installed version (niri 26.04).

## Goals / Non-Goals

**Goals:**
- Centre a newly focused column in the case where the view has to move anyway, using the compositor's own rule so nothing in the session has to track column positions.
- Leave the configuration saying why `"on-overflow"` was chosen over both `"never"` and `"always"`, since the value's name does not carry that on its own.
- Correct the comment on `always-center-single-column`, which currently asserts a value for `center-focused-column` that this change does not keep.

**Non-Goals:**
- Changing column widths. Which columns overflow against each other follows from the widths already set, and this change does not tune that.
- Changing `always-center-single-column`, whose value and behaviour stay as they are.
- Any keybinding change. `Mod+C` (`center-column`) stays as the way to centre a column the rule leaves alone.

## Decisions

**Take `"on-overflow"` rather than `"always"`.**
Both centre the focused column in the case the proposal describes. They differ on focus changes between columns that already share the output: `"always"` recentres the view for those too, so a workspace of narrow columns slides under the cursor on every focus change, and the column that was perfectly readable before the change moves in order to end up equally readable somewhere else. `"on-overflow"` restricts the centring to focus changes where the view has to scroll regardless, so it never adds motion — it only decides where motion that was already happening stops. Rejected `"always"` on that ground.

**Take `"on-overflow"` rather than keeping `"never"`.**
`"never"` is the value the session has held by default rather than by decision. It stops the scroll at the first position that brings the column into view, which is always an edge of the output. That position is not chosen for the column's sake; it is what falling out of the scroll arithmetic produces. Since the scroll happens either way, the edge costs the same motion as the centre and reads worse.

**Rewrite the tail of the `always-center-single-column` comment rather than delete it.**
That comment presently distinguishes the two settings by asserting that the focus rule "stays at `never`", which this change falsifies. The distinction it draws is still correct and still worth recording — the two settings decide different cases and are set independently — so the fix is to ground the distinction in the cases themselves rather than in a value that can change: a lone column has no previously focused column to overflow against, so no value of `center-focused-column` can decide its position.

## Risks / Trade-offs

- **The view moves further on some focus changes than it did before** → Only on focus changes that already scrolled the workspace. The compositor animates the scroll with the same animation it used before, so the change is in where it stops, not in whether something moves.
- **Which focus changes centre is not obvious from the setting alone** → It follows from column widths, which the same block already sets. `Mod+C` centres on demand for the cases the rule leaves alone.
- **A shared reading of "centre" across two adjacent settings** → Addressed by the comments; this is the same hazard the previous change to this block recorded, and the reason its comment needed correcting here.

## Migration Plan

Change the value, reload the config (niri reloads on write; no restart of the compositor or of any client is needed), and move focus onto an off-screen column. Rollback is restoring `"never"` and the reload that follows.
