## 1. Add the binding

- [x] 1.1 In `.config/herdr/config.toml`, append a `[[keys.command]]` block next to the existing `prefix+backslash` zoom block, with `key = "prefix+f"`, `type = "shell"`, `command = '"$HERDR_BIN_PATH" pane zoom --pane "$HERDR_ACTIVE_PANE_ID" --toggle'`, and `description = "toggle pane zoom"`, verifying with `grep -n -B2 -A5 'prefix+f' .config/herdr/config.toml` that the block reads as intended and that the `prefix = "ctrl+space"` line and the `prefix+backslash` block are untouched
- [x] 1.2 Run `herdr config check` and verify it reports no error and does not warn that the binding is invalid, disabled, or in conflict with a shipped action; if it reports a conflict on `f`, stop and report rather than shadowing the built-in
- [x] 1.3 Run `herdr server reload-config` and verify it succeeds, then confirm with `herdr status server` that the running server is up and the session survived

## 2. Verify the behaviour

- [x] 2.1 In a tab with at least two panes, press `ctrl+space` then `f` and verify the focused pane fills the tab and the other panes are hidden
- [x] 2.2 Press `ctrl+space` then `f` again and verify the tab returns to its previous pane sizes with focus still on the same pane
- [x] 2.3 Press `ctrl+space` then `z`, and separately `ctrl+space` then `\`, and verify both still toggle zoom exactly as before
- [x] 2.4 Zoom with `ctrl+space` `f`, then press `ctrl+space` `z`; repeat with `f` then `\`, and with each pair swapped, verifying every time that the pane unzooms rather than stacking a second zoom
- [x] 2.5 With a single-pane tab, press `ctrl+space` then `f` and verify nothing breaks and no error toast appears
- [x] 2.6 Verify `f` outside a prefix sequence still types the letter `f` into the focused pane

## 3. Land it

- [x] 3.1 Verify `git status --porcelain` lists `.config/herdr/config.toml` as the only modified path outside `openspec/`, confirming no machine-local herdr state leaked into the tracked set
- [x] 3.2 Run `openspec validate add-herdr-zoom-f --strict` and verify it passes
