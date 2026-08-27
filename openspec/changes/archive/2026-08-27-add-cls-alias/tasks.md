## 1. Confirm the name is free

- [x] 1.1 Verify `cls` resolves to nothing on this machine — `type cls` in a fresh interactive shell reports "not found", and `command -v cls` prints nothing and exits non-zero. If either resolves, stop and report the conflict rather than shadowing it (design.md — Risks).

## 2. Add the alias

- [x] 2.1 Add `alias cls='clear'` to `~/.bashrc`, immediately after the `alias l='ls -CF'` line that closes the stock ls-shorthand group, and verify `grep -n "alias cls=" ~/.bashrc` prints exactly one line sitting directly below `alias l=`.

## 3. Verify the behavior the spec requires

- [x] 3.1 Verify the shorthand works at the prompt — in a fresh interactive shell (`bash -i`), `type cls` reports it as an alias for `clear`, and entering `cls` clears the terminal.
- [x] 3.2 Verify `clear` is unchanged — `type clear` still reports the executable, and running it clears the terminal as before.
- [x] 3.3 Verify it is absent from scripts — `bash -c cls` fails with "command not found" and a non-zero status, confirming the alias is interactive-only.
- [x] 3.4 Verify re-sourcing is harmless — `source ~/.bashrc` twice in one shell leaves `cls` resolving to `clear` with no error.
