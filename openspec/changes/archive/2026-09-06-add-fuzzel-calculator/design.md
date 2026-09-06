## Context

See `proposal.md` — Why. The constraints that shape the approach, all measured on this machine:

- fuzzel 1.14.0. Its options list has no calculator mode and no plugin mechanism. Nothing in `fuzzel.ini` evaluates.
- fuzzel's dmenu mode returns the typed text on stdout when it matches no input line, and the entry's text when one is picked. `fuzzel-wifi` passes `--only-match` precisely to suppress the first behaviour. There is no flag that reports which of the two happened.
- `--search TEXT` pre-fills the input box; `--lines N` sets how many entries are shown; `--dmenu` with a closed empty stdin shows no entries and still accepts typed text.
- No `qalc`, no `bc`, no `galculator`. `python3` is present because the system depends on it, and `wl-copy` and `notify-send` are present and already used by the radio menus.
- `.local/bin` is on `PATH` — `shell-environment` requires it — and the launcher inherits that `PATH` from the session.
- The Bluetooth and Wi-Fi menus have already established the shape a launcher-driven tool takes here: a script under `.config/fuzzel/`, a desktop entry, an icon, a relative link in `.local/bin`.

## Goals / Non-Goals

**Goals:**

- One expression, one keystroke, one answer, without leaving the launcher.
- The answer is carried away rather than transcribed.
- The input box is not an execution surface.
- The tool is one file plus the three files that make it reachable, in the pattern already in use.

**Non-Goals:**

- Live evaluation under the cursor. fuzzel cannot do it, and the alternatives — a second launcher, or a patched fuzzel — cost more than the keystroke they save.
- Units, currency, number bases, variables, history. These are what `qalc` is for; if they are ever wanted, the interface here does not have to change to get them, only the evaluator behind it.
- A key binding. The launcher is one keystroke away already.

## Decisions

### The window is a loop of round trips, not a live filter

Each Enter closes one fuzzel window and opens the next. The loop keeps three pieces of state — the last expression, the last result, the last error message — and each iteration renders one of them as the window's single entry.

The alternative is rofi with `rofi-calc`, which does evaluate as it types. It would mean a second launcher installed alongside fuzzel, themed separately, sharing none of this session's launcher configuration, for a feature whose whole benefit is seeing the result one keystroke earlier. Patching fuzzel was not considered seriously: the session tracks configuration, not forks.

### Distinguishing "picked the result" from "typed something new" is done by comparing the text

dmenu mode reports no flag for this, so the loop compares the returned string to the entry it offered. Equal means the result was picked, which is the copy gesture; anything else is the next expression.

This is why the entry is the bare result — `8` — rather than `2*(2+2) = 8`. Both fuzzel's fuzzy matcher and this comparison get less reliable as the entry gets longer: an entry carrying the previous expression shares its operator characters with whatever is typed next, so a typed expression can fuzzy-match it and be read as a pick. With a bare number the only text that matches is a subsequence of that number's digits, and the worst case — typing the result's own digits and getting it copied — is the same value the user asked for.

The expression is therefore not shown back. What replaces it is the pre-fill: `--search` puts the result in the input box, so the window shows `= 8` with `8` selected and continuing means typing `*3`.

### The evaluator is an AST walk, not `eval`

`python3 -c` on the typed string is a shell. The narrower form — `eval(text, {"__builtins__": {}}, names)` — is not narrow: a literal reaches its own type, a type reaches its bases, and object's subclasses reach the interpreter. That escape is a well-known one-liner, so a stripped namespace buys nothing here.

`ast.parse(text, mode="eval")` followed by a recursive walk over an allowlist of node types is the same amount of code and admits exactly what it names: numeric literals, the arithmetic operators, unary sign, `pi`/`e`/`tau`, and calls to named functions from `math` plus `abs`, `round`, `min`, `max` and `sum`. Attribute access, subscripts, comprehensions, lambdas, starred arguments and keyword arguments are not in the allowlist, so they are refused at the node, before any value exists. It also produces better messages: an unknown name is "unsupported expression" rather than a `NameError` traceback.

Integer exponentiation is capped at 4096. `9**9**9` is not a slow answer but a process that consumes the machine, and the window has no cancel — a modal surface with no progress indicator and nothing to press.

### Results are rendered, not printed

An integer prints as itself. A float that is exactly integral prints without its `.0`. Everything else prints with ten significant digits, which is past a double's honest precision and stops `0.1+0.2` from answering `0.30000000000000004` — a correct answer to a question nobody asked a launcher.

### `^` means exponentiation

It is exclusive-or in Python and a power key on every calculator ever printed. A launcher input box is the second thing. A trailing `=` is stripped for the same reason: it is what a hand types out of habit.

## Risks / Trade-offs

- **One keystroke more than a live calculator.** → Accepted. It is the cost of the launcher already in the session, and the pre-fill means the second and later expressions are shorter than they would otherwise be.
- **A typed expression consisting only of digits from the current result copies it instead of computing it.** → Bounded by the bare-result entry: the value copied is the value typed. Nothing else can collide.
- **The clipboard is served by `wl-copy`'s background process, so a copied result dies with it.** → Standard for every Wayland clipboard writer in this session; the radio menus already depend on the same behaviour for nothing, and a paste immediately after a copy is the actual usage.
- **The allowlist will be short of some function someone wants.** → Adding a name to the tuple in the script is the whole change; the refusal message says the expression is unsupported rather than pretending the function does not exist.
