## Context

See proposal.md — Why. herdr 0.8.2 declares its built-in actions in a `[keys]` table, one key per action, with `zoom = "prefix+z"` as the shipped default. There is no list syntax there, so a second key for an existing action cannot be expressed as a second `[keys]` entry.

Custom bindings live in `[[keys.command]]` blocks, which take a `key` and a `command` and run with `type = "shell"` (detached), `"popup"` (session-modal terminal), or `"plugin_action"` (an installed plugin's action). A shell binding receives `HERDR_BIN_PATH` along with `HERDR_ACTIVE_WORKSPACE_ID`, `HERDR_ACTIVE_TAB_ID`, and `HERDR_ACTIVE_PANE_ID` in its environment. The CLI exposes the same operation the key performs: `herdr pane zoom [<pane_id>|--pane ID|--current] [--toggle|--on|--off]`.

`.config/herdr/config.toml` is tracked; the rest of that directory is ignored.

## Goals / Non-Goals

**Goals:**
- One extra key that is indistinguishable from `prefix+z` in effect.
- Declaration only, in the already-tracked configuration file.

**Non-Goals:**
- Retiring, moving, or re-keying `prefix+z`.
- A per-pane, per-tab, or persisted zoom state of our own — herdr owns that.
- Any general mechanism for aliasing built-in actions; this is one key.

## Decisions

**Route the second key through the CLI as a shell command.** `[keys]` cannot hold two keys for one action, so the alias must come from `[[keys.command]]`, and of the three types only `shell` can reach a built-in action. The command is `"$HERDR_BIN_PATH" pane zoom --pane "$HERDR_ACTIVE_PANE_ID" --toggle`.

*Alternatives considered.* Rebinding `zoom = "prefix+backslash"` gives a native binding at the cost of `prefix+z`, which the proposal keeps. Sending a synthetic `prefix+z` from a shell command would depend on key-injection timing and on `z` never being re-keyed later — strictly worse than calling the operation by name.

**Target the pane explicitly rather than with `--current`.** `--current` resolves against the server's idea of the focused pane at the moment the detached command connects, while `HERDR_ACTIVE_PANE_ID` is captured when the key is pressed. They agree in ordinary use and differ exactly when focus moves in the gap, so the explicit id is the one that matches what the user was looking at. Quote the expansion so an empty value fails the command rather than silently becoming `--pane` with the next argument.

**Pass `--toggle` explicitly.** The CLI's default with no flag is already a toggle, but naming it makes the binding say what the key does and keeps it correct if the default ever changes.

**Write the key as `prefix+backslash`.** herdr's key parser carries a `backslash` name; a literal `\` inside a TOML basic string would additionally need escaping as `\\`. The named form avoids both questions. `herdr config check` is in the task list to confirm the binding parses before it is relied on.

**Apply with `herdr server reload-config`.** Consistent with how the prefix binding was introduced; open sessions survive.

## Risks / Trade-offs

- **The shell round-trip makes the alias slower than the built-in key** → One local socket call, not perceptible at human speed. `prefix+z` stays bound as the direct path.
- **`herdr` is not on `PATH` when the key fires** → The command uses `HERDR_BIN_PATH`, which herdr sets for shell bindings, so it does not depend on `PATH` at all.
- **`backslash` is not the parser's name for the key** → `herdr config check` catches it during implementation; the fallbacks are the escaped literal `"prefix+\\"` or, failing that, another free key. Nothing else in the change depends on the spelling.
- **A conflict with `add-herdr-equalize-panes`, which also adds `[[keys.command]]` blocks** → Different keys and different actions, so the two only ever touch the same file, not the same block. Whichever lands second appends.
