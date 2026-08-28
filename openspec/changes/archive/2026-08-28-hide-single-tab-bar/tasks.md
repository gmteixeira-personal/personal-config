## 1. Configuration

- [x] 1.1 Add `hide_tab_bar_when_single_tab = true` to the `[ui]` section of `.config/herdr/config.toml`, with a comment noting the row returns on a second tab, and verify `herdr config check` reports no diagnostics
- [x] 1.2 Run `herdr server reload-config` and verify it applies with no diagnostics and every open pane keeps its running process

## 2. Verify the behaviour

- [x] 2.1 In a workspace holding one tab, verify no tab row is drawn and the pane area gained the line it occupied
- [x] 2.2 Create a second tab from the keyboard and verify the row appears listing both tabs and the new tab takes focus
- [x] 2.3 Switch between the two tabs with the prefix and a bare digit and verify each becomes active as before
- [x] 2.4 Close back down to one tab and verify the row stops being drawn and the survivor keeps its panes and their processes

## 3. Land it

- [x] 3.1 Run `openspec validate --strict hide-single-tab-bar` and verify it reports no errors
- [x] 3.2 Commit `.config/herdr/config.toml` with the change artifacts and verify `git status` offers nothing else from `.config/herdr/`
