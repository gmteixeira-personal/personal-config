## Context

See proposal.md — Why. The constraints that shape the approach:

- `.config/niri/config.kdl` reloads in place. niri watches the file and applies a valid edit immediately; an invalid one is rejected and the running configuration stays live. Nothing here is negotiated with clients at connection time, so unlike the `prefer-no-csd` request in the same block, no restart of niri or of any client is involved.
- The `focus-ring` block is on and the `border` block is `off`. The ring therefore is the whole focus indication: only the focused window draws one, and `width 2` with `gaps 2` makes it exactly fill the gap belonging to that window. Its colour is the seam between two tiled windows.
- The surface it is drawn against is declared in the same block: `background-color "#181825"`, Catppuccin Mocha mantle.
- `focus-ring inactive-color` is visible only on a monitor that is not the active one. One output is attached, so it is not visible at all today.
- The session restates one palette by hand in `.config/niri/config.kdl` (KDL), `.config/foot/foot.ini` (INI, no leading `#`), `.config/swaylock/config` (key/value), `.config/waybar/style.css` (CSS) and `.config/fuzzel/fuzzel.ini` (INI, with an alpha suffix). No two of those formats can share a definition, so a hand copy plus a comment naming the palette is the established mechanism.
- `.config/waybar/style.css` already answers the same question for a different surface: the focused workspace is `#89b4fa`, with a comment saying the colour exists because naming the focused thing is what that module is for.
- The change that set `width 2` listed this colour as an explicit non-goal — "niri's own blue and no requirement here decides it… the obvious next thing to bring into the palette and it is not this change". This is that change.

Measurements below are relative luminance and WCAG contrast ratio against `#181825`.

## Goals / Non-Goals

**Goals:**

- A focus marker that is quieter against the declared background than niri's default, without stopping being the thing that names the focused window.
- The last inherited value in the appearance block brought into the palette, so it can be checked against the other four files.
- A comment in the form the rest of that block already uses: the entry named, the palette named, and the reason it is not the default.

**Non-Goals:**

- `inactive-color`. It is `#505050` in both blocks, it is off-palette, and with one output nothing can see it. Bringing it in is a real follow-up and it needs a second monitor to judge; guessing at it here would state a value nobody has looked at.
- The `border` block. It is `off`, and its `active-color`, `inactive-color` and `urgent-color` are the defaults that came with the disabled block. Touching them would imply the block is a live decision.
- The ring's width, and therefore `gaps`. Both were decided together and are stated in terms of each other. The complaint is about intensity, not about how much of the screen the marker occupies.
- A darker colour of the ring's own, mixed or borrowed from another palette. Opacity is the mechanism here; see the decisions below.
- A shared palette definition across the five files. Five formats, no common loader — the comment convention is the mechanism, and this change follows it.

## Decisions

**Use Catppuccin Mocha blue `#89b4fa`, not a hand-darkened blue.**

Two things had to be true of the replacement: dimmer against `#181825`, and checkable — an entry of the palette the other four files restate, so that its origin can be recorded the way every other stated value in this block records one.

`#89b4fa` is both. Relative luminance falls from 0.5304 to 0.4486, a 15% drop, and contrast against the mantle from 9.7:1 to 8.3:1. Hue moves from 205.8 to 217.2 degrees — off cyan and onto blue proper — and HSV saturation from 50% to 45%. The result reads as a step down in loudness rather than as a different indicator, which is what "a little too bright" asks for.

It also makes one colour mean one thing across two surfaces. The bar already uses `#89b4fa` for the focused workspace, for the stated reason that the module exists to say which one has focus. The ring says the same about a window. After this change the answer to "what has focus here" is the same blue in the bar and around the window, which is a property worth more than the arithmetic.

Alternatives considered:

- *Mocha sapphire `#74c7ec`* — the palette entry closest to niri's default, and the obvious first guess. It is brighter than the target by the measure that matters: luminance 0.5062, contrast 9.3:1, barely below the default it replaces. It would be a hue change dressed as a dimming.
- *Mocha sky `#89dceb`* — 0.6250 and 11.3:1, brighter than the default. Wrong direction.
- *Mocha lavender `#b4befe`* — 0.5369, marginally brighter than the default, and it collides with the mauve the bar already uses.
- *Mocha overlay2 `#9399b2`* — the honest "much dimmer" answer at 0.3220 and 6.2:1, a 39% luminance drop. It is a grey. The only other thing drawn in the gap is the shadow, which is also grey, and the marker would then be distinguished from it by lightness alone. The spec forbids this for that reason.
- *A hand-mixed darker blue* — free choice of exactly how dim, and no palette to record it against. That is the cost the other four files pay a comment to avoid; re-paying it for the fifth is the opposite of the point.

**Carry the entry at `cc` rather than solid, and rather than as a third colour.**

The solid entry went in first and was looked at. It reads as a step down that stops short: 8.3:1 against the mantle is still a bright line, and the complaint it was meant to answer survived it. So the change needed a second, larger step, and there were two ways to take one.

A darker colour of the ring's own is the obvious one and it is the wrong one here. Mocha has no blue below `#89b4fa` — the entries below it in luminance are greys — so a darker blue would have to be mixed, and a mixed value belongs to no palette and cannot have its origin recorded. That is the cost the session's other four restatements pay a comment to avoid.

An alpha suffix takes the step without paying it. niri accepts `#rrggbbaa` and draws the ring over the declared background, so lowering alpha walks the rendered colour towards `#181825` along a straight line, and the stated value is still the palette entry plus a number. `cc` composites to `#7295cf` — luminance 0.2958, 5.8:1 — another 34% off the solid value, and measured on screen as `#7193cc`, the two-count difference being the shadow the ring is drawn over at the window edge.

The cost is real and is worth naming: the file no longer states the colour that lands on screen, so checking the ring against the other four palette copies means compositing by hand. The comment carries the composited value for exactly that reason, which turns a hidden step into a written one.

`cc` and not another suffix because it is the first step that answers the complaint. `e6` (7.0:1) and `dd` (6.6:1) are inside the range the solid entry already failed in. `aa` (`#6380b3`, 4.4:1) is the far end and starts trading away the marker's job. The suffix is a dial and the comment says which way to turn it.

Alternatives considered:

- *Stay solid at `#89b4fa`* — the value that is what it says it is, with nothing to composite by hand. It was shipped, looked at, and did not go far enough.
- *A hand-mixed darker blue* — free choice of exactly how dim, and no palette to record it against. See above.
- *Mocha overlay2 `#9399b2`* — the palette's honest "much dimmer" answer at 6.2:1, and a grey. Rejected on the same ground as before: the shadow is already the grey thing in the gap.

**Reuse the block's comment form rather than inventing one.**

Every other stated value in this block carries a comment saying what the value is and why it is not the default — the width says it, the gap says it and names the width, the background names its palette entry, the shadow names its dependency on the radius. The colour gets the same: the entry, the palette, the file where the session's copy of that palette otherwise lives, and the fact that it replaces niri's own blue because the background here is declared and dark.

The comment also carries the one thing the value cannot: that `inactive-color` immediately below it is still niri's default and still off-palette. Leaving that unmarked would let the next reader assume both lines were decided.

## Risks / Trade-offs

- *The dimming still misses.* The complaint is subjective and no measurement substitutes for looking at it — this is already the second step, the first having been shipped and found short → the suffix is two hex digits, niri reloads on save, and the comment names both directions with their composited values and contrasts.
- *The ring stops reading as focus.* It is the only focus indication this session has, and it has now been quietened twice → 5.8:1 against the background still clears the 4.5:1 threshold used for text, which is a harder target than a solid line, and the hue is retained precisely so the marker is not competing with the shadow on lightness alone.
- *The file no longer states what lands on screen.* A reader comparing the ring against the other four palette copies has to composite `cc` over the mantle by hand → the comment carries `#7295cf` and the measured `#7193cc`, so the arithmetic is done once and written down rather than repeated.
- *One blue now means "focused" in two places.* If either the bar or the compositor changes its mind later, the coincidence becomes a trap: the two files cannot see each other → the comment in each names the palette entry rather than the other file, which is the same mechanism the palette's other restatements rely on.
- *A sixth surface to keep in step if the palette changes.* Unavoidable given five formats and no shared loader; the mitigation is the comment convention this change follows.
- *`inactive-color` is now visibly inconsistent.* The block will hold one palette colour and one default, one line apart → that is an accurate description of the state, the comment says so, and inventing a value for a line no attached output can render would be worse.
- *Rollback.* Restore `#7fc8ff` and the previous comment, or drop the suffix for the solid entry. niri applies either on save. Nothing else reads the value and there is no state to migrate.

## Migration Plan

1. Edit the `focus-ring` block in `.config/niri/config.kdl`: `active-color` and its comment.
2. `niri validate -c .config/niri/config.kdl` to confirm the file parses.
3. Save. niri reloads in place; an invalid file would have been rejected with the running configuration left alone.
4. Tile two windows and confirm the seam on the focused one is a dimmer blue line and still tells the two windows apart at a glance.
5. Confirm the ring reads against the bar's focused workspace as the same colour, which is the check that the palette entry was copied correctly rather than approximated.

Rollback is step 1 in reverse with the same validate and save.
