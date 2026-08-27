## Why

herdr redistributes only the area of the pane being split, so splitting a column twice leaves widths of `1/2, 1/4, 1/4` instead of three equal columns, and closing a pane hands all of its space to a single neighbour. Every session therefore drifts into lopsided panes that have to be nudged back by hand with `herdr pane resize`, and herdr ships no equivalent of tmux's `select-layout -E` to correct them in one step.

## What Changes

- Install the `shibayu36/herdr-equalize-panes` plugin, which re-equalizes every pane in a tab automatically on each split and each pane close.
- Bind its `shibayu36.equalize-panes.equalize` action to `prefix+E` in the tracked `.config/herdr/config.toml`, so an on-demand re-equalize is available after manual resizing without waiting for the next split or close.
- Track `.config/herdr/.plugins.lock` so the installed plugin set travels with this repository, mirroring how `.config/nvim/lazy-lock.json` is tracked for Neovim. This reverses the current requirement that the plugin lock stay ignored.
- No change to the prefix key, the theme, or any other herdr preference.

## Capabilities

### New Capabilities
- `herdr-pane-layout`: how the panes of a herdr tab are sized relative to one another as panes are split and closed, and how a re-equalize is requested on demand.

### Modified Capabilities
- `herdr-config`: the requirement that everything in herdr's configuration directory other than `config.toml` remain ignored is narrowed — the plugin lock becomes tracked, while the sockets, the logs, and the session record stay ignored.

## Impact

- `.config/herdr/config.toml` — one new `[[keys.command]]` block for the equalize action.
- `.config/herdr/.plugins.lock` — becomes a tracked file; `.gitignore` gains an allowlist entry for it next to the existing `config.toml` entry.
- New dependency on the third-party plugin `shibayu36/herdr-equalize-panes` (MIT) and on `/usr/bin/perl`, which the plugin shells out to and which is already present.
- Requires herdr 0.7.2 or later; the installed version is 0.8.2.
- The plugin install tree itself stays untracked and is re-derived by `herdr plugin install` on a new machine.
- Behavioural side effect to accept: a manual `herdr pane resize` holds only until the next split or close in that tab, at which point the tab is re-equalized.
