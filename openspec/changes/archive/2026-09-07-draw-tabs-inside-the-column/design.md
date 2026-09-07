## Context

See proposal.md — Why.

The layout block of `.config/niri/config.kdl` has no `tab-indicator` section, so every part of the strip is at the compositor's default. On niri 26.04 those are `position "left"`, `width 4`, `gap 5`, `length total-proportion=0.5`, `gaps-between-tabs 0`, `corner-radius 0`, no colours, and placement outside the column. The strip therefore occupies 9 logical pixels to the left of the column against a `gaps 2` that gives it 2, which is the whole of the fault.

Two settings in the same block decide what the strip looks like without naming it. `border { off }` and `focus-ring { ... }` mean the compositor resolves the strip's unset colours against the focus ring rather than the border: the active tab takes `active-color "#89b4facc"` and every other tab takes `inactive-color "#505050"`. The window rule setting `geometry-corner-radius 12` and `clip-to-geometry true` decides the shape the strip is drawn beside.

`niri validate` accepts `place-within-column` on the installed version.

## Goals / Non-Goals

**Goals:**
- Fix the placement with the compositor's own setting for it, so nothing in this repository has to know where a column sits.
- Add one setting and leave every other part of the strip inherited, so that the block records a decision rather than a restatement of the defaults.
- Correct the one existing comment this change falsifies.

**Non-Goals:**
- Tuning the strip's thickness, gap, length, corner radius or position. Each is a separate judgement, and none of them is what makes the tabs invisible.
- Deciding the focus ring's inactive colour. The change makes it visible; choosing its replacement is a decision about a value that can then be looked at, which is the opposite of the position this repository takes on values chosen sight unseen.
- Changing when a column becomes tabbed. `Mod+W` and the default column display stay as they are.

## Decisions

**Use `place-within-column` rather than widening `gaps` to fit the strip.**
A gap of 9 or more would leave the strip somewhere to be drawn, and it would still be drawn in space between two columns rather than in the column that owns it — so the strip would still vanish at the edge of the output, which is the reported fault. It would also set the seam between every pair of tiled windows in the session from the needs of a mode most columns are not in, against a requirement that ties that seam to the focus marker's width. Rejected on both counts.

**Rather than a negative `gap`.**
`gap` accepts negative values, which draws the strip on top of the window. That keeps the strip inside the column's outer bounds and costs the window no width, so it looks like a cheaper fix. It is not the same fix: the strip is then painted over the client's own content, which is a worse trade for a session that already asks clients to omit their decorations so that nothing is drawn over a window that the window did not draw. Rejected.

**Rather than moving the strip to `position "top"`.**
A strip along the top of the column would be inside the output at the left edge, so it would answer the reported symptom. It answers it by accident — the strip would still be outside the column and would still overlay the column above in a stacked layout, and it changes where the user looks for tabs for a reason that has nothing to do with tabs. Rejected; `position` stays `left`, which is what the report describes and what the default already gives.

**Leave `width` and `gap` at the compositor's defaults, so the window loses 9 logical pixels while tabbed.**
The session's own vocabulary for lines is 2 pixels — `gaps 2` and the focus ring's `width 2` — so 4 on 5 is loud beside it, and tightening them is tempting in the same commit. It is a different question. The focus ring's width is argued from the marker being the entire seam between two windows; a tab strip is a list with one entry per window and has to stay legible as a list, which is an argument about how many tabs are distinguishable at a glance rather than about how wide a seam should be. Making both changes at once would also confound them: if the result reads badly there would be no way to tell which value did it. The 9 pixels are recorded here as the price and left to be re-opened once the strip has been used.

**Leave every colour unset.**
The compositor paints an unset strip from the focus ring, which this session already states as a palette entry with its opacity and composited value recorded. Setting `active-color` on the strip would copy `#89b4facc` into a second place in the same file, and the two would then have to be moved together by hand. Inheriting is what keeps one palette value answering "what has focus" in the ring, the bar and now the strip.

**Do not adopt `hide-when-single-tab`.**
It would stop a single-window tabbed column paying 9 pixels for a list of one, which is a real saving and is not this change: a column in tabbed mode showing that it is in tabbed mode is information, and removing it is a decision about what the mode should look like rather than about where the strip is drawn. Left for a separate change now that the strip is visible enough to judge.

**Put the block between `shadow` and `struts`.**
That is where the compositor's own documentation orders it within the layout block, so a reader following the upstream reference finds it in the expected place. It also puts it below `focus-ring`, which is the setting its colours come from and the one its comment has to point at.

**Correct the `inactive-color` comment in the same commit.**
The focus ring's `inactive-color "#505050"` carries a note saying that only a second monitor could render it and that nobody has looked at it. After this change every inactive tab renders it. Leaving the note would make the file state something false about a value on screen, which is worse than the value being off the palette.

## Risks / Trade-offs

- **A tabbed column's window is 9 logical pixels narrower than an untabbed one** → Inherent, and the point: the strip has to be somewhere and inside the column is where it can be seen. The width returns when the column leaves tabbed mode, and `width` and `gap` are the dials if 9 proves too many.
- **`#505050` is now on screen, and it is off the palette and unjudged** → Recorded rather than fixed, and the comment that denies it is corrected so the next reader finds the question rather than a contradiction. It is a grey against a dark background, so the failure mode is dull rather than wrong.
- **Square tabs beside a 12-pixel rounded window** → `corner-radius` is 0 by default and the window rule rounds windows to 12. At 4 pixels wide the strip is close to a line and the mismatch may not read at all; if it does, `corner-radius` is one line in the block this change creates.
- **The strip is drawn where the focus ring is also drawn** → Both are keyed to the same colour, so a focused tabbed column shows the ring and the active tab in one value. If that reads as one shape rather than two, the answer is a colour or a length on the strip, not a different placement.

## Migration Plan

Add the block, correct the `inactive-color` comment, run `niri validate`, and reload the config — niri reloads on write, and neither the compositor nor any client needs restarting. Check a tabbed column at the left edge of the output and a tabbed column with a neighbour to its left.

Rollback is deleting the block and restoring the comment; there is no state to unwind.
