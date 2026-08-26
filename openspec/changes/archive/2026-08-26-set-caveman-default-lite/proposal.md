## Why

The caveman plugin starts every session at its shipped default intensity, `full`, which drops articles and answers in fragments. Switching to `lite` with `/caveman lite` only lasts until the session ends, so the switch has to be repeated every time. The preference belongs in configuration, not in a per-session command.

## What Changes

- Set the caveman default intensity to `lite` in the user-level caveman configuration at `~/.config/caveman/config.json`.
- Track that file in the home repository so the preference travels to every environment, rather than being re-set by hand on each machine.
- Allowlist `/.config/caveman/config.json` in the root ignore file, beside the existing `.config/lazygit` and `.config/gh` entries.

## Capabilities

### New Capabilities

- `caveman-mode-default`: where the caveman session intensity default lives, which level it is set to, and how a mid-session override relates to it.

### Modified Capabilities

<!-- None. Tracking one more configuration file exercises the existing ignore-policy requirements rather than changing them. -->

## Impact

- New file `~/.config/caveman/config.json`, read by the plugin's SessionStart hook through its own configuration resolver.
- `.gitignore` gains one allowlist entry.
- Affects the assistant's response style at the start of every new Claude Code session in this environment.
- No change to the plugin itself: its cache under `.claude/plugins/` stays derived, untracked, and untouched.
