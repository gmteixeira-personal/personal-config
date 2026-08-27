## 1. Add the binding

- [x] 1.1 In `.config/herdr/config.toml`, append a `[[keys.command]]` block with `key = "prefix+backslash"`, `type = "shell"`, and `command = '"$HERDR_BIN_PATH" pane zoom --pane "$HERDR_ACTIVE_PANE_ID" --toggle'`, verifying with `grep -n -A3 'keys.command' .config/herdr/config.toml` that the block reads as intended and that the existing `prefix = "ctrl+f"` line is untouched
- [x] 1.2 Run `herdr config check` and verify it reports no error and does not warn that the keybinding is invalid or disabled; if it rejects `backslash`, fall back to the escaped literal `"prefix+\\"` and re-run the check
- [x] 1.3 Run `herdr server reload-config` and verify it succeeds, then confirm with `herdr status server` that the running server is still up and the session survived

## 2. Verify the behaviour

- [x] 2.1 In a tab with at least two panes, press `ctrl+f` then `\` and verify the focused pane fills the tab and the other panes are hidden
- [x] 2.2 Press `ctrl+f` then `\` again and verify the tab returns to its previous pane sizes with focus still on the same pane
- [x] 2.3 Press `ctrl+f` then `z` and verify the built-in key still toggles zoom exactly as before
- [x] 2.4 Zoom with `ctrl+f` `z`, then press `ctrl+f` `\`, and verify the pane unzooms rather than stacking a second zoom — and repeat with the two keys swapped
- [x] 2.5 With a single-pane tab, press `ctrl+f` then `\` and verify nothing breaks and no error toast appears

## 3. Land it

- [x] 3.1 Verify `git status --porcelain` lists `.config/herdr/config.toml` as the only modified path outside `openspec/`, confirming no machine-local herdr state leaked into the tracked set
- [x] 3.2 Run `openspec validate add-herdr-zoom-backslash --strict` and verify it passes
