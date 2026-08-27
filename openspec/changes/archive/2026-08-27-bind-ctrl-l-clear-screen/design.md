## Context

See proposal.md — Why. The mechanics that shape the approach:

- Vi editing mode gives readline two keymaps, `vi-insert` and `vi-command`, and a binding applies to whichever one is selected when the line is read. `set keymap <name>` selects it for the bindings that follow, and stays selected for the rest of the file.
- Measured against the system defaults alone — `/etc/inputrc` included, `set editing-mode vi`, nothing else — `bind -q clear-screen` reports `\C-l` under `vi-command` and "not bound to any keys" under `vi-insert`.
- `$include /etc/inputrc` is the first line of the user file, so anything the user file binds afterwards wins over the system one.
- `bash-readline-config` already requires that vi mode be established by the readline file and by no `bind` call in a shell startup file.

## Goals / Non-Goals

**Goals:**

- One keystroke with one meaning, whichever vi mode the line happens to be in.
- The behaviour written down rather than inherited, so it does not depend on a default that a distribution's `/etc/inputrc` could change.

**Non-Goals:**

- Changing what `Ctrl-L` does inside a full-screen program. Readline owns the prompt only.
- Reworking the file's structure or the mode indicator that follows these lines.
- Binding anything else. This is one key.

## Decisions

**Bind both keymaps, not only the one that was broken.** The insert keymap is where the gap was; the command keymap already agreed by default. Stating both makes the guarantee independent of a default that lives in a file this repository does not own — `/etc/inputrc` differs between distributions, and this configuration is carried to more than one. The cost is one redundant line today.

**Keep it in `~/.inputrc`.** The alternative is `bind -m vi-insert '"\C-l": clear-screen'` in `.bashrc`. Rejected: the capability already requires that readline behaviour be configured in the readline file, and a `bind` call would run per interactive shell to re-establish something the init file sets once, for readline in every program that links it rather than for bash alone.

**Place the bindings with the editing mode, above the mode-indicator settings.** They belong to the same subject — how the vi command line behaves — and the indicator settings below are `set` directives, which are global and unaffected by the keymap selection left in force above them.

## Risks / Trade-offs

- **The file ends with `vi-insert` selected** → a binding appended later lands in that keymap silently, which is a plausible surprise rather than a hypothetical one. Any future binding should name its keymap first; this is the reason to look at the last `set keymap` line before adding one.
- **A redundant declaration in the command keymap** → one line restating a default. Deliberate, per the decision above.
- **`Ctrl-L` is consumed by readline at the prompt** → it cannot be sent to a program that way, but no program is running at that moment. Inside one, the key never reaches readline at all.
- **Rollback** → delete the four lines; insert mode returns to having no binding and command mode falls back to the system default.
