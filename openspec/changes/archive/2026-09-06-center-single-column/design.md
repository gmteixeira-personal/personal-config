## Context

See proposal.md — Why. The layout block of `.config/niri/config.kdl` already sets `gaps`, `background-color`, `center-focused-column "never"`, the preset column widths and `default-column-width { proportion 0.5; }`. The last two matter here: a lone column opens at half the output width, so the difference between the current behaviour and the required one is half a screen of empty space moving from one side of the window to both sides of it.

The compositor offers a layout setting for exactly this case, so the change is one line plus its comment. `niri validate` accepts it on the installed version (niri 26.04).

## Goals / Non-Goals

**Goals:**
- Centre the lone column using the compositor's own rule for that case, so the behaviour survives windows opening and closing without anything tracking column counts.
- Leave the existing centring and width settings in the same block at their current values, and make the configuration say why they are not the same decision.

**Non-Goals:**
- Changing the width a window opens at. Centring and width are separate questions; a half-width column centred is the arrangement this change asks for.
- Changing how the workspace scrolls or where focus lands once a second column exists.
- Any keybinding change. `Mod+C` already centres the focused column on demand and stays as it is.

## Decisions

**Use the compositor's `always-center-single-column` setting rather than `center-focused-column "always"`.**
Both would centre a lone column. They differ everywhere else: `center-focused-column "always"` also recentres the view on every focus change once the workspace holds several columns, which turns a scrolling layout into a carousel and is a change nobody asked for. `always-center-single-column` is scoped to the one case in the requirement. Keeping `center-focused-column "never"` also means the two settings stay independent, which is what the spec asks the configuration to record.

**Leave `default-column-width { proportion 0.5; }` alone.**
An alternative reading of "centre the lone window" is "give it the whole screen", which `default-column-width` at a larger proportion would approximate. That answers a different question — how wide — and would change every column's width, not just a lone one's. Rejected.

**Write the comment against `center-focused-column`, which sits directly above it.**
The two settings are adjacent and both say "center". The comment's job is to say which case each covers, so the reader who finds one does not assume it subsumes the other.

## Risks / Trade-offs

- **A window jumps sideways when the second column opens or the last one closes** → Inherent to the requirement: the lone column's position differs from its position in a multi-column workspace, so a transition between the two moves it. The compositor animates the move with the same animation it uses for every other column movement, so it reads as the layout shifting rather than as a glitch.
- **The setting is a boolean with no value to tune** → If the centring turns out to be unwanted, the fix is deleting the line; there is no partial state to unwind.

## Migration Plan

Add the line, reload the config (niri reloads on write; no restart of the compositor or of any client is needed), and check a workspace holding one window. Rollback is deleting the line and the reload that follows.
