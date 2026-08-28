## Why

A workspace holding one tab still draws the tab row, so a row of screen is spent
telling us what the single pane already says. Most workspaces here run one tab,
so the cost is paid almost all of the time and buys nothing.

herdr already ships the setting that removes it — `ui.hide_tab_bar_when_single_tab`
— but it defaults to `false`, so it has to be declared in the tracked
configuration file to reach every machine.

## What Changes

- Set `ui.hide_tab_bar_when_single_tab = true` in `.config/herdr/config.toml`, so
  a workspace with exactly one tab draws no tab row and the space goes to the
  pane. A second tab brings the row back.
- No keybinding changes. Tabs are still created, renamed, and switched by the
  same keys, whether or not the row is drawn.
- No change to the tab row's position, its right-edge status entries, the prefix
  key, the theme, or any other herdr preference.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `herdr-config`: adds a requirement that the tab row is hidden while a workspace
  holds a single tab, and that tab actions keep working while it is hidden.

## Impact

- `.config/herdr/config.toml` — one new key in the existing `[ui]` section.
- Requires herdr 0.8.2 or later, which is the installed version.
- Applies to a running server through `herdr server reload-config`; no restart
  and no session loss.
- No change to `.gitignore` or `README.md`: the file is already tracked, and a
  single UI preference needs no setup on a fresh machine.
