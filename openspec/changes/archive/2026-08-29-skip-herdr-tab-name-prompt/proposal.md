## Why

Creating a tab in herdr opens a name prompt first, so the quickest action in the workspace — open a tab and start working — is gated behind a text field and an Enter press. The name is rarely worth deciding up front, and herdr already offers a rename, so the prompt asks for a decision that can be made later or not at all.

## What Changes

- Tab creation SHALL no longer open a name prompt. The prefixed `new_tab` key creates the tab and focuses it directly, and herdr names it itself.
- Renaming a tab afterwards SHALL keep working, so a name is still reachable for whoever wants one.
- Workspace creation is untouched: `prompt_new_workspace_name` keeps its current behavior, because a workspace is a longer-lived object created far less often, and the prompt costs little there.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `herdr-config`: adds a requirement that the tracked configuration disables the new-tab name prompt, and that tab creation is a single keystroke.

## Impact

- `.config/herdr/config.toml` — a new `prompt_new_tab_name` entry in the `[ui]` section.
- No other file changes. The setting is read by herdr itself and applies on a configuration reload.
