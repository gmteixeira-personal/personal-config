## Why

Clearing the screen is a constant, and `clear` is the only name this shell answers to. Anyone arriving from a Windows shell reaches for `cls` first, gets `command not found`, and has to retype. The habit is older than this machine and is not going to be retrained, so the shell should answer to the name that is actually typed.

## What Changes

- Add a `cls` alias in the tracked interactive shell configuration that runs `clear`.
- Establish `shell-aliases` as the capability covering the shorthand names this configuration defines for interactive use, so later aliases have somewhere to land.

## Capabilities

### New Capabilities

- `shell-aliases`: the command shorthands an interactive shell defines — which names are bound, what they resolve to, and the rules a new alias follows (interactive shells only, no shadowing of a real command, no effect on scripts).

### Modified Capabilities

<!-- None. PATH assembly, color advertisement, and readline bindings are untouched. -->

## Impact

- `~/.bashrc` — one alias definition added, in the tracked dotfiles repository.
- No effect on non-interactive shells, scripts, or `PATH`.
- No new dependency: `clear` is already required by the existing configuration.
