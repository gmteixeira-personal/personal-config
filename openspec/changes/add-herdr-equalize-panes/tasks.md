## 1. Review and install

- [ ] 1.1 Read the plugin's manifest and its Perl source on GitHub before installing, and confirm it only calls the herdr socket API and touches no path outside herdr's own directories
- [ ] 1.2 Install with `herdr plugin install shibayu36/herdr-equalize-panes` and verify `herdr plugin list` shows it as installed and enabled
- [ ] 1.3 Inspect `.config/herdr/.plugins.lock` and verify it records the plugin with no absolute paths or install timestamps that would churn between machines — if it is not portable, stop and revisit the tracking decision in design.md

## 2. Track the declaration

- [ ] 2.1 Add `!/.config/herdr/.plugins.lock` to `.gitignore` beside the existing `!/.config/herdr/config.toml` entry, and verify `git check-ignore -v .config/herdr/.plugins.lock` reports it as no longer ignored
- [ ] 2.2 Verify `git status` still offers nothing else from `.config/herdr/` — the sockets, the logs, and `session.json` stay ignored

## 3. Bind the manual action

- [ ] 3.1 Add the `[[keys.command]]` block binding `prefix+E` to `shibayu36.equalize-panes.equalize` in `.config/herdr/config.toml`, and verify the file still parses by running `herdr server reload-config` without error
- [ ] 3.2 Verify `herdr plugin action` lists the equalize action under the installed plugin's id, confirming the bound command name matches

## 4. Verify the behaviour

- [ ] 4.1 Split a full-tab pane vertically twice and verify with `herdr pane layout` that the three panes each hold roughly one third of the width, not 1/2, 1/4, 1/4
- [ ] 4.2 Close one of the three panes and verify the two survivors each hold roughly one half
- [ ] 4.3 Resize a pane by hand, verify the size sticks with no split or close, then press `prefix+E` and verify the panes return to equal shares
- [ ] 4.4 Verify the panes kept their order and their running processes across every step above

## 5. Land it

- [ ] 5.1 Run `openspec validate --strict add-herdr-equalize-panes` and verify it reports no errors
- [ ] 5.2 Commit `.gitignore`, `.config/herdr/config.toml`, and `.config/herdr/.plugins.lock` together, and verify `git ls-files` lists the plugin lock
