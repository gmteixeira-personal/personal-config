## Context

See proposal.md — Why. The mechanical facts the approach turns on:

- yazi's embedded dark theme ships `[tabs] active = { bg = "blue", bold = true }` and `[tabs] inactive = { fg = "blue", bg = "gray" }`. Those are the same two values `[mode]`'s `normal_main` and `normal_alt` shipped with, so the tab bar and the status bar started matched and the earlier legibility change separated them.
- `blue` and `gray` are foot's palette slots, left at foot's defaults on the reasoning recorded in `.config/foot/foot.ini`: `#24acd4` and `#e6e6e6`. An unset foreground falls through to foot's `foreground=aaaaaa`.
- `.config/yazi/theme.toml` is an override file with no `[flavor]` line. The Catppuccin Mocha flavor under `flavors/` is installed but not selected, so every key not stated here is yazi's shipped value, not Mocha's.
- yazi reads the theme once per process, at startup.

## Goals / Non-Goals

**Goals:**

- One foreground value on the blue background, used by every element that has that background.
- Every contrast ratio in the file at or above 4.5:1, so the file no longer carries a value marked as knowingly short.

**Non-Goals:**

- Selecting the Catppuccin Mocha flavor. Two literals are borrowed from that palette, as three values in this file already do; selecting it would repaint the whole window and is a different change.
- Repainting foot's palette slots. Already measured and ruled out in the file's header comment: with a foreground unset the text stays `#aaaaaa` whatever the slot becomes.
- Touching the file list, the row under the cursor, or the separator glyphs.

## Decisions

**Dark text rather than white on the blue background.** `#11111b` over `#24acd4` is 7.08:1; `#ffffff` over it is 2.65:1. The alternative was white, and white is what the file had — recorded as deliberately below the 4.5:1 threshold, with `#11111b` named in the same comment as the value to use if white read thin. It read thin. Taking the dark value now, rather than copying white into two more elements, is the difference between the file having one below-threshold value and having three.

**The status bar moves with the tab bar, not after it.** The tab bar could have been given dark text while `normal_main` and `progress_label` kept white. That satisfies legibility and fails the thing actually asked for: the top would then not match the bottom, in the one respect a user can see at a glance. The three elements share a background, so they share a foreground; the spec states that consequence rather than leaving it as a coincidence in the file.

**The tab values are restated, not derived.** TOML has no reference, so `[tabs] active` repeats `[mode] normal_main`'s three settings literally. The alternative — selecting a flavor and letting one palette feed both — is the non-goal above. The duplication is load-bearing and therefore commented as such at both ends: the comment says the values are the status bar's, and that changing the shared foreground changes all three.

**`bg = "blue"` stays a slot name in the new section.** The capability requires a 24-bit literal for a colour this configuration *chooses*, and permits a slot name for one it *keeps*, provided the file says that is why. The blue is kept: it is the colour on screen, the change is not about it, and naming a literal would mean picking a blue nobody decided on. This is the same call already made and recorded for `[mode]`.

**`sep_inner` and `sep_outer` are left shipped.** yazi draws the rounded caps from the adjoining tab styles, so they follow the two values above without being named. Stating them would add two more places to keep in step for no change in what is rendered.

## Risks / Trade-offs

- **The shared foreground is now three elements deep.** → Stated in the spec as an accepted consequence and recorded in the file at both ends, so the next edit to that colour is made knowing what it moves. There is no supported way to change one of the three alone.
- **`#11111b` and `#313244` are Mocha literals in a file that does not select Mocha.** → Already true of `normal_alt` before this change. If Mocha is ever selected, these keys become redundant rather than wrong.
- **A future yazi could change its shipped tab keys, or the meaning of `reversed`.** → This file now states both tab styles in full, so a shipped-default change cannot alter what is rendered. The risk moves to the key names themselves, and a renamed key in yazi is a startup error rather than a silent revert.
- **Running windows keep the old colours.** → Restart them. Same property as every other yazi configuration change and already recorded in the capability for `init.lua`.

## Migration Plan

Edit the one file and restart open yazi windows. Rollback is `git checkout .config/yazi/theme.toml`; nothing else reads these values and no state is written.
