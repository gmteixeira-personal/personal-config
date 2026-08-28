## Why

herdr's two creation keys are in the wrong places for the way this setup is
used. A new tab is `prefix+c`, which reads as "create" and says nothing about
what is created, while a new workspace is `prefix+shift+n`, a two-modifier chord
for the thing reached most often. The letter that names a tab, `t`, is unbound.

Putting the tab on `prefix+t` and the workspace on `prefix+c` makes each key name
its own object, and drops the workspace from a chord to a single letter.

## What Changes

- Bind `new_tab` to `prefix+t`, freeing `prefix+c` from its shipped default.
- Bind `new_workspace` to `prefix+c`, its shipped `prefix+shift+n` becoming
  unbound. Nothing else claims that chord afterwards, and it is left free rather
  than filled.
- Declare both in `[keys]` in the tracked `.config/herdr/config.toml`, so they
  reach every machine rather than being set per install.
- `next_tab` keeps `prefix+n`. Binding a second key to new-workspace was
  considered and dropped: `[keys]` holds one key per action, so the second key
  would have to be a `[[keys.command]]` block shelling out to
  `herdr workspace create --focus`, and it would have cost `next_tab` its key for
  a duplicate of a binding this change already makes a single letter.
- No change to any `[[keys.command]]` block, to the prefix, or to any other
  binding or preference.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `herdr-config`: adds requirements that `prefix+t` creates a tab and `prefix+c`
  creates a workspace, and that the tab and workspace actions this change does
  not name keep the keys they have.

## Impact

- `.config/herdr/config.toml` — two new keys in the existing `[keys]` table.
- Muscle memory: `prefix+c` creates a workspace rather than a tab, so the old
  reflex now produces the larger object. That is the change being asked for.
- `prefix+shift+n` stops creating a workspace and does nothing until something is
  bound to it.
- Applies to a running server through `herdr server reload-config`; no restart
  and no session loss.
- No change to `.gitignore` or `README.md`: the file is already tracked, and two
  key values need no setup on a fresh machine.
