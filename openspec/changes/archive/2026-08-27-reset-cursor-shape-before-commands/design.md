## Context

See proposal.md — Why. The mechanics that shape the approach:

- `PS0` is expanded and printed after bash has read a command line and before it executes it. That is precisely the hand-off point, and it is the only shell hook that sits there.
- `PS0` is skipped when the line is empty, so a bare Enter costs nothing.
- DECSCUSR `\e[0 q` resets the cursor to the shape the terminal profile specifies. `\e[2 q` would force a filled block instead.
- The Tailwind-style diagnosis was ruled out first: the `claude` binary was searched for cursor-shape sequences and contains none, and `bind -V` confirmed `vi-ins-mode-string` as `\e[5 q`. The beam is emitted by readline, not by the program that displays it.

## Goals / Non-Goals

**Goals:**

- One fix that covers every program, not the one program in which the symptom was noticed.
- The vi mode indicator preserved exactly as configured.

**Non-Goals:**

- Changing the mode strings in `~/.inputrc`. Making insert mode stop showing a beam would remove the indicator rather than fix the hand-off.
- A per-program wrapper or alias.
- Restoring the cursor after a command exits. The next prompt's insert-mode string already does that.

## Decisions

**Use `PS0`, not an alias.** An alias such as `alias claude='printf "\e[0 q"; command claude'` fixes the program it names and leaves the defect intact for every other one — a pager, a REPL, any TUI that does not set its own cursor. The defect is in the hand-off, which is shared, so the fix belongs there. Alternative considered: a `DEBUG` trap. Rejected — a trap fires per command including inside pipelines and functions, where `PS0` fires once per command line, and a `DEBUG` trap is a global resource other tooling may want.

**Reset with `\e[0 q` rather than naming a shape.** The existing `vi-cmd-mode-string` already uses `\e[0 q` for the same reason: it defers to the terminal profile — configured here with `"cursorShape": "emptyBox"` — instead of hard-coding a block that would override it. Using the same sequence keeps one answer to "what shape does this environment consider default". Alternative considered: `\e[2 q` for a steady block. Rejected — it overrides the profile, and the profile is where that choice already lives.

**Leave `~/.inputrc` alone.** The beam in insert mode is deliberate and is the working half of the indicator. The problem is that readline never un-sets it, not that it sets it.

**No non-printing markers.** `\[` and `\]` exist so readline can compute a prompt's visible width for redrawing. `PS0` is printed once and never redrawn, so it has no width to compute and needs no markers.

## Risks / Trade-offs

- **A terminal that ignores DECSCUSR** → the sequence is inert, exactly as the existing mode indicator already is on such a terminal. Nothing else changes.
- **A program that sets its own cursor and restores it badly on exit** → unchanged by this. The next prompt's insert-mode string re-asserts the beam, so any drift lasts at most one prompt.
- **One extra escape sequence written per command** → a handful of bytes to a terminal that is about to be written to anyway.
- **Rollback** → delete the `PS0` line; the previous behaviour returns in the next shell.
