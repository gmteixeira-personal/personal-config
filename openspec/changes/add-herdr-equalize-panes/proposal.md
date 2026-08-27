## Why

herdr redistributes only the area of the pane being split, so splitting a column twice leaves widths of `1/2, 1/4, 1/4` instead of three equal columns, and closing a pane hands all of its space to a single neighbour. Every session therefore drifts into lopsided panes that have to be nudged back by hand with `herdr pane resize`, and herdr ships no equivalent of tmux's `select-layout -E` to correct them in one step.

The published plugins that fill that gap all weight a divider by the number of *panes* on each side of it. A column holding three stacked panes then gets three times the width of its neighbours — the layout is "equal" only when every column holds exactly one pane. What is wanted instead is equal-width columns first, and equal-height rows inside each column, with a stacked column still counting as one column.

Automatic equalizing is also not always wanted: a deliberately wide editor beside a narrow log is a layout worth keeping, and equalizing on every split would destroy it. The automatic behaviour therefore has to be something that can be switched off from the keyboard and switched back on again.

## What Changes

- Add `.config/herdr/equalize-slots/`, a local herdr plugin tracked in this repository. It divides every split evenly among the slots that split separates, counted along that split's own axis, with a cross-axis subtree counting as one slot. It hooks pane creation, close, move, and exit, and exposes an `equalize` action.
- Add a tracked toggle script at `.config/herdr/herdr-equalize-toggle` that flips the plugin between `mode = "auto"` and `mode = "keybind"` and reports the mode it landed in as a herdr notification. Neither direction resizes anything by itself.
- Bind `prefix+plus` to the toggle script, and both `prefix+e` and `prefix+=` to the plugin's `equalize` action, so a tab can be evened out once without turning the automatic behaviour back on.
- Change `ui.toast.delivery` from `terminal` to `herdr`. The `terminal` setting asks the outer terminal for a desktop notification, which under WSL reaches nothing, so the toggle's report was invisible.
- Record the plugin in `README.md` with the one `herdr plugin link` command a fresh machine needs, following the precedent already set for Claude Code plugins. Nothing herdr writes for a plugin is portable enough to track: `.plugins.lock` is an empty lock file, and `plugins.json` carries absolute paths and an install timestamp.
- Ignore `.config/herdr/plugins/` and `.config/herdr/plugins.json` explicitly in `.gitignore` block 4 — herdr's per-machine plugin registry, config, and any managed checkout, which carries its own `.git` and would otherwise be offered as an embedded repository.
- No change to the prefix key, the theme, or any other herdr preference.

## Capabilities

### New Capabilities
- `herdr-pane-layout`: how the panes of a herdr tab are sized relative to one another as panes are split and closed, whether that sizing happens on its own, and how both the automatic behaviour and a one-shot equalize are driven from the keyboard.

### Modified Capabilities
- `herdr-config`: the requirement that everything in herdr's configuration directory other than `config.toml` remain ignored is narrowed — the toggle script and the local plugin beside it become tracked, while the sockets, the logs, the session record, and herdr's plugin registry stay ignored.

## Impact

- `.config/herdr/equalize-slots/` — new tracked plugin: `herdr-plugin.toml` and `equalize.py`.
- `.config/herdr/herdr-equalize-toggle` — new tracked executable.
- `.config/herdr/config.toml` — three new `[[keys.command]]` blocks, and `ui.toast.delivery` changed to `herdr`. That setting is global, so agent notifications now appear in herdr's own frame too.
- `.gitignore` — two block 3 allowlist entries, and one block 4 pair.
- `README.md` — a section on the plugin and its keys, plus a row in the "deliberately not tracked" table.
- Depends on Python 3 and on herdr 0.8.0 or later, for `layout.export` and `layout.set_split_ratio`; the installed versions are 3.14 and 0.8.2.
- The selected mode lives in the plugin's own config directory and stays untracked: it is a per-machine runtime choice, not a preference to carry between machines.
- No third-party plugin is installed. `shanefully-done/herdr-pane-equalizer` was installed while this change was being built and has been uninstalled.
