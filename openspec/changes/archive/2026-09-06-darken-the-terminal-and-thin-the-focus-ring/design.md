## Context

See proposal.md — Why. The constraints that shape the approach:

- `.config/foot/foot.ini` already has a `[colors-dark]` section carrying a single key. Adding a background is one more key in a section that exists, not a new section — and the `terminal-colors` spec forbids writing the counterpart `[colors-light]` section, so there is no second place to put it.
- foot reads this file once, when `foot --server` starts. An edit is invisible until `systemctl --user restart foot-server.service`. This is already stated at the top of the file and required by `terminal-emulator`.
- The session's palette is Catppuccin Mocha, restated by hand in `.config/niri/config.kdl` (KDL), `.config/swaylock/config` (key/value), `.config/waybar/style.css` (CSS) and `.config/fuzzel/fuzzel.ini` (INI). None of those formats can share a definition with `foot.ini`, so a fifth restatement is the only mechanism available.
- foot writes hex without a leading `#` and without an alpha suffix. The palette's values appear as `#181825` in niri's KDL, `11111b` and `1e1e2e` in swaylock's key/value form, `1e1e2eff` in fuzzel's INI and `#cdd6f4` in waybar's CSS. One palette, four spellings; the comment is what makes that legible.
- `.config/niri/config.kdl` reloads in place. niri watches the file and applies a valid edit immediately; an invalid one is rejected and the previous configuration stays live. So the compositor half of this change needs no restart and cannot leave the session unusable, which is the opposite of the terminal half in both respects.
- The focus ring draws only around the focused window. The `border` block is a second, always-visible indicator and is `off`. `prefer-no-csd` is set, so niri draws the ring *around* windows rather than as a rectangle behind them.

## Goals / Non-Goals

**Goals:**

- A terminal background that is near-black — a little above `000000`, with a small amount of blue in it — and that belongs to the palette every other surface here uses.
- A comment that survives the next reader: the palette named, its home file named, and no claim that the background is deliberately foot's own.
- No regression in legibility for text that carries no colour of its own.
- A focus marker that says which window has input without occupying the seam between two windows as a surface.
- A gap and a focus marker stated in terms of each other, so that neither can be changed alone without the file saying it is wrong.

**Non-Goals:**

- Re-theming the terminal. The sixteen palette slots stay unwritten and the foreground stays `aaaaaa`; this change moves one value.
- Reconciling programs that paint their own colours inside the window. herdr's `[theme] name = "gruvbox"` and Neovim's colorschemes are each their own decision and are out of scope.
- Introducing a shared palette definition. Five formats, no common loader; the comment convention is the mechanism and this change follows it rather than replacing it.
- Transparency. `alpha` stays unset. The bar can afford transparency because it pays for it with a text shadow; a terminal has nothing equivalent to spend.
- The focus ring's colour. `active-color "#7fc8ff"` is niri's own blue and no requirement here decides it. It is the obvious next thing to bring into the palette and it is not this change.
- Enabling the `border` block. It is a second indicator for a session that needs one, and turning it on would put the question of which indicator wins back on the table.

## Decisions

**Use Catppuccin Mocha crust `11111b`, not base, mantle, or a hand-mixed near-black.**

Catppuccin assigns its three darkest greys by depth: crust is what everything sits on, mantle is the layer above it, base is an application's own surface. Read by depth alone a terminal window is an application surface, and base is the entry that points at. Base was carried here first for exactly that reason, and it is not dark enough: at 0.0140 relative luminance it is a step down from `002b36` but still a tinted grey, and near-black was what was asked for.

Crust is that. Red and green sit at 17 and blue at 27, so it is a little above black carrying ten points of blue — the colour requested, and independently the palette's own darkest value. Relative luminance is 0.0060: 70% below `002b36`, 57% below base.

Depth is a convention in the palette, not a constraint on this session. Nothing composites these surfaces together — the lock screen replaces the desktop, a terminal covers both — so two of them holding one value costs nothing at any moment somebody is looking at either. What staying inside the palette buys is that the value remains checkable against the other four files, and crust buys that exactly as well as base does.

Alternatives considered:

- *Base `1e1e2e`* — the depth-correct entry, and what this change carried until the terminal was seen against the rest of the session. It reads as a tinted grey rather than a near-black, which is the thing being moved away from.
- *Mantle `181825`* — between the two, and the colour niri paints the desktop. A window whose background equals its backdrop stops reading as a window; niri's own borders would be the only thing separating them. Crust is not exposed to that, because the surface it matches is the lock screen, which is never on screen at the same time as a terminal.
- *A hand-mixed near-black* — `0d0d14`, or `000000` warmed with a little blue. A value belonging to no palette cannot have its origin recorded, so the fifth surface would stay unverifiable against the other four. That is the cost this change exists to remove, not one to re-pay.

**Halve the focus ring to `width 2` rather than pick a width from scratch.**

The spec's existing reasoning fixed the ring at niri's default of 4 because at zero gaps it "is no longer competing with a gap for attention". That compares the ring against something that is not there. What the width actually decides is the size of the seam: only the focused window draws a ring, so 4 logical pixels is 4 pixels of blue laid along the boundary of two windows the layout has just been told to make meet. It reads as a band with a colour of its own, which is the thing zero gaps was meant to remove.

2 is half of the value already in the file, which is why it is the value: it is the smallest change that answers the complaint, and it keeps the ring above the 1-pixel width at which a marker starts depending on the display's scale to be visible at all.

Alternatives considered:

- *`width 1`* — the narrowest a ring can be and still exist. On a scaled output it is the width most likely to disappear or alias into the window edge, and the marker is the only focus indication this session has.
- *`width 0` with the `border` block on instead* — swaps one indicator for another and re-opens which of the two the session uses. Nothing asked for that.
- *Leave 4 and rely on the colour* — the complaint is about how much of the screen the marker occupies, not which colour it is. Changing the colour would be answering a different question.

**Set `gaps` to the ring's width rather than to zero.**

Zero was tried first, as the value `window-appearance` already required. It is wrong for the same reason 4 was: it decides the gap without reference to the marker that lives in it. niri draws the ring outward from the focused window into the gap, so at `gaps 0` the ring has no space of its own; at `gaps 8` it sits inside a band of desktop six pixels wider than itself. Only at an equal value does the ring fill exactly the gap belonging to the window it marks, which makes the seam between two windows one constant size — the ring's colour beside the focused window, the declared background elsewhere.

That also settles the fractional-scale question neither value settles alone. This output is 1536x960 logical at scale 1.25, so 2 logical pixels is 2.5 physical and rounds to 3 — a column loses 2.4 logical pixels per edge, not 2, which is measurable in `niri msg windows`: the tile goes from 768.0 wide at `gaps 0` to 764.0 at `gaps 2`. Neither the gap nor the ring lands on a whole physical pixel on its own. Set equal, they round the same way and stay aligned at any scale.

The consequence is that the two values are no longer independent, and the spec and the file both have to say so. That is the cost of the decision and it is worth paying: two numbers that decide one seam were previously stated in unrelated terms, which is why one of them could be reverted by `9c5fe8d` without anything noticing.

Alternatives considered:

- *`gaps 0`* — the value the spec required. Costs no screen area, and gives the only focus indication this session has nowhere to be drawn.
- *`gaps 8`, the value `9c5fe8d` left* — a band of desktop wide enough to read as space, with a 2-pixel ring floating inside it. This is what the ring's width was hard to judge against.

**Leave `foreground=aaaaaa` alone.**

The foreground has its own recorded reason — it matches VGA colour 7, the Linux virtual console's default, so plain text lands at the intensity a TTY gives it. That reason says nothing about what is behind the text, so the change does not touch it. Contrast improves as a side effect: 6.5:1 against `002b36`, 8.1:1 against `11111b`, clearing the 7:1 WCAG AAA threshold rather than approaching it from the wrong side. Moving to Mocha's text `cdd6f4` was considered and rejected: it would discard a documented decision to buy palette tidiness the spec does not ask for, and it is not what was requested.

**Put the value in `[colors-dark]`, next to the foreground.**

Both are the same kind of setting — the colour used when no colour is selected — and the spec already requires exactly one colour section, the one `initial-color-theme` selects. Adding a key there needs no structural change and no second section to keep in step.

**Rewrite the existing comment rather than appending to it.**

The sentence "The background is left at foot's own on purpose -- only the foreground was too bright" becomes false the moment the key is added. Appending a correction below it leaves both readings on the page and makes the reader adjudicate. The sentence is replaced by one that names the value, its palette, and the file where this repository's copy of that palette lives — which is the form `.config/waybar/style.css` and `.config/fuzzel/fuzzel.ini` already use.

## Risks / Trade-offs

- *The edit looks like it did nothing.* foot's server reads the file once; opening another `footclient` shows the old colour, which reads as a broken change rather than an unapplied one → the restart is an explicit task step, and the file already carries the rule at the top.
- *Programs that assume a Solarized background.* Anything that picked its own colours to sit on `002b36` will sit on `11111b` instead. Nothing in this configuration does: `terminal-colors` requires every colour it chooses to be a 24-bit value it names, and those values were chosen for legibility rather than for that specific ground. Third-party colorschemes with a transparent background — Neovim's among them — will now show `11111b` through, which is the intended result.
- *A fifth hand-copy of the palette.* One more file to keep in step if the palette ever changes → unavoidable given five formats and no shared loader; the mitigation is the same one the other four use, a comment naming the palette and its home file, which this change adds rather than skips.
- *The focus marker becomes too quiet.* 2 logical pixels of ring is the whole indication of which window takes input, and on a scaled output it is thinner still → it is double the narrowest width that renders, the colour is unchanged, and the value is one number to raise if it turns out not to read.
- *The gap and the ring drift apart.* Nothing enforces that the two values stay equal; a later edit to one leaves the other wrong and niri validates either way → the requirement states the dependency, and the comment above each value names the other, which is the same mechanism the palette's five restatements rely on.
- *Rollback.* Delete the `background` line and restore the previous comment sentence, then restart the foot server; put `gaps 8` and `width 4` back, which niri applies on save. There is no state to migrate and nothing else reads any of the four values.

## Migration Plan

1. Edit `.config/foot/foot.ini`.
2. `foot --check-config` to confirm the file still parses and reports no deprecated setting.
3. Start a standalone `foot` — not a client — and query it for its own colours with OSC 11 and OSC 10. A standalone reads the tracked file fresh, so its answer is what the restarted server will read, and this can be done from inside a window the restart would close.
4. `systemctl --user restart foot-server.service`, from outside the foot windows it will close.
5. Open a new `footclient` and confirm the background changed and no notice precedes the first prompt.

The compositor half is separate and simpler:

1. Edit `.config/niri/config.kdl`.
2. `niri validate -c .config/niri/config.kdl` to confirm it parses.
3. Save. niri reloads the file in place — no restart, and an invalid file would have been rejected with the previous configuration left running.
4. Tile two windows and confirm they meet, and that the marker on the focused one is a line rather than a band.

Restarting the server closes every terminal window open at the time: each `footclient` is attached to the server process being replaced, and they go with it. Nothing running in those windows survives, so the restart is done from outside them — a TTY, or after the work in them is saved — rather than from a shell that the restart will take down with it. The alternative is to leave the server alone and let the new value arrive at the next login, which costs nothing but time.
