## Why

The bash command line uses the default emacs key bindings, so editing a long command means reaching for arrow keys and control chords instead of the vi motions used everywhere else in this environment. Vi mode is a one-line readline setting, but without a visible mode indicator it is unusable: there is no way to tell insert mode from normal mode, and the wrong keystroke silently does the wrong thing.

## What Changes

- Add a tracked `~/.inputrc` that turns on readline vi editing mode for every interactive bash session.
- Make the terminal cursor report the current mode: a steady block in normal mode, a blinking beam in insert mode.
- Keep the system-wide readline defaults by including `/etc/inputrc` from the user file, which readline would otherwise replace entirely.
- Allowlist `/.inputrc` in the root ignore file so it is trackable alongside the other shell configuration.

## Capabilities

### New Capabilities

- `bash-readline-config`: the readline configuration for interactive bash — the editing mode, the mode indicator, and how the user file relates to the system-wide one.

### Modified Capabilities

<!-- None. The ignore policy already covers explicit root allowlist entries; adding one exercises an existing requirement rather than changing one. -->

## Impact

- New file `~/.inputrc`, read automatically by readline at interactive bash startup. No `.bashrc` change and no `bind -f` call are needed.
- `.gitignore` gains one allowlist entry next to the existing `!/.bashrc`, `!/.profile`, `!/.bash_logout` lines.
- Affects every interactive bash session in this environment, including the cursor shape shown by the terminal emulator.
- Requires bash 4.4+ for `show-mode-in-prompt`; this machine runs 5.3.9.
