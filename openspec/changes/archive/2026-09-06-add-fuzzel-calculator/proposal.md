## Why

The session has no way to do arithmetic. There is no calculator application, no `qalc` and no `bc`; the answer to "what is 1440 × 0.65" is a foot window, `python3`, a prompt, and a window left open afterwards. The launcher is already the session's answer to reaching something without a window for it — the Bluetooth and Wi-Fi menus exist because a terminal was the wrong shape for a two-second task, and a sum is the same shape of task with a shorter answer.

The obstacle is that the launcher cannot do it. fuzzel has no calculator mode and no plugin interface through which one could be added: a filter that evaluates as it is typed is not among the things `fuzzel.ini` can turn on. What fuzzel does have is dmenu mode's custom entry — text matching no input line is returned on stdout as typed, which is the behaviour `fuzzel-wifi` passes `--only-match` to switch off. That is enough to build a calculator out of, at the cost of one Enter per result rather than a running total under the cursor.

## What Changes

- A new script, `.config/fuzzel/fuzzel-calc`, opens a fuzzel window whose prompt is `= `. An expression typed into it is evaluated and the result comes back as the window's single entry, with the input box pre-filled with the same value so the next expression can continue from it.
- Enter on the untouched result copies it to the clipboard and closes the window. Escape, or Enter on an empty box, closes it without copying. Anything else is the next expression.
- Evaluation is `python3` — the only interpreter this session is guaranteed to have — parsing to an AST and walking it against an allowlist of nodes, rather than `eval`. The input box is reachable by anyone at the keyboard and the launcher is a graphical session's most-opened surface; the difference between the two is whether typing `__import__("os").system(…)` into it runs.
- The calculator is reached the way the radio menus are: a desktop entry the launcher already reads, an icon it names, and a symbolic link putting the script on `PATH`. No key is bound to it.
- `.gitignore` gains four allowlist entries — one in block 3 for the script, three in block 5 for the entry, the icon and the link — under the rules those blocks already state. Three of its comments describing two scripts now describe three.

## Capabilities

### New Capabilities

- `expression-calculator`: What the session must be able to compute and how the answer is delivered — that arithmetic is reachable from the launcher without a terminal, that a result can be carried away rather than only read, that a typed expression cannot execute anything, and that a wrong expression is answered rather than swallowed.

### Modified Capabilities

<!-- None. `dotfiles-ignore-policy` already states when a block 5 carve-out is
     allowed and this change makes one under that rule; `application-launcher`
     governs how the launcher is drawn and what it does with a terminal entry,
     neither of which changes. -->

## Impact

- `.config/fuzzel/fuzzel-calc` — new, 182 lines, the script and the evaluator it embeds.
- `.local/share/applications/calculator.desktop`, `.local/share/icons/hicolor/scalable/apps/fuzzel-calc.svg`, `.local/bin/fuzzel-calc` — new, the same three-file pattern the Bluetooth and Wi-Fi menus use, with a relative link target and a bare `Exec` name for the same portability reason.
- `.gitignore` — four allowlist entries and three amended comments. No pattern line, and nothing in block 4.
- Dependencies: none added. `python3`, `wl-copy` and `notify-send` are already present and already relied on — the last two by the radio menus.
- Behaviour elsewhere: none. No key binding is taken, no bar module is touched, and the launcher gains one entry among the entries it already lists.
