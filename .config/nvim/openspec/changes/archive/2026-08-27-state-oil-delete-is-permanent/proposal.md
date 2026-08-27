## Why

Deleting an entry from the file explorer removes it outright: oil's `delete_to_trash` is off, so there is no trash can to fish the file back out of. The explorer's own confirmation prompt is the only thing between the keystroke and the file being gone.

`file-explorer` does not say so. It requires that destructive operations are confirmed, which reads as though the confirmation is a formality over a recoverable action, and leaves how recoverable a deletion is to be worked out from oil's defaults. The setting has just been written down in `lua/plugins/oil.lua` for the same reason; the requirement it implements should be written down too.

## What Changes

- Add a requirement to `file-explorer` that a deletion is permanent, so the confirmation prompt is understood as the only safeguard rather than one of several.

No behaviour changes. `delete_to_trash` was already `false` -- oil's own default -- and is now stated outright in `lua/plugins/oil.lua` rather than inherited.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `file-explorer`: gains a requirement that deleting an entry removes it from disk rather than moving it to a trash, and that this is what makes the existing confirmation the last check.

## Impact

- `openspec/specs/file-explorer/spec.md` -- gains a requirement once this change is archived.
- `lua/plugins/oil.lua` -- `delete_to_trash = false` already stated; no further change.
- No change to the confirmation behaviour, which is oil's default and already required.
