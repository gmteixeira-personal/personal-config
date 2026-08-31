## Why

fzf is installed on this machine, but its shell integration only exists as a command typed by hand (`fzf --fish`), so it dies with the session and does not exist at all on another machine or in bash. fzf is useless without that integration: its key bindings, widgets, and fuzzy completion are entirely produced by the init output.

## What Changes

- fish gains fzf integration: the widget functions and completion from `fzf --fish`, in a `conf.d` snippet of its own.
- bash gains the same from `fzf --bash`, placed so that a bash about to hand the session to fish never pays for it.
- The integration is optional at run time: a machine without fzf starts a shell with no error and simply lacks the pickers.
- No new key is bound over one this configuration already uses; fzf's Ctrl+T, Ctrl+R, and Alt+C do not collide with the existing Ctrl+F, Ctrl+B, and Ctrl+J bindings.

## Capabilities

### New Capabilities

- `fuzzy-finder`: what an interactive shell in this configuration gets from fzf — the file, history, and directory widgets on their keys, fuzzy completion, and the requirement that these are present in both shells and absent without error where fzf is not installed.

### Modified Capabilities

<!-- None. The bindings fzf installs are governed by the existing fish-key-bindings
     requirements on bindings being in effect at the prompt and surviving a mode
     reinstall; no requirement of an existing spec changes. -->

## Impact

- New tracked file: `~/.config/fish/conf.d/fzf.fish`.
- Modified: `~/.bashrc` (one guarded init block, below the `exec fish` line).
- New machine-level optional dependency: `fzf` 0.74 or newer, for the `--fish` and `--bash` flags.
- Incidentally corrects a comment in `~/.config/fish/conf.d/key-bindings.fish` about when fish re-runs `fish_user_key_bindings`, which measurement during this change showed to be wrong.
