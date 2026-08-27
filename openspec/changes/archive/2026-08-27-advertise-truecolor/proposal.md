## Why

The terminal this configuration runs in renders 24-bit color, and nothing tells the programs inside it so.

`COLORTERM` is the signal they read — `delta`, `bat`, `fzf`, `supports-color` behind every Node CLI built on chalk, `rich` in Python — and it was unset, so each fell back to approximating its theme in the 256-color palette. terminfo cannot supply the answer here either: `TERM` is `xterm-256color`, whose `colors#` capability is 256.

Neovim was never affected and is not the reason for this change: it sets `termguicolors` outright, which is why the editor has looked correct while everything around it has not.

The obvious alternative — pointing `TERM` at an entry that declares direct color, such as `xterm-direct` — is the wrong trade. `TERM` travels over `ssh`, and a remote host without that terminfo entry gets a broken session in exchange for a local improvement.

## What Changes

- Export `COLORTERM=truecolor` from `.bashrc` for interactive shells.
- Name it only where the terminal is known to support 24-bit color, and never over a value something else already set.
- Leave `TERM` alone.

## Capabilities

### Modified Capabilities

- `shell-environment`: adds a requirement covering what the shell tells programs about the terminal's color depth, which the existing `PATH` and tool-root requirements do not cover.

### New Capabilities

<!-- None. -->

## Impact

- `.bashrc` gains one guarded export, placed with the rest of the color configuration.
- Every program that gates truecolor on `COLORTERM` gets its true palette; nothing that ignores the variable changes at all.
- Non-interactive shells are unaffected, so a captured build log gains no escape sequences it did not have before.
- The guard is a list of terminals, and a capable terminal not on it simply gets no advertisement — the same state as before this change.
