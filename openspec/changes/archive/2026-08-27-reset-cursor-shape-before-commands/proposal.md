## Why

Every command launched from the prompt inherits a blinking beam cursor, which is wrong for anything that is not a readline insert mode.

The existing mode indicator is the cause. `~/.inputrc` reports the readline mode through the cursor, and readline repaints that cursor on a mode switch and at no other time — never on hand-off to the command being run. A prompt always begins in insert mode, so the beam is what is showing when Enter is pressed, and the command starts with it. A full-screen program that sets its own cursor overwrites it immediately and nothing is noticed; one that does not runs with the beam for its whole session. `claude` is such a program — its binary contains no cursor-shape sequence at all, so it has nothing to override what it was handed.

The indicator itself is worth keeping. What is missing is a reset at the moment the shell stops owning the cursor.

## What Changes

- Set `PS0` in `.bashrc` to a cursor-shape reset, so the terminal's own shape is restored after the command line is read and before the command runs.
- Reset to the terminal's configured shape rather than naming one, matching how the existing normal-mode indicator already defers to the terminal profile.
- Leave `~/.inputrc` untouched: both mode strings, and the indicator they drive, keep working exactly as before.

## Capabilities

### Modified Capabilities

- `bash-readline-config`: adds a requirement that the cursor is handed back to the terminal before a command runs, which the existing mode-indicator requirement does not cover.

### New Capabilities

<!-- None. -->

## Impact

- `.bashrc` gains one `PS0` assignment. `PS1` and the prompt are unchanged.
- Applies to every command run from an interactive bash prompt, not to any one program.
- Requires bash 4.4+ for `PS0`; this machine runs 5.3.9, the same floor `show-mode-in-prompt` already imposes.
- The mode indicator is unaffected: the beam returns with the next prompt.
