## Why

The status line renders the name set by `/rename` as a purple `[name]` block ahead of the badges, and the name is no longer worth the width it takes. Every character on that line competes with the prompt, and a name the user typed themselves is already known to them.

## What Changes

- Remove the purple session-name block from the status line's second row, so the row opens with the git-state badge.
- Stop reading the session registry under `~/.claude/sessions/` to resolve a user-set name, along with the `nameSource` check that distinguished a `/rename` name from a derived one.
- Record the removal as a spec requirement, so the field is not reintroduced as a labelled or unlabelled block later.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `claude-status-line`: add a requirement that the status line reports the session's location and state only, and does not show the session name set by `/rename`.

## Impact

- `~/.claude/statusline-command.sh`: the `session_name` helper in the embedded Python block, the `p_session`/`session` variables, the `sess` block, and its use in the rendered second line.
- No other consumer reads the session registry, so nothing else changes.
