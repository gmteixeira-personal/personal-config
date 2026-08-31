## Context

See proposal.md — Why. One property of `bat` is what makes this safe enough to do at all: it detects that its output is not a terminal and, in that case, prints the file plain — no highlighting, no line numbers, no paging. So `cat file | grep x` typed at the prompt behaves as it always did, even though `cat` is now `bat`.

## Goals / Non-Goals

**Goals:**

- The reflex — typing `cat` — gets the better reader.
- Nothing breaks on a machine without `bat`, and nothing is said about it.

**Non-Goals:**

- Configuring `bat` itself. Its defaults are the point; a theme or a config file is a separate decision.
- Touching `less`, `$PAGER`, or anything else that reads files.

## Decisions

**Alias rather than a function or an abbreviation.** fish's `abbr` expands at the prompt, which would rewrite the typed `cat` into `bat` in history and on screen — wrong here, because the name is meant to stay `cat`. That is exactly the split the aliases file's own header describes, and this case falls on the `alias` side.

**Keep `bat`'s default paging.** `bat` pages through `less` only when output is a terminal and does not fit on one screen — precisely the case where plain `cat` is least useful, because the text scrolls away. Forcing `--paging=never` would preserve the old reflex of scrolling back in the terminal's own buffer, at the cost of the behaviour that makes long files readable. The pager is the better default; `q` leaves it, and `command cat` is there for anyone who wants the raw dump.

**Guard with the same shape as `direnv` and `fzf`.** `type -q bat` in fish, `command -v bat` in bash. Absence is silent by construction: the alias is simply never defined, so `cat` resolves to the executable it always did.

## Risks / Trade-offs

- **A pipeline `cat`ing a huge file now runs `bat`, which is a heavier binary.** → It still streams, and the decorations are off when piped. The cost is process startup, on a command a person typed by hand.
- **Muscle memory that expects `cat` to leave text in the scrollback now sometimes lands in a pager.** → Only above one screenful, and `q` returns. This is the trade the proposal is making deliberately.
- **A future machine may ship the binary as `batcat`.** → Then the guard fails and `cat` stays `cat`, silently, which is the correct fallback. Naming that spelling too is a change to make when a machine needs it, not before.
