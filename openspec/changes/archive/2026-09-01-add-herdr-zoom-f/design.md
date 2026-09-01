## Context

See proposal.md — Why. herdr 0.8.2 declares its built-in actions in a `[keys]` table, one key per action, with `zoom = "prefix+z"` as the shipped default. A second key for a built-in action therefore cannot be a second `[keys]` entry; the `prefix+\` alias already in `.config/herdr/config.toml:77-81` solves that with a `[[keys.command]]` shell binding that calls `"$HERDR_BIN_PATH" pane zoom --pane "$HERDR_ACTIVE_PANE_ID" --toggle`. This change adds a third key by the same route. The prefix is now `ctrl+space`, and `f` is unbound in the tracked configuration.

## Goals / Non-Goals

**Goals:**

- One more zoom key, `prefix+f`, behaving identically to the two that exist.
- Reuse the established alias mechanism rather than introducing a second pattern for the same problem.

**Non-Goals:**

- Consolidating the three zoom keys, or retiring `prefix+\` now that a home-row key exists.
- A zoom state of our own — herdr owns that, and the alias only calls herdr's operation.
- Any change to the prefix, to `[keys]` built-ins, or to the equalize bindings that share the file.

## Decisions

**Copy the `prefix+\` block rather than invent anything.** The command line, the `type = "shell"`, and the environment variables are already proven in this exact config; only `key` differs. A divergent formulation for an identical action would be a maintenance trap the next time herdr's CLI surface moves.

*Alternatives considered.* Rebinding `zoom = "prefix+f"` in `[keys]` gives a native, marginally faster binding, but costs `prefix+z`, which the proposal keeps. Dropping the `\` alias and making `f` its replacement was not asked for; the request is additive.

**Place the new block adjacent to the `prefix+\` block.** Grouping both zoom aliases under one comment keeps the file readable and makes the "three keys, one action" relationship visible at the point of edit rather than only in the spec.

**Verify `f` is free with `herdr config check` after the edit, not by reading herdr's defaults.** herdr's shipped defaults are not enumerated in any tracked file here, and the binary's key table is not readable in a way worth trusting. `config check` is the authoritative answer and is already a task step.

## Risks / Trade-offs

- [`prefix+f` collides with a herdr 0.8.2 built-in, silently displacing it] → `herdr config check` runs immediately after the edit; if it reports a conflict or a disabled binding, stop and report rather than shadowing an action.
- [Three keys for one action is more surface to keep working across herdr upgrades] → All three converge on the same herdr operation, so an upgrade breaks all or none; the failure mode is uniform, not per-key.
- [Shell-backed bindings round-trip through the socket API and are slower than the built-in key] → Accepted, as with `prefix+\`; imperceptible at human speed, and `prefix+z` stays the direct path.

## Migration Plan

Edit `.config/herdr/config.toml`, run `herdr config check`, then `herdr server reload-config`. Open sessions survive the reload. Rollback is deleting the block and reloading again.
