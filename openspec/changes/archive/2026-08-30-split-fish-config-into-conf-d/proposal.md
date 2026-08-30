## Why

`~/.config/fish/config.fish` is the last shell startup file in this configuration with no rule about what belongs in it, and it has already gone wrong: every abbreviation, both custom functions, and the `e` alias are nested *inside* the body of `fish_user_key_bindings`. They exist today only because fish happens to call that function once per interactive session — change the key bindings and the shorthands go with them. The environment half of fish's configuration already lives in `conf.d/env.fish`, where fish sources it by name and topic; the interactive half does not.

## What Changes

- Split the contents of `config.fish` into topic-scoped files under `conf.d/`, sourced by fish in its own right rather than through a single unstructured file: key bindings in one, command shorthands in another.
- Move `mkcd` and `cl` to `functions/`, fish's autoload directory, so each is defined by being named rather than by having been declared during startup.
- Un-nest everything that is currently inside `fish_user_key_bindings`. That function keeps only the `bind` calls it exists for.
- Delete `config.fish`. fish requires no such file, and with nothing left in it that a `conf.d/` snippet does not hold, keeping an empty one would only invite the next unclassified setting.
- Track `functions/` in the dotfiles repository and drop the now-dangling `config.fish` allowlist line.
- No change to what the shell does: the same bindings, the same shorthands, the same functions, all still interactive-only.

## Capabilities

### New Capabilities

- `fish-startup-files`: where each kind of fish configuration lives — environment, key bindings, shorthands, functions — the guarantee that a snippet may not depend on another snippet having run first, and the rule that interactive-only configuration states its own guard rather than inheriting one from where it happens to sit.

### Modified Capabilities

None. `shell-aliases` already requires that a shorthand be interactive-only and that it not shadow an existing command, and both hold before and after; `shell-environment` governs `conf.d/env.fish`, which this change does not touch. The layout this introduces is not stated in any existing capability, which is why it is a new one rather than an edit to those.

## Impact

- `.config/fish/config.fish` — deleted.
- `.config/fish/conf.d/` — gains one file for key bindings and one for command shorthands, alongside the existing `env.fish`.
- `.config/fish/functions/` — created, holding `mkcd` and `cl`.
- `.gitignore` — the `!/.config/fish/config.fish` allowlist line goes; `functions/` is allowlisted so the two function files are tracked. `conf.d/**` is already allowlisted, so the new snippets need no entry.
- No new dependency, and nothing outside `~/.config/fish` reads these files. `~/.bashrc` keeps its own copy of the environment, as `conf.d/env.fish` already records.
