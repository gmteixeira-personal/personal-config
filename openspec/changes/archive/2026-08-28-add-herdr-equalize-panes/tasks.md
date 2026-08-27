## 1. Establish what the published plugins do

- [x] 1.1 Measure the candidates against a tab whose middle column holds stacked panes, and verify whether any equalizes by column rather than by pane — `shanefully-done/herdr-pane-equalizer` gave `61 | 183 | 61`, and its `equalize-width` action gave byte-identical widths
- [x] 1.2 Check the remaining candidates for the column rule and for event hooks — `ponko2` documents the same pane-count formula, `markhuot` has the column rule but declares no events, `jeph` rebuilds the tab into a grid and moves panes
- [x] 1.3 Uninstall the third-party plugin installed while investigating and verify `herdr plugin list` reports it gone

## 2. The plugin

- [x] 2.1 Write `.config/herdr/equalize-slots/herdr-plugin.toml` declaring the `equalize` action and hooks on `pane.created`, `pane.closed`, `pane.moved`, and `pane.exited`, and verify `herdr plugin link` accepts it and reports the plugin enabled
- [x] 2.2 Write `.config/herdr/equalize-slots/equalize.py`: divide each split among the slots it separates along its own axis, a cross-axis subtree counting as one slot, and apply the result with `layout.set_split_ratio`
- [x] 2.3 Read the mode from `config.toml` in the plugin's config directory on every invocation, defaulting to `auto`, so `--event` does nothing while the mode is `keybind` and `--action` always works
- [x] 2.4 Settle before measuring: poll `layout.export` until two consecutive reads agree on the tab's shape, so an event that arrives before herdr commits the change does not read a stale tree
- [x] 2.5 Resolve the event's tab from its payload, falling back to every tab in the named workspace when a close no longer names one, and verify an unchanged tab plans no moves

## 3. The toggle script

- [x] 3.1 Write `.config/herdr/herdr-equalize-toggle`: resolve the herdr binary from `HERDR_BIN_PATH`, read the mode defaulting to `auto`, write the opposite through a temp file plus `mv`, and report it with `herdr notification show` — without resizing anything, in either direction
- [x] 3.2 `chmod +x` and verify two runs flip the mode there and back
- [x] 3.3 Retry the notification while herdr answers `shown: false` — it shows one toast at a time, so the second of two quick presses was dropped; verify a back-to-back pair now reports both, the second landing after a few attempts

## 4. Configuration

- [x] 4.1 Bind `prefix+plus` to the toggle script with `type = "shell"`, and `prefix+e` and `prefix+=` to `local.equalize-slots.equalize` with `type = "plugin_action"`; verify `herdr config check` is clean — it rejects `prefix++`, so the toggle uses `prefix+plus`
- [x] 4.2 Set `ui.toast.delivery` to `herdr` so the toggle's report is drawn in-app, and verify `herdr notification show` answers `shown: true` instead of handing the toast to a terminal that ignores it
- [x] 4.3 Run `herdr server reload-config` and verify it applies with no diagnostics and open panes survive

## 5. Track it

- [x] 5.1 Add `!/.config/herdr/equalize-slots/**` and `!/.config/herdr/herdr-equalize-toggle` to block 3 of `.gitignore` and verify `git status` offers all three files
- [x] 5.2 Add `.config/herdr/plugins/` and `.config/herdr/plugins.json` to block 4 and verify `git status` offers neither herdr's registry nor a managed checkout, which carries its own `.git`
- [x] 5.3 Document the plugin in `README.md`: the rule it applies, the `herdr plugin link` command a fresh machine needs, what the three keys do, and that the mode is per-machine; add a row to the "deliberately not tracked" table
- [x] 5.4 Verify `git status` offers nothing else from `.config/herdr/` — sockets, logs, `session.json`, the plugin lock, and the per-plugin config directory stay ignored

## 6. Verify the behaviour

- [x] 6.1 With auto on, split a pane of a three-column tab downward twice and verify the columns hold their widths while the column's rows even out — measured `102 | 101 (27+27, then 18+18+18) | 102`
- [x] 6.2 Close one of the stacked rows and verify the survivors re-even and the columns are untouched — measured `102 | 101 (27+27) | 102`
- [x] 6.3 Split a side pane to the right and verify four equal columns, the stacked column still counting as one — measured `77 | 76 | 76 | 76`
- [x] 6.4 Close that pane and verify three equal columns return — measured `102 | 101 | 102`
- [x] 6.5 Toggle auto off, split a pane, and verify only the split pane's space is divided and nothing else moves — measured `51 | 51 | 101 | 101 | 102`
- [x] 6.6 Invoke the equalize action in that state and verify it evens the tab and leaves the mode at `keybind` — measured `77 | 76 | 76 | 76`
- [x] 6.7 Toggle auto back on with a lopsided tab and verify it reports the mode, resizes nothing, and fires no plugin run
- [x] 6.8 Verify panes kept their order and their running processes across every step above

## 7. Land it

- [x] 7.1 Run `openspec validate --strict add-herdr-equalize-panes` and verify it reports no errors
- [x] 7.2 Commit `.gitignore`, `README.md`, `.config/herdr/config.toml`, `.config/herdr/herdr-equalize-toggle`, and `.config/herdr/equalize-slots/` together, and verify `git ls-files` lists the plugin and the toggle script, the toggle keeping its executable bit
