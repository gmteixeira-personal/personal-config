## Why

Moving between workspaces takes a detour today. The only keyboard route is `prefix+w`, which opens the workspace navigation surface and then wants arrow keys and a confirmation, or the mouse. herdr has single-step actions for this, `next_workspace` and `previous_workspace`, but ships both unbound, so stepping to the neighbouring workspace — the move made most often — has no key of its own.

## What Changes

- Bind `next_workspace` to `prefix+u`, stepping down the sidebar's workspace list to the next workspace.
- Bind `previous_workspace` to `prefix+i`, stepping up the list to the previous workspace.
- Declare both in `[keys]` in the tracked `.config/herdr/config.toml`, so they reach every machine rather than being set per install.
- Neither chord displaces anything: herdr ships nothing on `prefix+u` or `prefix+i`, and the tracked configuration binds neither.
- `prefix+w` keeps opening the workspace navigation surface, and no tab, pane, creation, or closing key moves.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `herdr-config`: adds requirements that `prefix+u` steps to the next workspace and `prefix+i` to the previous one, that the other workspace and tab keys keep what they have, and that both bindings survive a restore and a reload.

## Impact

- `.config/herdr/config.toml` — two new keys in the existing `[keys]` table, next to the workspace creation key.
- Applied to a running server with `herdr server reload-config`; no restart and no session loss.
- No change to `.gitignore` or `README.md`: the file is already tracked, and two key values need no setup on a fresh machine.
