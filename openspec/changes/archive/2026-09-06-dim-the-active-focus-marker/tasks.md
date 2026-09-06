## 1. Change the focus ring's colour

- [x] 1.1 In the `focus-ring` block of `.config/niri/config.kdl`, set `active-color "#89b4fa"`, replacing niri's default `#7fc8ff`; verify by grepping the block and seeing the new value and no other colour changed.
- [x] 1.2 Replace the comment above `active-color` — currently "Color of the ring on the active monitor." — with one naming the palette entry (Catppuccin Mocha blue), the palette, and why it is not niri's default: the background behind windows is declared and dark, so the default is brighter than the job needs. Verify the comment answers both "which entry" and "why not the default", as the `width`, `gaps` and `background-color` comments in the same file already do.
- [x] 1.3 Extend the existing note under `inactive-color` to record that it is still niri's default and off-palette, and that with one output attached nothing renders it; verify a reader of the block can tell which of the two colours was decided.

## 2. Validate and apply

- [x] 2.1 Run `niri validate -c .config/niri/config.kdl` and verify it reports no error.
- [x] 2.2 Save the file and verify niri reloaded it — the ring changes colour with no restart of the compositor or of any client.

## 3. Confirm the result

- [x] 3.1 Tile two windows and verify the seam on the focused one is a visibly dimmer blue than before, and still names the focused window at a glance.
- [x] 3.2 Verify the ring is the same blue as the bar's focused workspace, which confirms the palette entry was copied rather than approximated.
- [x] 3.3 Verify the marker is still a colour and not a grey against the shadow drawn around every window; if the ring now reads as too quiet, revert to `#7fc8ff` rather than picking a third value outside the palette.

## 4. Record the change

- [x] 4.1 Commit `.config/niri/config.kdl` with a `feat(niri):` message; verify `git status` shows no other tracked file modified by this change.
