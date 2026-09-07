## 1. The theme file

- [x] 1.1 Create `~/.config/yazi/theme.toml` setting `[mode] normal_main` with a white foreground over the retained blue background, `[mode] normal_alt` with the palette's `surface0` behind the retained blue foreground, and `[status] progress_label` with a white foreground — verify the file parses by starting the file manager and seeing no configuration error
- [x] 1.2 Record in the file that yazi's shipped theme names palette slots, that `.config/foot/foot.ini` leaves those slots at the terminal's defaults, and that this is why the values here are 24-bit — verify a reader can tell why the file exists without the change history
- [x] 1.3 Record beside each chosen colour the contrast ratio it produces and the ratio it replaces, and mark the badge value as below the 4.5:1 threshold — verify each recorded ratio matches a measurement rather than an estimate
- [x] 1.4 Record that `bg = "blue"` on the mode badge is a retained slot name rather than a chosen value, and that the row under the cursor was considered and left alone because the program offers no key for it and it already measures 7.08:1 — verify both notes are present

## 2. Tracking

- [x] 2.1 Allow `.config/yazi/theme.toml` through `.gitignore`, whose policy is deny-by-default, with a comment naming what the file is and why it exists — verify `git check-ignore` no longer matches the path
- [x] 2.2 Verify `flavors/` and `package.toml` remain ignored, since nothing this change writes references them

## 3. Verification

- [x] 3.1 Restart the file manager and verify the mode badge and the position badge are drawn in white rather than the terminal's grey
- [x] 3.2 Verify the two pale chips are drawn on a dark background rather than the terminal's near-white slot
- [x] 3.3 Verify the row under the cursor is unchanged from before the change
