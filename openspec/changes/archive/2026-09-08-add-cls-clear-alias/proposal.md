## Why

`shell-aliases` says an interactive shell answers to `cls`, and bash does. Fish does not. The requirement was written when this configuration was bash only, and the fish configuration that arrived afterwards never picked the shorthand up, so the name that was bound precisely because the reflex is not going to be retrained fails in the shell that is actually the login shell.

## What Changes

- Bind `cls` to `clear` in the fish configuration, alongside the shorthands already defined there.
- Say in `shell-aliases` that a shorthand this configuration defines is defined in every interactive shell it configures, not in whichever one happened to exist when the requirement was written, so the next shorthand cannot drift into one shell only.

## Capabilities

### New Capabilities

<!-- None. shell-aliases already covers the shorthand names this configuration defines. -->

### Modified Capabilities

- `shell-aliases`: the rule that a shorthand is an interactive convenience gains the second half it was missing — which shells it must be a convenience in. `cls` is stated to hold in bash and in fish rather than in an unnamed "interactive shell".

## Impact

- `~/.config/fish/conf.d/aliases.fish` — one `alias` definition added to the existing interactive-only block.
- `~/.bashrc` — unchanged; it already carries `alias cls='clear'`.
- No effect on non-interactive shells or scripts: both files define their shorthands under an interactive guard.
- No new dependency: `clear` ships with ncurses and is already required.
