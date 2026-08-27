## Context

See proposal.md — Why. The mechanics that shape the approach:

- `COLORTERM` is a convention rather than a standard. Nothing writes it for the shell; each terminal emulator either exports it or does not, and Windows Terminal does not.
- terminfo is the standardised channel and cannot help. `TERM` is `xterm-256color` with `colors#0x100`; the entries that declare direct color (`xterm-direct`, `colors#0x1000000`) exist locally but not necessarily on any host reached over `ssh`, which reads the `TERM` the client sends.
- `WT_SESSION` is set by Windows Terminal and reaches WSL because it is listed in `WSLENV`. It is the marker available here, and it is per-session rather than per-machine, so it is absent in a bare console.
- The terminal's actual capability can be probed at runtime, by writing a 24-bit color and reading back what the terminal reports. That is a synchronous round trip with a timeout, at every shell start.

## Goals / Non-Goals

**Goals:**

- Programs that ask about color depth get a true answer on this terminal.
- Silence rather than a wrong answer anywhere else, since this file is tracked and reaches every machine.

**Non-Goals:**

- Changing `TERM`, or shipping a custom terminfo entry.
- Making Neovim look different. It already sets `termguicolors`, which is why the editor was never part of the problem.
- Detecting the terminal's capability by probing it.
- Configuring the palette itself. Which sixteen colors the terminal draws is the terminal's own configuration, not the shell's.

## Decisions

**Advertise, do not probe.** A capability query means writing an escape sequence and waiting for a reply, with a timeout for terminals that never answer — cost paid at every interactive shell start, to learn something an environment variable already implies. Alternative considered: probing once and caching the answer. Rejected — a cache keyed on what, invalidated when, and stale after the terminal is reconfigured.

**Guard on known terminals rather than exporting unconditionally.** This file is tracked and reaches every environment, including a bare Linux console and an `ssh` session from a client that cannot render 24-bit color. Claiming truecolor there is worse than saying nothing: the program believes the claim and emits sequences the terminal draws as literal characters. Alternative considered: exporting it always and letting each program cope. Rejected — the variable exists precisely so programs do not have to guess, so a false value defeats it.

**A list of markers, accepting false negatives.** `WT_SESSION`, `WEZTERM_EXECUTABLE`, `KITTY_WINDOW_ID` and two `TERM_PROGRAM` values cover the terminals this configuration is likely to meet. A capable terminal not on the list gets no advertisement — the state that existed before this change, so nothing regresses. The failure mode is one-sided by construction.

**Never overwrite an existing value.** A terminal that sets `COLORTERM` itself, or a user who set it deliberately, knows more than a name-based guess. The test is for an empty value, not for the variable being undefined, so an explicit empty string is also left alone.

**Place it after the non-interactive early return.** The `PATH` and `EDITOR` blocks sit above that return because scripts need them. Color depth is for a terminal a human is looking at; a build log captured by a tool runner is better without escape sequences in it. Most programs also test whether their output is a terminal, so this mostly duplicates their own check — cheaply, and in the right direction.

## Risks / Trade-offs

- **The marker list ages** → a terminal released later is unrecognised until a line is added. Consequence is the pre-change state, not a regression.
- **`ssh` into this machine from a capable terminal gets nothing** → `WT_SESSION` is not forwarded over `ssh`, so an inbound session sees no marker. Correct by the rule above: the shell cannot see that client and should not guess for it.
- **A terminal that sets `WT_SESSION` while not rendering truecolor** → would produce a false claim. Windows Terminal has rendered 24-bit color since 2019, and nothing else sets that variable.
- **Rollback** → delete the block; the next shell is back to an unset `COLORTERM`.
