## Why

herdr's prefix is `ctrl+f`, a left-hand chord that collides with the left hand's reach for most prefixed actions and, in a vi-mode shell, sits next to keys that are used constantly. `ctrl+space` was previously taken by the Flow Launcher global hotkey on the Windows host; that hotkey has been moved to `shift+space`, so `ctrl+space` is now free and is the better prefix — it is a two-hand chord reachable with either thumb, and no other binding in this configuration wants it.

## What Changes

- Rebind herdr's prefix from `ctrl+f` to `ctrl+space` in the tracked `.config/herdr/config.toml`.
- Release `ctrl+f` back to programs running inside a pane, which will now receive it instead of herdr swallowing it.
- **BREAKING** for muscle memory only: every existing prefixed action (`\` zoom, `e`/`=` equalize, `+` auto-equalize toggle, `shift+1..9` focus agent, and the built-in keys) keeps its second key but is now reached through `ctrl+space`.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `herdr-config`: the requirement fixing the prefix key changes from `ctrl+f` to `ctrl+space`, including what the configuration file must declare and which key must no longer take the prefix.

## Impact

- `.config/herdr/config.toml` — the `prefix` key in `[keys]`; every `[[keys.command]]` block is expressed as `prefix+…` and needs no edit.
- Nothing else in the repository binds `ctrl+f` or `ctrl+space`: `.inputrc` does not bind `C-@`, and no shell alias or script depends on either key.
- The terminal must deliver `ctrl+space` to herdr as NUL (`\0`); a terminal that swallows it or sends nothing would leave the session with no prefix, so the change is verified in the live terminal before the old binding is considered retired.
