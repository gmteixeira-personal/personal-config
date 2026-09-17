## 1. Colour the tab bar

- [x] 1.1 Add a `[tabs]` section to `.config/yazi/theme.toml` setting `active = { fg = "#11111b", bg = "blue", bold = true }` and `inactive = { fg = "blue", bg = "#313244" }`, and verify both keys state a foreground and a background
- [x] 1.2 Verify the two values are `[mode]`'s `normal_main` and `normal_alt` restated key for key, so the active tab matches the mode badge and the inactive tab matches the pale chip
- [x] 1.3 Verify `sep_inner` and `sep_outer` are absent from the section, so yazi keeps deriving the rounded caps from the two tab styles

## 2. Take the blue-backed foregrounds to the threshold

- [x] 2.1 Change `[mode] normal_main` from `fg = "#ffffff"` to `fg = "#11111b"`, and verify no `#ffffff` remains in the file
- [x] 2.2 Change `[status] progress_label` the same way, and verify it sits on the same blue as the mode badge and the active tab
- [x] 2.3 Verify every foreground-on-coloured-background pair in the file measures at least 4.5:1 — `#11111b` on `#24acd4` is 7.08:1 and `#24acd4` on `#313244` is 4.75:1 — so no value in the file needs the withdrawn below-threshold allowance

## 3. Record the reasoning in the file

- [x] 3.1 Rewrite the `[mode]` comment so it states 7.08:1 against the shipped 1.14:1 and records that white was measured first at 2.65:1 and rejected as below the threshold, and verify no comment still presents a value as knowingly short
- [x] 3.2 Update the `[status]` comment to state 1.14:1 before and 7.08:1 after, and verify it no longer names 2.65:1
- [x] 3.3 Write the `[tabs]` comment recording yazi's shipped `active = { bg = "blue", bold = true }` and `inactive = { fg = "blue", bg = "gray" }`, that they are the status bar's shipped values and the same two faults, that the new values are the status bar's restated, and that the shared foreground changes all three elements together
- [x] 3.4 Verify the `[tabs] active` comment says the `bg = "blue"` slot name is kept rather than chosen, on the same grounds already recorded for `[mode]`

## 4. Confirm the result in the running program

- [x] 4.1 Restart yazi and verify the active tab renders as dark text on blue and the inactive tab as blue text on the dark chip, both legible at a glance
- [x] 4.2 Verify the tab bar and the status bar read as one piece of chrome — the active tab and the `NOR` badge identical, the inactive tab and the size chip identical
- [x] 4.3 Verify the row under the cursor is unchanged and the file list's colours are untouched, so the legibility change stayed inside the chrome
- [x] 4.4 Verify `git status --porcelain` lists `.config/yazi/theme.toml` and no other file under `.config/yazi/`
